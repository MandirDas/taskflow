import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/taskflow_theme.dart';
import '../../../../core/widgets/motion.dart';
import '../../../../core/widgets/responsive_layout.dart';

const taskFlowBrandHeroTag = 'taskflow-brand-mark';

class TaskFlowBrandMark extends StatelessWidget {
  final double size;
  final bool hero;
  final bool onGradient;

  const TaskFlowBrandMark({
    super.key,
    this.size = 64,
    this.hero = true,
    this.onGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/taskflow_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
    return hero
        ? Hero(
            tag: taskFlowBrandHeroTag,
            child: Material(type: MaterialType.transparency, child: mark))
        : mark;
  }
}

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        if (sizeClass == WindowSizeClass.expanded) {
          return Row(
            children: [
              const Expanded(flex: 5, child: _BrandPanel()),
              Expanded(
                flex: 6,
                child: _AuthFormRegion(
                  title: title,
                  subtitle: subtitle,
                  child: child,
                ),
              ),
            ],
          );
        }
        return _CompactAuthLayout(
          title: title,
          subtitle: subtitle,
          child: child,
        );
      },
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Stack(
        children: [
          const Positioned(top: -80, left: -80, child: _Glow(size: 260)),
          const Positioned(bottom: -120, right: -80, child: _Glow(size: 340)),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TaskFlowBrandMark(size: 78, onGradient: true),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Turn plans into\nmeaningful progress.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Organize projects, focus on the right work, and keep your team moving together.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _FeatureLine(
                    icon: Icons.bolt_rounded,
                    label: 'Clear priorities at a glance'),
                const _FeatureLine(
                    icon: Icons.groups_2_outlined,
                    label: 'Simple team collaboration'),
                const _FeatureLine(
                    icon: Icons.insights_outlined,
                    label: 'Progress that stays visible'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  const _Glow({required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      );
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white)),
          ],
        ),
      );
}

class _CompactAuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CompactAuthLayout(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
            child: Column(
              children: [
                const TaskFlowBrandMark(size: 68, onGradient: true),
                const SizedBox(height: AppSpacing.md),
                Text('TaskFlow',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.xxl),
                _AuthCard(title: title, subtitle: subtitle, child: child),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthFormRegion extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AuthFormRegion(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _AuthCard(
              title: title,
              subtitle: subtitle,
              showMark: true,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showMark;

  const _AuthCard(
      {required this.title,
      required this.subtitle,
      required this.child,
      this.showMark = false});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: AppMotion.reduceMotion(context) ? 1 : 0.96, end: 1),
      duration: AppMotion.duration(context),
      curve: AppMotion.standardCurve,
      builder: (context, value, content) =>
          Transform.scale(scale: value, child: content),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.modal),
          border: Border.all(color: context.taskflowColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.07),
              blurRadius: 34,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMark) ...[
              const Align(
                  alignment: Alignment.centerLeft,
                  child: TaskFlowBrandMark(size: 54)),
              const SizedBox(height: AppSpacing.xl),
            ],
            Semantics(
                header: true,
                child: Text(title,
                    style: Theme.of(context).textTheme.headlineLarge)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.taskflowColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}
