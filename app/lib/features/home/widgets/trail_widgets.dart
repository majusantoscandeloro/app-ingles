import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/course.dart';
import '../../courses/course_providers.dart';

class UnitHeader extends StatelessWidget {
  const UnitHeader({super.key, required this.unit, required this.color});

  final TrailUnit unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = unit.isLocked ? AppColors.lockedDark : color;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border(bottom: BorderSide(color: AppColors.darken(bg, 0.12), width: 5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIDADE ${unit.number}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.unit.title,
                  style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                if (unit.unit.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(unit.unit.description, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                ],
              ],
            ),
          ),
          if (unit.isCompleted) const Text('🏆', style: TextStyle(fontSize: 32)),
          if (unit.isLocked) const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

class LessonNode extends StatefulWidget {
  const LessonNode({super.key, required this.item, required this.color, required this.onTap});

  final TrailLesson item;
  final Color color;
  final VoidCallback onTap;

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isCurrent) _bounce.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant LessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isCurrent && !_bounce.isAnimating) _bounce.repeat(reverse: true);
    if (!widget.item.isCurrent && _bounce.isAnimating) _bounce.stop();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  IconData get _icon {
    final item = widget.item;
    if (item.status == LessonStatus.locked) return Icons.lock_rounded;
    if (item.status == LessonStatus.completed) return Icons.check_rounded;
    return switch (item.lesson.kind) {
      LessonKind.listening => Icons.headphones_rounded,
      LessonKind.speaking => Icons.mic_rounded,
      LessonKind.review => Icons.replay_rounded,
      LessonKind.challenge => Icons.emoji_events_rounded,
      LessonKind.standard => Icons.star_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final locked = item.status == LessonStatus.locked;
    final completed = item.status == LessonStatus.completed;
    final base = locked ? AppColors.locked : (completed ? AppColors.xp : widget.color);
    final shadow = locked ? AppColors.lockedDark : AppColors.darken(base, 0.14);
    const size = 72.0;
    const depth = 6.0;

    final node = Semantics(
      button: true,
      label: '${item.lesson.title}${locked ? ', bloqueada' : completed ? ', concluída' : ''}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: SizedBox(
          width: size,
          height: size + depth,
          child: Stack(
            children: [
              Positioned(
                top: depth,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: shadow, shape: BoxShape.circle),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                top: _pressed ? depth : 0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: base, shape: BoxShape.circle),
                  child: Icon(_icon, size: 36, color: locked ? AppColors.lockedDark : Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!item.isCurrent) return node;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounce,
          builder: (context, child) => Transform.translate(offset: Offset(0, -4 * _bounce.value), child: child),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Text(
              'COMEÇAR',
              style: TextStyle(color: widget.color, fontWeight: FontWeight.w900, letterSpacing: 0.8),
            ),
          ),
        ),
        node,
      ],
    );
  }
}
