import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color secondary = Color(0xFF0F172A);
  static const Color accent = Color(0xFF6366F1);
  static const Color accentSoft = Color(0xFFE0E7FF);

  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color online = Color(0xFF0F766E);
  static const Color offline = Color(0xFF64748B);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF111C2E);
  static const Color darkSurfaceSoft = Color(0xFF17233A);
  static const Color darkBorder = Color(0xFF24324A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkGlass = Color(0xDD0F172A);
  static const Color lightGlass = Color(0xDDF8FAFC);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF0F766E), Color(0xFF6366F1)],
    stops: [0.0, 0.58, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
  );
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double page = 20;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
  static const double button = 18;
  static const double card = 22;
  static const double sheet = 28;
}

abstract final class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.09),
      blurRadius: 26,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.18),
      blurRadius: 36,
      offset: const Offset(0, 18),
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.24),
      blurRadius: 34,
      spreadRadius: 1,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> toast = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.24),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration page = Duration(milliseconds: 350);
  static const Duration toast = Duration(milliseconds: 3200);
  static const Duration splash = Duration(milliseconds: 2200);
  static const Duration shimmer = Duration(milliseconds: 1200);
}
