import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/injection.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/notifications/presentation/cubit/notification_cubit.dart';
import 'cubit/app_settings_cubit.dart';
import 'cubit/connectivity_cubit.dart';
import 'cubit/inactivity_cubit.dart';
import 'cubit/sync_cubit.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> with WidgetsBindingObserver {
  late final AppRouter _appRouter;
  late final InactivityCubit _inactivityCubit;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(authCubit: sl<AuthCubit>());
    _inactivityCubit = InactivityCubit();
    WidgetsBinding.instance.addObserver(this);

    // Initialize timeout from settings.
    final settings = sl<AppSettingsCubit>().state;
    _inactivityCubit.setTimeout(settings.sessionTimeout.duration);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityCubit.close();
    _appRouter.router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _inactivityCubit.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _inactivityCubit.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<AppSettingsCubit>.value(value: sl<AppSettingsCubit>()),
        BlocProvider<ConnectivityCubit>.value(value: sl<ConnectivityCubit>()),
        BlocProvider<NotificationCubit>.value(value: sl<NotificationCubit>()),
        BlocProvider<InactivityCubit>.value(value: _inactivityCubit),
        BlocProvider<SyncCubit>.value(value: sl<SyncCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              final notifications = context.read<NotificationCubit>();
              if (state is AuthAuthenticated) {
                notifications.load(state.session.userId);
                // Start inactivity timer when authenticated.
                _inactivityCubit.recordActivity();
              } else if (state is AuthUnauthenticated) {
                notifications.clear();
              }
            },
          ),
          BlocListener<InactivityCubit, InactivityState>(
            listener: (context, state) {
              if (state is InactivityTimedOut) {
                final settings = context.read<AppSettingsCubit>().state;
                // Lock only if biometric is enabled; otherwise let session
                // expire naturally via token.
                if (settings.biometricEnabled) {
                  context.read<AuthCubit>().lockSession();
                  _inactivityCubit.acknowledge();
                }
              }
            },
          ),
          BlocListener<AppSettingsCubit, AppSettingsState>(
            listener: (context, state) {
              // Update timeout when settings change.
              _inactivityCubit.setTimeout(state.sessionTimeout.duration);
            },
          ),
          BlocListener<ConnectivityCubit, ConnectivityState>(
            listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
            listener: (context, state) {
              // Trigger sync on reconnect.
              context.read<SyncCubit>().syncAll();
            },
          ),
        ],
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, settings) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _inactivityCubit.recordActivity,
              onPanDown: (_) => _inactivityCubit.recordActivity(),
              child: MaterialApp.router(
                title: 'TaskFlow',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.themeMode,
                themeAnimationDuration: const Duration(milliseconds: 220),
                themeAnimationCurve: Curves.easeOutCubic,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                locale: settings.locale,
                routerConfig: _appRouter.router,
                builder: (context, child) {
                  final mediaQuery = MediaQuery.of(context);
                  return MediaQuery(
                    data: mediaQuery.copyWith(
                      disableAnimations:
                          mediaQuery.disableAnimations || settings.reduceMotion,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
