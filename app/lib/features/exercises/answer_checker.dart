import '../../core/utils/text_normalizer.dart';
import '../../shared/models/exercise.dart';

enum AnswerVerdict { correct, almost, incorrect }

class AnswerResult {
  const AnswerResult({
    required this.verdict,
    required this.correctAnswer,
    this.hasTypo = false,
    this.similarity = 0,
  });

  final AnswerVerdict verdict;
  final String correctAnswer;

  /// Aceito, mas com pequeno erro de digitação.
  final bool hasTypo;
  final double similarity;

  bool get isCorrect => verdict == AnswerVerdict.correct;
}

class AnswerChecker {
  const AnswerChecker({this.speakCorrectThreshold = 0.85, this.speakAlmostThreshold = 0.6});

  final double speakCorrectThreshold;
  final double speakAlmostThreshold;

  AnswerResult check(Exercise exercise, String answer) {
    final normalized = normalizeAnswer(answer);
    final accepted = exercise.allAcceptedAnswers.map(normalizeAnswer).where((a) => a.isNotEmpty).toList();

    if (normalized.isEmpty) return _result(exercise, AnswerVerdict.incorrect);
    if (accepted.contains(normalized)) return _result(exercise, AnswerVerdict.correct, similarity: 1);

    switch (exercise.type) {
      case ExerciseType.speak:
        final best = accepted.map((a) => spokenSimilarity(normalized, a)).fold<double>(0, (m, s) => s > m ? s : m);
        final verdict = best >= speakCorrectThreshold
            ? AnswerVerdict.correct
            : best >= speakAlmostThreshold
                ? AnswerVerdict.almost
                : AnswerVerdict.incorrect;
        return _result(exercise, verdict, similarity: best);
      case ExerciseType.translation:
      case ExerciseType.listen when exercise.options.isEmpty:
        final typo = accepted.any((a) => _isTypo(normalized, a));
        return _result(exercise, typo ? AnswerVerdict.correct : AnswerVerdict.incorrect, hasTypo: typo);
      default:
        return _result(exercise, AnswerVerdict.incorrect);
    }
  }

  bool _isTypo(String answer, String expected) {
    if (expected.length < 5) return false;
    final allowed = expected.length >= 15 ? 2 : 1;
    return charDistance(answer, expected) <= allowed;
  }

  AnswerResult _result(Exercise e, AnswerVerdict verdict, {bool hasTypo = false, double similarity = 0}) =>
      AnswerResult(verdict: verdict, correctAnswer: e.correctAnswer, hasTypo: hasTypo, similarity: similarity);
}
