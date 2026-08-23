import 'package:flutter/material.dart';

import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/async_action_button.dart';

class ProjectFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool isEditing;
  final Future<void> Function(String name, String description) onSubmit;

  const ProjectFormDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.isEditing = false,
    required this.onSubmit,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    await widget.onSubmit(
        _nameController.text.trim(), _descriptionController.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(13)),
            child: Icon(
                widget.isEditing
                    ? Icons.edit_outlined
                    : Icons.create_new_folder_outlined,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child:
                  Text(widget.isEditing ? 'Edit project' : 'Create project')),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                validator: Validators.projectName,
                textInputAction: TextInputAction.next,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Project name',
                    hintText: 'e.g. Mobile app launch',
                    prefixIcon: Icon(Icons.folder_outlined)),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What will this project accomplish?',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded)),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      actions: [
        TextButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        AsyncActionButton(
          expanded: false,
          onPressed: _submit,
          label: widget.isEditing ? 'Save Changes' : 'Create Project',
          icon: widget.isEditing ? Icons.save_outlined : Icons.add_rounded,
          status:
              _submitting ? AsyncActionStatus.loading : AsyncActionStatus.idle,
        ),
      ],
    );
  }
}
