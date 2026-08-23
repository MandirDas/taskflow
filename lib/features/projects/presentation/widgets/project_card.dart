import 'package:flutter/material.dart';

import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool compact;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Hero(
      tag: 'project-card-${project.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Padding(
              padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: compact ? 42 : 48,
                        height: compact ? 42 : 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary.withValues(alpha: 0.16),
                              scheme.tertiary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            Icon(Icons.folder_rounded, color: scheme.primary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${project.taskCount} ${project.taskCount == 1 ? 'task' : 'tasks'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: context.taskflowColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          tooltip: 'Project actions',
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Edit'),
                                ),
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.delete_outline_rounded,
                                      color: scheme.error),
                                  title: Text('Delete',
                                      style: TextStyle(color: scheme.error)),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      project.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.taskflowColors.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 15, color: context.taskflowColors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Created ${AppDateUtils.formatDate(project.createdAt)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.taskflowColors.textTertiary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.taskflowColors.success
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.chip),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 13,
                                color: context.taskflowColors.success),
                            const SizedBox(width: 4),
                            Text('Active',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: context.taskflowColors.success)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
