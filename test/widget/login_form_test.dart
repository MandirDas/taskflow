import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow/features/auth/presentation/screens/login_screen.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders sign in button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders sign up link', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('shows validation error when email is empty', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Tap sign in without filling fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).first,
        'notanemail',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows validation error when password is empty',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      // Enter valid email but no password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('calls login when form is valid', (tester) async {
      when(() => mockAuthCubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'ava.admin@nimbusdigital.test',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123!',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.login(
            email: 'ava.admin@nimbusdigital.test',
            password: 'Password123!',
          )).called(1);
    });

    testWidgets('shows loading indicator when state is AuthLoading',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Initially password is obscured
      final passwordField = find.byType(TextFormField).last;
      expect(passwordField, findsOneWidget);

      // Find and tap visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now should show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
