import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/motion.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/lock_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../shell/main_shell.dart';
import 'route_names.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: _guardRedirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.lock,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) =>
            _transitionPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (context, state) =>
            _transitionPage(state, const RegisterScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: RouteNames.home,
                builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: RouteNames.projects,
                builder: (_, __) => const ProjectListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: RouteNames.tasks,
                builder: (_, __) => const TaskListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: RouteNames.notifications,
                builder: (_, __) => const NotificationScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: RouteNames.settings,
                builder: (_, __) => const SettingsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: RouteNames.projectDetail,
        pageBuilder: (context, state) => _transitionPage(
          state,
          ProjectDetailScreen(projectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.taskDetail,
        pageBuilder: (context, state) => _transitionPage(
          state,
          TaskDetailScreen(taskId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.createTask,
        pageBuilder: (context, state) => _transitionPage(
          state,
          TaskFormScreen(projectId: state.uri.queryParameters['projectId']),
        ),
      ),
      GoRoute(
        path: RouteNames.editTask,
        pageBuilder: (context, state) => _transitionPage(
          state,
          TaskFormScreen(taskId: state.pathParameters['id']!),
        ),
      ),
    ],
  );

  String? _guardRedirect(BuildContext context, GoRouterState state) {
    final authState = authCubit.state;
    final isSplash = state.matchedLocation == RouteNames.splash;
    final isAuth = state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register;
    final isLock = state.matchedLocation == RouteNames.lock;

    // Handle locked state — biometric required.
    if (authState is AuthLocked) {
      return isLock ? null : RouteNames.lock;
    }

    if (isSplash) {
      if (authState is AuthAuthenticated) return RouteNames.home;
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return RouteNames.login;
      }
      return null;
    }
    if (authState is AuthUnauthenticated || authState is AuthError) {
      return isAuth ? null : RouteNames.login;
    }
    if (authState is AuthAuthenticated && (isAuth || isLock)) {
      return RouteNames.home;
    }
    return null;
  }

  static Page<void> _transitionPage(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppMotion.emphasized,
      reverseTransitionDuration: AppMotion.standard,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final reduced = AppMotion.reduceMotion(context);
        final curved = CurvedAnimation(
            parent: animation,
            curve: AppMotion.standardCurve,
            reverseCurve: AppMotion.exitCurve);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: reduced ? Offset.zero : const Offset(0, 0.025),
                    end: Offset.zero)
                .animate(curved),
            child: HeroMode(enabled: !reduced, child: child),
          ),
        );
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
