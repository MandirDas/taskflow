import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Centralized accessibility helpers for TaskFlow.
/// Provides screen-reader announcements and semantic wrappers.
class AppAccessibility {
  AppAccessibility._();

  /// Announce a message to assistive technology (screen readers).
  /// Use for asynchronous state changes: loading complete, error occurred,
  /// task completed, filter results changed, connectivity status, etc.
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, Directionality.of(context));
  }

  /// Announce a polite message with a slight delay to avoid interrupting
  /// the current screen-reader focus.
  static Future<void> announceDelayed(
    BuildContext context,
    String message, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
    if (context.mounted) {
      SemanticsService.announce(message, Directionality.of(context));
    }
  }
}

/// A widget that wraps its child and marks it as a semantic heading.
/// Use for page titles and section headers.
class SemanticHeader extends StatelessWidget {
  final Widget child;
  final bool isHeader;

  const SemanticHeader({
    super.key,
    required this.child,
    this.isHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: isHeader,
      child: child,
    );
  }
}

/// Wraps a decorative widget to exclude it from the semantic tree.
/// Use for purely visual elements (gradient circles, decoration lines, etc.).
class Decorative extends StatelessWidget {
  final Widget child;

  const Decorative({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: child);
  }
}
