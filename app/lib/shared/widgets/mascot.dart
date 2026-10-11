import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum MascotMood { normal, happy, celebrating, thinking, sad, encouraging, streak }

/// Mascote desenhado em código (placeholder). Para usar ilustrações, troque o
/// `CustomPaint` por `Image.asset('assets/mascot/${mood.name}.png')`.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.mood = MascotMood.normal, this.size = 120});

  final MascotMood mood;
  final double size;

  String? get _badge => switch (mood) {
        MascotMood.celebrating => '🎉',
        MascotMood.thinking => '💭',
        MascotMood.encouraging => '💪',
        MascotMood.streak => '🔥',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _MascotPainter(mood))),
          if (badge != null)
            Positioned(
              right: -size * 0.04,
              top: -size * 0.04,
              child: Text(badge, style: TextStyle(fontSize: size * 0.28)),
            ),
        ],
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.mood);
  final MascotMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.55);
    final r = w * 0.42;

    // Orelhas
    final ear = Paint()..color = AppColors.primaryDark;
    for (final dx in [-1, 1]) {
      final path = Path()
        ..moveTo(center.dx + dx * r * 0.35, center.dy - r * 0.8)
        ..lineTo(center.dx + dx * r * 0.85, center.dy - r * 1.15)
        ..lineTo(center.dx + dx * r * 0.85, center.dy - r * 0.45)
        ..close();
      canvas.drawPath(path, ear);
    }

    // Corpo
    canvas.drawCircle(center.translate(0, r * 0.06), r, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(center, r, Paint()..color = AppColors.primary);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, r * 0.45), width: r * 1.1, height: r * 0.8),
      Paint()..color = AppColors.primaryLight,
    );

    // Olhos
    final eyeY = center.dy - r * 0.18;
    final eyeDx = r * 0.36;
    final eyeR = r * 0.24;
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = AppColors.textPrimary;
    for (final dx in [-eyeDx, eyeDx]) {
      final eye = Offset(center.dx + dx, eyeY);
      if (mood == MascotMood.happy || mood == MascotMood.celebrating) {
        final arc = Paint()
          ..color = AppColors.textPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.08
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(Rect.fromCircle(center: eye, radius: eyeR * 0.6), math.pi, math.pi, false, arc);
        continue;
      }
      canvas.drawCircle(eye, eyeR, white);
      final look = mood == MascotMood.thinking ? Offset(eyeR * 0.3, -eyeR * 0.35) : Offset(0, eyeR * 0.15);
      canvas.drawCircle(eye + look, eyeR * 0.5, pupil);
      canvas.drawCircle(eye + look + Offset(-eyeR * 0.18, -eyeR * 0.2), eyeR * 0.15, white);
    }

    // Bochechas
    final cheek = Paint()..color = const Color(0xFFFF9BB3).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(center.dx - r * 0.62, center.dy + r * 0.12), r * 0.11, cheek);
    canvas.drawCircle(Offset(center.dx + r * 0.62, center.dy + r * 0.12), r * 0.11, cheek);

    // Boca
    final mouthCenter = Offset(center.dx, center.dy + r * 0.2);
    final mouth = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case MascotMood.celebrating:
      case MascotMood.streak:
        final rect = Rect.fromCenter(center: mouthCenter, width: r * 0.5, height: r * 0.45);
        canvas.drawArc(rect, 0, math.pi, true, Paint()..color = AppColors.textPrimary);
        canvas.drawArc(rect.deflate(r * 0.08).translate(0, r * 0.06), 0.3, math.pi - 0.6, false,
            Paint()..color = const Color(0xFFFF7A90));
      case MascotMood.sad:
        canvas.drawArc(
          Rect.fromCenter(center: mouthCenter.translate(0, r * 0.12), width: r * 0.4, height: r * 0.25),
          math.pi,
          math.pi,
          false,
          mouth,
        );
      case MascotMood.thinking:
        canvas.drawLine(mouthCenter.translate(-r * 0.14, 0), mouthCenter.translate(r * 0.14, r * 0.03), mouth);
      default:
        canvas.drawArc(
          Rect.fromCenter(center: mouthCenter, width: r * 0.42, height: r * 0.3),
          0.2,
          math.pi - 0.4,
          false,
          mouth,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => oldDelegate.mood != mood;
}
