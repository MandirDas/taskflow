import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/widgets/accessibility.dart';
import '../../../../core/widgets/app_badges.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final session = auth is AuthAuthenticated ? auth.session : null;
    return BlocProvider(
      create: (_) => DashboardCubit(
        projectRepository: sl<ProjectRepository>(),
        taskRepository: sl<TaskRepository>(),
        networkInfo: sl<NetworkInfo>(),
      )..load(orgId: session?.orgId ?? '', userName: session?.name ?? 'there'),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<DashboardCubit, DashboardState>(
          listener: (context, state) {
            if (state is DashboardSuccess) {
              AppAccessibility.announceDelayed(
                context,
                'Dashboard loaded. ${state.todoCount} to do, '
                '${state.inProgressCount} in progress, '
                '${state.doneCount} done.',
              );
            } else if (state is DashboardError) {
              AppAccessibility.announce(
                  context, 'Dashboard error: ${state.message}');
            }
          },
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) => AppFadeSwitcher(
              child: switch (state) {
                DashboardInitial() ||
                DashboardLoading() =>
                  const _DashboardSkeleton(key: ValueKey('skeleton')),
                DashboardError(:final message) => ErrorDisplayWidget(
                    key: const ValueKey('error'),
                    message: message,
                    onRetry: context.read<DashboardCubit>().refresh),
                DashboardEmpty(:final userName) => _DashboardEmptyView(
                    key: const ValueKey('empty'), userName: userName),
                DashboardSuccess() => _DashboardContent(
                    key: const ValueKey('content'), state: state),
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _DashboardEmptyView extends StatelessWidget {
  final String userName;
  const _DashboardEmptyView({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(userName: userName),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'All clear for now!',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "You're all caught up. New tasks will\nappear here when they're assigned.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: context.taskflowColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton(
                    onPressed: () => context.go(RouteNames.projects),
                    child: const Text('Browse projects'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final DashboardSuccess state;
  const _DashboardContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<DashboardCubit>().refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _PageHeader(userName: state.userName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _ProgressHero(state: state),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _StatsRow(state: state),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SectionHeader(
              title: 'Focus today',
              subtitle: 'The work that needs your attention next',
              action: TextButton(
                onPressed: () => context.go(RouteNames.tasks),
                child: const Text('View all'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.focusTasks.map((task) => _FocusTaskCard(task: task)),
          if (state.focusTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _AllClearCard(),
            ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SectionHeader(
              title: 'Recent projects',
              subtitle: '${state.projects.length} projects',
              action: TextButton(
                onPressed: () => context.go(RouteNames.projects),
                child: const Text('View all'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: state.projects.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => _ProjectMiniCard(
                project: state.projects[index],
                taskCount: state.tasks
                    .where((t) => t.projectId == state.projects[index].id)
                    .length,
                doneCount: state.tasks
                    .where((t) =>
                        t.projectId == state.projects[index].id && t.isDone)
                    .length,
                onTap: () => context.push(
                    RouteNames.projectDetailPath(state.projects[index].id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final String userName;
  const _PageHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, $firstName',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.taskflowColors.textSecondary),
                ),
              ],
            ),
          ),
          UserAvatar(name: userName, radius: 20),
        ],
      ),
    );
  }
}

// ─── Progress Hero ────────────────────────────────────────────────────────────

class _ProgressHero extends StatelessWidget {
  final DashboardSuccess state;
  const _ProgressHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final percent = (state.completion * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace progress',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  percent >= 80
                      ? 'Strong finish in sight.'
                      : percent >= 40
                          ? 'Momentum is building.'
                          : 'Every task moves the plan forward.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${state.doneCount} of ${state.tasks.length} tasks complete\nacross ${state.projects.length} projects',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: AppMotion.reduceMotion(context) ? state.completion : 0,
              end: state.completion,
            ),
            duration: AppMotion.duration(context, AppMotion.emphasized),
            curve: AppMotion.standardCurve,
            builder: (context, value, _) => SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    color: Colors.white,
                  ),
                  Text(
                    '${(value * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row (2×2 grid) ─────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardSuccess state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.radio_button_unchecked_rounded,
                color: context.taskflowColors.statusTodo,
                count: state.todoCount,
                label: 'To do',
                onTap: () => context.go(RouteNames.tasks),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                icon: Icons.timelapse_rounded,
                color: context.taskflowColors.statusInProgress,
                count: state.inProgressCount,
                label: 'In progress',
                onTap: () => context.go(RouteNames.tasks),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_outline_rounded,
                color: context.taskflowColors.statusDone,
                count: state.doneCount,
                label: 'Completed',
                onTap: () => context.go(RouteNames.tasks),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                icon: Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
                count: state.overdueCount,
                label: 'Overdue',
                onTap: () => context.go(RouteNames.tasks),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$count',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.taskflowColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: context.taskflowColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Focus Task Card ──────────────────────────────────────────────────────────

class _FocusTaskCard extends StatelessWidget {
  final TaskEntity task;
  const _FocusTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs / 2),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          AppStatusBadge(status: task.status, compact: true),
                          AppPriorityBadge(
                              priority: task.priority, compact: true),
                        ],
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: task.isOverdue
                                  ? Theme.of(context).colorScheme.error
                                  : context.taskflowColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due ${DateFormat('MMM d').format(task.dueDate!)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: task.isOverdue
                                        ? Theme.of(context).colorScheme.error
                                        : context.taskflowColors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                UserAvatar(
                  name: task.assigneeId ?? '?',
                  radius: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── All Clear Card ───────────────────────────────────────────────────────────

class _AllClearCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.taskflowColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.done_all_rounded,
                  color: context.taskflowColors.success),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'No overdue or upcoming work needs immediate attention.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Project Mini Card ────────────────────────────────────────────────────────

class _ProjectMiniCard extends StatelessWidget {
  final ProjectEntity project;
  final int taskCount;
  final int doneCount;
  final VoidCallback onTap;

  const _ProjectMiniCard({
    required this.project,
    required this.taskCount,
    required this.doneCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = taskCount > 0 ? doneCount / taskCount : 0.0;
    final percent = (progress * 100).round();
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 152,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.folder_outlined,
                          size: 20, color: scheme.primary),
                    ),
                    const Spacer(),
                    Icon(Icons.more_vert_rounded,
                        size: 18, color: context.taskflowColors.textTertiary),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  project.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$taskCount tasks',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.taskflowColors.textTertiary),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor:
                              scheme.primary.withValues(alpha: 0.12),
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.taskflowColors.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton Loading ─────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatefulWidget {
  const _DashboardSkeleton({super.key});

  @override
  State<_DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<_DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.5,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotion(context);
    final color = context.taskflowColors.surfaceTonal;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = reduceMotion ? 0.7 : _controller.value;
        return Opacity(
          opacity: opacity,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Header skeleton
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: 200, height: 22, color: color),
                        const SizedBox(height: 8),
                        _SkeletonBox(width: 130, height: 14, color: color),
                      ],
                    ),
                  ),
                  _SkeletonBox(width: 40, height: 40, color: color, radius: 20),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Hero skeleton
              _SkeletonBox(
                  width: double.infinity,
                  height: 140,
                  color: color,
                  radius: 20),
              const SizedBox(height: AppSpacing.lg),
              // Stats skeleton
              Row(
                children: [
                  Expanded(
                      child: _SkeletonBox(
                          width: double.infinity,
                          height: 52,
                          color: color,
                          radius: 14)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _SkeletonBox(
                          width: double.infinity,
                          height: 52,
                          color: color,
                          radius: 14)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                      child: _SkeletonBox(
                          width: double.infinity,
                          height: 52,
                          color: color,
                          radius: 14)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: _SkeletonBox(
                          width: double.infinity,
                          height: 52,
                          color: color,
                          radius: 14)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Focus section skeleton
              _SkeletonBox(width: 140, height: 16, color: color),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SkeletonBox(
                      width: double.infinity,
                      height: 88,
                      color: color,
                      radius: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
