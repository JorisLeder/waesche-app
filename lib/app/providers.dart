import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/gemma_service.dart';
import '../ai/mobilenet_embedder.dart';
import '../core/db/database.dart';
import '../core/db/photo_store.dart';
import '../core/db/wardrobe_repository.dart';
import '../features/household/household_package.dart';

/// Werden in main() mit den geöffneten Instanzen überschrieben.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));
final photoStoreProvider = Provider<PhotoStore>((ref) => throw UnimplementedError('photoStoreProvider'));

final repositoryProvider = Provider<WardrobeRepository>(
  (ref) => WardrobeRepository(ref.watch(databaseProvider), ref.watch(photoStoreProvider)),
);

final householdProvider = Provider<HouseholdPackage>(
  (ref) => HouseholdPackage(ref.watch(databaseProvider), ref.watch(photoStoreProvider)),
);

final gemmaServiceProvider = Provider<GemmaService>((ref) {
  final s = GemmaService();
  ref.onDispose(s.unload);
  return s;
});

final describerProvider = Provider<GemmaDescriber>((ref) => GemmaDescriber(ref.watch(gemmaServiceProvider)));
final matcherProvider = Provider<GemmaMatcher>((ref) => GemmaMatcher(ref.watch(gemmaServiceProvider)));

final embedderProvider = Provider<MobileNetEmbedder>((ref) {
  final e = MobileNetEmbedder();
  ref.onDispose(e.close);
  return e;
});

final personsProvider = StreamProvider<List<PersonRow>>((ref) => ref.watch(repositoryProvider).watchPersons());
final itemsProvider = StreamProvider<List<ItemView>>((ref) => ref.watch(repositoryProvider).watchItems());
