import 'model_utils.dart';

class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.unitId,
    required this.courseId,
    this.completed = false,
    this.bestScore = 0,
    this.attempts = 0,
    this.completedAt,
  });

  final String lessonId;
  final String unitId;
  final String courseId;
  final bool completed;

  /// Melhor precisão obtida (0–100).
  final int bestScore;
  final int attempts;
  final DateTime? completedAt;

  factory LessonProgress.fromMap(String lessonId, Map<String, dynamic> map) => LessonProgress(
        lessonId: lessonId,
        unitId: (map['unitId'] ?? '') as String,
        courseId: (map['courseId'] ?? '') as String,
        completed: map['completed'] == true,
        bestScore: parseInt(map['bestScore'] ?? map['score']),
        attempts: parseInt(map['attempts']),
        completedAt: parseDate(map['completedAt']),
      );

  Map<String, dynamic> toMap() => {
        'lessonId': lessonId,
        'unitId': unitId,
        'courseId': courseId,
        'completed': completed,
        'bestScore': bestScore,
        'attempts': attempts,
        'completedAt': completedAt,
      };
}
