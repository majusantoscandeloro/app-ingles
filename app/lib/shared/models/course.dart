import 'model_utils.dart';

class Course {
  const Course({
    required this.id,
    required this.title,
    this.description = '',
    this.level = 'A1',
    this.imageUrl,
    this.order = 0,
    this.active = true,
  });

  final String id;
  final String title;
  final String description;
  final String level;
  final String? imageUrl;
  final int order;
  final bool active;

  factory Course.fromMap(String id, Map<String, dynamic> map) => Course(
        id: id,
        title: (map['title'] ?? map['name'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        level: (map['level'] ?? 'A1') as String,
        imageUrl: map['imageUrl'] as String?,
        order: parseInt(map['order']),
        active: map['active'] != false,
      );
}

class Unit {
  const Unit({
    required this.id,
    required this.courseId,
    required this.title,
    this.description = '',
    this.order = 0,
    this.imageUrl,
    this.active = true,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final int order;
  final String? imageUrl;
  final bool active;

  factory Unit.fromMap(String id, Map<String, dynamic> map) => Unit(
        id: id,
        courseId: (map['courseId'] ?? '') as String,
        title: (map['title'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        order: parseInt(map['order']),
        imageUrl: map['imageUrl'] as String?,
        active: map['active'] != false,
      );
}

/// Define apenas o ícone/estilo do nó na trilha; o conteúdo vem de `exercises`.
enum LessonKind {
  standard('STANDARD'),
  listening('LISTENING'),
  speaking('SPEAKING'),
  review('REVIEW'),
  challenge('CHALLENGE');

  const LessonKind(this.value);
  final String value;

  static LessonKind fromValue(String? value) => LessonKind.values.firstWhere(
        (k) => k.value == value,
        orElse: () => LessonKind.standard,
      );
}

class Lesson {
  const Lesson({
    required this.id,
    required this.unitId,
    required this.courseId,
    required this.title,
    this.description = '',
    this.order = 0,
    this.xp = 20,
    this.kind = LessonKind.standard,
    this.active = true,
  });

  final String id;
  final String unitId;
  final String courseId;
  final String title;
  final String description;
  final int order;

  /// Bônus de XP por concluir a lição.
  final int xp;
  final LessonKind kind;
  final bool active;

  factory Lesson.fromMap(String id, Map<String, dynamic> map) => Lesson(
        id: id,
        unitId: (map['unitId'] ?? '') as String,
        courseId: (map['courseId'] ?? '') as String,
        title: (map['title'] ?? '') as String,
        description: (map['description'] ?? '') as String,
        order: parseInt(map['order']),
        xp: parseInt(map['xp'], 20),
        kind: LessonKind.fromValue(map['kind'] as String?),
        active: map['active'] != false,
      );
}
