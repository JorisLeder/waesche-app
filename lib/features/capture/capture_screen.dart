import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/utils/image_prep.dart';

/// Kamera mit quadratischem Zielrahmen. Liefert das auf den Rahmen
/// zugeschnittene JPEG (max. 1024 px) zurück, oder null bei Abbruch.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.title = 'Foto aufnehmen', this.hint});

  final String title;
  final String? hint;

  static Future<Uint8List?> open(BuildContext context, {String title = 'Foto aufnehmen', String? hint}) =>
      Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(builder: (_) => CaptureScreen(title: title, hint: hint)),
      );

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() => _error = 'Keine Kamera gefunden. Foto aus der Galerie wählen.');
        return;
      }
      final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
      final c = CameraController(
        back,
        ResolutionPreset.veryHigh, // 1080p: genug Details für Rippung, Nähte, Etiketten
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await c.initialize();
      await c.setFlashMode(FlashMode.off);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } on CameraException catch (e) {
      setState(() => _error = 'Kamera nicht verfügbar (${e.code}). Bitte die Kamera-Berechtigung erlauben.');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      // Erst aus dem Baum nehmen, dann freigeben (sonst baut CameraPreview
      // noch mit einem freigegebenen Controller).
      setState(() => _controller = null);
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      final cropped = await ImagePrep.cropToFrame(bytes);
      if (mounted) Navigator.of(context).pop(cropped);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aufnahme fehlgeschlagen: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final f = await FilePicker.pickFile(type: FileType.image);
    if (f == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await f.xFile.readAsBytes();
      final cropped = await ImagePrep.cropToFrame(bytes);
      if (mounted) Navigator.of(context).pop(cropped);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bild nicht lesbar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Aus Galerie',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _busy ? null : _pickFromGallery,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      )
                    : c == null || !c.value.isInitialized
                    ? const CircularProgressIndicator()
                    : AspectRatio(
                        // Im Hochformat ist das Sensor-Seitenverhältnis umgekehrt.
                        aspectRatio: 1 / c.value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(c),
                            const _FrameOverlay(),
                          ],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(
                widget.hint ?? 'Teil flach auf einen ruhigen, hellen Untergrund legen und den Rahmen ausfüllen.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: SizedBox(
                width: 76,
                height: 76,
                child: FilledButton(
                  style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                  onPressed: c == null || _busy ? null : _capture,
                  child: _busy
                      ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3))
                      : const Icon(Icons.camera_alt, size: 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Abgedunkelter Bereich um den quadratischen Zielrahmen. Die Größe passt zu
/// [ImagePrep.frameFraction], damit Sucher und Zuschnitt übereinstimmen.
class _FrameOverlay extends StatelessWidget {
  const _FrameOverlay();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final side = (box.maxWidth < box.maxHeight ? box.maxWidth : box.maxHeight) * ImagePrep.frameFraction;
      return CustomPaint(painter: _FramePainter(side));
    },
  );
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.side);

  final double side;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side);
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.side != side;
}
