import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/user_profile.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) => ref.watch(authRepositoryProvider).authStateChanges());

final currentUidProvider = Provider<String?>((ref) => ref.watch(authStateProvider).value?.uid);

/// Ações de autenticação usadas pelas telas de login/cadastro.
class AuthController {
  AuthController(this._ref);
  final Ref _ref;

  Future<void> signIn(String email, String password) =>
      _ref.read(authRepositoryProvider).signIn(email: email, password: password);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? startingLevel,
  }) async {
    final user = await _ref.read(authRepositoryProvider).signUp(name: name, email: email, password: password);
    await _ref.read(userDataRepositoryProvider).createProfile(
          UserProfile(uid: user.uid, name: name.trim(), email: user.email, startingLevel: startingLevel),
          overwriteBasics: true,
        );
  }

  Future<void> sendPasswordReset(String email) => _ref.read(authRepositoryProvider).sendPasswordReset(email);

  Future<void> signOut() => _ref.read(authRepositoryProvider).signOut();
}

final authControllerProvider = Provider<AuthController>(AuthController.new);
