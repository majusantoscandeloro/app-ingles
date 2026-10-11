import 'model_utils.dart';

/// Registro de erro do aluno, usado na tela "Praticar".
class UserError {
  const UserError({
    required this.exerciseId,
    required this.lessonId,
    required this.correctAnswer,
    this.lastAnswer,
    this.count = 1,
    this.lastErrorAt,
  });

  final String exerciseId;
  final String lessonId;
  final String correctAnswer;
  final String? lastAnswer;
  final int count;
  final DateTime? lastErrorAt;

  factory UserError.fromMap(String exerciseId, Map<String, dynamic> map) => UserError(
        exerciseId: exerciseId,
        lessonId: (map['lessonId'] ?? '') as String,
        correctAnswer: (map['correctAnswer'] ?? '') as String,
        lastAnswer: map['lastAnswer'] as String?,
        count: parseInt(map['count'], 1),
        lastErrorAt: parseDate(map['lastErrorAt']),
      );

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'lessonId': lessonId,
        'correctAnswer': correctAnswer,
        'lastAnswer': lastAnswer,
        'count': count,
        'lastErrorAt': lastErrorAt,
      };
}
