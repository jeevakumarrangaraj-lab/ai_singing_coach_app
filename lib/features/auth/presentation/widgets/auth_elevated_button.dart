import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';

class AuthElevatedButton extends StatelessWidget {
  const AuthElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    this.iconPosition = IconPosition.start,
  });

  final String label;
  final FutureOr<void> Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.65),
                    AppColors.primaryDark.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null &&
                            iconPosition == IconPosition.start) ...[
                          Icon(icon, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        if (icon != null &&
                            iconPosition == IconPosition.end) ...[
                          const SizedBox(width: 8),
                          Icon(icon, color: Colors.white, size: 22),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
