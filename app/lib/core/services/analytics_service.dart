import 'package:flutter/foundation.dart';

/// Eventos de produto (seção 67 do planejamento). Hoje registra no console;
/// basta criar uma implementação com Firebase Analytics para enviar de fato.
abstract class AnalyticsService {
  void log(String event, [Map<String, Object?> params = const {}]);
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  void log(String event, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) debugPrint('[analytics] $event $params');
  }
}

abstract final class AnalyticsEvents {
  static const lessonStarted = 'lesson_started';
  static const lessonCompleted = 'lesson_completed';
  static const lessonFailed = 'lesson_failed';
  static const exerciseCorrect = 'exercise_correct';
  static const exerciseWrong = 'exercise_wrong';
  static const speakingStarted = 'speaking_started';
  static const speakingCompleted = 'speaking_completed';
  static const streakUpdated = 'streak_updated';
  static const unitCompleted = 'unit_completed';
  static const reviewCompleted = 'review_completed';
}
