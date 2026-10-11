import 'dart:math' as math;

import '../../core/constants/gamification_rules.dart';
import '../../core/utils/day_key.dart';
import '../../shared/models/user_profile.dart';
import 'achievements.dart';

class HeartsState {
  const HeartsState({required this.hearts, required this.anchor});

  final int hearts;

  /// Momento a partir do qual a próxima recarga é contada.
  final DateTime anchor;
}

class LevelProgress {
  const LevelProgress({required this.level, required this.currentLevelXp, required this.nextLevelXp});

  final int level;
  final int currentLevelXp;
  final int nextLevelXp;

  double progress(int xp) =>
      ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp)).clamp(0.0, 1.0).toDouble();
}

class StreakUpdate {
  const StreakUpdate({required this.current, required this.longest, required this.day, required this.increased});

  final int current;
  final int longest;
  final String day;
  final bool increased;
}

/// Regras puras de XP, nível, streak, corações e conquistas (sem I/O).
class GamificationService {
  const GamificationService([this.rules = const GamificationRules()]);

  final GamificationRules rules;

  // ---------- Corações ----------

  HeartsState heartsAt(UserProfile profile, DateTime now) {
    final anchor = profile.heartsUpdatedAt ?? now;
    if (profile.hearts >= rules.maxHearts) return HeartsState(hearts: rules.maxHearts, anchor: now);

    final elapsed = now.difference(anchor);
    final refilled = elapsed.isNegative ? 0 : elapsed.inSeconds ~/ rules.heartRefillInterval.inSeconds;
    final hearts = math.min(rules.maxHearts, profile.hearts + refilled);
    if (hearts >= rules.maxHearts) return HeartsState(hearts: rules.maxHearts, anchor: now);
    return HeartsState(hearts: hearts, anchor: anchor.add(rules.heartRefillInterval * refilled));
  }

  HeartsState loseHeart(HeartsState state, DateTime now) {
    if (state.hearts <= 0) return state;
    final anchor = state.hearts >= rules.maxHearts ? now : state.anchor;
    return HeartsState(hearts: state.hearts - 1, anchor: anchor);
  }

  HeartsState gainHearts(HeartsState state, int amount, DateTime now) {
    final hearts = math.min(rules.maxHearts, state.hearts + amount);
    return HeartsState(hearts: hearts, anchor: hearts >= rules.maxHearts ? now : state.anchor);
  }

  Duration? timeToNextHeart(HeartsState state, DateTime now) {
    if (state.hearts >= rules.maxHearts) return null;
    final next = state.anchor.add(rules.heartRefillInterval).difference(now);
    return next.isNegative ? Duration.zero : next;
  }

  // ---------- Streak ----------

  /// Streak exibida: zera se o aluno não estudou hoje nem ontem.
  int effectiveStreak(UserProfile profile, DateTime now) {
    final last = profile.lastStudyDay;
    if (last == null) return 0;
    if (last == dayKey(now) || last == yesterdayKey(now)) return profile.currentStreak;
    return 0;
  }

  bool studiedToday(UserProfile profile, DateTime now) => profile.lastStudyDay == dayKey(now);

  StreakUpdate registerStudy(UserProfile profile, DateTime now) {
    final today = dayKey(now);
    if (profile.lastStudyDay == today) {
      return StreakUpdate(
        current: profile.currentStreak,
        longest: math.max(profile.longestStreak, profile.currentStreak),
        day: today,
        increased: false,
      );
    }
    final current = profile.lastStudyDay == yesterdayKey(now) ? profile.currentStreak + 1 : 1;
    return StreakUpdate(
      current: current,
      longest: math.max(profile.longestStreak, current),
      day: today,
      increased: true,
    );
  }

  // ---------- XP e nível ----------

  /// Nível n exige 50·(n−1)² XP: 0, 50, 200, 450, 800...
  int xpForLevel(int level) => 50 * (level - 1) * (level - 1);

  LevelProgress levelProgress(int xp) {
    final level = math.sqrt(math.max(0, xp) / 50).floor() + 1;
    return LevelProgress(level: level, currentLevelXp: xpForLevel(level), nextLevelXp: xpForLevel(level + 1));
  }

  int lessonBonusXp({required int lessonXp, required bool perfect}) =>
      lessonXp + (perfect ? rules.perfectLessonBonusXp : 0);

  // ---------- Conquistas ----------

  List<Achievement> newlyUnlocked(UserProfile updated) => kAchievements
      .where((a) => !updated.achievements.contains(a.id) && a.isUnlocked(updated))
      .toList();
}
