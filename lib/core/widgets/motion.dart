import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
  static const emphasized = Duration(milliseconds: 320);
  static const brand = Duration(milliseconds: 500);

  static const standardCurve = Curves.easeOutCubic;
  static const emphasizedCurve = Curves.easeInOutCubicEmphasized;
  static const exitCurve = Curves.easeInCubic;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  static Duration duration(
    BuildContext context, [
    Duration normal = standard,
  ]) =>
      reduceMotion(context) ? Duration.zero : normal;
}

class AppFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const AppFadeSwitcher({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context),
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.exitCurve,
      layoutBuilder: (current, previous) => Stack(
        alignment: alignment,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: AppMotion.reduceMotion(context)
                ? Offset.zero
                : const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
