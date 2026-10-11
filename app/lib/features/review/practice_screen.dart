import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/mascot.dart';
import '../../shared/widgets/state_views.dart';
import '../progress/progress_providers.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(userErrorsProvider);
    final sessionSize = ref.watch(gamificationServiceProvider).rules.reviewSessionSize;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Praticar')),
      body: errors.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(userErrorsProvider)),
        data: (errors) {
          if (errors.isEmpty) {
            return const MessageView(
              title: 'Nenhum erro para revisar!',
              message: 'Quando você errar um exercício, ele aparecerá aqui para praticar.',
              mood: MascotMood.happy,
            );
          }
          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Mascot(mood: MascotMood.encouraging, size: 80),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${errors.length} ${errors.length == 1 ? 'exercício' : 'exercícios'} para revisar',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            const Text('Revisar recupera ❤️ e conta para sua sequência.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: errors.length > sessionSize ? 'Revisar $sessionSize agora' : 'Começar revisão',
                  variant: AppButtonVariant.sky,
                  onPressed: () => context.push('/review'),
                ),
                const SizedBox(height: 24),
                Text('Seus erros recentes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final e in errors)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border, width: 2),
                    ),
                    child: ListTile(
                      title: Text(e.correctAnswer, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: e.lastAnswer == null || e.lastAnswer!.isEmpty
                          ? null
                          : Text('Você respondeu: ${e.lastAnswer}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        '${e.count}×',
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
