import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/pipeline/decisions.dart';
import 'package:waesche_app/pipeline/identification_pipeline.dart';

import 'support/fakes.dart';

Uint8List photo(int key) => Uint8List.fromList([key, 0, 0]);

const weisseSocke = GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt');

void main() {
  test('eindeutiger Treffer: Vorfilter entscheidet, LLM wird nicht gefragt', () async {
    final matcher = ScriptedMatcher([]);
    final p = IdentificationPipeline(
      describer: FakeDescriber(const GarmentAttributes(
        kategorie: 'Socke',
        farben: ['schwarz'],
        muster: 'geringelt',
        laengeSchnitt: 'Wadensocke',
        materialOptik: 'Baumwolle',
      )),
      matcher: matcher,
    );
    final s = await p.start(photo(1), [
      item('schwarz', farben: ['schwarz'], muster: 'geringelt', laenge: 'Wadensocke'),
      item('weiss'),
    ]);
    expect(s, isA<PipelineProposal>());
    expect((s as PipelineProposal).item.id, 'schwarz');
    expect(s.stage, Stage.filter);
    expect(matcher.seenCandidates, isEmpty);
  });

  test('LLM ordnet zu', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([(c) => AssignDecision(itemId: c[1].itemId, confidence: 0.9)]),
    );
    final s = await p.start(photo(1), [item('a', person: 'Anna'), item('b', person: 'Ben')]);
    expect(s, isA<PipelineProposal>());
    expect((s as PipelineProposal).stage, Stage.llm);
  });

  test('Rückfrage löst auf (Beispiel Rippung)', () async {
    final matcher = ScriptedMatcher([
      (c) => AskDecision(Question(
        text: 'Ist die Rippung über den ganzen Socken oder erst ab dem Knöchel?',
        options: [
          AnswerOption(text: 'ganz', itemIds: [c.firstWhere((x) => x.itemId == 'ganz').itemId]),
          AnswerOption(text: 'ab Knöchel', itemIds: [c.firstWhere((x) => x.itemId == 'knoechel').itemId]),
        ],
        source: 'llm',
      )),
    ]);
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: matcher);
    final s = await p.start(photo(1), [
      item('ganz', merkmale: 'Rippung über den ganzen Socken'),
      item('knoechel', person: 'Ben', merkmale: 'Rippung ab dem Knöchel'),
    ]);
    expect(s, isA<PipelineQuestion>());
    final q = (s as PipelineQuestion).question;
    final r = await p.answer(q.options.firstWhere((o) => o.text == 'ab Knöchel'));
    expect(r, isA<PipelineProposal>());
    expect((r as PipelineProposal).item.id, 'knoechel');
    expect(r.stage, Stage.rueckfrage);
  });

  test('nach unklarer Antwort entscheidet der Bildvergleich (NN)', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([(c) => UnclearDecision(c.map((x) => x.itemId).toList())]),
      embedder: FakeEmbedder({
        1: [1, 0, 0],
      }),
    );
    final s = await p.start(photo(1), [
      item('a', embeddings: [
        [0.95, 0.31, 0],
      ]),
      item('b', person: 'Ben', embeddings: [
        [0.7, 0.71, 0],
      ]),
    ]);
    expect(s, isA<PipelineProposal>());
    expect((s as PipelineProposal).item.id, 'a');
    expect(s.stage, Stage.nn);
  });

  test('NN unentschieden -> Fotovergleich, manuelle Wahl', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([(c) => UnclearDecision(c.map((x) => x.itemId).toList())]),
      embedder: FakeEmbedder({
        1: [1, 0, 0],
      }),
    );
    final s = await p.start(photo(1), [
      item('a', embeddings: [
        [1, 0.1, 0],
      ]),
      item('b', person: 'Ben', embeddings: [
        [1, 0.12, 0],
      ]),
    ]);
    expect(s, isA<PipelineManualChoice>());
    expect((s as PipelineManualChoice).candidates, hasLength(2));
    final chosen = p.chooseManually('b');
    expect(chosen.stage, Stage.manuell);
    expect(chosen.userChosen, isTrue);
  });

  test('kaputte LLM-Ausgabe -> Wiederholung -> regelbasierte Rückfrage', () async {
    final matcher = ScriptedMatcher([
      (_) => const InvalidDecision('Prosa'),
      (_) => const InvalidDecision('Prosa'),
    ]);
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: matcher);
    final s = await p.start(photo(1), [
      item('a', laenge: 'Knöchelsocke'),
      item('b', person: 'Ben', laenge: 'Wadensocke'),
    ]);
    expect(matcher.seenCandidates, hasLength(2), reason: 'ein Versuch + eine Wiederholung');
    expect(s, isA<PipelineQuestion>());
    final q = (s as PipelineQuestion).question;
    expect(q.source, startsWith('regel'));
    final r = await p.answer(q.options.firstWhere((o) => o.text == 'Wadensocke'));
    expect((r as PipelineProposal).item.id, 'b');
  });

  test('LLM-Absturz wird abgefangen', () async {
    final matcher = ScriptedMatcher([])..throwError = true;
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: matcher);
    final s = await p.start(photo(1), [
      item('a', laenge: 'Knöchelsocke'),
      item('b', person: 'Ben', laenge: 'Wadensocke'),
    ]);
    expect(s, isA<PipelineQuestion>());
    expect(matcher.seenCandidates, hasLength(1), reason: 'Absturz wird nicht wiederholt');
  });

  test('VLM-Ausfall: Bildvergleich trägt allein', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke, fail: true),
      matcher: ScriptedMatcher([(c) => UnclearDecision(c.map((x) => x.itemId).toList())]),
      embedder: FakeEmbedder({
        1: [1, 0, 0],
      }),
    );
    final s = await p.start(photo(1), [
      item('a', embeddings: [
        [1, 0.02, 0],
      ]),
      item('b', person: 'Ben', kategorie: 'T-Shirt', embeddings: [
        [0, 1, 0],
      ]),
    ]);
    expect(s, isA<PipelineProposal>());
    expect((s as PipelineProposal).item.id, 'a');
  });

  test('"Weiß nicht" geht zum Bildvergleich', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([
        (c) => AskDecision(Question(
          text: 'Welche Ferse?',
          options: [
            AnswerOption(text: 'grau', itemIds: [c[0].itemId]),
            AnswerOption(text: 'weiß', itemIds: [c[1].itemId]),
          ],
          source: 'llm',
        )),
      ]),
    );
    final s = await p.start(photo(1), [item('a'), item('b', person: 'Ben')]);
    expect(s, isA<PipelineQuestion>());
    final r = await p.answerUnknown();
    expect(r, isA<PipelineManualChoice>(), reason: 'ohne Embeddings bleibt nur der Fotovergleich');
  });

  test('höchstens zwei Rückfrage-Runden', () async {
    MatchDecision ask(List c) => AskDecision(Question(
      text: 'Frage',
      options: [
        AnswerOption(text: 'x', itemIds: [c[0].itemId, c[1].itemId]),
        AnswerOption(text: 'y', itemIds: [c.last.itemId]),
      ],
      source: 'llm',
    ));
    final matcher = ScriptedMatcher([ask, ask, ask]);
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: matcher);
    var s = await p.start(photo(1), [item('a'), item('b', person: 'Ben'), item('c', person: 'Cleo')]);
    expect(s, isA<PipelineQuestion>());
    s = await p.answer((s as PipelineQuestion).question.options.first);
    expect(s, isA<PipelineQuestion>(), reason: 'zweite Runde');
    expect((s as PipelineQuestion).round, 2);
    s = await p.answer(s.question.options.first);
    expect(s, isA<PipelineManualChoice>(), reason: 'nach zwei Runden kein LLM mehr');
    expect(matcher.seenAnswers.last, hasLength(1), reason: 'bisherige Antworten gehen ans LLM');
  });

  test('Ablehnen eines Vorschlags führt zum Fotovergleich ohne das abgelehnte Teil', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([(c) => AssignDecision(itemId: c[0].itemId, confidence: 0.9)]),
    );
    final s = await p.start(photo(1), [item('a'), item('b', person: 'Ben')]);
    final proposed = (s as PipelineProposal).item.id;
    final r = p.reject(proposed);
    expect(r, isA<PipelineManualChoice>());
    expect((r as PipelineManualChoice).candidates.map((c) => c.item.id), isNot(contains(proposed)));
  });

  test('Besitzer-Abkürzung: alle ähnlichen Teile gehören derselben Person', () async {
    final matcher = ScriptedMatcher([]);
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: matcher);
    final s = await p.start(photo(1), [
      item('a1'),
      item('a2', laenge: 'Wadensocke'),
      item('b', person: 'Ben', kategorie: 'Socke', farben: ['schwarz'], muster: 'geringelt'),
    ]);
    expect(s, isA<PipelineProposal>());
    final prop = s as PipelineProposal;
    expect(prop.ownerOnly, isTrue);
    expect(prop.item.personName, 'Anna');
    expect(matcher.seenCandidates, isEmpty, reason: 'kein LLM nötig');
  });

  test('Besitzer-Abkürzung nach einer Rückfrage', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(weisseSocke),
      matcher: ScriptedMatcher([
        (c) => AskDecision(Question(
          text: 'Welche Länge?',
          options: [
            AnswerOption(text: 'Knöchel', itemIds: [c[0].itemId, c[1].itemId]),
            AnswerOption(text: 'Wade', itemIds: [c[2].itemId]),
          ],
          source: 'llm',
        )),
      ]),
    );
    final s = await p.start(photo(1), [item('a1'), item('a2'), item('b', person: 'Ben')]);
    expect(s, isA<PipelineQuestion>());
    final r = await p.answer((s as PipelineQuestion).question.options.first);
    expect(r, isA<PipelineProposal>());
    expect((r as PipelineProposal).ownerOnly, isTrue);
  });

  test('leerer Katalog', () async {
    final p = IdentificationPipeline(describer: FakeDescriber(weisseSocke), matcher: ScriptedMatcher([]));
    expect(await p.start(photo(1), []), isA<PipelineNoMatch>());
  });
}
