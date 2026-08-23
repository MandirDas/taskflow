import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_shell.dart';

/// Biometric lock screen shown when session exists but device unlock is required.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _authenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-prompt biometric after a brief delay so the UI renders first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _attemptBiometric();
    });
  }

  Future<void> _attemptBiometric() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _errorMessage = null;
    });

    await context.read<AuthCubit>().unlockWithBiometric();

    if (mounted && context.read<AuthCubit>().state is AuthLocked) {
      setState(() {
        _authenticating = false;
        _errorMessage = 'Authentication failed. Try again or use password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final session = authState is AuthLocked ? authState.session : null;
    final duration = AppMotion.duration(context, AppMotion.standard);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TaskFlowBrandMark(size: 56, onGradient: true),
                  const SizedBox(height: AppSpacing.xxl),
                  if (session != null) ...[
                    UserAvatar(name: session.name, radius: 36),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Welcome back, ${session.name.split(' ').first}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      session.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                  AnimatedSwitcher(
                    duration: duration,
                    child: _authenticating
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : IconButton.filled(
                            key: const ValueKey('unlock'),
                            onPressed: _attemptBiometric,
                            iconSize: 40,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.15),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(20),
                            ),
                            icon: const Icon(Icons.fingerprint_rounded),
                            tooltip: 'Unlock with biometrics',
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _authenticating ? 'Verifying identity…' : 'Tap to unlock',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  TextButton(
                    onPressed: () =>
                        context.read<AuthCubit>().unlockWithoutBiometric(),
                    child: const Text(
                      'Use password instead',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    child: Text(
                      'Sign out',
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
