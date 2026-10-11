import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_badge.dart';
import '../../progress/progress_providers.dart';

class TopStatsBar extends ConsumerWidget {
  const TopStatsBar({super.key, required this.courseTitle});
  final String courseTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final gamification = ref.watch(gamificationServiceProvider);

    final streak = profile == null ? 0 : gamification.effectiveStreak(profile, now);
    final studiedToday = profile != null && gamification.studiedToday(profile, now);
    final hearts = profile == null ? gamification.rules.maxHearts : gamification.heartsAt(profile, now).hearts;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 2)),
      ),
      child: Row(
        children: [
          const Text('🇺🇸', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              courseTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          StatBadge(
            emoji: '🔥',
            value: '$streak',
            color: studiedToday ? AppColors.streak : AppColors.lockedDark,
            tooltip: studiedToday ? 'Sequência de $streak dias' : 'Faça uma lição hoje para manter a sequência',
          ),
          const SizedBox(width: 14),
          StatBadge(emoji: '⭐', value: '${profile?.xp ?? 0}', color: AppColors.warningDark, tooltip: 'XP total'),
          const SizedBox(width: 14),
          StatBadge(emoji: '❤️', value: '$hearts', color: AppColors.heart, tooltip: 'Corações'),
        ],
      ),
    );
  }
}
