import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/mascot.dart';
import 'auth_providers.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (e) {
      if (mounted) showAuthError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Recuperar senha',
      mood: MascotMood.thinking,
      children: _sent
          ? [
              const Text(
                'Se existir uma conta com este e-mail, você receberá um link para criar uma nova senha. '
                'Confira também a caixa de spam.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Voltar para o login', onPressed: () => context.pop()),
            ]
          : [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  validator: validateEmail,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(label: 'Enviar link', loading: _loading, onPressed: _submit),
            ],
    );
  }
}
