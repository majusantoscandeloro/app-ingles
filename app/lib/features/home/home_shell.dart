import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../progress/progress_providers.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorsCount = ref.watch(userErrorsProvider).value?.length ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Trilha'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: errorsCount > 0,
              label: Text('$errorsCount'),
              child: const Icon(Icons.fitness_center_outlined),
            ),
            selectedIcon: const Icon(Icons.fitness_center),
            label: 'Praticar',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
