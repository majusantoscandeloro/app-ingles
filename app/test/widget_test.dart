import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:livia_ingles/features/exercises/widgets/choice_exercises.dart';
import 'package:livia_ingles/shared/models/exercise.dart';

/// Garante que o conteúdo demonstrativo é válido para o motor de exercícios.
void main() {
  test('demo_course.json é consistente', () {
    final data = jsonDecode(File('assets/seed/demo_course.json').readAsStringSync()) as Map<String, dynamic>;
    final lessonIds = (data['lessons'] as List).map((l) => l['id']).toSet();
    final exercises = (data['exercises'] as List)
        .cast<Map<String, dynamic>>()
        .map((m) => Exercise.fromMap(m['id'] as String, m))
        .toList();

    expect((data['units'] as List).length, 18);
    expect((data['lessons'] as List).length, 54);
    expect(exercises, isNotEmpty);
    final perLesson = <String, int>{};
    for (final e in exercises) {
      perLesson[e.lessonId] = (perLesson[e.lessonId] ?? 0) + 1;
    }
    for (final lesson in data['lessons'] as List) {
      expect(perLesson[lesson['id']], 8, reason: lesson['id'] as String);
    }
    for (final e in exercises) {
      expect(e.type, isNot(ExerciseType.unknown), reason: e.id);
      expect(lessonIds, contains(e.lessonId), reason: e.id);
      expect(e.correctAnswer, isNotEmpty, reason: e.id);
      if (e.options.isNotEmpty) {
        expect(e.options.map((o) => o.text), contains(e.correctAnswer), reason: e.id);
      }
      if (e.type == ExerciseType.fillBlank) expect(e.question, contains('___'), reason: e.id);
    }

    final withOptions = exercises.where((e) => e.options.length > 1).toList();
    final correctStillFirst = withOptions.where((e) => stableOptionOrder(e).first.text == e.correctAnswer).length;
    expect(correctStillFirst, lessThan(withOptions.length));
    for (final e in withOptions) {
      final again = stableOptionOrder(e).map((o) => o.text).join('|');
      expect(stableOptionOrder(e).map((o) => o.text).join('|'), again, reason: e.id);
    }
  });
}
