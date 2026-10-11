class GamificationRules {
  const GamificationRules({
    this.perfectLessonBonusXp = 30,
    this.reviewCompletionXp = 10,
    this.maxHearts = 5,
    this.heartRefillInterval = const Duration(minutes: 30),
    this.reviewHeartReward = 1,
    this.maxSpeakAttempts = 3,
    this.reviewSessionSize = 10,
  });

  /// O bônus por concluir vem de `Lesson.xp`, configurável no painel.
  final int perfectLessonBonusXp;
  final int reviewCompletionXp;
  final int maxHearts;
  final Duration heartRefillInterval;

  /// Corações recuperados ao concluir uma sessão de revisão.
  final int reviewHeartReward;
  final int maxSpeakAttempts;
  final int reviewSessionSize;
}
