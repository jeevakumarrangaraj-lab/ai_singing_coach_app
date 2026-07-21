import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

Future<void> navigateBackSafely(
  BuildContext context, {
  required String fallbackRoute,
}) async {
  if (!context.mounted) return;

  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute);
  }
}
