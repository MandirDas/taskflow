import 'package:flutter/material.dart';

import '../../app/theme/taskflow_theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final String? semanticLabel;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 20,
    this.semanticLabel,
  });

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final value = words.take(2).map((e) => e[0].toUpperCase()).join();
    return value.isEmpty ? '?' : value;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      image: true,
      label: semanticLabel ?? name,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: context.taskflowColors.surfaceTonal,
        foregroundImage: imageUrl == null || imageUrl!.isEmpty
            ? null
            : NetworkImage(imageUrl!),
        onForegroundImageError:
            imageUrl == null || imageUrl!.isEmpty ? null : (_, __) {},
        child: Text(
          _initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.65,
              ),
        ),
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double radius;
  final int maxVisible;

  const AvatarStack({
    super.key,
    required this.names,
    this.radius = 15,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final extra = names.length - visible.length;
    return SizedBox(
      width: visible.isEmpty
          ? 0
          : radius * 2 + (visible.length - 1) * radius * 1.35,
      height: radius * 2,
      child: Stack(
        children: [
          for (var index = 0; index < visible.length; index++)
            Positioned(
              left: index * radius * 1.35,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: UserAvatar(name: visible[index], radius: radius),
              ),
            ),
          if (extra > 0)
            Positioned(
              right: 0,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: context.taskflowColors.surfaceTonal,
                child: Text('+$extra',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
        ],
      ),
    );
  }
}
