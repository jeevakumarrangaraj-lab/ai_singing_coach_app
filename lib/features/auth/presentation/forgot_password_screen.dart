import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_page_background.dart';
import '../presentation/auth_controller.dart';
import 'widgets/auth_elevated_button.dart';
import 'widgets/auth_text_field.dart';
import '../../../../common/widgets/app_back_button.dart';

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return 'Email is required.';
  }

  if (!email.contains('@')) {
    return 'Enter a valid email.';
  }

  final parts = email.split('@');

  if (parts.length != 2 ||
      parts.first.isEmpty ||
      parts.last.isEmpty ||
      !parts.last.contains('.')) {
    return 'Enter a valid email.';
  }

  return null;
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsivePageBackground(
        imagePath: 'assets/images/signup_bg.png',
        mobileAlignment: Alignment.center,
        wideAlignment: Alignment.bottomCenter,
        mobileOverlayAlpha: 0.28,
        wideOverlayAlpha: 0.18,
        maxContentWidth: 520,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 420
                  ? 18.0
                  : 28.0;
              final maxFormWidth = constraints.maxWidth < 420
                  ? double.infinity
                  : 420.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 22,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxFormWidth),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const AppBackButton(),
                            const SizedBox(height: 10),
                            Text(
                              'Reset password',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your email and we\'ll send you a reset link.',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.85,
                                ),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 26),
                            AuthTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              hintText: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 22),
                            AuthElevatedButton(
                              label: 'Send reset link',
                              isLoading:
                                  authState.isLoading &&
                                  authState.action == AuthAction.forgotPassword,
                              onPressed: () async {
                                final valid =
                                    _formKey.currentState?.validate() ?? false;
                                if (!valid) return;

                                final email = _emailController.text.trim();

                                final message = await ref
                                    .read(authControllerProvider.notifier)
                                    .forgotPassword(email: email);

                                if (!context.mounted) return;
                                if (message != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Reset link sent. Please check your email.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                'Back to login',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
