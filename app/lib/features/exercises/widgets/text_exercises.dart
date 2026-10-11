import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/mascot.dart';
import 'exercise_common.dart';

class _PromptBubble extends StatelessWidget {
  const _PromptBubble(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Mascot(size: 72, mood: MascotMood.thinking),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
}

class TranslationExercise extends StatelessWidget {
  const TranslationExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PromptBubble(exercise.question),
          const SizedBox(height: 24),
          AnswerTextField(enabled: !locked, hint: 'Escreva em inglês', onChanged: onChanged),
        ],
      );
}

class WordOrderExercise extends StatefulWidget {
  const WordOrderExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  State<WordOrderExercise> createState() => _WordOrderExerciseState();
}

class _WordOrderExerciseState extends State<WordOrderExercise> {
  late final List<String> _bank;

  /// Índices do banco escolhidos, na ordem em que o aluno montou a frase.
  final List<int> _picked = [];

  @override
  void initState() {
    super.initState();
    final source = widget.exercise.words.isNotEmpty
        ? widget.exercise.words
        : widget.exercise.correctAnswer.replaceAll(RegExp(r'[.!?]'), '').split(RegExp(r'\s+'));
    _bank = [...source]..shuffle(math.Random(widget.exercise.id.hashCode));
  }

  void _toggle(int bankIndex) {
    if (widget.locked) return;
    setState(() => _picked.contains(bankIndex) ? _picked.remove(bankIndex) : _picked.add(bankIndex));
    widget.onChanged(_picked.isEmpty ? null : _picked.map((i) => _bank[i]).join(' '));
  }

  Widget _chip(String word, {required VoidCallback? onTap, bool placeholder = false}) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: placeholder ? AppColors.locked : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: placeholder ? AppColors.locked : AppColors.border, width: 2),
              left: BorderSide(color: placeholder ? AppColors.locked : AppColors.border, width: 2),
              right: BorderSide(color: placeholder ? AppColors.locked : AppColors.border, width: 2),
              bottom: BorderSide(color: placeholder ? AppColors.locked : AppColors.border, width: 4),
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: placeholder ? Colors.transparent : AppColors.textPrimary,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PromptBubble(widget.exercise.question),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(minHeight: 110),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: AppColors.border, width: 2)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final i in _picked) _chip(_bank[i], onTap: () => _toggle(i))],
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < _bank.length; i++)
                _picked.contains(i)
                    ? _chip(_bank[i], onTap: null, placeholder: true)
                    : _chip(_bank[i], onTap: () => _toggle(i)),
            ],
          ),
        ],
      );
}
