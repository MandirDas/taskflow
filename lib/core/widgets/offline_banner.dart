import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';

/// Animated bottom pill indicator for connectivity state.
/// - Offline: a circle appears, expands into a yellow/amber pill with text.
/// - Back online: the pill turns green, shrinks back to a circle, then disappears.
class OfflineBanner extends StatefulWidget {
  final bool isOffline;
  final bool isStaleData;
  final bool justReconnected;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.isStaleData = false,
    this.justReconnected = false,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _expandAnimation;

  bool _showWidget = false;
  bool _showingReconnected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.isOffline) {
      _showWidget = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isOffline && widget.isOffline) {
      // Went offline: show circle → expand to pill
      _showingReconnected = false;
      _showWidget = true;
      _controller.forward(from: 0);
    } else if (oldWidget.isOffline && !widget.isOffline) {
      // Came back online: turn green → shrink → disappear
      setState(() => _showingReconnected = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showWidget = false;
                _showingReconnected = false;
              });
            }
          });
        }
      });
    } else if (!oldWidget.justReconnected && widget.justReconnected) {
      // justReconnected flag without going through offline→online
      setState(() {
        _showingReconnected = true;
        _showWidget = true;
      });
      _controller.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            _controller.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _showWidget = false;
                  _showingReconnected = false;
                });
              }
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showWidget) return const SizedBox.shrink();

    final isReconnected = _showingReconnected;
    final color = isReconnected
        ? context.taskflowColors.success
        : const Color(0xFFF59E0B);
    final textColor = isReconnected ? Colors.white : const Color(0xFF78350F);
    final icon = isReconnected ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final label = isReconnected ? 'Back online' : "You're offline";

    return Semantics(
      liveRegion: true,
      label: label,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          // Interpolate width: circle (44) → full pill (~200)
          final expandValue = _expandAnimation.value;
          final width = 44.0 + (180.0 * expandValue);
          final height = 44.0;
          final borderRadius = height / 2;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: textColor, size: 20),
                  if (expandValue > 0.3) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Opacity(
                        opacity: ((expandValue - 0.3) / 0.7).clamp(0.0, 1.0),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
