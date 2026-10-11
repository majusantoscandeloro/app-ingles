import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/models/lesson_progress.dart';
import '../../shared/models/user_error.dart';
import '../../shared/models/user_profile.dart';
import '../auth/auth_providers.dart';

/// Perfil do aluno logado. Cria o documento automaticamente se não existir.
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    yield null;
    return;
  }
  final repo = ref.watch(userDataRepositoryProvider);
  await for (final profile in repo.watchProfile(user.uid)) {
    if (profile == null) {
      final fallbackName = user.displayName?.trim().isNotEmpty == true ? user.displayName! : user.email.split('@').first;
      await repo.createProfile(UserProfile(uid: user.uid, name: fallbackName, email: user.email));
      continue;
    }
    yield profile;
  }
});

final progressProvider = StreamProvider<Map<String, LessonProgress>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const {});
  return ref.watch(userDataRepositoryProvider).watchProgress(uid);
});

final userErrorsProvider = StreamProvider<List<UserError>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(userDataRepositoryProvider).watchErrors(uid).map(
        (list) => [...list]..sort((a, b) => (b.lastErrorAt ?? DateTime(0)).compareTo(a.lastErrorAt ?? DateTime(0))),
      );
});

/// Relógio que atualiza a cada 30s (recarga de corações, streak).
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});
