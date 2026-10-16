import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/exercise.dart';
import 'exercise_common.dart';

/// A resposta certa costuma vir primeiro no conteúdo. A ordem na tela é
/// embaralhada com semente fixa, então não muda no meio do exercício.
List<ExerciseOption> stableOptionOrder(Exercise exercise) {
  final options = [...exercise.options];
  if (options.length > 1) options.shuffle(math.Random(exercise.id.hashCode));
  return options;
}

class _OptionList extends StatelessWidget {
  const _OptionList({required this.options, required this.selected, required this.locked, required this.onSelect});

  final List<ExerciseOption> options;
  final String? selected;
  final bool locked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, option) in options.indexed) ...[
            ChoiceTile(
              selected: selected == option.text,
              onTap: locked ? null : () => onSelect(option.text),
              child: Row(
                children: [
                  _IndexBadge(index: i + 1, selected: selected == option.text),
                  const SizedBox(width: 12),
                  if (option.emoji != null) ...[Text(option.emoji!, style: const TextStyle(fontSize: 22)), const SizedBox(width: 8)],
                  Expanded(child: Text(option.text)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
}

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({required this.index, required this.selected});
  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 2),
        ),
        child: Text(
          '$index',
          style: TextStyle(fontSize: 14, color: selected ? AppColors.primary : AppColors.textSecondary),
        ),
      );
}

/// Base com estado de seleção para exercícios de escolha.
abstract class _ChoiceState<T extends StatefulWidget> extends State<T> {
  String? selected;

  void select(String value, AnswerChanged onChanged) {
    setState(() => selected = value);
    onChanged(value);
  }
}

class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends _ChoiceState<MultipleChoiceExercise> {
  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (e.audioText != null) ...[
              SpeakerButtons(text: e.audioText!, large: false, showSlow: false),
              const SizedBox(width: 12),
            ],
            Expanded(child: QuestionText(e.question)),
          ],
        ),
        const SizedBox(height: 24),
        _OptionList(
          options: stableOptionOrder(e),
          selected: selected,
          locked: widget.locked,
          onSelect: (v) => select(v, widget.onChanged),
        ),
      ],
    );
  }
}

class FillBlankExercise extends StatefulWidget {
  const FillBlankExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  State<FillBlankExercise> createState() => _FillBlankExerciseState();
}

class _FillBlankExerciseState extends _ChoiceState<FillBlankExercise> {
  @override
  Widget build(BuildContext context) {
    final parts = widget.exercise.question.split(RegExp(r'_{2,}'));
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (parts[i].isNotEmpty) Text(parts[i], style: style),
              if (i < parts.length - 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  constraints: const BoxConstraints(minWidth: 70),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.primary, width: 3)),
                  ),
                  child: Text(selected ?? ' ', textAlign: TextAlign.center, style: style?.copyWith(color: AppColors.primary)),
                ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final option in stableOptionOrder(widget.exercise))
              ChoiceTile(
                selected: selected == option.text,
                onTap: widget.locked ? null : () => select(option.text, widget.onChanged),
                child: Text(option.text),
              ),
          ],
        ),
      ],
    );
  }
}

class ImageSelectionExercise extends StatefulWidget {
  const ImageSelectionExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  State<ImageSelectionExercise> createState() => _ImageSelectionExerciseState();
}

class _ImageSelectionExerciseState extends _ChoiceState<ImageSelectionExercise> {
  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionText(e.question),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 500 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final option in stableOptionOrder(e))
                  ChoiceTile(
                    selected: selected == option.text,
                    onTap: widget.locked ? null : () => select(option.text, widget.onChanged),
                    padding: const EdgeInsets.all(8),
                    child: Semantics(label: option.text, child: Center(child: _OptionImage(option))),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OptionImage extends StatelessWidget {
  const _OptionImage(this.option);
  final ExerciseOption option;

  @override
  Widget build(BuildContext context) {
    if (option.imageUrl != null) {
      return Image.network(
        option.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(option.emoji ?? '🖼️', style: const TextStyle(fontSize: 56)),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return FittedBox(child: Text(option.emoji ?? option.text, style: const TextStyle(fontSize: 64)));
  }
}

class ListeningExercise extends ConsumerStatefulWidget {
  const ListeningExercise({super.key, required this.exercise, required this.locked, required this.onChanged});

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;

  @override
  ConsumerState<ListeningExercise> createState() => _ListeningExerciseState();
}

class _ListeningExerciseState extends ConsumerState<ListeningExercise> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(ttsServiceProvider).speak(widget.exercise.speechText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (e.question.isNotEmpty) ...[QuestionText(e.question), const SizedBox(height: 20)],
        Center(child: SpeakerButtons(text: e.speechText)),
        const SizedBox(height: 28),
        if (e.options.isNotEmpty)
          _OptionList(
            options: stableOptionOrder(e),
            selected: _selected,
            locked: widget.locked,
            onSelect: (v) {
              setState(() => _selected = v);
              widget.onChanged(v);
            },
          )
        else
          AnswerTextField(
            enabled: !widget.locked,
            hint: 'Digite em inglês o que você ouviu',
            onChanged: (v) => widget.onChanged(v),
          ),
      ],
    );
  }
}
