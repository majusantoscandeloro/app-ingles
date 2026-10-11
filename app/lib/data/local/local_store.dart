import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento JSON reativo sobre SharedPreferences (modo demonstração).
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;
  final _changes = StreamController<String>.broadcast();

  dynamic read(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : jsonDecode(raw);
  }

  Future<void> write(String key, Object? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(
        key,
        jsonEncode(value, toEncodable: (o) => o is DateTime ? o.toIso8601String() : o),
      );
    }
    _changes.add(key);
  }

  /// Emite o valor atual e, depois, a cada alteração da chave.
  Stream<T> watch<T>(String key, T Function(dynamic raw) map) async* {
    yield map(read(key));
    yield* _changes.stream.where((k) => k == key).map((_) => map(read(key)));
  }
}
