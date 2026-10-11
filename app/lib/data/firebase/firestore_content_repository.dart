import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/course.dart';
import '../../shared/models/exercise.dart';
import '../repositories/content_repository.dart';
import 'firestore_utils.dart';

/// As consultas filtram `active == true` porque as Security Rules só liberam
/// conteúdo ativo para alunos. A ordenação é feita no cliente para dispensar
/// índices compostos.
class FirestoreContentRepository implements ContentRepository {
  FirestoreContentRepository(this._db);

  final FirebaseFirestore _db;

  Future<List<T>> _query<T>(
    String collection,
    T Function(String id, Map<String, dynamic> map) parse, {
    String? field,
    String? equals,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collection).where('active', isEqualTo: true);
    if (field != null) query = query.where(field, isEqualTo: equals);
    final snapshot = await query.get();
    return snapshot.docs.map((d) => parse(d.id, fromFirestore(d.data()))).toList();
  }

  @override
  Future<List<Course>> getCourses() async =>
      (await _query('courses', Course.fromMap))..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Unit>> getUnits(String courseId) async =>
      (await _query('units', Unit.fromMap, field: 'courseId', equals: courseId))
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Lesson>> getLessons(String courseId) async =>
      (await _query('lessons', Lesson.fromMap, field: 'courseId', equals: courseId))
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Exercise>> getExercises(String lessonId) async =>
      (await _query('exercises', Exercise.fromMap, field: 'lessonId', equals: lessonId))
        ..sort((a, b) => a.order.compareTo(b.order));

  @override
  Future<List<Exercise>> getExercisesByIds(List<String> ids) async {
    final result = <Exercise>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snapshot = await _db
          .collection('exercises')
          .where('active', isEqualTo: true)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(snapshot.docs.map((d) => Exercise.fromMap(d.id, fromFirestore(d.data()))));
    }
    return result;
  }
}
