import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';

enum WindowSizeClass { compact, medium, expanded }

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context, WindowSizeClass sizeClass)
      builder;

  const ResponsiveLayout({super.key, required this.builder});

  static WindowSizeClass sizeClassFor(double width) {
    if (width >= 840) return WindowSizeClass.expanded;
    if (width >= 600) return WindowSizeClass.medium;
    return WindowSizeClass.compact;
  }

  static WindowSizeClass of(BuildContext context) =>
      sizeClassFor(MediaQuery.sizeOf(context).width);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, sizeClassFor(constraints.maxWidth)),
    );
  }
}

/// Centers and constrains page content while applying adaptive page padding.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool applyPadding;
  final EdgeInsets? compactPadding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.applyPadding = true,
    this.compactPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = ResponsiveLayout.sizeClassFor(constraints.maxWidth);
        final horizontal = switch (sizeClass) {
          WindowSizeClass.compact => AppSpacing.md,
          WindowSizeClass.medium => AppSpacing.xl,
          WindowSizeClass.expanded => AppSpacing.xxl,
        };
        final padding = compactPadding ??
            EdgeInsets.symmetric(
                horizontal: horizontal, vertical: AppSpacing.md);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child:
                applyPadding ? Padding(padding: padding, child: child) : child,
          ),
        );
      },
    );
  }
}
