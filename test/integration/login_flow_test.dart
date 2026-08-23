import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/services/biometric_service.dart';
import 'package:taskflow/features/auth/domain/entities/user_session.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

/// Integration test: Login flow against mock credentials.
/// Tests the full cubit → repository interaction without UI.

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late AuthCubit authCubit;

  final validSession = UserSession(
    userId: 'user_001',
    email: 'ava.admin@nimbusdigital.test',
    name: 'Ava Thompson',
    orgId: 'org_a1b2c3',
    role: 'org_admin',
    accessToken: 'mock.access.token.123',
    refreshToken: 'mock.refresh.token.123',
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

  tearDown(() => authCubit.close());

  group('Login Flow Integration', () {
    blocTest<AuthCubit, AuthState>(
      'successful login with Org A admin credentials',
      build: () {
        when(() => mockAuthRepository.login(
              email: 'ava.admin@nimbusdigital.test',
              password: 'Password123!',
            )).thenAnswer((_) async => validSession);
        return authCubit;
      },
      act: (cubit) => cubit.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      ),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(session: validSession),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login(
              email: 'ava.admin@nimbusdigital.test',
              password: 'Password123!',
            )).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'failed login with wrong password',
      build: () {
        when(() => mockAuthRepository.login(
              email: 'ava.admin@nimbusdigital.test',
              password: 'WrongPassword!',
            )).thenThrow(
          const UnauthorizedException(message: 'Invalid email or password'),
        );
        return authCubit;
      },
      act: (cubit) => cubit.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'WrongPassword!',
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'failed login with network error',
      build: () {
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          const NetworkException(message: 'No internet connection'),
        );
        return authCubit;
      },
      act: (cubit) => cubit.login(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'session check → refresh → authenticated flow',
      build: () {
        final expiredSession = validSession.copyWith(
          tokenIssuedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        );
        when(() => mockAuthRepository.checkSession())
            .thenAnswer((_) async => expiredSession);
        when(() => mockAuthRepository.refreshToken())
            .thenAnswer((_) async => validSession);
        return authCubit;
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(session: validSession),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.checkSession()).called(1);
        verify(() => mockAuthRepository.refreshToken()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'logout clears session',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
