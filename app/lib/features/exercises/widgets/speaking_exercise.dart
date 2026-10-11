import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/exercise.dart';
import 'exercise_common.dart';

class SpeakingExercise extends ConsumerStatefulWidget {
  const SpeakingExercise({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onChanged,
    required this.onSkip,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  /// "Não posso falar agora" — também usado quando o reconhecimento não está disponível.
  final VoidCallback onSkip;

  @override
  ConsumerState<SpeakingExercise> createState() => _SpeakingExerciseState();
}

class _SpeakingExerciseState extends ConsumerState<SpeakingExercise> {
  late final SpeechService _speech;
  String _transcript = '';
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    _speech = ref.read(speechServiceProvider);
  }

  @override
  void dispose() {
    if (_speech.isListening.value) _speech.cancel();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (widget.locked) return;
    if (_speech.isListening.value) {
      await _speech.stop();
      return;
    }
    await ref.read(ttsServiceProvider).stop();
    final ok = await _speech.ensureInitialized();
    if (!mounted) return;
    if (!ok) {
      setState(() => _unavailable = true);
      return;
    }
    setState(() => _transcript = '');
    widget.onChanged(null);
    ref.read(analyticsProvider).log(AnalyticsEvents.speakingStarted, {'exerciseId': widget.exercise.id});
    await _speech.listen(onResult: (words, isFinal) {
      if (!mounted) return;
      setState(() => _transcript = words);
      widget.onChanged(words.isEmpty ? null : words);
      if (isFinal) {
        ref.read(analyticsProvider).log(AnalyticsEvents.speakingCompleted, {'exerciseId': widget.exercise.id});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SpeakerButtons(text: e.speechText, large: false, showSlow: false),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                e.question.isNotEmpty ? e.question : e.correctAnswer,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: _speech.isListening,
            builder: (context, listening, _) => _MicButton(
              listening: listening,
              enabled: !widget.locked && !_unavailable,
              onTap: _toggleMic,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: _speech.isListening,
          builder: (context, listening, _) => Text(
            _unavailable
                ? 'Reconhecimento de voz indisponível neste aparelho.'
                : listening
                    ? 'Ouvindo... fale agora'
                    : _transcript.isEmpty
                        ? 'Toque no microfone e fale a frase'
                        : 'Toque novamente para regravar',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        if (_transcript.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
            child: Text(
              '“$_transcript”',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(height: 12),
        if (!widget.locked)
          TextButton(
            onPressed: widget.onSkip,
            child: const Text(
              'NÃO POSSO FALAR AGORA',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.6),
            ),
          ),
      ],
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.listening, required this.enabled, required this.onTap});

  final bool listening;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled ? AppColors.locked : (listening ? AppColors.error : AppColors.sky);
    return Semantics(
      button: true,
      label: listening ? 'Parar gravação' : 'Iniciar gravação',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: listening ? 120 : 108,
          height: listening ? 120 : 108,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              if (listening) BoxShadow(color: AppColors.error.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 8),
              BoxShadow(color: AppColors.darken(color, 0.12), offset: const Offset(0, 5)),
            ],
          ),
          child: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 52),
        ),
      ),
    );
  }
}
