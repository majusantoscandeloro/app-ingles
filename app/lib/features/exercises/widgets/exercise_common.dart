import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

/// Contrato comum dos widgets de exercício: reportam a resposta atual
/// (ou `null`) e ficam somente-leitura quando [locked] (após verificar).
typedef AnswerChanged = void Function(String? answer);

class QuestionText extends StatelessWidget {
  const QuestionText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.3),
      );
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppColors.primary : AppColors.border;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              top: BorderSide(color: border, width: 2),
              left: BorderSide(color: border, width: 2),
              right: BorderSide(color: border, width: 2),
              bottom: BorderSide(color: border, width: 5),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primaryDark : AppColors.textPrimary,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Botão de áudio (TTS) com opção de velocidade lenta.
class SpeakerButtons extends ConsumerWidget {
  const SpeakerButtons({super.key, required this.text, this.large = true, this.showSlow = true});

  final String text;
  final bool large;
  final bool showSlow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.read(ttsServiceProvider);
    final size = large ? 84.0 : 48.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundAudioButton(
          size: size,
          tooltip: 'Ouvir',
          onTap: () => tts.speak(text),
          child: Icon(Icons.volume_up_rounded, color: Colors.white, size: size * 0.5),
        ),
        if (showSlow) ...[
          const SizedBox(width: 12),
          _RoundAudioButton(
            size: size * 0.7,
            tooltip: 'Ouvir devagar',
            onTap: () => tts.speak(text, slow: true),
            child: Text('🐢', style: TextStyle(fontSize: size * 0.32)),
          ),
        ],
      ],
    );
  }
}

class _RoundAudioButton extends StatelessWidget {
  const _RoundAudioButton({required this.size, required this.child, required this.tooltip, required this.onTap});

  final double size;
  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.sky,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: AppColors.skyDark, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: SizedBox(width: size, height: size, child: Center(child: child)),
          ),
        ),
      );
}

class AnswerTextField extends StatelessWidget {
  const AnswerTextField({super.key, required this.enabled, required this.onChanged, required this.hint});

  final bool enabled;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) => TextField(
        readOnly: !enabled,
        onChanged: onChanged,
        minLines: 3,
        maxLines: 5,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(hintText: hint),
      );
}
