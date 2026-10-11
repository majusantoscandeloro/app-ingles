import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/lessons/lesson_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/review/practice_screen.dart';
import '../../features/splash/splash_screen.dart';

const _authRoutes = {'/login', '/register', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.listen(onboardingSeenProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;

      if (auth.isLoading && !auth.hasValue) return location == '/splash' ? null : '/splash';

      final loggedIn = auth.value != null;
      if (!loggedIn) {
        if (!ref.read(onboardingSeenProvider)) return location == '/onboarding' ? null : '/onboarding';
        return _authRoutes.contains(location) ? null : '/login';
      }
      if (location == '/splash' || location == '/onboarding' || _authRoutes.contains(location)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/practice', builder: (_, _) => const PracticeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())]),
        ],
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (_, state) => LessonScreen.lesson(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(path: '/review', builder: (_, _) => const LessonScreen.review()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
