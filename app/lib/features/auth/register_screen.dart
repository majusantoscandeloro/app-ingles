import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/mascot.dart';
import 'auth_providers.dart';
import 'widgets/auth_scaffold.dart';

const _levels = {
  'BEGINNER': 'Iniciante',
  'BASIC': 'Básico',
  'INTERMEDIATE': 'Intermediário',
};

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _level = 'BEGINNER';
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).signUp(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            startingLevel: _level,
          );
    } on AuthFailure catch (e) {
      if (mounted) showAuthError(context, e);
    } catch (_) {
      if (mounted) showAuthError(context, 'Não foi possível criar a conta. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crie sua conta',
      mood: MascotMood.celebrating,
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Nome'),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Informe seu nome.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  validator: validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    hintText: 'Senha (mín. 6 caracteres)',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: validatePassword,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Qual seu nível de inglês?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final entry in _levels.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: _level == entry.key,
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _level == entry.key ? AppColors.primaryDark : AppColors.textPrimary,
                ),
                onSelected: (_) => setState(() => _level = entry.key),
              ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Criar conta', loading: _loading, onPressed: _submit),
      ],
    );
  }
}
