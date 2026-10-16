import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/sound_effects.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/course.dart';
import '../../shared/models/exercise.dart';
import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/widgets/state_views.dart';
import '../courses/course_providers.dart';
import '../exercises/exercise_renderer.dart';
import '../gamification/gamification_service.dart';
import 'lesson_session_controller.dart';
import 'session_completion_service.dart';
import 'widgets/feedback_panel.dart';
import 'widgets/no_hearts_view.dart';
import 'widgets/session_result_view.dart';

class _SessionSetup {
  const _SessionSetup({
    required this.exercises,
    required this.profile,
    required this.hearts,
    required this.hasErrors,
    this.lesson,
    this.content,
  });

  final List<Exercise> exercises;
  final UserProfile profile;
  final HeartsState hearts;
  final bool hasErrors;
  final Lesson? lesson;
  final CourseContent? content;
}

/// Dados frescos do aluno, lidos direto do repositório.
class _UserSnapshot {
  const _UserSnapshot(this.profile, this.progress, this.errors);
  final UserProfile? profile;
  final Map<String, LessonProgress> progress;
  final List<UserError> errors;
}

class _LoadFailure implements Exception {
  const _LoadFailure(this.message);
  final String message;
}

/// Executa uma lição (`lessonId`) ou uma sessão de revisão de erros (`lessonId == null`).
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen.lesson({super.key, required String this.lessonId}) : mode = SessionMode.lesson;
  const LessonScreen.review({super.key})
      : lessonId = null,
        mode = SessionMode.review;

  final String? lessonId;
  final SessionMode mode;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late Future<_SessionSetup> _setup;
  LessonSessionController? _controller;
  _SessionSetup? _data;

  SessionSummary? _summary;
  bool _saving = false;
  Object? _saveError;
  String? _completedUnitTitle;
  CheckState? _lastFeedback;
  bool _playedLose = false;

  @override
  void initState() {
    super.initState();
    _setup = _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Lê direto do repositório em vez de `provider.future`: o Riverpod 3 pausa
  /// providers de telas encobertas e o `future` pode nunca resolver.
  Future<_UserSnapshot> _readUser(String uid) async {
    final repo = ref.read(userDataRepositoryProvider);
    final results = await Future.wait<Object?>([
      repo.watchProfile(uid).first,
      repo.watchProgress(uid).first,
      repo.watchErrors(uid).first,
    ]).timeout(const Duration(seconds: 20));
    return _UserSnapshot(
      results[0] as UserProfile?,
      results[1] as Map<String, LessonProgress>,
      results[2] as List<UserError>,
    );
  }

  Future<_SessionSetup> _load() async {
    final uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) throw const _LoadFailure('Sessão expirada. Entre novamente.');
    final contentRepo = ref.read(contentRepositoryProvider);
    final gamification = ref.read(gamificationServiceProvider);

    final user = await _readUser(uid);
    final profile = user.profile;
    if (profile == null) throw const _LoadFailure('Perfil não encontrado. Entre novamente.');
    final hearts = gamification.heartsAt(profile, DateTime.now());
    final errors = [...user.errors]
      ..sort((a, b) => (b.lastErrorAt ?? DateTime(0)).compareTo(a.lastErrorAt ?? DateTime(0)));

    if (widget.mode == SessionMode.review) {
      final ids = errors.take(gamification.rules.reviewSessionSize).map((e) => e.exerciseId).toList();
      final exercises = ids.isEmpty ? <Exercise>[] : await contentRepo.getExercisesByIds(ids);
      return _SessionSetup(exercises: exercises..shuffle(), profile: profile, hearts: hearts, hasErrors: errors.isNotEmpty);
    }

    final content = await loadCourseContent(contentRepo);
    final trailLesson = content == null ? null : buildTrail(content, user.progress).find(widget.lessonId!);
    if (trailLesson == null) throw const _LoadFailure('Lição não encontrada.');
    if (!trailLesson.isPlayable) throw const _LoadFailure('Complete a lição anterior para desbloquear esta.');
    final exercises = await contentRepo.getExercises(widget.lessonId!);
    return _SessionSetup(
      exercises: exercises,
      profile: profile,
      hearts: hearts,
      hasErrors: errors.isNotEmpty,
      lesson: trailLesson.lesson,
      content: content,
    );
  }

  LessonSessionController _createController(_SessionSetup data) {
    final uid = data.profile.uid;
    final analytics = ref.read(analyticsProvider);
    final repo = ref.read(userDataRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);

    analytics.log(AnalyticsEvents.lessonStarted, {'lessonId': data.lesson?.id, 'mode': widget.mode.name});

    final controller = LessonSessionController(
      exercises: data.exercises,
      mode: widget.mode,
      hearts: data.hearts,
      checker: ref.read(answerCheckerProvider),
      gamification: ref.read(gamificationServiceProvider),
      onHeartLost: (h) => repo.updateHearts(uid, hearts: h.hearts, anchor: h.anchor),
      onAnswered: (exercise, correct) {
        ref.read(soundEffectsProvider).play(correct ? SoundEffect.correct : SoundEffect.wrong);
        correct ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
        analytics.log(
          correct ? AnalyticsEvents.exerciseCorrect : AnalyticsEvents.exerciseWrong,
          {'exerciseId': exercise.id, 'type': exercise.type.value},
        );
        final spoken = switch (exercise.type) {
          ExerciseType.translation || ExerciseType.wordOrder => exercise.correctAnswer,
          ExerciseType.fillBlank => exercise.question.replaceFirst(RegExp(r'_{2,}'), exercise.correctAnswer),
          _ => null,
        };
        if (spoken != null) tts.speak(spoken);
      },
    );
    controller.addListener(() {
      if (controller.state == CheckState.retry && _lastFeedback != CheckState.retry) {
        ref.read(soundEffectsProvider).play(SoundEffect.almost);
      }
      _lastFeedback = controller.state;
      if (controller.phase == SessionPhase.outOfHearts && !_playedLose) {
        _playedLose = true;
        ref.read(soundEffectsProvider).play(SoundEffect.lose);
      }
      if (controller.phase != SessionPhase.playing && _summary == null && !_saving) _finish();
    });
    return controller;
  }

  Future<void> _finish() async {
    final controller = _controller!;
    final data = _data!;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final user = await _readUser(data.profile.uid);
      final trail = data.content == null ? null : buildTrail(data.content!, user.progress);
      final service = SessionCompletionService(
        repository: ref.read(userDataRepositoryProvider),
        gamification: ref.read(gamificationServiceProvider),
        analytics: ref.read(analyticsProvider),
      );
      final summary = await service.finish(
        profile: user.profile ?? data.profile,
        mode: widget.mode,
        lesson: data.lesson,
        answers: controller.answers,
        hearts: controller.hearts,
        completed: controller.phase == SessionPhase.completed,
        progress: user.progress,
        existingErrors: user.errors,
      );

      if (summary.completed && data.lesson != null && trail != null) {
        final unit = trail.unitOf(data.lesson!.id);
        final othersDone = unit?.lessons
                .where((l) => l.lesson.id != data.lesson!.id)
                .every((l) => l.status == LessonStatus.completed) ??
            false;
        final alreadyDone = trail.find(data.lesson!.id)?.status == LessonStatus.completed;
        if (unit != null && othersDone && !alreadyDone) {
          _completedUnitTitle = unit.unit.title;
          ref.read(analyticsProvider).log(AnalyticsEvents.unitCompleted, {'unitId': unit.unit.id});
        }
      }
      if (mounted) {
        setState(() => _summary = summary);
        if (summary.completed) {
          final celebrate = summary.perfect || _completedUnitTitle != null;
          ref.read(soundEffectsProvider).play(celebrate ? SoundEffect.perfect : SoundEffect.win);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _saveError = e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da lição?'),
        content: const Text('Você vai perder o progresso desta lição.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuar estudando')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _exit() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    final playing = _controller != null && _summary == null && _controller!.phase == SessionPhase.playing;

    return PopScope(
      canPop: !playing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) _exit();
      },
      child: Scaffold(
        body: FutureBuilder<_SessionSetup>(
          future: _setup,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              final error = snapshot.error;
              return SafeArea(
                child: MessageView(
                  title: error is _LoadFailure ? error.message : 'Não foi possível carregar a lição',
                  message: error is _LoadFailure ? null : 'Verifique sua conexão e tente novamente.',
                  actionLabel: 'Voltar',
                  onAction: _exit,
                ),
              );
            }
            if (!snapshot.hasData) return const LoadingView(message: 'Preparando sua lição...');
            final data = snapshot.data!;

            if (data.exercises.isEmpty) {
              return SafeArea(
                child: MessageView(
                  title: widget.mode == SessionMode.review ? 'Nada para revisar!' : 'Lição sem exercícios',
                  message: widget.mode == SessionMode.review
                      ? 'Você não tem erros pendentes. Continue avançando na trilha.'
                      : 'Esta lição ainda não possui conteúdo.',
                  actionLabel: 'Voltar para a trilha',
                  onAction: _exit,
                ),
              );
            }

            if (_controller == null) {
              _data = data;
              final gamification = ref.read(gamificationServiceProvider);
              if (widget.mode == SessionMode.lesson && data.hearts.hearts <= 0) {
                return _noHearts(gamification.timeToNextHeart(data.hearts, DateTime.now()), hasErrors: data.hasErrors);
              }
              _controller = _createController(data);
            }

            return ListenableBuilder(listenable: _controller!, builder: (context, _) => _buildSession());
          },
        ),
      ),
    );
  }

  Widget _noHearts(Duration? timeToNext, {required bool hasErrors}) {
    return NoHeartsView(
      timeToNextHeart: timeToNext,
      onBack: _exit,
      onPractice: hasErrors ? () => context.pushReplacement('/review') : null,
    );
  }

  Widget _buildSession() {
    final c = _controller!;

    if (_saving) return const LoadingView(message: 'Salvando seu progresso...');
    if (_saveError != null) {
      return SafeArea(child: ErrorView(message: 'Não conseguimos salvar seu progresso.', onRetry: _finish));
    }
    final summary = _summary;
    if (summary != null) {
      if (!summary.completed) {
        final gamification = ref.read(gamificationServiceProvider);
        return _noHearts(
          gamification.timeToNextHeart(c.hearts, DateTime.now()),
          hasErrors: _data!.hasErrors || summary.wrongCount > 0,
        );
      }
      return SessionResultView(
        summary: summary,
        mode: widget.mode,
        completedUnitTitle: _completedUnitTitle,
        onContinue: _exit,
        onReviewErrors:
            widget.mode == SessionMode.lesson && summary.wrongCount > 0 ? () => context.pushReplacement('/review') : null,
      );
    }
    if (c.phase != SessionPhase.playing) return const LoadingView();

    final exercise = c.current;
    final locked = c.state != CheckState.answering;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ResponsiveCenter(
            maxWidth: 640,
            child: _SessionTopBar(
              progress: c.progress,
              hearts: c.usesHearts ? c.hearts.hearts : null,
              onClose: () async {
                if (await _confirmExit() && mounted) _exit();
              },
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ResponsiveCenter(
              maxWidth: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.mode == SessionMode.review)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('🔁 ERRO ANTERIOR',
                          style: TextStyle(color: AppColors.streak, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                    ),
                  Text(
                    exercise.displayInstruction,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),
                  ExerciseRenderer(
                    key: ValueKey('${exercise.id}-${c.index}-${c.attempt}'),
                    exercise: exercise,
                    locked: locked,
                    onChanged: c.setAnswer,
                    onSkip: c.skipCurrent,
                  ),
                ],
              ),
            ),
          ),
        ),
        LessonBottomBar(controller: c),
      ],
    );
  }
}

class _SessionTopBar extends StatelessWidget {
  const _SessionTopBar({required this.progress, required this.hearts, required this.onClose});

  final double progress;
  final int? hearts;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.close_rounded, size: 30, color: AppColors.textSecondary),
              onPressed: onClose,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 16,
                    backgroundColor: AppColors.locked,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            if (hearts != null) ...[
              const SizedBox(width: 16),
              const Icon(Icons.favorite_rounded, color: AppColors.heart, size: 26),
              const SizedBox(width: 4),
              Text(
                '$hearts',
                style: const TextStyle(color: AppColors.heart, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ],
        ),
      );
}