import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_display_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          context.read<NotificationCubit>().state is! NotificationInitial) {
        return;
      }
      final auth = context.read<AuthCubit>().state;
      if (auth is AuthAuthenticated) {
        context.read<NotificationCubit>().load(auth.session.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state is NotificationError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AppPageScaffold(
        title: AppLocalizations.of(context).notificationsTitle,
        subtitle: AppLocalizations.of(context).notificationsSubtitle,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded || state.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: state.isMutating
                    ? null
                    : context.read<NotificationCubit>().markAllAsRead,
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) => AppFadeSwitcher(
            child: switch (state) {
              NotificationInitial() ||
              NotificationLoading() =>
                const ShimmerLoadingList(
                    key: ValueKey('loading'), itemCount: 6, itemHeight: 84),
              NotificationEmpty() => const EmptyStateWidget(
                  key: ValueKey('empty'),
                  title: 'You’re all caught up',
                  subtitle:
                      'New assignments and task updates will appear here.',
                  icon: Icons.notifications_none_rounded),
              NotificationError(:final message) => ErrorDisplayWidget(
                  key: const ValueKey('error'),
                  message: message,
                  onRetry: context.read<NotificationCubit>().refresh),
              NotificationLoaded() => _NotificationContent(
                  key: const ValueKey('content'), state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final NotificationLoaded state;
  const _NotificationContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final items = state.visibleNotifications;
    return RefreshIndicator(
      onRefresh: context.read<NotificationCubit>().refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        label: Text('All'),
                        icon: Icon(Icons.inbox_outlined)),
                    ButtonSegment(
                        value: true,
                        label: Text('Unread'),
                        icon: Icon(Icons.mark_email_unread_outlined)),
                  ],
                  selected: {state.showUnreadOnly},
                  onSelectionChanged: (value) => context
                      .read<NotificationCubit>()
                      .setUnreadOnly(value.first),
                ),
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                  title: 'No unread notifications',
                  subtitle: 'You have reviewed every update.',
                  icon: Icons.done_all_rounded),
            )
          else
            ..._groupSlivers(context, items),
        ],
      ),
    );
  }

  List<Widget> _groupSlivers(
      BuildContext context, List<AppNotification> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <String, List<AppNotification>>{'Today': [], 'Earlier': []};
    for (final item in items) {
      final date = DateTime(
          item.createdAt.year, item.createdAt.month, item.createdAt.day);
      groups[date == today ? 'Today' : 'Earlier']!.add(item);
    }
    final slivers = <Widget>[];
    for (final entry in groups.entries) {
      if (entry.value.isEmpty) continue;
      slivers.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        sliver: SliverToBoxAdapter(child: SectionHeader(title: entry.key)),
      ));
      slivers.add(SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        sliver: SliverList.separated(
          itemCount: entry.value.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) =>
              _NotificationTile(notification: entry.value[index]),
        ),
      ));
    }
    return slivers;
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (notification.type) {
      'task_assigned' => Icons.assignment_ind_outlined,
      'task_updated' => Icons.update_rounded,
      _ => Icons.notifications_outlined,
    };
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.fast),
      decoration: BoxDecoration(
        color: notification.read
            ? scheme.surface
            : scheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
            color: notification.read
                ? context.taskflowColors.border
                : scheme.primary.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        onTap: () async {
          if (!notification.read) {
            await context.read<NotificationCubit>().markAsRead(notification.id);
          }
          if (notification.taskId != null && context.mounted) {
            context.push(RouteNames.taskDetailPath(notification.taskId!));
          }
        },
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: scheme.primary
                  .withValues(alpha: notification.read ? 0.07 : 0.12),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon,
              color: notification.read
                  ? context.taskflowColors.textTertiary
                  : scheme.primary),
        ),
        title: Text(notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight:
                    notification.read ? FontWeight.w400 : FontWeight.w600)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(AppDateUtils.timeAgo(notification.createdAt),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.taskflowColors.textTertiary))),
        trailing: notification.read
            ? const Icon(Icons.chevron_right_rounded)
            : Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                    color: scheme.primary, shape: BoxShape.circle)),
      ),
    );
  }
}
