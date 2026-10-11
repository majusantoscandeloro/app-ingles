import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/repositories/content_repository.dart';
import '../../shared/models/course.dart';
import '../../shared/models/lesson_progress.dart';
import '../progress/progress_providers.dart';

enum LessonStatus { locked, available, completed }

class TrailLesson {
  const TrailLesson({required this.lesson, required this.status, required this.isCurrent, this.progress});

  final Lesson lesson;
  final LessonStatus status;
  final bool isCurrent;
  final LessonProgress? progress;

  bool get isPlayable => status != LessonStatus.locked;
}

class TrailUnit {
  const TrailUnit({required this.unit, required this.number, required this.lessons});

  final Unit unit;
  final int number;
  final List<TrailLesson> lessons;

  bool get isCompleted => lessons.isNotEmpty && lessons.every((l) => l.status == LessonStatus.completed);
  bool get isLocked => lessons.isNotEmpty && lessons.every((l) => l.status == LessonStatus.locked);
}

class Trail {
  const Trail({required this.course, required this.units});

  final Course course;
  final List<TrailUnit> units;

  Iterable<TrailLesson> get allLessons => units.expand((u) => u.lessons);
  TrailLesson? get current => allLessons.where((l) => l.isCurrent).firstOrNull;
  int get completedLessons => allLessons.where((l) => l.status == LessonStatus.completed).length;
  int get completedUnits => units.where((u) => u.isCompleted).length;

  TrailLesson? find(String lessonId) => allLessons.where((l) => l.lesson.id == lessonId).firstOrNull;
  TrailUnit? unitOf(String lessonId) =>
      units.where((u) => u.lessons.any((l) => l.lesson.id == lessonId)).firstOrNull;
}

class CourseContent {
  const CourseContent({required this.course, required this.units, required this.lessons});

  final Course course;
  final List<Unit> units;
  final List<Lesson> lessons;
}

/// No MVP há um curso ativo: o primeiro por `order`.
Future<CourseContent?> loadCourseContent(ContentRepository repo) async {
  final courses = await repo.getCourses();
  if (courses.isEmpty) return null;
  final course = courses.first;
  final results = await Future.wait([repo.getUnits(course.id), repo.getLessons(course.id)]);
  return CourseContent(course: course, units: results[0] as List<Unit>, lessons: results[1] as List<Lesson>);
}

final courseContentProvider =
    FutureProvider<CourseContent?>((ref) => loadCourseContent(ref.watch(contentRepositoryProvider)));

/// Desbloqueio sequencial: a lição N libera quando a N−1 (na ordem global
/// unidade → lição) está concluída.
Trail buildTrail(CourseContent content, Map<String, LessonProgress> progress) {
  var previousCompleted = true;
  var currentAssigned = false;
  final units = <TrailUnit>[];

  for (final (index, unit) in content.units.indexed) {
    final lessons = <TrailLesson>[];
    for (final lesson in content.lessons.where((l) => l.unitId == unit.id)) {
      final p = progress[lesson.id];
      final completed = p?.completed ?? false;
      final status = completed
          ? LessonStatus.completed
          : previousCompleted
              ? LessonStatus.available
              : LessonStatus.locked;
      final isCurrent = !currentAssigned && status == LessonStatus.available;
      if (isCurrent) currentAssigned = true;
      lessons.add(TrailLesson(lesson: lesson, status: status, isCurrent: isCurrent, progress: p));
      previousCompleted = completed;
    }
    units.add(TrailUnit(unit: unit, number: index + 1, lessons: lessons));
  }
  return Trail(course: content.course, units: units);
}

final trailProvider = FutureProvider<Trail?>((ref) async {
  final content = await ref.watch(courseContentProvider.future);
  if (content == null) return null;
  final progress = await ref.watch(progressProvider.future);
  return buildTrail(content, progress);
});
