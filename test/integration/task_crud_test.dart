import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/projects/domain/entities/project_entity.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow/features/tasks/domain/entities/task_filter.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_list_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

/// Integration test: Task CRUD operations.

void main() {
  late MockTaskRepository mockTaskRepository;
  late MockProjectRepository mockProjectRepository;
  late TaskListCubit taskListCubit;

  final testProjects = [
    ProjectEntity(
      id: 'proj_1001',
      orgId: 'org_a1b2c3',
      name: 'Website Relaunch',
      description: 'Desc',
      taskCount: 3,
      status: 'active',
      createdAt: DateTime(2025, 12, 1),
    ),
  ];

  final testTasks = [
    TaskEntity(
      id: 'task_2001',
      projectId: 'proj_1001',
      title: 'Set up design tokens',
      description: 'Define tokens',
      status: 'done',
      priority: 'medium',
      assigneeId: 'user_002',
      dueDate: DateTime(2026, 1, 5),
      createdAt: DateTime(2025, 12, 2),
    ),
    TaskEntity(
      id: 'task_2002',
      projectId: 'proj_1001',
      title: 'Build responsive nav',
      description: 'Nav component',
      status: 'in_progress',
      priority: 'high',
      assigneeId: 'user_003',
      dueDate: DateTime(2026, 1, 20),
      createdAt: DateTime(2025, 12, 5),
    ),
  ];

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockProjectRepository = MockProjectRepository();
    taskListCubit = TaskListCubit(
      taskRepository: mockTaskRepository,
      projectRepository: mockProjectRepository,
    );
  });

  tearDown(() => taskListCubit.close());

  setUpAll(() {
    registerFallbackValue(const TaskFilter());
  });

  group('Task Listing Integration', () {
    blocTest<TaskListCubit, TaskListState>(
      'loads tasks for org projects',
      build: () {
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => testProjects);
        when(() => mockTaskRepository.getTasksByOrgProjects(
              ['proj_1001'],
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testTasks);
        return taskListCubit;
      },
      act: (cubit) => cubit.loadTasksForOrg('org_a1b2c3'),
      expect: () => [
        const TaskListLoading(),
        TaskListSuccess(tasks: testTasks),
      ],
    );

    blocTest<TaskListCubit, TaskListState>(
      'loads tasks for specific project',
      build: () {
        when(() => mockTaskRepository.getTasks(
              projectId: 'proj_1001',
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testTasks);
        return taskListCubit;
      },
      act: (cubit) => cubit.loadTasksForProject('proj_1001'),
      expect: () => [
        const TaskListLoading(),
        TaskListSuccess(tasks: testTasks),
      ],
    );

    blocTest<TaskListCubit, TaskListState>(
      'shows empty when no tasks match filter',
      build: () {
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => testProjects);
        when(() => mockTaskRepository.getTasksByOrgProjects(
              ['proj_1001'],
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => []);
        return taskListCubit;
      },
      act: (cubit) => cubit.loadTasksForOrg('org_a1b2c3'),
      expect: () => [
        const TaskListLoading(),
        isA<TaskListEmpty>(),
      ],
    );
  });

  group('Task Delete Integration', () {
    blocTest<TaskListCubit, TaskListState>(
      'deletes a task and reloads',
      build: () {
        when(() => mockTaskRepository.deleteTask('task_2001'))
            .thenAnswer((_) async {});
        // After delete, reload returns remaining tasks
        when(() => mockProjectRepository.getProjectsByOrgId('org_a1b2c3'))
            .thenAnswer((_) async => testProjects);
        when(() => mockTaskRepository.getTasksByOrgProjects(
              ['proj_1001'],
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => [testTasks[1]]);
        return taskListCubit;
      },
      seed: () => TaskListSuccess(tasks: testTasks),
      act: (cubit) {
        // Set the org for reload
        cubit.loadTasksForOrg('org_a1b2c3');
        return cubit.deleteTask('task_2001');
      },
      verify: (_) {
        verify(() => mockTaskRepository.deleteTask('task_2001')).called(1);
      },
    );
  });
}
