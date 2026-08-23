import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../app/cubit/app_settings_cubit.dart';
import '../../../../app/cubit/connectivity_cubit.dart';
import '../../../../app/cubit/sync_cubit.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../data/datasources/mock_data_source.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final MockDataSource _mockDataSource = sl<MockDataSource>();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await sl<BiometricService>().isAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final session = auth is AuthAuthenticated ? auth.session : null;
    final settings = context.watch<AppSettingsCubit>().state;
    final connectivity = context.watch<ConnectivityCubit>().state;

    final l10n = AppLocalizations.of(context);

    return AppPageScaffold(
      title: l10n.settingsTitle,
      subtitle: l10n.settingsSubtitle,
      body: ResponsiveContent(
        maxWidth: 820,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            if (session != null) ...[
              const SectionHeader(title: 'Profile'),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      UserAvatar(name: session.name, radius: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(session.name,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(session.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: context
                                            .taskflowColors.textSecondary)),
                            const SizedBox(height: AppSpacing.xs),
                            Chip(
                                avatar: Icon(
                                    session.isOrgAdmin
                                        ? Icons.admin_panel_settings_outlined
                                        : Icons.person_outline_rounded,
                                    size: 16),
                                label: Text(session.isOrgAdmin
                                    ? 'Organization Admin'
                                    : 'Member')),
                          ])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            const SectionHeader(
                title: 'Appearance',
                subtitle: 'Use a theme that fits your environment.'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color theme',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_outlined),
                              label: Text('System')),
                          ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Light')),
                          ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Dark')),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (value) => context
                            .read<AppSettingsCubit>()
                            .setThemeMode(value.first),
                      ),
                    ),
                    const Divider(height: 32),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.motion_photos_off_outlined),
                      title: const Text('Reduce motion'),
                      subtitle: const Text(
                          'Use fades or immediate changes instead of movement.'),
                      value: settings.reduceMotion,
                      onChanged: (value) => context
                          .read<AppSettingsCubit>()
                          .setMotionPreference(value
                              ? MotionPreference.reduced
                              : MotionPreference.system),
                    ),
                    const Divider(height: 32),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded),
                      title: const Text('Language'),
                      subtitle: Text(settings.locale == null
                          ? 'System default'
                          : _localeDisplayName(settings.locale!)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showLocalePicker(context, settings),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
                title: 'Security & Privacy',
                subtitle: 'Control how your session is protected.'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('Biometric unlock'),
                    subtitle: Text(_biometricAvailable
                        ? 'Use Face ID or fingerprint to unlock your session.'
                        : 'No biometric hardware available on this device.'),
                    value: settings.biometricEnabled,
                    onChanged: _biometricAvailable
                        ? (value) => context
                            .read<AppSettingsCubit>()
                            .setBiometricEnabled(value)
                        : null,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Auto-lock after inactivity'),
                    subtitle: Text(settings.sessionTimeout.label),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showTimeoutPicker(context, settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
                title: 'Developer & Demo',
                subtitle: 'Simulate assignment scenarios without a backend.'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ExpansionTile(
                leading: Icon(
                    connectivity.isOffline
                        ? Icons.cloud_off_outlined
                        : Icons.science_outlined,
                    color: connectivity.isOffline
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary),
                title: const Text('Simulation controls'),
                subtitle: Text(connectivity.isOffline
                    ? 'Offline mode is active'
                    : 'Connected · mock data source'),
                children: [
                  SwitchListTile(
                    title: const Text('Simulate offline'),
                    subtitle: const Text(
                        'Cached reads remain available; changes require connection.'),
                    secondary: Icon(connectivity.isOffline
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded),
                    value: connectivity.isOffline,
                    onChanged: (value) =>
                        context.read<ConnectivityCubit>().setConnected(!value),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('Force server errors'),
                    subtitle: const Text(
                        'Mock data-source requests return an error.'),
                    secondary: const Icon(Icons.error_outline_rounded),
                    value: _mockDataSource.forceError,
                    onChanged: (value) =>
                        setState(() => _mockDataSource.forceError = value),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('Force timeout'),
                    subtitle: const Text(
                        'Mock data-source requests exceed the timeout.'),
                    secondary: const Icon(Icons.timer_off_outlined),
                    value: _mockDataSource.forceTimeout,
                    onChanged: (value) =>
                        setState(() => _mockDataSource.forceTimeout = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                        'Special IDs such as error_404 and error_timeout can still trigger targeted assignment states.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.taskflowColors.textTertiary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Offline Queue'),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<SyncCubit, SyncState>(
              builder: (context, syncState) {
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          syncState.isSyncing
                              ? Icons.sync_rounded
                              : syncState.pendingCount > 0
                                  ? Icons.cloud_upload_outlined
                                  : Icons.cloud_done_outlined,
                          color: syncState.pendingCount > 0
                              ? Theme.of(context).colorScheme.primary
                              : context.taskflowColors.success,
                        ),
                        title: Text(syncState.isSyncing
                            ? 'Syncing…'
                            : '${syncState.pendingCount} pending operation${syncState.pendingCount == 1 ? '' : 's'}'),
                        subtitle: Text(syncState.pendingCount == 0
                            ? 'All changes are synced.'
                            : 'Will sync automatically when online.'),
                        trailing: syncState.pendingCount > 0
                            ? IconButton(
                                icon: const Icon(Icons.delete_sweep_outlined),
                                tooltip: 'Clear queue',
                                onPressed: () =>
                                    context.read<SyncCubit>().clearQueue(),
                              )
                            : null,
                      ),
                      if (syncState.pendingCount > 0 &&
                          connectivity.isConnected) ...[
                        const Divider(indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.sync_rounded),
                          title: const Text('Sync now'),
                          onTap: syncState.isSyncing
                              ? null
                              : () => context.read<SyncCubit>().syncAll(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Session'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(children: [
                ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Token status'),
                    subtitle: Text(
                        session != null && session.isAccessTokenExpired
                            ? 'Refresh required'
                            : 'Access token valid'),
                    trailing: Icon(
                        session != null && session.isAccessTokenExpired
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: session != null && session.isAccessTokenExpired
                            ? context.taskflowColors.warning
                            : context.taskflowColors.success)),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: const Text('Organization'),
                    subtitle: Text(session?.orgId ?? 'Not available')),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: Icon(Icons.logout_rounded,
                  color: Theme.of(context).colorScheme.error),
              label: Text('Sign out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
                child: Text('TaskFlow 1.0.0 · Assignment build',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.taskflowColors.textTertiary))),
          ],
        ),
      ),
    );
  }

  String _localeDisplayName(Locale locale) {
    return switch (locale.languageCode) {
      'en' => 'English',
      'es' => 'Español',
      'hi' => 'हिन्दी',
      _ => locale.languageCode,
    };
  }

  Future<void> _showLocalePicker(
      BuildContext context, AppSettingsState settings) async {
    final selected = await showDialog<Locale?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppLocalizations.of(context).settingsTitle),
        children: [
          RadioListTile<Locale?>(
            title: const Text('System default'),
            value: null,
            groupValue: settings.locale,
            onChanged: (value) => Navigator.of(ctx).pop(value),
          ),
          RadioListTile<Locale?>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: settings.locale,
            onChanged: (value) => Navigator.of(ctx).pop(value),
          ),
          RadioListTile<Locale?>(
            title: const Text('हिन्दी (Hindi)'),
            value: const Locale('hi'),
            groupValue: settings.locale,
            onChanged: (value) => Navigator.of(ctx).pop(value),
          ),
          RadioListTile<Locale?>(
            title: const Text('Español'),
            value: const Locale('es'),
            groupValue: settings.locale,
            onChanged: (value) => Navigator.of(ctx).pop(value),
          ),
        ],
      ),
    );
    if (selected != settings.locale && context.mounted) {
      context.read<AppSettingsCubit>().setLocale(selected);
    }
  }

  Future<void> _showTimeoutPicker(
      BuildContext context, AppSettingsState settings) async {
    final selected = await showDialog<SessionTimeoutDuration>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Auto-lock timeout'),
        children: SessionTimeoutDuration.values
            .map((option) => RadioListTile<SessionTimeoutDuration>(
                  title: Text(option.label),
                  value: option,
                  groupValue: settings.sessionTimeout,
                  onChanged: (value) => Navigator.of(ctx).pop(value),
                ))
            .toList(),
      ),
    );
    if (selected != null && context.mounted) {
      context.read<AppSettingsCubit>().setSessionTimeout(selected);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Sign out',
        message: 'Sign out of this TaskFlow session?',
        confirmLabel: 'Sign out',
        isDestructive: true);
    if (confirmed && context.mounted) await context.read<AuthCubit>().logout();
  }
}
