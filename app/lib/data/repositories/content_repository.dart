import '../../shared/models/course.dart';
import '../../shared/models/exercise.dart';

/// Conteúdo pedagógico (somente leitura no app; editado pelo painel).
/// Implementações devem retornar apenas itens ativos, ordenados por `order`.
abstract class ContentRepository {
  Future<List<Course>> getCourses();
  Future<List<Unit>> getUnits(String courseId);
  Future<List<Lesson>> getLessons(String courseId);
  Future<List<Exercise>> getExercises(String lessonId);
  Future<List<Exercise>> getExercisesByIds(List<String> ids);
}
