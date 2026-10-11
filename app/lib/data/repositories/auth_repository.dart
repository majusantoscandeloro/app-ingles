import '../../shared/models/app_user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({required String name, required String email, required String password});
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
