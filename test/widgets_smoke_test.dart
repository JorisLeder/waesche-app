import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:waesche_app/ai/gemma_service.dart';
import 'package:waesche_app/app/providers.dart';
import 'package:waesche_app/core/db/database.dart';
import 'package:waesche_app/core/db/photo_store.dart';
import 'package:waesche_app/core/db/wardrobe_repository.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/features/debug/feasibility_screen.dart';
import 'package:waesche_app/features/home/home_screen.dart';
import 'package:waesche_app/features/household/household_screen.dart';
import 'package:waesche_app/features/persons/persons_screen.dart';
import 'package:waesche_app/features/setup/setup_screen.dart';
import 'package:waesche_app/features/wardrobe/item_edit_screen.dart';
import 'package:waesche_app/features/wardrobe/wardrobe_screen.dart';

/// Ohne native KI-Laufzeit: Modell gilt als installiert.
class FakeGemma extends GemmaService {
  @override
  Future<bool> refreshInstalled() async {
    status.value = const ModelStatus(ModelPhase.installed);
    return true;
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late Directory tmp;
  late WardrobeRepository repo;
  late String itemId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('smoke');
    repo = WardrobeRepository(db, PhotoStore(tmp));
    final anna = await repo.addPerson('Anna', 0xFFE53935);
    await repo.addPerson('Ben', 0xFF1E88E5);
    final photo = img.encodeJpg(img.Image(width: 32, height: 32));
    itemId = await repo.addItem(
      personId: anna,
      attributes: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt'),
      name: 'Laufsocke',
      newPhotos: [NewPhoto(Uint8List.fromList(photo), 'vorne')],
    );
  });

  tearDown(() async {
    await tmp.delete(recursive: true);
  });

  /// Baut den Baum ab und lässt die Null-Timer der drift-Streams auslaufen,
  /// sonst meldet der Test hängende Timer und db.close() wartet ewig.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(() => db.close());
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        photoStoreProvider.overrideWithValue(PhotoStore(tmp)),
        gemmaServiceProvider.overrideWithValue(FakeGemma()),
      ],
      child: MaterialApp(home: child),
    ));
    // Streams aus drift brauchen echte Zeit.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
  }

  testWidgets('Startbildschirm', (t) async {
    await pump(t, const HomeScreen());
    expect(find.text('Teil scannen'), findsOneWidget);
    expect(find.text('Kleiderschrank'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Personen', (t) async {
    await pump(t, const PersonsScreen());
    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Ben'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Kleiderschrank', (t) async {
    await pump(t, const WardrobeScreen());
    expect(find.text('Laufsocke'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Teil bearbeiten', (t) async {
    await pump(t, ItemEditScreen(itemId: itemId));
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await t.pump();
    expect(find.text('Teil bearbeiten'), findsOneWidget);
    expect(find.text('Fotos'), findsOneWidget);
    expect(find.text('Anna'), findsWidgets);
    await finish(t);
  });

  testWidgets('Neues Teil', (t) async {
    await pump(t, const ItemEditScreen());
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await t.pump();
    expect(find.text('Teil einpflegen'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Haushaltspaket', (t) async {
    await pump(t, const HouseholdScreen());
    expect(find.text('Komplettes Paket teilen'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Modell-Setup', (t) async {
    await pump(t, const SetupScreen());
    expect(find.textContaining('Gemma 4 E2B'), findsOneWidget);
    await finish(t);
  });

  testWidgets('Machbarkeits-Test', (t) async {
    await pump(t, const FeasibilityScreen());
    expect(find.text('1. Modell laden'), findsOneWidget);
    await finish(t);
  });
}
