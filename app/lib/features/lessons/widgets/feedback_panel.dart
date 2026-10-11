import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../exercises/answer_checker.dart';
import '../lesson_session_controller.dart';

const _praises = ['Muito bem!', 'Excelente!', 'Perfeito!', 'Mandou bem!', 'Isso aí!'];

/// Rodapé da lição: botão "Verificar" ou painel de feedback com "Continuar".
class LessonBottomBar extends StatelessWidget {
  const LessonBottomBar({super.key, required this.controller});
  final LessonSessionController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final result = c.result;
    final theme = Theme.of(context);

    Widget panel({
      required Color bg,
      required Color fg,
      required IconData icon,
      required String title,
      String? subtitle,
      String? detail,
      required AppButton button,
    }) =>
        Container(
          width: double.infinity,
          color: bg,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(icon, color: fg, size: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle, style: theme.textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w800)),
                ],
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(detail, style: theme.textTheme.bodyMedium?.copyWith(color: fg)),
                ],
                const SizedBox(height: 16),
                button,
              ],
            ),
          ),
        );

    switch (c.state) {
      case CheckState.answering:
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border, width: 2))),
          child: SafeArea(
            top: false,
            child: AppButton(label: 'Verificar', variant: AppButtonVariant.success, onPressed: c.canCheck ? c.check : null),
          ),
        );
      case CheckState.retry:
        return panel(
          bg: AppColors.warningBg,
          fg: AppColors.warningDark,
          icon: Icons.hearing_rounded,
          title: 'Quase! Tente novamente.',
          subtitle: c.answer == null ? null : 'Entendi: “${c.answer}”',
          detail: 'Fale devagar e com clareza.',
          button: AppButton(label: 'Tentar novamente', variant: AppButtonVariant.warning, onPressed: c.retry),
        );
      case CheckState.correct:
        final praise = _praises[(c.index + c.answers.length) % _praises.length];
        final almost = result?.verdict == AnswerVerdict.almost;
        return panel(
          bg: AppColors.successBg,
          fg: AppColors.successDark,
          icon: Icons.check_rounded,
          title: almost ? 'Quase lá! Vamos considerar.' : praise,
          subtitle: (result?.hasTypo ?? false) || almost ? 'Resposta: ${result!.correctAnswer}' : null,
          detail: (result?.hasTypo ?? false) ? 'Atenção à digitação.' : c.current.explanation,
          button: AppButton(label: 'Continuar', variant: AppButtonVariant.success, onPressed: c.next),
        );
      case CheckState.incorrect:
        return panel(
          bg: AppColors.errorBg,
          fg: AppColors.errorDark,
          icon: Icons.close_rounded,
          title: 'Resposta correta:',
          subtitle: result?.correctAnswer ?? c.current.correctAnswer,
          detail: c.current.explanation,
          button: AppButton(label: 'Continuar', variant: AppButtonVariant.danger, onPressed: c.next),
        );
    }
  }
}
