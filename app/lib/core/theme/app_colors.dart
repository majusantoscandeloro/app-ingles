import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF6C4CF1);
  static const primaryDark = Color(0xFF4F32C9);
  static const primaryLight = Color(0xFFEDE8FF);

  static const sky = Color(0xFF1CB0F6);
  static const skyDark = Color(0xFF1593CF);

  static const success = Color(0xFF35C46A);
  static const successDark = Color(0xFF26A157);
  static const successBg = Color(0xFFE3F9EA);

  static const error = Color(0xFFFF5A5F);
  static const errorDark = Color(0xFFD9363C);
  static const errorBg = Color(0xFFFFE5E6);

  static const warning = Color(0xFFFFB020);
  static const warningDark = Color(0xFFDB9100);
  static const warningBg = Color(0xFFFFF4DB);

  static const xp = Color(0xFFFFC233);
  static const streak = Color(0xFFFF8A00);
  static const heart = Color(0xFFFF4B6E);

  static const locked = Color(0xFFE5E5EA);
  static const lockedDark = Color(0xFFC7C7CC);

  static const textPrimary = Color(0xFF2B2D42);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const surface = Color(0xFFF7F7FB);

  static const unitPalette = [primary, sky, streak, success, Color(0xFFE84393)];

  static Color unitColor(int index) => unitPalette[index % unitPalette.length];

  static Color darken(Color color, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
