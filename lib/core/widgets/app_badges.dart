import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/taskflow_theme.dart';
import '../utils/constants.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const AppStatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.taskflowColors;
    final (color, icon) = switch (status) {
      TaskStatus.inProgress => (
          colors.statusInProgress,
          Icons.timelapse_rounded
        ),
      TaskStatus.review => (colors.statusReview, Icons.visibility_outlined),
      TaskStatus.done => (
          colors.statusDone,
          Icons.check_circle_outline_rounded
        ),
      _ => (colors.statusTodo, Icons.radio_button_unchecked_rounded),
    };
    final label = TaskStatus.displayName(status);
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPriorityBadge extends StatelessWidget {
  final String priority;
  final bool compact;

  const AppPriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (priority) {
      TaskPriority.urgent => (AppColors.priorityUrgent, Icons.priority_high),
      TaskPriority.high => (AppColors.priorityHigh, Icons.arrow_upward_rounded),
      TaskPriority.low => (AppColors.priorityLow, Icons.arrow_downward_rounded),
      _ => (AppColors.priorityMedium, Icons.drag_handle_rounded),
    };
    final label = TaskPriority.displayName(priority);
    return Semantics(
      label: 'Priority: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 5,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
