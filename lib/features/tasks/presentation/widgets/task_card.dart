import 'package:flutter/material.dart';

import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_badges.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? assigneeName;
  final String? projectName;
  final bool compact;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onDelete,
    this.assigneeName,
    this.projectName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semanticLabel = _buildSemanticLabel();
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 5,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (projectName != null) ...[
                            Text(
                              projectName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: scheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isDone
                                      ? context.taskflowColors.textSecondary
                                      : null,
                                ),
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        tooltip: 'Task actions',
                        onSelected: (value) {
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 18, color: scheme.error),
                                const SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: scheme.error)),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Icon(Icons.chevron_right_rounded,
                          color: context.taskflowColors.textTertiary),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    AppStatusBadge(status: task.status, compact: compact),
                    AppPriorityBadge(priority: task.priority, compact: compact),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        task.isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.schedule_rounded,
                        size: 16,
                        color: task.isOverdue
                            ? scheme.error
                            : context.taskflowColors.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          AppDateUtils.dueDateDisplay(task.dueDate!),
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: task.isOverdue
                                        ? scheme.error
                                        : context.taskflowColors.textTertiary,
                                    fontWeight:
                                        task.isOverdue ? FontWeight.w600 : null,
                                  ),
                        ),
                      ),
                    ] else
                      Text('No due date',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.taskflowColors.textTertiary)),
                    const Spacer(),
                    if (assigneeName != null)
                      UserAvatar(name: assigneeName!, radius: 13)
                    else ...[
                      Icon(
                          task.isAssigned
                              ? Icons.person_outline_rounded
                              : Icons.person_off_outlined,
                          size: 16,
                          color: context.taskflowColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(task.isAssigned ? 'Assigned' : 'Unassigned',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.taskflowColors.textTertiary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final parts = <String>[task.title];
    if (projectName != null) parts.add('in $projectName');
    parts.add('status ${task.status}');
    parts.add('priority ${task.priority}');
    if (task.dueDate != null) {
      parts.add(task.isOverdue
          ? 'overdue'
          : 'due ${AppDateUtils.dueDateDisplay(task.dueDate!)}');
    }
    if (assigneeName != null) {
      parts.add('assigned to $assigneeName');
    } else if (!task.isAssigned) {
      parts.add('unassigned');
    }
    return parts.join(', ');
  }

  Color _priorityColor(String priority) => switch (priority) {
        'urgent' => const Color(0xFFDC2626),
        'high' => const Color(0xFFF97316),
        'medium' => const Color(0xFFF59E0B),
        _ => const Color(0xFF64748B),
      };
}
