import 'package:flutter/foundation.dart';

import '../../core/constants/gamification_rules.dart';
import '../../shared/models/exercise.dart';
import '../exercises/answer_checker.dart';
import '../gamification/gamification_service.dart';

enum SessionMode { lesson, review }

/// Estados do exercício (seção 41): `answering` → `correct`/`incorrect`.
/// `retry` é o "Quase!" da fala, que permite nova tentativa sem perder coração.
enum CheckState { answering, correct, incorrect, retry }

enum SessionPhase { playing, completed, outOfHearts }

class AnsweredExercise {
  const AnsweredExercise({required this.exercise, required this.correct, this.answer, this.skipped = false});

  final Exercise exercise;
  final bool correct;
  final String? answer;
  final bool skipped;
}

class LessonSessionController extends ChangeNotifier {
  LessonSessionController({
    required List<Exercise> exercises,
    required this.mode,
    required HeartsState hearts,
    required this.checker,
    required this.gamification,
    this.onHeartLost,
    this.onAnswered,
  })  : exercises = exercises.where((e) => e.type != ExerciseType.unknown).toList(),
        _hearts = hearts;

  final List<Exercise> exercises;
  final SessionMode mode;
  final AnswerChecker checker;
  final GamificationService gamification;
  final void Function(HeartsState hearts)? onHeartLost;
  final void Function(Exercise exercise, bool correct)? onAnswered;

  GamificationRules get rules => gamification.rules;

  HeartsState _hearts;
  HeartsState get hearts => _hearts;
  bool get usesHearts => mode == SessionMode.lesson;

  int _index = 0;
  int get index => _index;
  Exercise get current => exercises[_index];
  bool get isEmpty => exercises.isEmpty;

  String? _answer;
  String? get answer => _answer;
  bool get canCheck => state == CheckState.answering && (_answer?.trim().isNotEmpty ?? false);

  CheckState _state = CheckState.answering;
  CheckState get state => _state;

  AnswerResult? _result;
  AnswerResult? get result => _result;

  /// Tentativas no exercício atual (usado na fala e como chave do widget).
  int _attempt = 0;
  int get attempt => _attempt;

  SessionPhase _phase = SessionPhase.playing;
  SessionPhase get phase => _phase;

  final List<AnsweredExercise> _answers = [];
  List<AnsweredExercise> get answers => List.unmodifiable(_answers);

  double get progress => exercises.isEmpty ? 0 : _answers.length / exercises.length;

  void setAnswer(String? value) {
    if (_state != CheckState.answering) return;
    _answer = value;
    notifyListeners();
  }

  void check() {
    if (!canCheck) return;
    final exercise = current;
    final result = checker.check(exercise, _answer!);
    _result = result;

    if (result.verdict == AnswerVerdict.almost && _attempt + 1 < rules.maxSpeakAttempts) {
      _state = CheckState.retry;
      notifyListeners();
      return;
    }

    // Na última tentativa de fala, "quase" é aceito: o STT nativo erra com frequência.
    final correct = result.verdict != AnswerVerdict.incorrect;
    _answers.add(AnsweredExercise(exercise: exercise, correct: correct, answer: _answer));
    _state = correct ? CheckState.correct : CheckState.incorrect;

    if (!correct && usesHearts) {
      _hearts = gamification.loseHeart(_hearts, DateTime.now());
      onHeartLost?.call(_hearts);
    }
    onAnswered?.call(exercise, correct);
    notifyListeners();
  }

  void retry() {
    if (_state != CheckState.retry) return;
    _attempt++;
    _answer = null;
    _result = null;
    _state = CheckState.answering;
    notifyListeners();
  }

  /// "Não posso falar agora": pula sem contar acerto nem erro.
  void skipCurrent() {
    if (_state != CheckState.answering) return;
    _answers.add(AnsweredExercise(exercise: current, correct: false, skipped: true));
    _advance();
  }

  void next() {
    if (_state != CheckState.correct && _state != CheckState.incorrect) return;
    if (usesHearts && _hearts.hearts <= 0) {
      _phase = SessionPhase.outOfHearts;
      notifyListeners();
      return;
    }
    _advance();
  }

  void _advance() {
    if (_index >= exercises.length - 1) {
      _phase = SessionPhase.completed;
    } else {
      _index++;
      _attempt = 0;
      _answer = null;
      _result = null;
      _state = CheckState.answering;
    }
    notifyListeners();
  }
}
