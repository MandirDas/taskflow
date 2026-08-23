import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/async_action_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() => setState(() {});

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) context.go(RouteNames.home);
        },
        child: AuthShell(
          title: 'Create your account',
          subtitle: 'Start a local demo workspace in just a moment.',
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (context.watch<AuthCubit>().state
                      case AuthError(:final message))
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.control),
                      ),
                      child: Text(message,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                    ),
                  Text('Your details',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: Validators.name,
                    decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'How should we address you?',
                        prefixIcon: Icon(Icons.person_outline_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@company.com',
                        prefixIcon: Icon(Icons.alternate_email_rounded)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Secure your account',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a strong password',
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
                  const SizedBox(height: AppSpacing.xs),
                  _PasswordRequirements(password: _passwordController.text),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: Tooltip(
                        message: _obscureConfirmPassword
                            ? 'Show password'
                            : 'Hide password',
                        child: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) => AsyncActionButton(
                      onPressed: _submit,
                      label: 'Create Account',
                      icon: Icons.arrow_forward_rounded,
                      status: state is AuthLoading
                          ? AsyncActionStatus.loading
                          : AsyncActionStatus.idle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Account creation is handled locally on this device.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.taskflowColors.textTertiary),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Text('Already have an account?',
                              style: Theme.of(context).textTheme.bodyMedium)),
                      TextButton(
                          onPressed: () => context.go(RouteNames.login),
                          child: const Text('Sign In')),
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

class _PasswordRequirements extends StatelessWidget {
  final String password;
  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xxs,
      children: [
        _Requirement(label: '8+ characters', met: password.length >= 8),
        _Requirement(
            label: 'Uppercase', met: password.contains(RegExp('[A-Z]'))),
        _Requirement(label: 'Number', met: password.contains(RegExp('[0-9]'))),
      ],
    );
  }
}

class _Requirement extends StatelessWidget {
  final String label;
  final bool met;
  const _Requirement({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    final color = met
        ? context.taskflowColors.success
        : context.taskflowColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
