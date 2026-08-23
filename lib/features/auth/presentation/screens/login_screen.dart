import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/async_action_button.dart';
import '../../../../core/widgets/motion.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _fillDemo(String email) {
    _emailController.text = email;
    _passwordController.text = 'Password123!';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) context.go(RouteNames.home);
        },
        child: AuthShell(
          title: 'Welcome back',
          subtitle: 'Sign in to pick up where your team left off.',
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) =>
                        previous is AuthError || current is AuthError,
                    builder: (context, state) => AnimatedSize(
                      duration: AppMotion.duration(context),
                      child: state is AuthError
                          ? _InlineAuthError(message: state.message)
                          : const SizedBox.shrink(),
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email
                    ],
                    autocorrect: false,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@company.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) =>
                        Validators.required(value, 'Password'),
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: Tooltip(
                        message: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        child: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding:
                        const EdgeInsets.only(bottom: AppSpacing.sm),
                    title: Text('Quick access accounts',
                        style: Theme.of(context).textTheme.labelLarge),
                    leading: Icon(Icons.science_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          ActionChip(
                            avatar: const Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 16),
                            label: const Text('Admin'),
                            onPressed: () =>
                                _fillDemo('ava.admin@nimbusdigital.test'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.person_outline_rounded,
                                size: 16),
                            label: const Text('Member'),
                            onPressed: () =>
                                _fillDemo('marcus.member@nimbusdigital.test'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => AsyncActionButton(
                      onPressed: _submit,
                      label: 'Sign In',
                      icon: Icons.arrow_forward_rounded,
                      status: state is AuthLoading
                          ? AsyncActionStatus.loading
                          : AsyncActionStatus.idle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                          onPressed: () => context.go(RouteNames.register),
                          child: const Text('Sign Up')),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 16, color: context.taskflowColors.textTertiary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Your session is stored securely on this device.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.taskflowColors.textTertiary),
                        ),
                      ),
                    ],
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

class _InlineAuthError extends StatelessWidget {
  final String message;
  const _InlineAuthError({required this.message});

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 20, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                  child: Text(message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error))),
            ],
          ),
        ),
      );
}
