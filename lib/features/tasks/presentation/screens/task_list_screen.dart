import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/motion.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../cubit/task_list_cubit.dart';
import '../cubit/task_list_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_sheet.dart';

enum _TaskSort { dueSoon, priority, newest, status }

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = TaskListCubit(
            taskRepository: sl<TaskRepository>(),
            projectRepository: sl<ProjectRepository>());
        final auth = context.read<AuthCubit>().state;
        if (auth is AuthAuthenticated) {
          cubit.loadTasksForOrg(auth.session.orgId);
        }
        return cubit;
      },
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatefulWidget {
  const _TaskListView();

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  final _searchController = TextEditingController();
  String _query = '';
  _TaskSort _sort = _TaskSort.dueSoon;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context).tasksTitle,
      subtitle: AppLocalizations.of(context).tasksSubtitle,
      actions: [
        BlocBuilder<TaskListCubit, TaskListState>(
          builder: (context, state) {
            final count =
                context.read<TaskListCubit>().currentFilter.activeCount;
            return IconButton(
              tooltip:
                  count == 0 ? 'Filter tasks' : 'Filter tasks, $count active',
              onPressed: _showFilters,
              icon: Badge.count(
                  count: count,
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.tune_rounded)),
            );
          },
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(RouteNames.createTask);
          if (mounted) await _refresh();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: BlocBuilder<TaskListCubit, TaskListState>(
        builder: (context, state) => AppFadeSwitcher(
          child: switch (state) {
            TaskListInitial() || TaskListLoading() => const ShimmerLoadingList(
                key: ValueKey('loading'), itemCount: 6, itemHeight: 132),
            TaskListError(:final message) => ErrorDisplayWidget(
                key: const ValueKey('error'),
                message: message,
                onRetry: _refresh),
            TaskListEmpty() => _TaskEmpty(
                key: const ValueKey('empty'),
                state: state,
                onCreate: () async {
                  await context.push(RouteNames.createTask);
                  if (mounted) await _refresh();
                }),
            TaskListSuccess() => _buildTaskList(state),
            _ => const SizedBox.shrink(key: ValueKey('unknown')),
          },
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskListSuccess state) {
    final tasks = state.tasks.where((task) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();
    _sortTasks(tasks);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        key: const ValueKey('tasks'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (state.activeFilter.isActive)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: InputChip(
                              avatar: const Icon(Icons.filter_list_rounded,
                                  size: 16),
                              label: Text(
                                  '${state.activeFilter.activeCount} active'),
                              onDeleted:
                                  context.read<TaskListCubit>().clearFilters,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      PopupMenuButton<_TaskSort>(
                        tooltip: 'Sort tasks',
                        initialValue: _sort,
                        onSelected: (value) => setState(() => _sort = value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: _TaskSort.dueSoon,
                              child: Text('Due soon')),
                          PopupMenuItem(
                              value: _TaskSort.priority,
                              child: Text('Priority')),
                          PopupMenuItem(
                              value: _TaskSort.newest,
                              child: Text('Recently created')),
                          PopupMenuItem(
                              value: _TaskSort.status, child: Text('Status')),
                        ],
                        child: Chip(
                            avatar: const Icon(Icons.sort_rounded, size: 16),
                            label: Text(_sortLabel)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (tasks.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                  title: 'No matching tasks',
                  subtitle: 'Try another search or remove a filter.',
                  icon: Icons.search_off_rounded),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              sliver: SliverList.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () async {
                      await context.push(RouteNames.taskDetailPath(task.id));
                      if (mounted) await _refresh();
                    },
                    onDelete: () => _confirmDelete(task),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String get _sortLabel => switch (_sort) {
        _TaskSort.dueSoon => 'Due soon',
        _TaskSort.priority => 'Priority',
        _TaskSort.newest => 'Newest',
        _TaskSort.status => 'Status',
      };

  void _sortTasks(List<TaskEntity> tasks) {
    const ranks = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
    switch (_sort) {
      case _TaskSort.dueSoon:
        tasks.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case _TaskSort.priority:
        tasks.sort((a, b) =>
            (ranks[a.priority] ?? 4).compareTo(ranks[b.priority] ?? 4));
      case _TaskSort.newest:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _TaskSort.status:
        tasks.sort((a, b) => a.status.compareTo(b.status));
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) {
      await context.read<TaskListCubit>().loadTasksForOrg(auth.session.orgId);
    }
  }

  void _showFilters() {
    final cubit = context.read<TaskListCubit>();
    TaskFilterSheet.show(
        context: context,
        currentFilter: cubit.currentFilter,
        onApply: cubit.applyFilter);
  }

  Future<void> _confirmDelete(TaskEntity task) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete task',
      message: 'Delete “${task.title}”?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      await context.read<TaskListCubit>().deleteTask(task.id);
    }
  }
}

class _TaskEmpty extends StatelessWidget {
  final TaskListEmpty state;
  final VoidCallback onCreate;
  const _TaskEmpty({super.key, required this.state, required this.onCreate});

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
        title: state.activeFilter.isActive
            ? 'No tasks match your filters'
            : 'Create your first task',
        subtitle: state.activeFilter.isActive
            ? 'Adjust the filters to see more work.'
            : 'Choose a project and define the next clear action.',
        icon: state.activeFilter.isActive
            ? Icons.filter_alt_off_outlined
            : Icons.add_task_rounded,
        actionLabel:
            state.activeFilter.isActive ? 'Clear Filters' : 'Create Task',
        onAction: state.activeFilter.isActive
            ? context.read<TaskListCubit>().clearFilters
            : onCreate,
      );
}
