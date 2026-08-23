import 'package:flutter/material.dart';

import 'app_colors.dart';

/// TaskFlow-specific semantic colors not represented by Material ColorScheme.
@immutable
class TaskFlowColors extends ThemeExtension<TaskFlowColors> {
  final Color surfaceTonal;
  final Color border;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color info;
  final Color statusTodo;
  final Color statusInProgress;
  final Color statusReview;
  final Color statusDone;

  const TaskFlowColors({
    required this.surfaceTonal,
    required this.border,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.info,
    required this.statusTodo,
    required this.statusInProgress,
    required this.statusReview,
    required this.statusDone,
  });

  static const light = TaskFlowColors(
    surfaceTonal: AppColors.surfaceTonalLight,
    border: AppColors.borderLight,
    textSecondary: AppColors.textSecondaryLight,
    textTertiary: AppColors.textTertiaryLight,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    statusTodo: AppColors.statusTodo,
    statusInProgress: AppColors.statusInProgress,
    statusReview: AppColors.statusReview,
    statusDone: AppColors.statusDone,
  );

  static const dark = TaskFlowColors(
    surfaceTonal: AppColors.surfaceTonalDark,
    border: AppColors.borderDark,
    textSecondary: AppColors.textSecondaryDark,
    textTertiary: AppColors.textTertiaryDark,
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    statusTodo: Color(0xFF94A3B8),
    statusInProgress: Color(0xFF60A5FA),
    statusReview: Color(0xFFC4B5FD),
    statusDone: Color(0xFF34D399),
  );

  @override
  TaskFlowColors copyWith({
    Color? surfaceTonal,
    Color? border,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? info,
    Color? statusTodo,
    Color? statusInProgress,
    Color? statusReview,
    Color? statusDone,
  }) {
    return TaskFlowColors(
      surfaceTonal: surfaceTonal ?? this.surfaceTonal,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      statusTodo: statusTodo ?? this.statusTodo,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusReview: statusReview ?? this.statusReview,
      statusDone: statusDone ?? this.statusDone,
    );
  }

  @override
  TaskFlowColors lerp(covariant TaskFlowColors? other, double t) {
    if (other == null) return this;
    return TaskFlowColors(
      surfaceTonal: Color.lerp(surfaceTonal, other.surfaceTonal, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      statusTodo: Color.lerp(statusTodo, other.statusTodo, t)!,
      statusInProgress:
          Color.lerp(statusInProgress, other.statusInProgress, t)!,
      statusReview: Color.lerp(statusReview, other.statusReview, t)!,
      statusDone: Color.lerp(statusDone, other.statusDone, t)!,
    );
  }
}

extension TaskFlowThemeContext on BuildContext {
  TaskFlowColors get taskflowColors =>
      Theme.of(this).extension<TaskFlowColors>() ?? TaskFlowColors.light;
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadii {
  AppRadii._();

  static const double chip = 10;
  static const double control = 14;
  static const double card = 18;
  static const double modal = 26;
}
