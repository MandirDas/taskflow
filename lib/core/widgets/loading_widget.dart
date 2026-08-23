import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';
import 'motion.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Semantics(
      liveRegion: true,
      label: message ?? 'Loading',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.taskflowColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    return fullScreen ? Center(child: content) : content;
  }
}

class ShimmerLoadingList extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerLoadingList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 96,
  });

  @override
  State<ShimmerLoadingList> createState() => _ShimmerLoadingListState();
}

class _ShimmerLoadingListState extends State<ShimmerLoadingList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.55,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotion(context);
    final color = context.taskflowColors.surfaceTonal;
    final highlight = Theme.of(context).colorScheme.surface;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Opacity(
          opacity: reduceMotion ? 0.78 : _controller.value,
          child: Container(
            height: widget.itemHeight,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SkeletonLine(
                      width: constraints.maxWidth * 0.62, color: highlight),
                  const SizedBox(height: 12),
                  _SkeletonLine(
                      width: constraints.maxWidth * 0.38,
                      color: highlight,
                      height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _SkeletonLine(
      {required this.width, required this.color, this.height = 14});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
      );
}
