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

  final emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  if (!emailRegex.hasMatch(email)) {
    return 'Enter a valid email.';
  }

  return null;
}

String? _validatePassword(String? value) {
  final password = value ?? '';

  if (password.isEmpty) {
    return 'Password is required.';
  }

  if (password.length < 6) {
    return 'Password must be at least 6 characters.';
  }

  return null;
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                          children: [
                            const AppBackButton(),
                            const SizedBox(height: 10),
                            Text(
                              'Create account',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign up to start practicing with AI feedback.',
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
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              hintText: 'At least 6 characters',
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              onToggleObscure: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              obscureIcon: _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                            const SizedBox(height: 10),
                            AuthTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter password',
                              obscureText: _obscureConfirmPassword,
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) {
                                  return 'Confirm password is required.';
                                }
                                if (value != _passwordController.text.trim()) {
                                  return 'Passwords do not match.';
                                }

                                return null;
                              },
                              onToggleObscure: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              obscureIcon: _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                            const SizedBox(height: 22),
                            AuthElevatedButton(
                              label: 'Sign Up',
                              isLoading:
                                  authState.isLoading &&
                                  authState.action == AuthAction.signup,
                              onPressed: () async {
                                FocusScope.of(context).unfocus();

                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                final email = _emailController.text.trim();
                                final password = _passwordController.text
                                    .trim();
                                final confirmPassword =
                                    _confirmPasswordController.text.trim();

                                if (password != confirmPassword) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match.'),
                                    ),
                                  );
                                  return;
                                }

                                final message = await ref
                                    .read(authControllerProvider.notifier)
                                    .signup(email: email, password: password);

                                if (!context.mounted) return;

                                if (message != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                context.go('/verify-email');
                              },
                            ),

                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Log in',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
