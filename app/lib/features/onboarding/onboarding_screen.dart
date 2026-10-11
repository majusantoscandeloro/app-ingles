import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/mascot.dart';
import '../../shared/widgets/state_views.dart';
import 'onboarding_provider.dart';

class _Page {
  const _Page(this.mood, this.title, this.text);
  final MascotMood mood;
  final String title;
  final String text;
}

const _pages = [
  _Page(MascotMood.happy, 'Aprenda inglês de forma prática', 'Lições curtas e divertidas, no seu ritmo.'),
  _Page(MascotMood.thinking, 'Complete lições curtas', 'Avance por unidades e desbloqueie novos conteúdos.'),
  _Page(MascotMood.streak, 'Ganhe XP e mantenha sua sequência', 'Estude todo dia para não perder seu 🔥.'),
  _Page(MascotMood.celebrating, 'Pratique leitura, escuta e fala', 'Ouça frases em inglês e fale pelo microfone.'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      ref.read(onboardingSeenProvider.notifier).complete();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 520,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: last ? null : () => ref.read(onboardingSeenProvider.notifier).complete(),
                  child: Text(last ? '' : 'Pular'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Mascot(mood: page.mood, size: 170),
                          const SizedBox(height: 36),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.text,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : AppColors.locked,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(label: last ? 'Começar' : 'Próximo', onPressed: _next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
