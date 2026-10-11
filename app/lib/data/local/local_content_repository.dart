import 'dart:convert';

import 'package:flutter/services.dart';

import '../../shared/models/course.dart';
import '../../shared/models/exercise.dart';
import '../repositories/content_repository.dart';

/// Lê o curso demonstrativo de `assets/seed/demo_course.json` — o mesmo
/// arquivo usado para popular o Firestore.
class LocalContentRepository implements ContentRepository {
  LocalContentRepository({AssetBundle? bundle, this.assetPath = 'assets/seed/demo_course.json'})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  Future<Map<String, dynamic>>? _data;

  Future<Map<String, dynamic>> _load() =>
      _data ??= _bundle.loadString(assetPath).then((s) => jsonDecode(s) as Map<String, dynamic>);

  Future<List<T>> _items<T>(String key, T Function(String id, Map<String, dynamic> map) parse) async {
    final data = await _load();
    return (data[key] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((m) => m['active'] != false)
        .map((m) => parse(m['id'] as String, m))
        .toList();
  }

  @override
  Future<List<Course>> getCourses() async =>
      (await _items('courses', Course.fromMap))..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Unit>> getUnits(String courseId) async =>
      (await _items('units', Unit.fromMap)).where((u) => u.courseId == courseId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Lesson>> getLessons(String courseId) async =>
      (await _items('lessons', Lesson.fromMap)).where((l) => l.courseId == courseId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Exercise>> getExercises(String lessonId) async =>
      (await _items('exercises', Exercise.fromMap)).where((e) => e.lessonId == lessonId).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Exercise>> getExercisesByIds(List<String> ids) async {
    final wanted = ids.toSet();
    return (await _items('exercises', Exercise.fromMap)).where((e) => wanted.contains(e.id)).toList();
  }
}
