import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';
import '../repositories/user_data_repository.dart';
import 'firestore_utils.dart';

/// Estrutura: `users/{uid}`, `users/{uid}/progress/{lessonId}` e
/// `users/{uid}/errors/{exerciseId}`.
class FirestoreUserDataRepository implements UserDataRepository {
  FirestoreUserDataRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  @override
  Stream<UserProfile?> watchProfile(String uid) => _user(uid)
      .snapshots()
      .map((s) => s.exists ? UserProfile.fromMap(uid, fromFirestore(s.data())) : null);

  @override
  Future<void> createProfile(UserProfile profile, {bool overwriteBasics = false}) async {
    final ref = _user(profile.uid);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        tx.set(ref, {...profile.toMap(), 'createdAt': FieldValue.serverTimestamp()});
      } else if (overwriteBasics) {
        tx.update(ref, {'name': profile.name, 'startingLevel': profile.startingLevel});
      }
    });
  }

  @override
  Stream<Map<String, LessonProgress>> watchProgress(String uid) => _user(uid).collection('progress').snapshots().map(
        (s) => {for (final d in s.docs) d.id: LessonProgress.fromMap(d.id, fromFirestore(d.data()))},
      );

  @override
  Stream<List<UserError>> watchErrors(String uid) => _user(uid)
      .collection('errors')
      .snapshots()
      .map((s) => s.docs.map((d) => UserError.fromMap(d.id, fromFirestore(d.data()))).toList());

  @override
  Future<void> updateHearts(String uid, {required int hearts, required DateTime anchor}) =>
      _user(uid).update({'hearts': hearts, 'heartsUpdatedAt': anchor});

  @override
  Future<void> commitSession(String uid, SessionCommit commit) async {
    final batch = _db.batch();
    batch.set(_user(uid), commit.profile.toMap(), SetOptions(merge: true));

    final progress = commit.progress;
    if (progress != null) {
      batch.set(_user(uid).collection('progress').doc(progress.lessonId), progress.toMap());
    }
    for (final e in commit.upsertErrors) {
      batch.set(_user(uid).collection('errors').doc(e.exerciseId), e.toMap());
    }
    for (final id in commit.resolvedErrorIds) {
      batch.delete(_user(uid).collection('errors').doc(id));
    }
    await batch.commit();
  }
}
