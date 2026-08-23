import 'package:flutter/material.dart';

import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/task_filter.dart';

class TaskFilterSheet extends StatefulWidget {
  final TaskFilter currentFilter;
  final void Function(TaskFilter filter) onApply;

  const TaskFilterSheet(
      {super.key, required this.currentFilter, required this.onApply});

  static Future<void> show({
    required BuildContext context,
    required TaskFilter currentFilter,
    required void Function(TaskFilter filter) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          TaskFilterSheet(currentFilter: currentFilter, onApply: onApply),
    );
  }

  @override
  State<TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<TaskFilterSheet> {
  late String? _status = widget.currentFilter.status;
  late String? _priority = widget.currentFilter.priority;
  late DateTime? _dueDateFrom = widget.currentFilter.dueDateFrom;
  late DateTime? _dueDateTo = widget.currentFilter.dueDateTo;
  String? _dateError;

  void _apply() {
    if (_dueDateFrom != null &&
        _dueDateTo != null &&
        _dueDateFrom!.isAfter(_dueDateTo!)) {
      setState(
          () => _dateError = 'The start date must be before the end date.');
      return;
    }
    widget.onApply(TaskFilter(
      status: _status,
      priority: _priority,
      assigneeId: widget.currentFilter.assigneeId,
      dueDateFrom: _dueDateFrom,
      dueDateTo: _dueDateTo,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                    child: Text('Filter tasks',
                        style: Theme.of(context).textTheme.titleLarge)),
                TextButton(
                  onPressed: () {
                    widget.onApply(const TaskFilter());
                    Navigator.pop(context);
                  },
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterLabel(
                        title: 'Status',
                        subtitle: _status == null
                            ? 'Any workflow stage'
                            : TaskStatus.displayName(_status!)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: TaskStatus.all
                          .map((status) => ChoiceChip(
                                label: Text(TaskStatus.displayName(status)),
                                selected: _status == status,
                                onSelected: (selected) => setState(
                                    () => _status = selected ? status : null),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _FilterLabel(
                        title: 'Priority',
                        subtitle: _priority == null
                            ? 'Any priority'
                            : TaskPriority.displayName(_priority!)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: TaskPriority.all
                          .map((priority) => ChoiceChip(
                                label: Text(TaskPriority.displayName(priority)),
                                selected: _priority == priority,
                                onSelected: (selected) => setState(() =>
                                    _priority = selected ? priority : null),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _FilterLabel(
                        title: 'Due date',
                        subtitle: 'Choose an optional date range'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                            child: _DateButton(
                                label: 'From',
                                date: _dueDateFrom,
                                onPressed: () => _pickDate(isStart: true))),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: _DateButton(
                                label: 'To',
                                date: _dueDateTo,
                                onPressed: () => _pickDate(isStart: false))),
                      ],
                    ),
                    if (_dateError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(_dateError!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            onPressed: _apply,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Apply filters'))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? _dueDateFrom : _dueDateTo) ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _dueDateFrom = date;
        } else {
          _dueDateTo = date;
        }
        _dateError = null;
      });
    }
  }
}

class _FilterLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FilterLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.taskflowColors.textSecondary)),
        ],
      );
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPressed;
  const _DateButton(
      {required this.label, required this.date, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.calendar_today_outlined, size: 17),
        label: Text(
            date == null ? label : '${date!.month}/${date!.day}/${date!.year}',
            overflow: TextOverflow.ellipsis),
      );
}
