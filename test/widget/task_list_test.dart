import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/widgets/empty_state_widget.dart';
import 'package:taskflow/core/widgets/error_display_widget.dart';
import 'package:taskflow/core/widgets/loading_widget.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow/features/auth/domain/entities/user_session.dart';
import 'package:taskflow/features/tasks/domain/entities/task_entity.dart';
import 'package:taskflow/features/tasks/domain/entities/task_filter.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_list_cubit.dart';
import 'package:taskflow/features/tasks/presentation/cubit/task_list_state.dart';
import 'package:taskflow/features/tasks/presentation/widgets/task_card.dart';

class MockTaskListCubit extends MockCubit<TaskListState>
    implements TaskListCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockTaskListCubit mockTaskListCubit;
  late MockAuthCubit mockAuthCubit;

  final testSession = UserSession(
    userId: 'user_001',
    email: 'ava.admin@nimbusdigital.test',
    name: 'Ava Thompson',
    orgId: 'org_a1b2c3',
    role: 'org_admin',
    accessToken: 'mock.token',
    refreshToken: 'mock.refresh',
    tokenIssuedAt: DateTime.now(),
  );

  final testTasks = [
    TaskEntity(
      id: 'task_1',
      projectId: 'proj_1',
      title: 'Build responsive nav component',
      description: 'Nav description',
      status: 'in_progress',
      priority: 'high',
      assigneeId: 'user_001',
      dueDate: DateTime(2026, 1, 20),
      createdAt: DateTime(2025, 12, 5),
    ),
    TaskEntity(
      id: 'task_2',
      projectId: 'proj_1',
      title: 'Write homepage copy',
      description: 'Copy description',
      status: 'review',
      priority: 'medium',
      assigneeId: null,
      dueDate: DateTime(2026, 1, 15),
      createdAt: DateTime(2025, 12, 6),
    ),
  ];

  setUp(() {
    mockTaskListCubit = MockTaskListCubit();
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state)
        .thenReturn(AuthAuthenticated(session: testSession));
    when(() => mockTaskListCubit.currentFilter).thenReturn(const TaskFilter());
  });

  Widget buildWidget(TaskListState state) {
    when(() => mockTaskListCubit.state).thenReturn(state);

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
          BlocProvider<TaskListCubit>.value(value: mockTaskListCubit),
        ],
        child: Scaffold(
          body: BlocBuilder<TaskListCubit, TaskListState>(
            builder: (context, state) {
              if (state is TaskListLoading) {
                return const LoadingWidget(message: 'Loading tasks...');
              }
              if (state is TaskListError) {
                return ErrorDisplayWidget(message: state.message);
              }
              if (state is TaskListEmpty) {
                return const EmptyStateWidget(
                  title: 'No tasks yet',
                  icon: Icons.task_outlined,
                );
              }
              if (state is TaskListSuccess) {
                return ListView.builder(
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) => TaskCard(
                    task: state.tasks[index],
                    onTap: () {},
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('Task List Widget States', () {
    testWidgets('shows loading widget in loading state', (tester) async {
      await tester.pumpWidget(buildWidget(const TaskListLoading()));

      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.text('Loading tasks...'), findsOneWidget);
    });

    testWidgets('shows error widget in error state', (tester) async {
      await tester.pumpWidget(
        buildWidget(const TaskListError(message: 'Network error')),
      );

      expect(find.byType(ErrorDisplayWidget), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('shows empty state when no tasks', (tester) async {
      await tester.pumpWidget(buildWidget(const TaskListEmpty()));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('shows task cards in success state', (tester) async {
      await tester.pumpWidget(
        buildWidget(TaskListSuccess(tasks: testTasks)),
      );

      expect(find.byType(TaskCard), findsNWidgets(2));
      expect(find.text('Build responsive nav component'), findsOneWidget);
      expect(find.text('Write homepage copy'), findsOneWidget);
    });

    testWidgets('task card shows status badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(TaskListSuccess(tasks: [testTasks.first])),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('task card shows priority badge', (tester) async {
      await tester.pumpWidget(
        buildWidget(TaskListSuccess(tasks: [testTasks.first])),
      );

      expect(find.text('High'), findsOneWidget);
    });
  });
}
