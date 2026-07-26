import 'package:flutter/material.dart';

/// A reusable navigation link widget that renders a non-interactive prefix
/// text followed by an interactive action link.
///
/// Use this to consistently style "Already have an account? Login" and
/// "Don't have an account? Sign up" footers across auth screens.
class AuthNavigationLink extends StatelessWidget {
  const AuthNavigationLink({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.semanticLabel,
    required this.onPressed,
    this.isDisabled = false,
  });

  /// Non-interactive text rendered before the action link (e.g. "Already have an account? ").
  final String prefixText;

  /// Interactive action text (e.g. "Login" or "Sign up").
  final String actionText;

  /// Accessibility label for the action button.
  final String semanticLabel;

  /// Callback invoked when the action is tapped.
  final VoidCallback onPressed;

  /// When true the action button is disabled (prevents duplicate navigation).
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(
          prefixText,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
        Semantics(
          button: true,
          label: semanticLabel,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: isDisabled ? null : onPressed,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
                  }
                  if (states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.focused)) {
                    // Brighter cyan/teal on hover/focus
                    return colorScheme.primary.withValues(alpha: 0.85);
                  }
                  return colorScheme.primary;
                }),
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return colorScheme.primary.withValues(alpha: 0.08);
                  }
                  if (states.contains(WidgetState.pressed)) {
                    return colorScheme.primary.withValues(alpha: 0.16);
                  }
                  if (states.contains(WidgetState.focused)) {
                    return colorScheme.primary.withValues(alpha: 0.12);
                  }
                  return null;
                }),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                ),
                minimumSize: WidgetStateProperty.all(const Size(48, 44)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
                  if (states.contains(WidgetState.focused)) {
                    return BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      width: 2,
                    );
                  }
                  return BorderSide.none;
                }),
              ),
              child: Text(
                actionText,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
