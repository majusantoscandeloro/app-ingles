import 'package:flutter_test/flutter_test.dart';
import 'package:livia_ingles/features/exercises/answer_checker.dart';
import 'package:livia_ingles/shared/models/exercise.dart';

Exercise _exercise(ExerciseType type, String answer, {List<String> accepted = const [], List<String> options = const []}) =>
    Exercise(
      id: 'e',
      lessonId: 'l',
      type: type,
      correctAnswer: answer,
      acceptedAnswers: accepted,
      options: options.map((o) => ExerciseOption(text: o)).toList(),
    );

void main() {
  const checker = AnswerChecker();

  group('normalização', () {
    test('ignora maiúsculas, pontuação e espaços extras', () {
      final e = _exercise(ExerciseType.translation, 'I am Brazilian.');
      expect(checker.check(e, '  i am   brazilian ').isCorrect, isTrue);
    });

    test('expande contrações', () {
      final e = _exercise(ExerciseType.translation, 'I am fine.');
      expect(checker.check(e, "I'm fine").isCorrect, isTrue);
      expect(checker.check(e, 'I’m fine!').isCorrect, isTrue);
    });

    test('aceita respostas alternativas', () {
      final e = _exercise(ExerciseType.translation, 'I am fine.', accepted: ['I am good']);
      expect(checker.check(e, 'I am good').isCorrect, isTrue);
    });
  });

  group('tradução', () {
    test('tolera um erro de digitação em frases maiores', () {
      final result = checker.check(_exercise(ExerciseType.translation, 'Good afternoon'), 'Good afternon');
      expect(result.isCorrect, isTrue);
      expect(result.hasTypo, isTrue);
    });

    test('não tolera erro em palavras curtas', () {
      expect(checker.check(_exercise(ExerciseType.translation, 'Hi'), 'Ha').isCorrect, isFalse);
    });

    test('resposta errada', () {
      expect(checker.check(_exercise(ExerciseType.translation, 'Good night'), 'Good morning').isCorrect, isFalse);
    });
  });

  group('escolha', () {
    test('múltipla escolha exige correspondência exata', () {
      final e = _exercise(ExerciseType.multipleChoice, 'Cachorro', options: ['Gato', 'Cachorro']);
      expect(checker.check(e, 'Cachorro').isCorrect, isTrue);
      expect(checker.check(e, 'Gato').isCorrect, isFalse);
    });
  });

  group('fala', () {
    final e = _exercise(ExerciseType.speak, 'I would like a coffee');

    test('frase reconhecida igual é correta', () {
      expect(checker.check(e, 'I would like a coffee').verdict, AnswerVerdict.correct);
    });

    test('frase parecida é "quase"', () {
      expect(checker.check(e, 'I like a coffee').verdict, AnswerVerdict.almost);
    });

    test('frase diferente é incorreta', () {
      expect(checker.check(e, 'good morning').verdict, AnswerVerdict.incorrect);
    });

    test('reconhecedor que dobra consoante em nome ainda conta como certo', () {
      final name = _exercise(ExerciseType.speak, 'My name is Ana');
      expect(checker.check(name, 'My name is Anna').verdict, AnswerVerdict.correct);
    });

    test('palavra parecida que não é letra dobrada continua errada', () {
      final live = _exercise(ExerciseType.speak, 'I live in Brazil');
      expect(checker.check(live, 'I love in Brazil').verdict, isNot(AnswerVerdict.correct));
      expect(checker.check(_exercise(ExerciseType.speak, 'Good morning'), 'God morning').verdict, isNot(AnswerVerdict.correct));
    });
  });
}
