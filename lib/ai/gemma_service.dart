import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';

import '../core/device/device_info.dart';
import '../core/device/memory_guard.dart';
import '../core/models/garment_attributes.dart';
import '../pipeline/decisions.dart';
import 'engines.dart';
import 'prompts.dart';
import 'response_parser.dart';
import 'tool_schemas.dart';

/// Das eine Modell für beide Rollen (VLM und LLM).
class GemmaModelSpec {
  GemmaModelSpec._();

  static const url =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';
  static const fileName = 'gemma-4-E2B-it.litertlm';
  static const approxBytes = 2580 * 1000 * 1000;
  static const displayName = 'Gemma 4 E2B';
}

enum ModelPhase { unknown, notInstalled, downloading, installed, loading, ready, error }

class ModelStatus {
  const ModelStatus(this.phase, {this.progress = 0, this.message = '', this.backend, this.lastLoad});

  final ModelPhase phase;
  final int progress;
  final String message;
  final PreferredBackend? backend;
  final LoadReport? lastLoad;
}

class LoadReport {
  const LoadReport({required this.elapsed, required this.backend, required this.before, required this.after});

  final Duration elapsed;
  final PreferredBackend? backend;
  final DeviceSnapshot before;
  final DeviceSnapshot after;

  String describe() =>
      'Laden: ${elapsed.inMilliseconds} ms, Backend: ${backend?.name ?? '–'}\n'
      'Vorher: ${before.describe()}\nNachher: ${after.describe()}';
}

/// Verwaltet Download, Laden und Entladen von Gemma 4 E2B.
///
/// Speicherbudget: Das Modell wird erst bei Bedarf geladen, nach
/// [idleTimeout] ohne Nutzung und beim Wechsel in den Hintergrund entladen.
/// Aufrufe laufen nacheinander (eine Session zur Zeit).
class GemmaService {
  GemmaService({
    this.idleTimeout = const Duration(minutes: 2),
    this.memoryGuard = const MemoryGuard(),
    this.preferredBackend = PreferredBackend.gpu,
    this.maxTokens = 4096,
  });

  final Duration idleTimeout;
  final MemoryGuard memoryGuard;

  /// Gewünschtes Backend; was wirklich lief, steht in [ModelStatus.backend].
  PreferredBackend preferredBackend;

  /// Kontextfenster (Prompt + Bild + Antwort). Ein Bild kostet einige hundert Tokens.
  int maxTokens;

  final status = ValueNotifier(const ModelStatus(ModelPhase.unknown));

  InferenceModel? _model;
  Timer? _idleTimer;
  Future<void> _queue = Future.value();
  LoadReport? lastLoad;

  bool get isLoaded => _model != null && !_model!.isClosed;

  /// Einstellungen für den Machbarkeits-Test; erzwingt ein Neuladen.
  Future<void> configure({PreferredBackend? backend, int? maxTokens}) async {
    if (backend != null) preferredBackend = backend;
    if (maxTokens != null) this.maxTokens = maxTokens;
    await unload();
  }

  Future<bool> refreshInstalled() async {
    final installed = await FlutterEdgeAi.isModelInstalled(GemmaModelSpec.fileName);
    if (status.value.phase == ModelPhase.unknown ||
        status.value.phase == ModelPhase.notInstalled ||
        status.value.phase == ModelPhase.installed) {
      status.value = ModelStatus(installed ? ModelPhase.installed : ModelPhase.notInstalled);
    }
    return installed;
  }

  Future<void> install() async {
    status.value = const ModelStatus(ModelPhase.downloading, message: 'Download startet …');
    try {
      await FlutterEdgeAi.installModel(modelType: ModelType.gemma4, fileType: ModelFileType.litertlm)
          .fromNetwork(GemmaModelSpec.url, foreground: true)
          .withProgress((p) => status.value = ModelStatus(ModelPhase.downloading, progress: p))
          .install();
      status.value = const ModelStatus(ModelPhase.installed);
    } catch (e) {
      status.value = ModelStatus(ModelPhase.error, message: 'Download fehlgeschlagen: $e');
      rethrow;
    }
  }

  /// Führt [f] mit geladenem Modell aus – seriell, mit Leerlauf-Timer.
  Future<T> run<T>(Future<T> Function(InferenceModel model) f) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      _idleTimer?.cancel();
      try {
        final model = await _ensureLoaded();
        completer.complete(await f(model));
      } catch (e, st) {
        completer.completeError(e, st);
      } finally {
        _idleTimer = Timer(idleTimeout, () => unload());
      }
    });
    return completer.future;
  }

  Future<InferenceModel> _ensureLoaded() async {
    final m = _model;
    if (m != null && !m.isClosed) return m;
    status.value = const ModelStatus(ModelPhase.loading, message: 'Modell wird geladen …');
    try {
      final before = await memoryGuard.check();
      final sw = Stopwatch()..start();
      final model = await FlutterEdgeAi.getActiveModel(
        maxTokens: maxTokens,
        preferredBackend: preferredBackend,
        supportImage: true,
        maxNumImages: 1,
      );
      sw.stop();
      final after = await DeviceInfo.snapshot();
      _model = model;
      lastLoad = LoadReport(elapsed: sw.elapsed, backend: model.activeBackend, before: before, after: after);
      status.value = ModelStatus(ModelPhase.ready, backend: model.activeBackend, lastLoad: lastLoad);
      return model;
    } catch (e) {
      status.value = ModelStatus(ModelPhase.error, message: '$e');
      rethrow;
    }
  }

  /// Gibt den Speicher frei. Sicher mehrfach aufrufbar.
  Future<void> unload() {
    _idleTimer?.cancel();
    final done = Completer<void>();
    _queue = _queue.then((_) async {
      final m = _model;
      _model = null;
      if (m != null && !m.isClosed) {
        try {
          await m.close();
        } catch (e) {
          debugPrint('Modell schließen: $e');
        }
      }
      if (status.value.phase == ModelPhase.ready || status.value.phase == ModelPhase.loading) {
        status.value = const ModelStatus(ModelPhase.installed);
      }
      done.complete();
    });
    return done.future;
  }

  static Tool toolFrom(Map<String, dynamic> schema) => Tool(
    name: schema['name'] as String,
    description: schema['description'] as String,
    parameters: schema['parameters'] as Map<String, dynamic>,
  );
}

/// Liest die erste verwertbare Antwort eines Chats.
Future<({String? toolName, Map<String, dynamic>? args, String text})> _collect(InferenceChat chat) async {
  final response = await chat.generateChatResponse();
  switch (response) {
    case FunctionCallResponse(:final name, :final args):
      return (toolName: name, args: args, text: '$name $args');
    case ParallelFunctionCallResponse(:final calls):
      final first = calls.isEmpty ? null : calls.first;
      return (toolName: first?.name, args: first?.args, text: calls.map((c) => '${c.name} ${c.args}').join('\n'));
    case TextResponse(:final token):
      return (toolName: null, args: null, text: token);
    case ThinkingResponse(:final content):
      return (toolName: null, args: null, text: content);
  }
}

/// Stufe 1 mit Gemma: Bild -> Attribute (Function Calling, JSON als Rückfall).
class GemmaDescriber implements DescriberEngine {
  GemmaDescriber(this.service);

  final GemmaService service;
  final _parser = const ResponseParser();

  @override
  Future<Description> describe(Uint8List jpeg) => service.run((model) async {
    final sw = Stopwatch()..start();
    final chat = await model.createChat(
      supportImage: true,
      tools: [GemmaService.toolFrom(ToolSchemas.describe())],
      supportsFunctionCalls: true,
      toolChoice: ToolChoice.required,
      modelType: ModelType.gemma4,
      systemInstruction: Prompts.describeSystem,
      maxOutputTokens: 256,
      temperature: 0.2,
    );
    var raw = '';
    try {
      await chat.addQueryChunk(Message(text: Prompts.describeUser(), isUser: true, imageBytes: jpeg));
      final r = await _collect(chat);
      raw = r.text;
      final attrs = _parser.parseDescription(toolName: r.toolName, args: r.args, text: r.text);
      if (attrs != null) {
        return Description(attributes: attrs, raw: raw, elapsed: sw.elapsed, viaTool: r.toolName != null);
      }
    } finally {
      await chat.close();
    }

    // Rückfall: ohne Werkzeuge, Antwort als JSON-Text.
    final plain = await model.createChat(
      supportImage: true,
      modelType: ModelType.gemma4,
      systemInstruction: Prompts.describeSystem,
      maxOutputTokens: 320,
      temperature: 0.2,
    );
    try {
      await plain.addQueryChunk(Message(text: Prompts.describeUserJsonFallback(), isUser: true, imageBytes: jpeg));
      final r = await _collect(plain);
      raw = '$raw\n--- JSON-Rückfall ---\n${r.text}';
      final attrs = _parser.parseDescription(text: r.text) ?? GarmentAttributes.empty;
      return Description(attributes: attrs, raw: raw, elapsed: sw.elapsed, viaTool: false);
    } finally {
      await plain.close();
    }
  });
}

/// Stufe 2 mit Gemma: Beschreibung + Kandidaten -> Entscheidung.
class GemmaMatcher implements MatcherEngine {
  GemmaMatcher(this.service);

  final GemmaService service;
  final _parser = const ResponseParser();

  /// Rohantwort des letzten Aufrufs (Debug-Anzeige).
  String lastRaw = '';

  @override
  Future<MatchDecision> decide({
    required GarmentAttributes scan,
    required List<LabeledCandidate> candidates,
    List<String> previousAnswers = const [],
  }) => service.run((model) async {
    final labels = candidates.map((c) => c.label).toList();
    final chat = await model.createChat(
      tools: [
        GemmaService.toolFrom(ToolSchemas.assign(labels)),
        GemmaService.toolFrom(ToolSchemas.ask(labels)),
        GemmaService.toolFrom(ToolSchemas.unclear(labels)),
      ],
      supportsFunctionCalls: true,
      toolChoice: ToolChoice.required,
      modelType: ModelType.gemma4,
      systemInstruction: Prompts.matchSystem,
      maxOutputTokens: 256,
      temperature: 0.2,
    );
    try {
      await chat.addQueryChunk(Message(
        text: Prompts.matchUser(scan: scan, candidates: candidates, previousAnswers: previousAnswers),
        isUser: true,
      ));
      final r = await _collect(chat);
      lastRaw = r.text;
      return _parser.parseMatch(candidates: candidates, toolName: r.toolName, args: r.args, text: r.text);
    } finally {
      await chat.close();
    }
  });
}
