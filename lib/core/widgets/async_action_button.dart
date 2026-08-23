import 'package:flutter/material.dart';

import 'motion.dart';

enum AsyncActionStatus { idle, loading, success }

class AsyncActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final AsyncActionStatus status;
  final IconData? icon;
  final bool expanded;

  const AsyncActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.status = AsyncActionStatus.idle,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: status == AsyncActionStatus.loading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: AppMotion.duration(context, AppMotion.fast),
        child: switch (status) {
          AsyncActionStatus.loading => const Row(
              key: ValueKey('loading'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Please wait…'),
              ],
            ),
          AsyncActionStatus.success => const Row(
              key: ValueKey('success'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 18),
                SizedBox(width: 8),
                Text('Done')
              ],
            ),
          AsyncActionStatus.idle => Row(
              key: const ValueKey('idle'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8)
                ],
                Text(label),
              ],
            ),
        },
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
