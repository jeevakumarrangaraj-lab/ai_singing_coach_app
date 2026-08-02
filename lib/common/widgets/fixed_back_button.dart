import 'package:flutter/material.dart';

import 'package:ai_singing_coach/core/theme/app_colors.dart';
import 'package:ai_singing_coach/l10n/app_localizations.dart';

/// Fixed top-left back button with 48×48 touch target, SafeArea-aware,
/// themed border/hover/splash states. Used for screens needing a persistent
/// back button that stays fixed while content scrolls.
class FixedBackButton extends StatelessWidget {
  const FixedBackButton({
    super.key,
    required this.onPressed,
    required this.l10n,
  });

  final VoidCallback? onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.tunoDarkBorder.withValues(alpha: 0.7)
        : AppColors.tunoLightBorder.withValues(alpha: 0.6);
    final surfaceColor = colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      label: l10n.back,
      child: Tooltip(
        message: l10n.back,
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
            highlightColor: colorScheme.onSurface.withValues(alpha: 0.14),
            splashColor: colorScheme.onSurface.withValues(alpha: 0.20),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
