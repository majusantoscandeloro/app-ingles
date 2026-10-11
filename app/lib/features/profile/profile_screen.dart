import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/state_views.dart';
import '../auth/auth_providers.dart';
import '../courses/course_providers.dart';
import '../gamification/achievements.dart';
import '../progress/progress_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    );
    if (confirm == true) await ref.read(authControllerProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final trail = ref.watch(trailProvider).value;
    final gamification = ref.watch(gamificationServiceProvider);
    final isDemo = ref.watch(appConfigProvider).isDemo;
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(userProfileProvider)),
        data: (profile) {
          if (profile == null) return const LoadingView();
          final level = gamification.levelProgress(profile.xp);
          final streak = gamification.effectiveStreak(profile, now);

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (isDemo)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      '🧪 Modo demonstração: os dados ficam salvos apenas neste aparelho.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        profile.name.isEmpty ? '?' : profile.name.characters.first.toUpperCase(),
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                          Text(profile.email, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                          if (profile.createdAt != null)
                            Text(
                              'Desde ${profile.createdAt!.month.toString().padLeft(2, '0')}/${profile.createdAt!.year}',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Nível ${level.level}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: level.progress(profile.xp),
                    minHeight: 14,
                    backgroundColor: AppColors.locked,
                    color: AppColors.xp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.xp} / ${level.nextLevelXp} XP para o nível ${level.level + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Text('Estatísticas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _StatTile(emoji: '🔥', value: '$streak', label: 'Dias de sequência'),
                    _StatTile(emoji: '⭐', value: '${profile.xp}', label: 'XP total'),
                    _StatTile(emoji: '📘', value: '${trail?.completedLessons ?? profile.lessonsCompleted}', label: 'Aulas concluídas'),
                    _StatTile(emoji: '🏆', value: '${trail?.completedUnits ?? 0}', label: 'Unidades concluídas'),
                    _StatTile(emoji: '⚡', value: '${profile.longestStreak}', label: 'Maior sequência'),
                    _StatTile(emoji: '💎', value: '${profile.perfectLessons}', label: 'Aulas perfeitas'),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Conquistas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                for (final a in kAchievements) _AchievementTile(achievement: a, unlocked: profile.achievements.contains(a.id)),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Sair da conta',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _signOut(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.emoji, required this.value, required this.label});
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.unlocked});
  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: unlocked ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: unlocked ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: ListTile(
            leading: Text(unlocked ? achievement.emoji : '🔒', style: const TextStyle(fontSize: 28)),
            title: Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(achievement.description),
          ),
        ),
      );
}
