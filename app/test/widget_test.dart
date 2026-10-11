import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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

    expect(exercises, isNotEmpty);
    for (final e in exercises) {
      expect(e.type, isNot(ExerciseType.unknown), reason: e.id);
      expect(lessonIds, contains(e.lessonId), reason: e.id);
      expect(e.correctAnswer, isNotEmpty, reason: e.id);
      if (e.options.isNotEmpty) {
        expect(e.options.map((o) => o.text), contains(e.correctAnswer), reason: e.id);
      }
      if (e.type == ExerciseType.fillBlank) expect(e.question, contains('___'), reason: e.id);
    }
  });
}
