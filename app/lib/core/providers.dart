import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/firebase/firebase_auth_repository.dart';
import '../data/firebase/firestore_content_repository.dart';
import '../data/firebase/firestore_user_data_repository.dart';
import '../data/local/local_auth_repository.dart';
import '../data/local/local_content_repository.dart';
import '../data/local/local_store.dart';
import '../data/local/local_user_data_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/user_data_repository.dart';
import '../features/exercises/answer_checker.dart';
import '../features/gamification/gamification_service.dart';
import 'config/app_config.dart';
import 'services/analytics_service.dart';
import 'services/speech_service.dart';
import 'services/tts_service.dart';

/// Sobrescritos em `main.dart` após a inicialização.
final appConfigProvider = Provider<AppConfig>((ref) => throw UnimplementedError());
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final localStoreProvider = Provider<LocalStore>((ref) => LocalStore(ref.watch(sharedPreferencesProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(appConfigProvider).isDemo
      ? LocalAuthRepository(ref.watch(localStoreProvider))
      : FirebaseAuthRepository(FirebaseAuth.instance);
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ref.watch(appConfigProvider).isDemo
      ? LocalContentRepository()
      : FirestoreContentRepository(FirebaseFirestore.instance);
});

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  return ref.watch(appConfigProvider).isDemo
      ? LocalUserDataRepository(ref.watch(localStoreProvider))
      : FirestoreUserDataRepository(FirebaseFirestore.instance);
});

final gamificationServiceProvider = Provider<GamificationService>((ref) => const GamificationService());
final answerCheckerProvider = Provider<AnswerChecker>((ref) => const AnswerChecker());
final analyticsProvider = Provider<AnalyticsService>((ref) => DebugAnalyticsService());

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(tts.stop);
  return tts;
});

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
