import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_badges.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../cubit/task_detail_cubit.dart';
import '../cubit/task_detail_state.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final orgId = auth is AuthAuthenticated ? auth.session.orgId : '';
    return BlocProvider(
      create: (_) => TaskDetailCubit(
        taskRepository: sl<TaskRepository>(),
        userRepository: sl<UserRepository>(),
        orgId: orgId,
      )..loadTask(taskId),
      child: _TaskDetailView(taskId: taskId),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  final String taskId;
  const _TaskDetailView({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Task details',
      subtitle: 'Update progress, ownership, and conversation.',
      actions: [
        IconButton(
          tooltip: 'Edit task',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            await context.push(RouteNames.editTaskPath(taskId));
            if (context.mounted) {
              await context.read<TaskDetailCubit>().loadTask(taskId);
            }
          },
        ),
        IconButton(
          tooltip: 'Delete task',
          icon: Icon(Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error),
          onPressed: () => _confirmDelete(context),
        ),
      ],
      body: BlocBuilder<TaskDetailCubit, TaskDetailState>(
        builder: (context, state) => AppFadeSwitcher(
          child: switch (state) {
            TaskDetailInitial() ||
            TaskDetailLoading() =>
              const ShimmerLoadingList(
                  key: ValueKey('loading'), itemCount: 5, itemHeight: 106),
            TaskDetailError(:final message) => ErrorDisplayWidget(
                key: const ValueKey('error'),
                message: message,
                onRetry: () =>
                    context.read<TaskDetailCubit>().loadTask(taskId)),
            TaskDetailSuccess() => _TaskDetailContent(
                key: const ValueKey('content'), state: state, taskId: taskId),
            _ => const SizedBox.shrink(key: ValueKey('unknown')),
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete task',
      message: 'Delete this task and its local activity?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await sl<TaskRepository>().deleteTask(taskId);
      if (context.mounted) context.pop(true);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete task: $error')));
      }
    }
  }
}

class _TaskDetailContent extends StatelessWidget {
  final TaskDetailSuccess state;
  final String taskId;
  const _TaskDetailContent(
      {super.key, required this.state, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<TaskDetailCubit>().loadTask(taskId),
      child: ResponsiveContent(
        maxWidth: 860,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            _TaskHero(task: state.task),
            const SizedBox(height: AppSpacing.md),
            _PlanningCard(task: state.task, taskId: taskId),
            const SizedBox(height: AppSpacing.md),
            _AssigneeCard(
              assignee: state.assignee,
              members: state.orgMembers,
              onAssign: (userId) =>
                  context.read<TaskDetailCubit>().assignUser(taskId, userId),
            ),
            if (state.task.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Description'),
              const SizedBox(height: AppSpacing.sm),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(state.task.description))),
            ],
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
                title: 'Activity',
                subtitle:
                    '${state.comments.length} ${state.comments.length == 1 ? 'comment' : 'comments'}'),
            const SizedBox(height: AppSpacing.sm),
            _Comments(
              comments: state.comments,
              members: state.orgMembers,
              onAdd: (body) {
                final auth = context.read<AuthCubit>().state;
                if (auth is AuthAuthenticated) {
                  context
                      .read<TaskDetailCubit>()
                      .addComment(taskId, auth.session.userId, body);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskHero extends StatelessWidget {
  final TaskEntity task;
  const _TaskHero({required this.task});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.taskflowColors.surfaceTonal,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.taskflowColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: [
              AppStatusBadge(status: task.status),
              AppPriorityBadge(priority: task.priority)
            ]),
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Icon(
                  task.isOverdue
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_outlined,
                  size: 17,
                  color: task.isOverdue
                      ? Theme.of(context).colorScheme.error
                      : context.taskflowColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                  task.dueDate == null
                      ? 'No due date'
                      : AppDateUtils.dueDateDisplay(task.dueDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: task.isOverdue
                          ? Theme.of(context).colorScheme.error
                          : context.taskflowColors.textSecondary)),
            ]),
          ],
        ),
      );
}

class _PlanningCard extends StatelessWidget {
  final TaskEntity task;
  final String taskId;
  const _PlanningCard({required this.task, required this.taskId});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Planning', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final fields = [
                  DropdownButtonFormField<String>(
                    value: task.status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: TaskStatus.all
                        .map((status) => DropdownMenuItem(
                            value: status,
                            child: AppStatusBadge(status: status)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<TaskDetailCubit>()
                            .updateStatus(taskId, value);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: task.priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: TaskPriority.all
                        .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: AppPriorityBadge(priority: priority)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<TaskDetailCubit>()
                            .updatePriority(taskId, value);
                      }
                    },
                  ),
                ];
                return compact
                    ? Column(children: [
                        fields[0],
                        const SizedBox(height: AppSpacing.md),
                        fields[1]
                      ])
                    : Row(children: [
                        Expanded(child: fields[0]),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: fields[1])
                      ]);
              }),
            ],
          ),
        ),
      );
}

class _AssigneeCard extends StatelessWidget {
  final UserEntity? assignee;
  final List<UserEntity> members;
  final ValueChanged<String?> onAssign;
  const _AssigneeCard(
      {required this.assignee, required this.members, required this.onAssign});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          leading: UserAvatar(
              name: assignee?.name ?? 'Unassigned',
              imageUrl: assignee?.avatarUrl),
          title: const Text('Assignee'),
          subtitle: Text(assignee?.name ?? 'Unassigned'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => showModalBottomSheet(
            context: context,
            useSafeArea: true,
            builder: (sheetContext) => SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text('Assign task',
                          style: Theme.of(context).textTheme.titleLarge)),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.person_off_outlined)),
                          title: const Text('Unassigned'),
                          trailing: assignee == null
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () {
                            onAssign(null);
                            Navigator.pop(sheetContext);
                          },
                        ),
                        ...members.map((user) => ListTile(
                              leading: UserAvatar(
                                  name: user.name,
                                  imageUrl: user.avatarUrl,
                                  radius: 18),
                              title: Text(user.name),
                              subtitle: Text(user.email),
                              trailing: assignee?.id == user.id
                                  ? const Icon(Icons.check_rounded)
                                  : null,
                              onTap: () {
                                onAssign(user.id);
                                Navigator.pop(sheetContext);
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Comments extends StatefulWidget {
  final List<CommentEntity> comments;
  final List<UserEntity> members;
  final ValueChanged<String> onAdd;
  const _Comments(
      {required this.comments, required this.members, required this.onAdd});

  @override
  State<_Comments> createState() => _CommentsState();
}

class _CommentsState extends State<_Comments> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  UserEntity? _author(String id) =>
      widget.members.where((user) => user.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                              hintText: 'Add a comment…',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none))),
                  IconButton(
                    tooltip: 'Send comment',
                    onPressed: () {
                      final value = _controller.text.trim();
                      if (value.isEmpty) return;
                      widget.onAdd(value);
                      _controller.clear();
                    },
                    icon: Icon(Icons.send_rounded,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...widget.comments.map((comment) {
            final author = _author(comment.authorId);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(
                          name: author?.name ?? 'Unknown',
                          imageUrl: author?.avatarUrl,
                          radius: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Expanded(
                                  child: Text(author?.name ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge)),
                              Text(AppDateUtils.timeAgo(comment.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: context
                                              .taskflowColors.textTertiary))
                            ]),
                            const SizedBox(height: 6),
                            Text(comment.body),
                          ])),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
}
