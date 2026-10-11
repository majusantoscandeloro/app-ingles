import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/state_views.dart';

class AuthScaffold extends ConsumerWidget {
  const AuthScaffold({super.key, required this.title, required this.children, this.mood = MascotMood.happy});

  final String title;
  final List<Widget> children;
  final MascotMood mood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(appConfigProvider).isDemo;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ResponsiveCenter(
            maxWidth: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Mascot(mood: mood, size: 100)),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (isDemo) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      '🧪 Modo demonstração (Firebase não configurado). A conta é criada só neste aparelho e a senha não é verificada.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Informe seu e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'E-mail inválido.';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Informe sua senha.';
  if (value.length < 6) return 'A senha precisa ter pelo menos 6 caracteres.';
  return null;
}

void showAuthError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(backgroundColor: AppColors.errorDark, content: Text(error.toString())));
}
