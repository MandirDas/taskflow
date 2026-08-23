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
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../cubit/project_list_cubit.dart';
import '../cubit/project_list_state.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_dialog.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit =
            ProjectListCubit(projectRepository: sl<ProjectRepository>());
        final auth = context.read<AuthCubit>().state;
        if (auth is AuthAuthenticated) cubit.loadProjects(auth.session.orgId);
        return cubit;
      },
      child: const _ProjectListView(),
    );
  }
}

class _ProjectListView extends StatefulWidget {
  const _ProjectListView();

  @override
  State<_ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<_ProjectListView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthAuthenticated && auth.session.isOrgAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: AppLocalizations.of(context).projectsTitle,
      subtitle: AppLocalizations.of(context).projectsSubtitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
      ),
      body: BlocBuilder<ProjectListCubit, ProjectListState>(
        builder: (context, state) {
          return AppFadeSwitcher(
            child: switch (state) {
              ProjectListInitial() ||
              ProjectListLoading() =>
                const ShimmerLoadingList(
                    key: ValueKey('loading'), itemCount: 5, itemHeight: 178),
              ProjectListError(:final message) => ErrorDisplayWidget(
                  key: const ValueKey('error'),
                  message: message,
                  onRetry: _refresh),
              ProjectListEmpty() => EmptyStateWidget(
                  key: const ValueKey('empty'),
                  title: 'Start with your first project',
                  subtitle:
                      'Give your team a shared place for tasks, progress, and decisions.',
                  icon: Icons.create_new_folder_outlined,
                  actionLabel: 'Create Project',
                  onAction: _showProjectForm,
                ),
              ProjectListSuccess() => _buildProjects(state),
              _ => const SizedBox.shrink(key: ValueKey('unknown')),
            },
          );
        },
      ),
    );
  }

  Widget _buildProjects(ProjectListSuccess state) {
    final projects = state.projects.where((project) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        key: const ValueKey('projects'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search ${state.projects.length} projects',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
          ),
          if (projects.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: 'No matching projects',
                subtitle: 'Try a different project name or description.',
                icon: Icons.search_off_rounded,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 760 ? 2 : 1;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: columns == 1 ? 1.75 : 1.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () async {
                            await context
                                .push(RouteNames.projectDetailPath(project.id));
                            if (mounted) await _refresh();
                          },
                          onEdit: () => _showProjectForm(project: project),
                          onDelete:
                              _isAdmin ? () => _confirmDelete(project) : null,
                        );
                      },
                      childCount: projects.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) {
      await context.read<ProjectListCubit>().loadProjects(auth.session.orgId);
    }
  }

  Future<void> _showProjectForm({ProjectEntity? project}) async {
    final cubit = context.read<ProjectListCubit>();
    final auth = context.read<AuthCubit>().state;
    if (auth is! AuthAuthenticated) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ProjectFormDialog(
        initialName: project?.name,
        initialDescription: project?.description,
        isEditing: project != null,
        onSubmit: (name, description) async {
          if (project == null) {
            await cubit.createProject(
                orgId: auth.session.orgId,
                name: name,
                description: description);
          } else {
            await cubit.updateProject(
                id: project.id,
                name: name,
                description: description,
                orgId: auth.session.orgId);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(ProjectEntity project) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete project',
      message: 'Delete “${project.name}”? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) {
      await context.read<ProjectListCubit>().deleteProject(
            project.id,
            auth.session.orgId,
            actorRole: auth.session.role,
          );
    }
  }
}
