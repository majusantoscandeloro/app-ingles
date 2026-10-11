import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';
import '../repositories/user_data_repository.dart';
import 'local_store.dart';

class LocalUserDataRepository implements UserDataRepository {
  LocalUserDataRepository(this._store);

  final LocalStore _store;

  String _profileKey(String uid) => 'demo.profile.$uid';
  String _progressKey(String uid) => 'demo.progress.$uid';
  String _errorsKey(String uid) => 'demo.errors.$uid';

  Map<String, dynamic> _map(String key) => Map<String, dynamic>.from(_store.read(key) as Map? ?? {});

  @override
  Stream<UserProfile?> watchProfile(String uid) => _store.watch(
        _profileKey(uid),
        (raw) => raw is Map ? UserProfile.fromMap(uid, Map<String, dynamic>.from(raw)) : null,
      );

  @override
  Future<void> createProfile(UserProfile profile, {bool overwriteBasics = false}) async {
    final existing = _map(_profileKey(profile.uid));
    if (existing.isEmpty) {
      await _store.write(_profileKey(profile.uid), {...profile.toMap(), 'createdAt': DateTime.now()});
    } else if (overwriteBasics) {
      await _store.write(
        _profileKey(profile.uid),
        {...existing, 'name': profile.name, 'startingLevel': profile.startingLevel},
      );
    }
  }

  @override
  Stream<Map<String, LessonProgress>> watchProgress(String uid) => _store.watch(
        _progressKey(uid),
        (raw) => (raw as Map? ?? {}).map(
          (k, v) => MapEntry(k as String, LessonProgress.fromMap(k, Map<String, dynamic>.from(v as Map))),
        ),
      );

  @override
  Stream<List<UserError>> watchErrors(String uid) => _store.watch(
        _errorsKey(uid),
        (raw) => (raw as Map? ?? {})
            .entries
            .map((e) => UserError.fromMap(e.key as String, Map<String, dynamic>.from(e.value as Map)))
            .toList(),
      );

  @override
  Future<void> updateHearts(String uid, {required int hearts, required DateTime anchor}) async {
    final profile = _map(_profileKey(uid));
    if (profile.isEmpty) return;
    await _store.write(_profileKey(uid), {...profile, 'hearts': hearts, 'heartsUpdatedAt': anchor});
  }

  @override
  Future<void> commitSession(String uid, SessionCommit commit) async {
    final existing = _map(_profileKey(uid));
    await _store.write(_profileKey(uid), {...existing, ...commit.profile.toMap()});

    final progress = commit.progress;
    if (progress != null) {
      await _store.write(_progressKey(uid), {..._map(_progressKey(uid)), progress.lessonId: progress.toMap()});
    }

    if (commit.upsertErrors.isNotEmpty || commit.resolvedErrorIds.isNotEmpty) {
      final errors = _map(_errorsKey(uid));
      for (final e in commit.upsertErrors) {
        errors[e.exerciseId] = e.toMap();
      }
      commit.resolvedErrorIds.forEach(errors.remove);
      await _store.write(_errorsKey(uid), errors);
    }
  }
}
