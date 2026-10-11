import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/mascot.dart';
import '../../shared/widgets/state_views.dart';
import '../courses/course_providers.dart';
import 'widgets/top_stats_bar.dart';
import 'widgets/trail_widgets.dart';

/// Tela inicial: trilha de aprendizado.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trail = ref.watch(trailProvider);

    return Scaffold(
      body: SafeArea(
        child: trail.when(
          loading: () => const LoadingView(message: 'Carregando sua trilha...'),
          error: (error, _) => ErrorView(
            message: 'Não foi possível carregar o curso.',
            onRetry: () => ref.invalidate(courseContentProvider),
          ),
          data: (trail) {
            if (trail == null || trail.units.isEmpty) {
              return const MessageView(
                title: 'Nenhum curso disponível',
                message: 'Assim que o conteúdo for publicado, ele aparecerá aqui.',
                mood: MascotMood.thinking,
              );
            }
            return Column(
              children: [
                TopStatsBar(courseTitle: trail.course.title),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(courseContentProvider),
                    child: _TrailList(trail: trail),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrailList extends StatelessWidget {
  const _TrailList({required this.trail});
  final Trail trail;

  /// Deslocamento horizontal em zigue-zague (fração da amplitude).
  static const _pattern = [0.0, 0.5, 1.0, 0.5, 0.0, -0.5, -1.0, -0.5];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        for (final unit in trail.units) ...[
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: 560,
              child: UnitHeader(unit: unit, color: AppColors.unitColor(unit.number - 1)),
            ),
          ),
          SliverList.builder(
            itemCount: unit.lessons.length,
            itemBuilder: (context, i) {
              final item = unit.lessons[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(_pattern[i % _pattern.length] * 70, 0),
                    child: LessonNode(
                      item: item,
                      color: AppColors.unitColor(unit.number - 1),
                      onTap: () => _onLessonTap(context, item, AppColors.unitColor(unit.number - 1)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _onLessonTap(BuildContext context, TrailLesson item, Color color) {
    if (!item.isPlayable) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Complete a lição anterior para desbloquear esta. 🔒')));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _LessonSheet(item: item, color: color),
    );
  }
}

class _LessonSheet extends StatelessWidget {
  const _LessonSheet({required this.item, required this.color});

  final TrailLesson item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = item.status == LessonStatus.completed;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.lesson.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            if (item.lesson.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.lesson.description, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            ],
            if (completed && item.progress != null) ...[
              const SizedBox(height: 10),
              Text(
                '✅ Concluída • Melhor precisão: ${item.progress!.bestScore}%',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.successDark),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: completed ? 'Praticar de novo' : 'Começar +${item.lesson.xp} XP',
              variant: completed ? AppButtonVariant.outline : AppButtonVariant.primary,
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.pop(context);
                router.push('/lesson/${item.lesson.id}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
