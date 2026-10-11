import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/models/app_user.dart';
import '../repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email ?? '', displayName: user.displayName);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signIn({required String email, required String password}) => _guard(() async {
        final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
        return _map(cred.user)!;
      });

  @override
  Future<AppUser> signUp({required String name, required String email, required String password}) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await cred.user!.updateDisplayName(name.trim());
        return AppUser(uid: cred.user!.uid, email: cred.user!.email ?? email.trim(), displayName: name.trim());
      });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _auth.signOut();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_message(e.code));
    }
  }

  String _message(String code) => switch (code) {
        'invalid-email' => 'E-mail inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'A senha precisa ter pelo menos 6 caracteres.',
        'too-many-requests' => 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
        'network-request-failed' => 'Sem conexão com a internet.',
        _ => 'Não foi possível concluir. Tente novamente.',
      };
}
