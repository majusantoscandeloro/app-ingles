import 'package:flutter/material.dart';

import '../../shared/models/exercise.dart';
import 'widgets/choice_exercises.dart';
import 'widgets/exercise_common.dart';
import 'widgets/speaking_exercise.dart';
import 'widgets/text_exercises.dart';

/// Ponto único que decide qual componente renderizar a partir de `exercise.type`.
/// Para um novo tipo: adicione-o em [ExerciseType] e um `case` aqui.
class ExerciseRenderer extends StatelessWidget {
  const ExerciseRenderer({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onChanged,
    required this.onSkip,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerChanged onChanged;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => switch (exercise.type) {
        ExerciseType.multipleChoice => MultipleChoiceExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.fillBlank => FillBlankExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.imageSelection => ImageSelectionExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.listen => ListeningExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.translation => TranslationExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.wordOrder => WordOrderExercise(exercise: exercise, locked: locked, onChanged: onChanged),
        ExerciseType.speak => SpeakingExercise(exercise: exercise, locked: locked, onChanged: onChanged, onSkip: onSkip),
        ExerciseType.unknown => const SizedBox.shrink(),
      };
}
