import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';
import 'firebase_options.dart';

/// `flutter run --dart-define=DEMO_MODE=true` força o modo demonstração.
const _forceDemo = bool.fromEnvironment('DEMO_MODE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final backend = _forceDemo ? BackendMode.demo : await _initFirebase();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig(backend: backend)),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LiviaApp(),
    ),
  );
}

Future<BackendMode> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return BackendMode.firebase;
  } catch (e) {
    // Em release, cair silenciosamente no modo demo criaria contas só locais.
    if (kReleaseMode) rethrow;
    debugPrint('Firebase indisponível, usando modo demonstração: $e');
    return BackendMode.demo;
  }
}
