import 'package:flutter_test/flutter_test.dart';
import 'package:livia_ingles/features/courses/course_providers.dart';
import 'package:livia_ingles/features/gamification/gamification_service.dart';
import 'package:livia_ingles/shared/models/course.dart';
import 'package:livia_ingles/shared/models/lesson_progress.dart';
import 'package:livia_ingles/shared/models/user_profile.dart';

UserProfile _profile({int hearts = 5, DateTime? heartsAt, String? lastDay, int streak = 0, int xp = 0}) => UserProfile(
      uid: 'u',
      name: 'Aluno',
      email: 'a@a.com',
      hearts: hearts,
      heartsUpdatedAt: heartsAt,
      lastStudyDay: lastDay,
      currentStreak: streak,
      longestStreak: streak,
      xp: xp,
    );

void main() {
  const service = GamificationService();
  final now = DateTime(2026, 10, 11, 12);

  group('streak', () {
    test('primeiro estudo inicia em 1', () {
      final s = service.registerStudy(_profile(), now);
      expect(s.current, 1);
      expect(s.increased, isTrue);
    });

    test('estudo em dia seguido incrementa', () {
      expect(service.registerStudy(_profile(lastDay: '2026-10-10', streak: 4), now).current, 5);
    });

    test('estudar de novo no mesmo dia não incrementa', () {
      final s = service.registerStudy(_profile(lastDay: '2026-10-11', streak: 4), now);
      expect(s.current, 4);
      expect(s.increased, isFalse);
    });

    test('pular um dia zera e recomeça', () {
      expect(service.registerStudy(_profile(lastDay: '2026-10-08', streak: 9), now).current, 1);
      expect(service.effectiveStreak(_profile(lastDay: '2026-10-08', streak: 9), now), 0);
    });
  });

  group('corações', () {
    test('recarrega 1 coração a cada 30 minutos', () {
      final p = _profile(hearts: 2, heartsAt: now.subtract(const Duration(minutes: 65)));
      final h = service.heartsAt(p, now);
      expect(h.hearts, 4);
      expect(service.timeToNextHeart(h, now), const Duration(minutes: 25));
    });

    test('não passa do máximo', () {
      final p = _profile(hearts: 4, heartsAt: now.subtract(const Duration(hours: 10)));
      expect(service.heartsAt(p, now).hearts, 5);
    });

    test('perder coração com vida cheia inicia a recarga agora', () {
      final h = service.loseHeart(HeartsState(hearts: 5, anchor: DateTime(2020)), now);
      expect(h.hearts, 4);
      expect(h.anchor, now);
    });
  });

  group('nível', () {
    test('curva de XP', () {
      expect(service.levelProgress(0).level, 1);
      expect(service.levelProgress(49).level, 1);
      expect(service.levelProgress(50).level, 2);
      expect(service.levelProgress(200).level, 3);
    });
  });

  group('trilha', () {
    const course = Course(id: 'c', title: 'Curso');
    const units = [Unit(id: 'u1', courseId: 'c', title: 'U1', order: 1), Unit(id: 'u2', courseId: 'c', title: 'U2', order: 2)];
    const lessons = [
      Lesson(id: 'a', unitId: 'u1', courseId: 'c', title: 'A', order: 1),
      Lesson(id: 'b', unitId: 'u1', courseId: 'c', title: 'B', order: 2),
      Lesson(id: 'c1', unitId: 'u2', courseId: 'c', title: 'C', order: 1),
    ];
    const content = CourseContent(course: course, units: units, lessons: lessons);

    test('somente a primeira lição começa liberada', () {
      final trail = buildTrail(content, const {});
      expect(trail.allLessons.map((l) => l.status).toList(),
          [LessonStatus.available, LessonStatus.locked, LessonStatus.locked]);
      expect(trail.current?.lesson.id, 'a');
    });

    test('concluir libera a próxima, inclusive na próxima unidade', () {
      final trail = buildTrail(content, const {
        'a': LessonProgress(lessonId: 'a', unitId: 'u1', courseId: 'c', completed: true),
        'b': LessonProgress(lessonId: 'b', unitId: 'u1', courseId: 'c', completed: true),
      });
      expect(trail.find('c1')?.status, LessonStatus.available);
      expect(trail.units.first.isCompleted, isTrue);
      expect(trail.completedUnits, 1);
    });
  });
}
