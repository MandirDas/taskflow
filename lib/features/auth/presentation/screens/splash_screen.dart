import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubit/app_settings_cubit.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/widgets/motion.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _entered = true);
      final biometricEnabled =
          context.read<AppSettingsCubit>().state.biometricEnabled;
      context
          .read<AuthCubit>()
          .checkSession(biometricEnabled: biometricEnabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.brand);
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.home);
        } else if (state is AuthLocked) {
          context.go(RouteNames.lock);
        } else if (state is AuthUnauthenticated || state is AuthError) {
          context.go(RouteNames.login);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Stack(
            children: [
              Positioned(
                left: -120,
                top: -100,
                child: _AmbientCircle(size: 360, opacity: 0.07),
              ),
              Positioned(
                right: -150,
                bottom: -130,
                child: _AmbientCircle(size: 430, opacity: 0.06),
              ),
              Center(
                child: AnimatedOpacity(
                  opacity: _entered ? 1 : 0,
                  duration: duration,
                  curve: AppMotion.standardCurve,
                  child: AnimatedScale(
                    scale:
                        _entered || AppMotion.reduceMotion(context) ? 1 : 0.92,
                    duration: duration,
                    curve: AppMotion.standardCurve,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TaskFlowBrandMark(size: 86, onGradient: true),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'TaskFlow',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Calm focus. Meaningful progress.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Preparing your workspace',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _AmbientCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity)),
        ),
      );
}
