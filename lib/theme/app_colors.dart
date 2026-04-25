import 'package:flutter/material.dart';

// Translated from reru/docs/design-system/colors_and_type.css
// OKLCH values converted to sRGB hex for Flutter compatibility.
abstract final class AppColors {
  // Green scale
  static const green900 = Color(0xFF1A3320); // oklch(28% 0.10 145)
  static const green700 = Color(0xFF235C30); // oklch(38% 0.13 145) — primary buttons, active states
  static const green600 = Color(0xFF2D7840); // oklch(46% 0.15 145) — button hover, icon color
  static const green500 = Color(0xFF3A9650); // oklch(54% 0.16 145) — input focus border
  static const green400 = Color(0xFF55B36A); // oklch(64% 0.15 145) — gradient end, decorative
  static const green200 = Color(0xFFA8D9B4); // oklch(82% 0.10 145) — hover border, tint border
  static const green100 = Color(0xFFD4EDD9); // oklch(92% 0.06 145) — icon wells, badge bg
  static const green50  = Color(0xFFEBF6ED); // oklch(96% 0.03 145) — section alt bg, card tint

  // Semantic surfaces
  static const background = Color(0xFFEFF7F0); // oklch(97% 0.01 145)
  static const surface    = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE0EFE2); // oklch(90% 0.03 145)

  // Semantic text
  static const textPrimary   = Color(0xFF0F1F11); // oklch(14% 0.02 145) — headings
  static const textSecondary = Color(0xFF4A6B4F); // oklch(42% 0.04 145) — body
  static const textMuted     = Color(0xFF7A9B80); // oklch(62% 0.03 145) — captions, hints

  // Status colors
  static const accent  = Color(0xFF47B87A); // oklch(68% 0.16 160) — best value, highlight
  static const danger  = Color(0xFFB84040); // oklch(52% 0.18 25)  — error, missed
  static const warning = Color(0xFFD4A020); // oklch(72% 0.16 75)  — pending payment

  // Status semantic pairs
  static const successBg   = Color(0xFFD4EDD9);
  static const successText = Color(0xFF235C30);
  static const errorBg     = Color(0xFFF8E8E8);
  static const errorText   = Color(0xFFB84040);
  static const warningBg   = Color(0xFFFAF0D0);
  static const warningText = Color(0xFF8A6010);
  static const infoBg      = Color(0xFFE0ECFA);
  static const infoText    = Color(0xFF1E4A8A);
  static const grayBg      = Color(0xFFECEEEC);
  static const grayText    = Color(0xFF7A9B80);
}
