import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';
import 'accessibility.dart';
import 'responsive_layout.dart';

/// Height to reserve at the bottom of scrollable content to avoid
/// the floating bottom navigation bar obscuring content.
/// Nav bar (68) + bottom margin (12) + safe area (~34) + buffer (8) = ~122
const double kFloatingNavBarHeight = 100;

/// Shared page shell with modern header spacing and responsive content width.
class AppPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final bool constrainBody;
  final double maxWidth;

  const AppPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
    this.constrainBody = true,
    this.maxWidth = 1120,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: subtitle == null ? 68 : 80,
        titleSpacing: AppSpacing.md,
        title: SemanticHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.taskflowColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                ),
            ],
          ),
        ),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: kFloatingNavBarHeight),
              child: floatingActionButton,
            )
          : null,
      body: constrainBody
          ? ResponsiveContent(
              maxWidth: maxWidth, applyPadding: false, child: body)
          : body,
    );
  }
}
