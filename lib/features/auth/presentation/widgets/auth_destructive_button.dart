import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/icon_position.dart';

class AuthDestructiveButton extends StatelessWidget {
  const AuthDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
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
          color: isLoading
              ? AppColors.error.withValues(alpha: 0.15)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLoading
                ? AppColors.error.withValues(alpha: 0.5)
                : AppColors.error,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(18),
            splashColor: AppColors.error.withValues(alpha: 0.15),
            highlightColor: AppColors.error.withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.error,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null &&
                            iconPosition == IconPosition.start) ...[
                          Icon(icon, color: AppColors.error, size: 22),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.error,
                          ),
                        ),
                        if (icon != null &&
                            iconPosition == IconPosition.end) ...[
                          const SizedBox(width: 8),
                          Icon(icon, color: AppColors.error, size: 22),
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
