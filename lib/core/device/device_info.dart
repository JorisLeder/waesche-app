import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_edge_ai_diagnostics/flutter_edge_ai_diagnostics.dart';

/// Gerätedaten für Speicherwächter und Machbarkeits-Test.
class DeviceSnapshot {
  const DeviceSnapshot({
    this.model,
    this.soc,
    this.sdkInt,
    this.totalRamBytes,
    this.availRamBytes,
    this.freeDiskBytes,
    this.appAnonymousBytes,
    this.appFileBackedBytes,
    this.appPeakBytes,
  });

  final String? model;
  final String? soc;
  final int? sdkInt;
  final int? totalRamBytes;

  /// Freier Arbeitsspeicher des Geräts (Android: MemAvailable, optimistisch).
  final int? availRamBytes;
  final int? freeDiskBytes;

  /// Speicher der App laut OS (siehe flutter_edge_ai_diagnostics).
  final int? appAnonymousBytes;
  final int? appFileBackedBytes;
  final int? appPeakBytes;

  static String gb(int? bytes) => bytes == null ? '–' : '${(bytes / (1 << 30)).toStringAsFixed(2)} GB';

  String describe() => [
    'Gerät: ${model ?? '–'} (${soc ?? '–'}, API ${sdkInt ?? '–'})',
    'RAM gesamt: ${gb(totalRamBytes)}, frei: ${gb(availRamBytes)}',
    'App-Speicher: ${gb(appAnonymousBytes)} anonym, ${gb(appFileBackedBytes)} dateibasiert'
        '${appPeakBytes != null ? ', Spitze ${gb(appPeakBytes)}' : ''}',
    'Freier Speicherplatz: ${gb(freeDiskBytes)}',
  ].join('\n');
}

class DeviceInfo {
  DeviceInfo._();

  static const _channel = MethodChannel('waeschewer/device');

  static Future<DeviceSnapshot> snapshot() async {
    Map<Object?, Object?>? info;
    if (Platform.isAndroid) {
      try {
        info = await _channel.invokeMapMethod<Object?, Object?>('deviceInfo');
      } on PlatformException {
        info = null;
      } on MissingPluginException {
        info = null;
      }
    }
    MemorySnapshot? mem;
    if (FlutterEdgeAiDiagnostics.isSupported) {
      try {
        mem = await FlutterEdgeAiDiagnostics.memorySnapshot();
      } on MemoryReadException {
        mem = null;
      }
    }
    int? asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);
    return DeviceSnapshot(
      model: info?['model'] as String?,
      soc: info?['soc'] as String?,
      sdkInt: asInt(info?['sdkInt']),
      totalRamBytes: asInt(info?['totalRamBytes']),
      availRamBytes: asInt(info?['availRamBytes']) ?? mem?.availableBytes,
      freeDiskBytes: asInt(info?['freeDiskBytes']),
      appAnonymousBytes: mem?.anonymousBytes,
      appFileBackedBytes: mem?.fileBackedBytes,
      appPeakBytes: mem?.anonymousPeakBytes,
    );
  }
}
