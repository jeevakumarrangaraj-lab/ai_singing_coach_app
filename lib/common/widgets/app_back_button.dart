import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.iconColor,
    this.iconSize = 22,
    this.onPressed,
    this.showOnlyIfCanPop = true,
  });

  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onPressed;
  final bool showOnlyIfCanPop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.onSurface;
    final canPop = GoRouter.of(context).canPop();

    if (showOnlyIfCanPop && !canPop && onPressed == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? (canPop ? () => context.pop() : null),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
          highlightColor: colorScheme.onSurface.withValues(alpha: 0.14),
          splashColor: colorScheme.onSurface.withValues(alpha: 0.20),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: resolvedIconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
