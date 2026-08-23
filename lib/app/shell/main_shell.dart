import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_state.dart';
import '../cubit/connectivity_cubit.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<_NavigationItem> _buildItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _NavigationItem(Icons.dashboard_outlined, Icons.dashboard_rounded,
          l10n.dashboardTitle),
      _NavigationItem(
          Icons.folder_outlined, Icons.folder_rounded, l10n.projectsTitle),
      _NavigationItem(Icons.task_outlined, Icons.task_rounded, l10n.tasksTitle),
      _NavigationItem(Icons.notifications_outlined, Icons.notifications_rounded,
          l10n.notificationsTitle),
      _NavigationItem(
          Icons.settings_outlined, Icons.settings_rounded, l10n.settingsTitle),
    ];
  }

  Widget _destinationIcon(BuildContext context, int index, IconData icon) {
    if (index != 3) return Icon(icon);
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (previous, current) {
        final previousCount =
            previous is NotificationLoaded ? previous.unreadCount : 0;
        final currentCount =
            current is NotificationLoaded ? current.unreadCount : 0;
        return previousCount != currentCount;
      },
      builder: (context, state) {
        final count = state is NotificationLoaded ? state.unreadCount : 0;
        return Badge.count(
          count: count,
          isLabelVisible: count > 0,
          child: Icon(icon),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);

    return ResponsiveLayout(
      builder: (context, sizeClass) {
        // ─── Tablet: NavigationRail ────────────────────────────────────
        if (sizeClass == WindowSizeClass.expanded) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.tertiary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.task_alt_rounded,
                            color: Colors.white),
                      ),
                    ),
                    destinations: items
                        .asMap()
                        .entries
                        .map((entry) => NavigationRailDestination(
                              icon: _destinationIcon(
                                  context, entry.key, entry.value.icon),
                              selectedIcon: _destinationIcon(
                                  context, entry.key, entry.value.selectedIcon),
                              label: Text(entry.value.label),
                            ))
                        .toList(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Stack(
                    children: [
                      navigationShell,
                      _BottomOfflinePill(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ─── Phone: Floating bottom nav ────────────────────────────────
        return Scaffold(
          body: Stack(
            children: [
              navigationShell,
              // Offline pill — positioned above the nav bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 120,
                child: Center(child: _BottomOfflinePill()),
              ),
            ],
          ),
          extendBody: true,
          bottomNavigationBar: _FloatingBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: _select,
            items: items,
            buildIcon: _destinationIcon,
          ),
        );
      },
    );
  }
}

// ─── Floating Bottom Navigation Bar ───────────────────────────────────────────

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavigationItem> items;
  final Widget Function(BuildContext, int, IconData) buildIcon;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.buildIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: _NavItem(
                      icon: buildIcon(
                        context,
                        index,
                        isSelected ? item.selectedIcon : item.icon,
                      ),
                      label: item.label,
                      isSelected: isSelected,
                      color: scheme.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.45);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 0,
              vertical: isSelected ? 6 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: isSelected ? color : unselectedColor,
                size: 22,
              ),
              child: icon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? color : unselectedColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Offline Pill ──────────────────────────────────────────────────────

class _BottomOfflinePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) => OfflineBanner(
        isOffline: state.isOffline,
        justReconnected: state.justReconnected,
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavigationItem(this.icon, this.selectedIcon, this.label);
}
