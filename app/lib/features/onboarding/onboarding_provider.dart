import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class OnboardingNotifier extends Notifier<bool> {
  static const _key = 'onboarding.seen';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
