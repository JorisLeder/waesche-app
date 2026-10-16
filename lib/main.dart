import 'package:flutter/material.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/db/database.dart';
import 'core/db/photo_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterEdgeAi.initialize(inferenceEngines: [LiteRtLmEngine()]);
  final photos = await PhotoStore.open();
  final db = AppDatabase();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(photos),
      ],
      child: const WaescheApp(),
    ),
  );
}
