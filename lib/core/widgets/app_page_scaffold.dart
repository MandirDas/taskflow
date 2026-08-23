import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';
import 'accessibility.dart';
import 'responsive_layout.dart';

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
      floatingActionButton: floatingActionButton,
      body: constrainBody
          ? ResponsiveContent(
              maxWidth: maxWidth, applyPadding: false, child: body)
          : body,
    );
  }
}
