import 'dart:async';

import '../../shared/models/app_user.dart';
import '../repositories/auth_repository.dart';
import 'local_store.dart';

/// Autenticação simulada do modo demonstração. Não valida senha nem envia
/// e-mails: serve apenas para navegar no app antes do Firebase ser configurado.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._store);

  static const _currentKey = 'demo.auth.current';
  static const _accountsKey = 'demo.auth.accounts';

  final LocalStore _store;

  AppUser? _fromJson(dynamic raw) => raw is Map
      ? AppUser(uid: raw['uid'] as String, email: raw['email'] as String, displayName: raw['name'] as String?)
      : null;

  Map<String, dynamic> get _accounts => Map<String, dynamic>.from(_store.read(_accountsKey) as Map? ?? {});

  @override
  Stream<AppUser?> authStateChanges() => _store.watch(_currentKey, _fromJson);

  @override
  AppUser? get currentUser => _fromJson(_store.read(_currentKey));

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final key = email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null) throw const AuthFailure('Conta não encontrada. Crie uma conta para continuar.');
    await _store.write(_currentKey, account);
    return _fromJson(account)!;
  }

  @override
  Future<AppUser> signUp({required String name, required String email, required String password}) async {
    final key = email.trim().toLowerCase();
    final accounts = _accounts;
    if (accounts.containsKey(key)) throw const AuthFailure('Este e-mail já está cadastrado.');
    final account = {'uid': 'demo_${DateTime.now().microsecondsSinceEpoch}', 'email': key, 'name': name.trim()};
    accounts[key] = account;
    await _store.write(_accountsKey, accounts);
    await _store.write(_currentKey, account);
    return _fromJson(account)!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() => _store.write(_currentKey, null);
}
