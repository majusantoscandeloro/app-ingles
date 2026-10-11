import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/state_views.dart';
import '../lesson_session_controller.dart';
import '../session_completion_service.dart';

class SessionResultView extends StatelessWidget {
  const SessionResultView({
    super.key,
    required this.summary,
    required this.mode,
    required this.onContinue,
    this.onReviewErrors,
    this.completedUnitTitle,
  });

  final SessionSummary summary;
  final SessionMode mode;
  final VoidCallback onContinue;
  final VoidCallback? onReviewErrors;
  final String? completedUnitTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = summary;
    final title = completedUnitTitle != null
        ? 'Unidade concluída!'
        : mode == SessionMode.review
            ? 'Revisão concluída!'
            : s.perfect
                ? 'Aula perfeita!'
                : 'Aula concluída!';

    return SafeArea(
      child: ResponsiveCenter(
        maxWidth: 520,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
                    Mascot(mood: s.accuracy >= 60 ? MascotMood.celebrating : MascotMood.encouraging, size: 140),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.warningDark,
                      ),
                    ),
                    if (completedUnitTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(completedUnitTitle!, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${s.correct} / ${s.total} corretas',
                      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'XP TOTAL', value: '+${s.xpEarned}', color: AppColors.xp, icon: '⭐')),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'PRECISÃO', value: '${s.accuracy}%', color: AppColors.success, icon: '🎯')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: s.streakIncreased ? 'SEQUÊNCIA ↑' : 'SEQUÊNCIA',
                            value: '${s.streak} ${s.streak == 1 ? 'dia' : 'dias'}',
                            color: AppColors.streak,
                            icon: '🔥',
                          ),
                        ),
                      ],
                    ),
                    if (s.heartsRestored > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        '❤️ +${s.heartsRestored} coração recuperado',
                        style: theme.textTheme.titleMedium?.copyWith(color: AppColors.heart, fontWeight: FontWeight.w800),
                      ),
                    ],
                    if (s.newAchievements.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text('Nova conquista!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      for (final a in s.newAchievements)
                        Card(
                          elevation: 0,
                          color: AppColors.primaryLight,
                          child: ListTile(
                            leading: Text(a.emoji, style: const TextStyle(fontSize: 30)),
                            title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text(a.description),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  AppButton(label: 'Continuar', onPressed: onContinue),
                  if (onReviewErrors != null) ...[
                    const SizedBox(height: 12),
                    AppButton(label: 'Revisar erros', variant: AppButtonVariant.outline, onPressed: onReviewErrors),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final String value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$icon $value',
                  style: TextStyle(color: AppColors.darken(color, 0.1), fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      );
}
