import 'dart:math' as math;

import '../../core/services/analytics_service.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../shared/models/course.dart';
import '../../shared/models/exercise.dart';
import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';
import '../gamification/achievements.dart';
import '../gamification/gamification_service.dart';
import 'lesson_session_controller.dart';

class SessionSummary {
  const SessionSummary({
    required this.completed,
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.streak,
    required this.streakIncreased,
    required this.perfect,
    required this.newAchievements,
    required this.heartsRestored,
    required this.wrongCount,
  });

  final bool completed;
  final int correct;
  final int total;
  final int xpEarned;
  final int streak;
  final bool streakIncreased;
  final bool perfect;
  final List<Achievement> newAchievements;
  final int heartsRestored;
  final int wrongCount;

  int get accuracy => total == 0 ? 100 : (correct * 100 / total).round();
}

/// Calcula XP/streak/conquistas e grava tudo em um único commit.
class SessionCompletionService {
  SessionCompletionService({required this.repository, required this.gamification, required this.analytics});

  final UserDataRepository repository;
  final GamificationService gamification;
  final AnalyticsService analytics;

  Future<SessionSummary> finish({
    required UserProfile profile,
    required SessionMode mode,
    required List<AnsweredExercise> answers,
    required HeartsState hearts,
    required bool completed,
    required Map<String, LessonProgress> progress,
    required List<UserError> existingErrors,
    Lesson? lesson,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final graded = answers.where((a) => !a.skipped).toList();
    final correctAnswers = graded.where((a) => a.correct).toList();
    final wrongAnswers = graded.where((a) => !a.correct).toList();
    final errorsById = {for (final e in existingErrors) e.exerciseId: e};

    final upsertErrors = [
      for (final a in wrongAnswers)
        UserError(
          exerciseId: a.exercise.id,
          lessonId: a.exercise.lessonId,
          correctAnswer: a.exercise.correctAnswer,
          lastAnswer: a.answer,
          count: (errorsById[a.exercise.id]?.count ?? 0) + 1,
          lastErrorAt: at,
        ),
    ];
    final resolvedErrorIds = [
      for (final a in correctAnswers)
        if (errorsById.containsKey(a.exercise.id)) a.exercise.id,
    ];

    if (!completed) {
      await repository.commitSession(
        profile.uid,
        SessionCommit(
          profile: profile.copyWith(hearts: hearts.hearts, heartsUpdatedAt: hearts.anchor),
          upsertErrors: upsertErrors,
          resolvedErrorIds: resolvedErrorIds,
        ),
      );
      analytics.log(AnalyticsEvents.lessonFailed, {'lessonId': lesson?.id, 'correct': correctAnswers.length});
      return SessionSummary(
        completed: false,
        correct: correctAnswers.length,
        total: graded.length,
        xpEarned: 0,
        streak: gamification.effectiveStreak(profile, at),
        streakIncreased: false,
        perfect: false,
        newAchievements: const [],
        heartsRestored: 0,
        wrongCount: wrongAnswers.length,
      );
    }

    final perfect = mode == SessionMode.lesson && graded.isNotEmpty && wrongAnswers.isEmpty;
    final answersXp = correctAnswers.fold<int>(0, (sum, a) => sum + a.exercise.xp);
    final bonusXp = mode == SessionMode.lesson && lesson != null
        ? gamification.lessonBonusXp(lessonXp: lesson.xp, perfect: perfect)
        : gamification.rules.reviewCompletionXp;
    final xpEarned = answersXp + bonusXp;

    final streak = gamification.registerStudy(profile, at);
    final heartsRestored = mode == SessionMode.review ? gamification.rules.reviewHeartReward : 0;
    final finalHearts = gamification.gainHearts(hearts, heartsRestored, at);
    final previous = lesson == null ? null : progress[lesson.id];
    final firstCompletion = mode == SessionMode.lesson && !(previous?.completed ?? false);
    int countOf(ExerciseType type) => correctAnswers.where((a) => a.exercise.type == type).length;

    var updated = profile.copyWith(
      xp: profile.xp + xpEarned,
      currentStreak: streak.current,
      longestStreak: streak.longest,
      lastStudyDay: streak.day,
      hearts: finalHearts.hearts,
      heartsUpdatedAt: finalHearts.anchor,
      lessonsCompleted: profile.lessonsCompleted + (firstCompletion ? 1 : 0),
      perfectLessons: profile.perfectLessons + (perfect ? 1 : 0),
      listenCompleted: profile.listenCompleted + countOf(ExerciseType.listen),
      speakCompleted: profile.speakCompleted + countOf(ExerciseType.speak),
    );
    final unlocked = gamification.newlyUnlocked(updated);
    updated = updated.copyWith(achievements: [...updated.achievements, ...unlocked.map((a) => a.id)]);

    final total = graded.length;
    final accuracy = total == 0 ? 100 : (correctAnswers.length * 100 / total).round();
    final lessonProgress = mode == SessionMode.lesson && lesson != null
        ? LessonProgress(
            lessonId: lesson.id,
            unitId: lesson.unitId,
            courseId: lesson.courseId,
            completed: true,
            bestScore: math.max(previous?.bestScore ?? 0, accuracy),
            attempts: (previous?.attempts ?? 0) + 1,
            completedAt: at,
          )
        : null;

    await repository.commitSession(
      profile.uid,
      SessionCommit(
        profile: updated,
        progress: lessonProgress,
        upsertErrors: upsertErrors,
        resolvedErrorIds: resolvedErrorIds,
      ),
    );

    analytics.log(
      mode == SessionMode.lesson ? AnalyticsEvents.lessonCompleted : AnalyticsEvents.reviewCompleted,
      {'lessonId': lesson?.id, 'accuracy': accuracy, 'xp': xpEarned},
    );
    if (streak.increased) analytics.log(AnalyticsEvents.streakUpdated, {'streak': streak.current});

    return SessionSummary(
      completed: true,
      correct: correctAnswers.length,
      total: total,
      xpEarned: xpEarned,
      streak: streak.current,
      streakIncreased: streak.increased,
      perfect: perfect,
      newAchievements: unlocked,
      heartsRestored: finalHearts.hearts - hearts.hearts,
      wrongCount: wrongAnswers.length,
    );
  }
}
