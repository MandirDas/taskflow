import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../cubit/project_detail_cubit.dart';
import '../cubit/project_detail_state.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectDetailCubit(
        projectRepository: sl<ProjectRepository>(),
        taskRepository: sl<TaskRepository>(),
      )..loadProject(projectId),
      child: _ProjectDetailView(projectId: projectId),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  final String projectId;
  const _ProjectDetailView({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Project details',
      subtitle: 'Progress, priorities, and next actions.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(RouteNames.createTaskForProject(projectId));
          if (context.mounted) {
            await context.read<ProjectDetailCubit>().loadProject(projectId);
          }
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Add Task'),
      ),
      body: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
        builder: (context, state) => AppFadeSwitcher(
          child: switch (state) {
            ProjectDetailInitial() ||
            ProjectDetailLoading() =>
              const ShimmerLoadingList(
                  key: ValueKey('loading'), itemCount: 5, itemHeight: 112),
            ProjectDetailError(:final message) => ErrorDisplayWidget(
                key: const ValueKey('error'),
                message: message,
                onRetry: () =>
                    context.read<ProjectDetailCubit>().loadProject(projectId)),
            ProjectDetailSuccess() => _ProjectContent(
                key: const ValueKey('content'),
                state: state,
                projectId: projectId),
            _ => const SizedBox.shrink(key: ValueKey('unknown')),
          },
        ),
      ),
    );
  }
}

class _ProjectContent extends StatelessWidget {
  final ProjectDetailSuccess state;
  final String projectId;
  const _ProjectContent(
      {super.key, required this.state, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<ProjectDetailCubit>().loadProject(projectId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProjectHero(
                    project: state.project,
                    totalTasks: state.tasks.length,
                    doneTasks: state.statusCounts[TaskStatus.done] ?? 0),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                    title: 'Task summary',
                    subtitle: '${state.tasks.length} tasks across every stage'),
                const SizedBox(height: AppSpacing.sm),
                _StatusSummary(statusCounts: state.statusCounts),
                const SizedBox(height: AppSpacing.xxl),
                SectionHeader(
                    title: 'Tasks',
                    subtitle: state.tasks.isEmpty
                        ? 'Add the first action for this project.'
                        : 'Open a task to update its progress.'),
                const SizedBox(height: AppSpacing.sm),
                if (state.tasks.isEmpty)
                  EmptyStateWidget(
                    fullScreen: false,
                    title: 'No tasks yet',
                    subtitle: 'Turn this project into a clear next action.',
                    icon: Icons.task_outlined,
                    actionLabel: 'Add Task',
                    onAction: () async {
                      await context
                          .push(RouteNames.createTaskForProject(projectId));
                      if (context.mounted) {
                        await context
                            .read<ProjectDetailCubit>()
                            .loadProject(projectId);
                      }
                    },
                  )
                else
                  ...state.tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: TaskCard(
                          task: task,
                          onTap: () async {
                            await context
                                .push(RouteNames.taskDetailPath(task.id));
                            if (context.mounted) {
                              await context
                                  .read<ProjectDetailCubit>()
                                  .loadProject(projectId);
                            }
                          },
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectHero extends StatelessWidget {
  final ProjectEntity project;
  final int totalTasks;
  final int doneTasks;
  const _ProjectHero(
      {required this.project,
      required this.totalTasks,
      required this.doneTasks});

  @override
  Widget build(BuildContext context) {
    final completion = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;
    return Hero(
      tag: 'project-card-${project.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.taskflowColors.surfaceTonal,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.taskflowColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(16)),
                    child:
                        const Icon(Icons.folder_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: Text(project.name,
                          style: Theme.of(context).textTheme.headlineMedium)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: context.taskflowColors.success
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.chip)),
                    child: Text('Active',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: context.taskflowColors.success)),
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.taskflowColors.textSecondary)),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 15, color: context.taskflowColors.textTertiary),
                  const SizedBox(width: 6),
                  Text('Created ${AppDateUtils.formatDate(project.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.taskflowColors.textTertiary)),
                  const Spacer(),
                  Text('${(completion * 100).round()}% complete',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TweenAnimationBuilder<double>(
                tween: Tween(
                    begin: AppMotion.reduceMotion(context) ? completion : 0,
                    end: completion),
                duration: AppMotion.duration(context, AppMotion.emphasized),
                curve: AppMotion.standardCurve,
                builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final Map<String, int> statusCounts;
  const _StatusSummary({required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        TaskStatus.todo,
        Icons.radio_button_unchecked_rounded,
        context.taskflowColors.statusTodo
      ),
      (
        TaskStatus.inProgress,
        Icons.timelapse_rounded,
        context.taskflowColors.statusInProgress
      ),
      (
        TaskStatus.review,
        Icons.visibility_outlined,
        context.taskflowColors.statusReview
      ),
      (
        TaskStatus.done,
        Icons.check_circle_outline_rounded,
        context.taskflowColors.statusDone
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 700 ? 4 : 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: constraints.maxWidth >= 700 ? 1.7 : 1.55,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
                color: item.$3.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: item.$3.withValues(alpha: 0.18))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: item.$3),
                const SizedBox(height: 4),
                Text('${statusCounts[item.$1] ?? 0}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: item.$3)),
                Text(TaskStatus.displayName(item.$1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: item.$3)),
              ],
            ),
          );
        },
      ),
    );
  }
}
