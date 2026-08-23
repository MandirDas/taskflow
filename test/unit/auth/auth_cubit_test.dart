import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/services/biometric_service.dart';
import 'package:taskflow/features/auth/domain/entities/user_session.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late AuthCubit authCubit;

  final testSession = UserSession(
    userId: 'user_001',
    email: 'ava.admin@nimbusdigital.test',
    name: 'Ava Thompson',
    orgId: 'org_a1b2c3',
    role: 'org_admin',
    accessToken: 'mock.access.token',
    refreshToken: 'mock.refresh.token',
    tokenIssuedAt: DateTime.now(),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    authCubit = AuthCubit(
      authRepository: mockAuthRepository,
      biometricService: mockBiometricService,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful login',
        build: () {
          when(() => mockAuthRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testSession);
          return authCubit;
        },
        act: (cubit) => cubit.login(
          email: 'ava.admin@nimbusdigital.test',
          password: 'Password123!',
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(session: testSession),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthError] on failed login',
        build: () {
          when(() => mockAuthRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Invalid email or password'));
          return authCubit;
        },
        act: (cubit) => cubit.login(
          email: 'wrong@email.com',
          password: 'wrongpass',
        ),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
        ],
      );
    });

    group('checkSession', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when session exists and valid',
        build: () {
          when(() => mockAuthRepository.checkSession())
              .thenAnswer((_) async => testSession);
          return authCubit;
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(session: testSession),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no session',
        build: () {
          when(() => mockAuthRepository.checkSession())
              .thenAnswer((_) async => null);
          return authCubit;
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [
          const AuthLoading(),
          isA<AuthUnauthenticated>(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'refreshes token when access token expired but refresh token valid',
        build: () {
          final expiredSession = UserSession(
            userId: 'user_001',
            email: 'ava.admin@nimbusdigital.test',
            name: 'Ava Thompson',
            orgId: 'org_a1b2c3',
            role: 'org_admin',
            accessToken: 'mock.access.token.old',
            refreshToken: 'mock.refresh.token',
            tokenIssuedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          );
          when(() => mockAuthRepository.checkSession())
              .thenAnswer((_) async => expiredSession);
          when(() => mockAuthRepository.refreshToken())
              .thenAnswer((_) async => testSession);
          return authCubit;
        },
        act: (cubit) => cubit.checkSession(),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(session: testSession),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthUnauthenticated] on logout',
        build: () {
          when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<AuthUnauthenticated>(),
        ],
      );
    });

    group('register', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] on successful register',
        build: () {
          when(() => mockAuthRepository.register(
                name: any(named: 'name'),
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testSession);
          return authCubit;
        },
        act: (cubit) => cubit.register(
          name: 'New User',
          email: 'new@example.com',
          password: 'Password123!',
        ),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(session: testSession),
        ],
      );
    });
  });
}
