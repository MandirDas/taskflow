import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow/features/users/domain/entities/user_entity.dart';
import 'package:taskflow/features/users/domain/repositories/user_repository.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_detail_cubit.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_detail_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockUserRepository extends Mock implements UserRepository {}

/// Integration test: Task assignment flow.

void main() {
  late MockTaskRepository mockTaskRepository;
  late MockUserRepository mockUserRepository;
  late TaskDetailCubit taskDetailCubit;

  final testTask = TaskEntity(
    id: 'task_2001',
    projectId: 'proj_1001',
    title: 'Set up design tokens',
    description: 'Define tokens',
    status: 'todo',
    priority: 'high',
    assigneeId: null,
    dueDate: DateTime(2026, 1, 5),
    createdAt: DateTime(2025, 12, 2),
  );

  final orgMembers = [
    const UserEntity(
      id: 'user_001',
      name: 'Ava Thompson',
      email: 'ava.admin@nimbusdigital.test',
    ),
    const UserEntity(
      id: 'user_002',
      name: 'Marcus Lee',
      email: 'marcus.member@nimbusdigital.test',
    ),
  ];

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockUserRepository = MockUserRepository();
    taskDetailCubit = TaskDetailCubit(
      taskRepository: mockTaskRepository,
      userRepository: mockUserRepository,
      orgId: 'org_a1b2c3',
    );
  });

  tearDown(() => taskDetailCubit.close());

  group('Task Assignment Integration', () {
    blocTest<TaskDetailCubit, TaskDetailState>(
      'loads task with assignee details',
      build: () {
        when(() => mockTaskRepository.getTaskById('task_2001'))
            .thenAnswer((_) async => testTask.copyWith(
                  assigneeId: () => 'user_002',
                ));
        when(() => mockTaskRepository.getTaskComments('task_2001'))
            .thenAnswer((_) async => []);
        when(() => mockUserRepository.getOrgMemberUsers('org_a1b2c3'))
            .thenAnswer((_) async => orgMembers);
        return taskDetailCubit;
      },
      act: (cubit) => cubit.loadTask('task_2001'),
      expect: () => [
        const TaskDetailLoading(),
        isA<TaskDetailSuccess>(),
      ],
      verify: (_) {
        final state = taskDetailCubit.state as TaskDetailSuccess;
        expect(state.assignee?.id, 'user_002');
        expect(state.assignee?.name, 'Marcus Lee');
        expect(state.orgMembers.length, 2);
      },
    );

    blocTest<TaskDetailCubit, TaskDetailState>(
      'assigns user to task successfully',
      build: () {
        final assignedTask = testTask.copyWith(assigneeId: () => 'user_001');
        when(() => mockUserRepository.isUserInOrg('user_001', 'org_a1b2c3'))
            .thenAnswer((_) async => true);
        when(() => mockTaskRepository.assignTask('task_2001', 'user_001'))
            .thenAnswer((_) async => assignedTask);
        when(() => mockTaskRepository.getTaskById('task_2001'))
            .thenAnswer((_) async => assignedTask);
        when(() => mockTaskRepository.getTaskComments('task_2001'))
            .thenAnswer((_) async => []);
        when(() => mockUserRepository.getOrgMemberUsers('org_a1b2c3'))
            .thenAnswer((_) async => orgMembers);
        return taskDetailCubit;
      },
      act: (cubit) => cubit.assignUser('task_2001', 'user_001'),
      expect: () => [
        const TaskDetailLoading(),
        isA<TaskDetailSuccess>(),
      ],
      verify: (_) {
        verify(() => mockUserRepository.isUserInOrg('user_001', 'org_a1b2c3'))
            .called(1);
        verify(() => mockTaskRepository.assignTask('task_2001', 'user_001'))
            .called(1);
      },
    );

    blocTest<TaskDetailCubit, TaskDetailState>(
      'prevents assigning user not in org',
      build: () {
        when(() => mockUserRepository.isUserInOrg('user_999', 'org_a1b2c3'))
            .thenAnswer((_) async => false);
        return taskDetailCubit;
      },
      act: (cubit) => cubit.assignUser('task_2001', 'user_999'),
      expect: () => [
        isA<TaskDetailError>(),
      ],
      verify: (_) {
        final state = taskDetailCubit.state as TaskDetailError;
        expect(state.message, contains('does not belong to this organization'));
        verifyNever(() => mockTaskRepository.assignTask(any(), any()));
      },
    );

    blocTest<TaskDetailCubit, TaskDetailState>(
      'unassigns user from task',
      build: () {
        final unassignedTask = testTask.copyWith(assigneeId: () => null);
        when(() => mockTaskRepository.assignTask('task_2001', null))
            .thenAnswer((_) async => unassignedTask);
        when(() => mockTaskRepository.getTaskById('task_2001'))
            .thenAnswer((_) async => unassignedTask);
        when(() => mockTaskRepository.getTaskComments('task_2001'))
            .thenAnswer((_) async => []);
        when(() => mockUserRepository.getOrgMemberUsers('org_a1b2c3'))
            .thenAnswer((_) async => orgMembers);
        return taskDetailCubit;
      },
      act: (cubit) => cubit.assignUser('task_2001', null),
      expect: () => [
        const TaskDetailLoading(),
        isA<TaskDetailSuccess>(),
      ],
      verify: (_) {
        final state = taskDetailCubit.state as TaskDetailSuccess;
        expect(state.task.assigneeId, isNull);
        expect(state.assignee, isNull);
      },
    );

    blocTest<TaskDetailCubit, TaskDetailState>(
      'updates task status',
      build: () {
        final updatedTask = testTask.copyWith(status: 'in_progress');
        when(() => mockTaskRepository.updateTask(
              id: 'task_2001',
              status: 'in_progress',
            )).thenAnswer((_) async => updatedTask);
        when(() => mockTaskRepository.getTaskById('task_2001'))
            .thenAnswer((_) async => updatedTask);
        when(() => mockTaskRepository.getTaskComments('task_2001'))
            .thenAnswer((_) async => []);
        when(() => mockUserRepository.getOrgMemberUsers('org_a1b2c3'))
            .thenAnswer((_) async => orgMembers);
        return taskDetailCubit;
      },
      act: (cubit) => cubit.updateStatus('task_2001', 'in_progress'),
      expect: () => [
        const TaskDetailLoading(),
        isA<TaskDetailSuccess>(),
      ],
      verify: (_) {
        final state = taskDetailCubit.state as TaskDetailSuccess;
        expect(state.task.status, 'in_progress');
      },
    );
  });
}
