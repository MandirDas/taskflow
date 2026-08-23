import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/features/projects/domain/entities/project_entity.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/presentation/cubit/project_list_cubit.dart';
import 'package:taskflow/features/projects/presentation/cubit/project_list_state.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

/// Integration test: Project listing flow.

void main() {
  late MockProjectRepository mockProjectRepository;
  late ProjectListCubit projectListCubit;

  final testProjects = [
    ProjectEntity(
      id: 'proj_1001',
      orgId: 'org_a1b2c3',
      name: 'Website Relaunch',
      description: 'Redesign the marketing website.',
      taskCount: 6,
      status: 'active',
      createdAt: DateTime(2025, 12, 1),
    ),
    ProjectEntity(
      id: 'proj_1002',
      orgId: 'org_a1b2c3',
      name: 'Mobile App v2',
      description: 'Second major release.',
      taskCount: 5,
      status: 'active',
      createdAt: DateTime(2026, 1, 10),
    ),
  ];

  setUp(() {
    mockProjectRepository = MockProjectRepository();
    projectListCubit =
        ProjectListCubit(projectRepository: mockProjectRepository);
  });

  tearDown(() => projectListCubit.close());

  group('Project Listing Integration', () {
    blocTest<ProjectListCubit, ProjectListState>(
      'loads projects for org successfully',
      build: () {
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => testProjects);
        return projectListCubit;
      },
      act: (cubit) => cubit.loadProjects('org_a1b2c3'),
      expect: () => [
        const ProjectListLoading(),
        ProjectListSuccess(projects: testProjects),
      ],
    );

    blocTest<ProjectListCubit, ProjectListState>(
      'shows empty state when no projects',
      build: () {
        when(() => mockProjectRepository.getProjectsByOrgId('org_empty'))
            .thenAnswer((_) async => []);
        return projectListCubit;
      },
      act: (cubit) => cubit.loadProjects('org_empty'),
      expect: () => [
        const ProjectListLoading(),
        const ProjectListEmpty(),
      ],
    );

    blocTest<ProjectListCubit, ProjectListState>(
      'shows error state on network failure',
      build: () {
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenThrow(
                const NetworkException(message: 'No internet connection'));
        return projectListCubit;
      },
      act: (cubit) => cubit.loadProjects('org_a1b2c3'),
      expect: () => [
        const ProjectListLoading(),
        isA<ProjectListError>(),
      ],
    );

    blocTest<ProjectListCubit, ProjectListState>(
      'creates project and reloads list',
      build: () {
        final newProject = ProjectEntity(
          id: 'proj_new',
          orgId: 'org_a1b2c3',
          name: 'New Project',
          description: 'Description',
          taskCount: 0,
          status: 'active',
          createdAt: DateTime.now(),
        );
        when(() => mockProjectRepository.createProject(
              orgId: 'org_a1b2c3',
              name: 'New Project',
              description: 'Description',
            )).thenAnswer((_) async => newProject);
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => [...testProjects, newProject]);
        return projectListCubit;
      },
      act: (cubit) => cubit.createProject(
        orgId: 'org_a1b2c3',
        name: 'New Project',
        description: 'Description',
      ),
      expect: () => [
        const ProjectListLoading(),
        isA<ProjectListSuccess>(),
      ],
      verify: (_) {
        verify(() => mockProjectRepository.createProject(
              orgId: 'org_a1b2c3',
              name: 'New Project',
              description: 'Description',
            )).called(1);
      },
    );

    blocTest<ProjectListCubit, ProjectListState>(
      'deletes project and reloads list',
      build: () {
        when(() => mockProjectRepository.deleteProject(
              'proj_1001',
              actorOrgId: 'org_a1b2c3',
              actorRole: 'org_admin',
            )).thenAnswer((_) async {});
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => [testProjects[1]]);
        return projectListCubit;
      },
      act: (cubit) => cubit.deleteProject(
        'proj_1001',
        'org_a1b2c3',
        actorRole: 'org_admin',
      ),
      expect: () => [
        const ProjectListLoading(),
        isA<ProjectListSuccess>(),
      ],
      verify: (_) {
        verify(() => mockProjectRepository.deleteProject(
              'proj_1001',
              actorOrgId: 'org_a1b2c3',
              actorRole: 'org_admin',
            )).called(1);
      },
    );
  });
}
