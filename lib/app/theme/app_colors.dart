import 'package:flutter/material.dart';

/// Brand and semantic colors used to construct TaskFlow themes.
///
/// Widgets should prefer [ColorScheme] and [TaskFlowColors] over selecting a
/// light-only color directly.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF5B5BD6);
  static const primaryLight = Color(0xFFA5B4FC);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryStrong = Color(0xFF4338CA);
  static const onPrimary = Colors.white;

  static const secondary = Color(0xFF0EA5E9);
  static const secondaryLight = Color(0xFF7DD3FC);
  static const secondaryDark = Color(0xFF0369A1);
  static const onSecondary = Colors.white;
  static const tertiary = Color(0xFF8B5CF6);
  static const tertiaryLight = Color(0xFFC4B5FD);

  static const backgroundLight = Color(0xFFF7F8FC);
  static const surfaceLight = Colors.white;
  static const cardLight = Colors.white;
  static const surfaceTonalLight = Color(0xFFEEF0FF);

  static const backgroundDark = Color(0xFF0B1020);
  static const surfaceDark = Color(0xFF151B2E);
  static const cardDark = Color(0xFF182036);
  static const surfaceTonalDark = Color(0xFF202943);

  static const textPrimaryLight = Color(0xFF171A2B);
  static const textSecondaryLight = Color(0xFF62677D);
  static const textTertiaryLight = Color(0xFF81869A);
  static const textPrimaryDark = Color(0xFFF4F6FF);
  static const textSecondaryDark = Color(0xFFAAB2CC);
  static const textTertiaryDark = Color(0xFF7D87A4);

  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  static const priorityUrgent = Color(0xFFDC2626);
  static const priorityHigh = Color(0xFFF97316);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityLow = Color(0xFF64748B);

  static const statusTodo = Color(0xFF64748B);
  static const statusInProgress = Color(0xFF3B82F6);
  static const statusReview = Color(0xFF8B5CF6);
  static const statusDone = Color(0xFF10B981);

  static const dividerLight = Color(0xFFE3E6F0);
  static const dividerDark = Color(0xFF303A56);
  static const borderLight = Color(0xFFD5D9E7);
  static const borderDark = Color(0xFF3A4562);

  static const shimmerBase = Color(0xFFE5E8F2);
  static const shimmerHighlight = Color(0xFFF4F5FA);
  static const offlineBanner = Color(0xFFFBBF24);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );
}
