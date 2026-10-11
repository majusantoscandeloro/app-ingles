import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';

/// Tudo que é gravado ao final de uma sessão, aplicado de forma atômica.
class SessionCommit {
  const SessionCommit({
    required this.profile,
    this.progress,
    this.upsertErrors = const [],
    this.resolvedErrorIds = const [],
  });

  final UserProfile profile;
  final LessonProgress? progress;
  final List<UserError> upsertErrors;
  final List<String> resolvedErrorIds;
}

abstract class UserDataRepository {
  Stream<UserProfile?> watchProfile(String uid);
  /// Cria o perfil se não existir. Com [overwriteBasics], um perfil já
  /// existente recebe `name` e `startingLevel` (usado no cadastro, que pode
  /// competir com a criação automática disparada pelo login).
  Future<void> createProfile(UserProfile profile, {bool overwriteBasics = false});
  Stream<Map<String, LessonProgress>> watchProgress(String uid);
  Stream<List<UserError>> watchErrors(String uid);
  Future<void> updateHearts(String uid, {required int hearts, required DateTime anchor});
  Future<void> commitSession(String uid, SessionCommit commit);
}
