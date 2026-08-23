import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_badges.dart';
import '../../../../core/widgets/async_action_button.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../projects/domain/repositories/project_repository.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../cubit/task_form_cubit.dart';

class TaskFormScreen extends StatelessWidget {
  final String? taskId;
  final String? projectId;

  const TaskFormScreen({super.key, this.taskId, this.projectId});

  bool get isEditing => taskId != null;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final orgId = auth is AuthAuthenticated ? auth.session.orgId : '';
    return BlocProvider(
      create: (_) {
        final cubit = TaskFormCubit(
          taskRepository: sl<TaskRepository>(),
          userRepository: sl<UserRepository>(),
          projectRepository: sl<ProjectRepository>(),
          orgId: orgId,
        );
        isEditing ? cubit.initEdit(taskId!) : cubit.initCreate();
        return cubit;
      },
      child: _TaskFormView(
          taskId: taskId, projectId: projectId, isEditing: isEditing),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  final String? taskId;
  final String? projectId;
  final bool isEditing;
  const _TaskFormView({this.taskId, this.projectId, required this.isEditing});

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = TaskPriority.medium;
  String? _assigneeId;
  String? _selectedProjectId;
  DateTime? _dueDate;
  bool _populated = false;
  TaskFormReady? _lastReady;
  String? _submitError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _populate(TaskFormReady state) {
    _lastReady = state;
    if (_populated) return;
    _populated = true;
    final task = state.existingTask;
    _selectedProjectId = widget.projectId ?? task?.projectId;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _priority = task.priority;
      _assigneeId = task.assigneeId;
      _dueDate = task.dueDate;
    }
  }

  void _submit() {
    setState(() => _submitError = null);
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<TaskFormCubit>();
    if (widget.isEditing) {
      cubit.updateTask(
        taskId: widget.taskId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
      );
    } else {
      if (_selectedProjectId == null) {
        setState(
            () => _submitError = 'Choose a project before creating this task.');
        return;
      }
      cubit.createTask(
        projectId: _selectedProjectId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        assigneeId: _assigneeId,
        dueDate: _dueDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isEditing ? 'Edit task' : 'Create task')),
      body: BlocConsumer<TaskFormCubit, TaskFormState>(
        listener: (context, state) {
          if (state is TaskFormReady) _populate(state);
          if (state is TaskFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(widget.isEditing ? 'Task updated' : 'Task created'),
                backgroundColor: AppColors.success));
            context.pop(true);
          }
          if (state is TaskFormError && _lastReady != null) {
            setState(() => _submitError = state.message);
          }
        },
        builder: (context, state) {
          if ((state is TaskFormLoading || state is TaskFormInitial) &&
              _lastReady == null) {
            return const ShimmerLoadingList(itemCount: 5, itemHeight: 72);
          }
          if (state is TaskFormReady) _populate(state);
          if (state is TaskFormError && _lastReady == null) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => widget.isEditing
                  ? context.read<TaskFormCubit>().initEdit(widget.taskId!)
                  : context.read<TaskFormCubit>().initCreate(),
            );
          }
          final ready = state is TaskFormReady ? state : _lastReady;
          if (ready == null) return const LoadingWidget();
          return _buildForm(ready, submitting: state is TaskFormSubmitting);
        },
      ),
    );
  }

  Widget _buildForm(TaskFormReady state, {required bool submitting}) {
    final lockedProject = widget.projectId != null || widget.isEditing;
    final selectedProject = state.projects
        .where((project) => project.id == _selectedProjectId)
        .firstOrNull;
    return ResponsiveContent(
      maxWidth: 680,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormSection(
                icon: Icons.task_alt_rounded,
                title: 'Task essentials',
                subtitle: 'Give the work a clear home and outcome.',
                child: Column(
                  children: [
                    if (lockedProject)
                      InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Project',
                            prefixIcon: Icon(Icons.folder_outlined)),
                        child: Text(
                            selectedProject?.name ?? 'Project unavailable'),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedProjectId,
                        decoration: const InputDecoration(
                            labelText: 'Project',
                            hintText: 'Choose a project',
                            prefixIcon: Icon(Icons.folder_outlined)),
                        validator: (value) =>
                            value == null ? 'Please select a project' : null,
                        items: state.projects
                            .map((project) => DropdownMenuItem(
                                value: project.id,
                                child: Text(project.name,
                                    overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: submitting
                            ? null
                            : (value) =>
                                setState(() => _selectedProjectId = value),
                      ),
                    if (state.projects.isEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text('Create a project before adding a task.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _titleController,
                      validator: Validators.taskTitle,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'What needs to be done?',
                          prefixIcon: Icon(Icons.title_rounded)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Add useful context or an expected outcome',
                          prefixIcon: Icon(Icons.notes_rounded),
                          alignLabelWithHint: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FormSection(
                icon: Icons.event_note_rounded,
                title: 'Planning',
                subtitle: 'Set urgency and a realistic target date.',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.flag_outlined)),
                      items: TaskPriority.all
                          .map((priority) => DropdownMenuItem(
                              value: priority,
                              child: AppPriorityBadge(priority: priority)))
                          .toList(),
                      onChanged: submitting
                          ? null
                          : (value) =>
                              setState(() => _priority = value ?? _priority),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: submitting ? null : _selectDueDate,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Due date',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                            suffixIcon: Icon(Icons.chevron_right_rounded)),
                        child: Text(
                            _dueDate == null
                                ? 'No due date'
                                : AppDateUtils.formatDate(_dueDate!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: _dueDate == null
                                        ? context.taskflowColors.textTertiary
                                        : null)),
                      ),
                    ),
                    if (_dueDate != null)
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: submitting
                                  ? null
                                  : () => setState(() => _dueDate = null),
                              child: const Text('Clear date'))),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FormSection(
                icon: Icons.people_alt_outlined,
                title: 'People',
                subtitle: 'Assign the task now or leave it open.',
                child: DropdownButtonFormField<String?>(
                  value: _assigneeId,
                  decoration: const InputDecoration(
                      labelText: 'Assignee',
                      prefixIcon: Icon(Icons.person_outline_rounded)),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Unassigned')),
                    ...state.orgMembers.map((user) => DropdownMenuItem<String?>(
                        value: user.id, child: Text(user.name))),
                  ],
                  onChanged: submitting
                      ? null
                      : (value) => setState(() => _assigneeId = value),
                ),
              ),
              if (_submitError != null) ...[
                const SizedBox(height: AppSpacing.md),
                _InlineFormError(message: _submitError!),
              ],
              const SizedBox(height: AppSpacing.xl),
              AsyncActionButton(
                onPressed: state.projects.isEmpty ? null : _submit,
                label: widget.isEditing ? 'Save Changes' : 'Create Task',
                icon: widget.isEditing
                    ? Icons.save_outlined
                    : Icons.add_task_rounded,
                status: submitting
                    ? AsyncActionStatus.loading
                    : AsyncActionStatus.idle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate != null && _dueDate!.isAfter(now)
        ? _dueDate!
        : now.add(const Duration(days: 7));
    final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(2035));
    if (date != null) setState(() => _dueDate = date);
  }
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  const _FormSection(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.child});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(11)),
                    child: Icon(icon,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.taskflowColors.textSecondary))
                    ])),
              ]),
              const SizedBox(height: AppSpacing.lg),
              child,
            ],
          ),
        ),
      );
}

class _InlineFormError extends StatelessWidget {
  final String message;
  const _InlineFormError({required this.message});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.control)),
        child: Row(children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
              child: Text(message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error)))
        ]),
      );
}
