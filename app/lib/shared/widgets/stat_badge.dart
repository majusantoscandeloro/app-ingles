import 'package:flutter/material.dart';

class StatBadge extends StatelessWidget {
  const StatBadge({super.key, required this.emoji, required this.value, required this.color, this.tooltip});

  final String emoji;
  final String value;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
    return tooltip == null ? badge : Tooltip(message: tooltip!, child: badge);
  }
}
