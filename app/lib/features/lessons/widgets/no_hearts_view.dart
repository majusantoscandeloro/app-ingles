import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/state_views.dart';

class NoHeartsView extends StatelessWidget {
  const NoHeartsView({super.key, required this.timeToNextHeart, required this.onBack, this.onPractice});

  final Duration? timeToNextHeart;
  final VoidCallback onBack;
  final VoidCallback? onPractice;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}h$m' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ResponsiveCenter(
        maxWidth: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Mascot(mood: MascotMood.sad, size: 130),
            const SizedBox(height: 24),
            Text(
              'Seus corações acabaram',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text('❤️ ❤️ ❤️ ❤️ ❤️', style: TextStyle(fontSize: 26, color: AppColors.locked)),
            const SizedBox(height: 12),
            Text(
              timeToNextHeart == null
                  ? 'Seus corações já estão recarregados.'
                  : 'Próximo coração em ${_format(timeToNextHeart!)}.\nPratique seus erros para recuperar agora!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            if (onPractice != null) ...[
              AppButton(label: 'Praticar erros (+1 ❤️)', variant: AppButtonVariant.sky, onPressed: onPractice),
              const SizedBox(height: 12),
            ],
            AppButton(label: 'Voltar para a trilha', variant: AppButtonVariant.outline, onPressed: onBack),
          ],
        ),
      ),
    );
  }
}
