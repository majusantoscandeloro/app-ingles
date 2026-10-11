import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'mascot.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ],
        ),
      );
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.title,
    this.message,
    this.mood = MascotMood.normal,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final MascotMood mood;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Mascot(mood: mood, size: 110),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                AppButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
        title: 'Ops! Algo deu errado',
        message: message ?? 'Verifique sua conexão e tente novamente.',
        mood: MascotMood.sad,
        actionLabel: onRetry == null ? null : 'Tentar novamente',
        onAction: onRetry,
      );
}

/// Limita a largura em tablets mantendo o layout de celular centralizado.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 600, this.padding = EdgeInsets.zero});

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: padding, child: child),
        ),
      );
}
