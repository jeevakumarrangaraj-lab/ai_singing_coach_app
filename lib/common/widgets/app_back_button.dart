import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 22,
    this.onPressed,
    this.showOnlyIfCanPop = true,
  });

  final Color iconColor;
  final double iconSize;
  final VoidCallback? onPressed;
  final bool showOnlyIfCanPop;

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();

    if (showOnlyIfCanPop && !canPop && onPressed == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: AppColors.deepPlum.withValues(alpha: 0.28),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed ?? (canPop ? () => context.pop() : null),
            mouseCursor: SystemMouseCursors.click,
            hoverColor: Colors.white.withValues(alpha: 0.08),
            highlightColor: Colors.white.withValues(alpha: 0.14),
            splashColor: Colors.white.withValues(alpha: 0.20),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
