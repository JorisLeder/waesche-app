import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/sync/merge.dart';

typedef Rec = ({String id, DateTime updatedAt});

void main() {
  final t0 = DateTime.utc(2026, 1, 1);
  final t1 = DateTime.utc(2026, 1, 2);

  MergePlan<Rec> plan(Map<String, DateTime> local, List<Rec> incoming) => planMerge<Rec>(
    localUpdatedAt: local,
    incoming: incoming,
    idOf: (r) => r.id,
    updatedAtOf: (r) => r.updatedAt,
  );

  test('neue IDs werden eingefügt', () {
    final p = plan({}, [(id: 'a', updatedAt: t0)]);
    expect(p.toInsert.map((r) => r.id), ['a']);
    expect(p.toUpdate, isEmpty);
  });

  test('neuere Stände gewinnen, ältere und gleiche bleiben', () {
    final p = plan({'a': t0, 'b': t1, 'c': t0}, [
      (id: 'a', updatedAt: t1),
      (id: 'b', updatedAt: t0),
      (id: 'c', updatedAt: t0),
    ]);
    expect(p.toUpdate.map((r) => r.id), ['a']);
    expect(p.unchanged, 2);
  });

  test('doppelte Einträge im Paket zählen einmal', () {
    final p = plan({}, [(id: 'a', updatedAt: t0), (id: 'a', updatedAt: t1)]);
    expect(p.toInsert, hasLength(1));
  });
}
