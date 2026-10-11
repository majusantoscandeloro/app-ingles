import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, success, danger, warning, sky, outline, ghost }

/// Botão com "profundidade" (sombra sólida inferior) que afunda ao pressionar.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;
  static const _depth = 4.0;

  ({Color bg, Color shadow, Color fg, Color? border}) get _colors => switch (widget.variant) {
        AppButtonVariant.primary => (bg: AppColors.primary, shadow: AppColors.primaryDark, fg: Colors.white, border: null),
        AppButtonVariant.success => (bg: AppColors.success, shadow: AppColors.successDark, fg: Colors.white, border: null),
        AppButtonVariant.danger => (bg: AppColors.error, shadow: AppColors.errorDark, fg: Colors.white, border: null),
        AppButtonVariant.warning => (bg: AppColors.warning, shadow: AppColors.warningDark, fg: Colors.white, border: null),
        AppButtonVariant.sky => (bg: AppColors.sky, shadow: AppColors.skyDark, fg: Colors.white, border: null),
        AppButtonVariant.outline => (
            bg: Colors.white,
            shadow: AppColors.border,
            fg: AppColors.primary,
            border: AppColors.border,
          ),
        AppButtonVariant.ghost => (bg: Colors.transparent, shadow: Colors.transparent, fg: AppColors.primary, border: null),
      };

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final c = _colors;
    final bg = enabled ? c.bg : (widget.variant == AppButtonVariant.ghost ? Colors.transparent : AppColors.locked);
    final shadow = enabled ? c.shadow : (widget.variant == AppButtonVariant.ghost ? Colors.transparent : AppColors.lockedDark);
    final fg = enabled ? c.fg : AppColors.textSecondary;
    final offset = _pressed ? _depth : 0.0;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
        else ...[
          if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: 20), const SizedBox(width: 8)],
          Flexible(
            child: Text(
              widget.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        child: SizedBox(
          height: 52 + _depth,
          child: Stack(
            children: [
              Positioned.fill(
                top: _depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: shadow, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                left: 0,
                right: 0,
                top: offset,
                height: 52,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: c.border != null ? Border.all(color: c.border!, width: 2) : null,
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
