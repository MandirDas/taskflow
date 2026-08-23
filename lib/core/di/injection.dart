import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/cubit/app_settings_cubit.dart';
import '../../app/cubit/connectivity_cubit.dart';
import '../../app/cubit/inactivity_cubit.dart';
import '../../app/cubit/sync_cubit.dart';
import '../../data/datasources/mock_data_source.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../network/network_info.dart';
import '../services/biometric_service.dart';
import '../services/pending_operations_queue.dart';

/// Service locator instance — accessible throughout the app.
final GetIt sl = GetIt.instance;

/// Initialize all dependencies.
/// Called once at app startup before runApp().
Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // ─── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => SimulatedNetworkInfo());
  sl.registerLazySingleton<BiometricService>(() => BiometricService());

  // ─── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<MockDataSource>(() => MockDataSource());
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<FlutterSecureStorage>()),
  );

  // ─── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      mockDataSource: sl<MockDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      mockDataSource: sl<MockDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      mockDataSource: sl<MockDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      mockDataSource: sl<MockDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      mockDataSource: sl<MockDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ─── Cubits ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      biometricService: sl<BiometricService>(),
    ),
  );
  sl.registerLazySingleton<AppSettingsCubit>(
    () => AppSettingsCubit(preferences: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(networkInfo: sl<NetworkInfo>()),
  );
  sl.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(repository: sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<PendingOperationsQueue>(
    () => PendingOperationsQueue(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<SyncCubit>(
    () => SyncCubit(
      queue: sl<PendingOperationsQueue>(),
      networkInfo: sl<NetworkInfo>(),
      projectRepository: sl<ProjectRepository>(),
      taskRepository: sl<TaskRepository>(),
    ),
  );
  sl.registerFactory<InactivityCubit>(() => InactivityCubit());
}
