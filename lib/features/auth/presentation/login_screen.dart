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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _loginError;

  void _clearLoginError() {
    if (_loginError == null) return;

    setState(() {
      _loginError = null;
    });
  }

  void _showMessage({required String message, required Color backgroundColor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _handleLogin() async {
    final authState = ref.read(authControllerProvider);

    final isLoginLoading =
        authState.isLoading && authState.action == AuthAction.login;

    if (isLoginLoading) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() {
      _loginError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final message = await ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;

    if (message != null) {
      setState(() {
        _loginError = message;
      });

      _showMessage(message: message, backgroundColor: Colors.redAccent);

      return;
    }

    _showMessage(message: 'Login successful.', backgroundColor: Colors.green);

    final currentUser = ref.read(authControllerProvider).user;
    final emailVerified = currentUser?.emailVerified ?? false;

    if (emailVerified) {
      context.go('/home');
    } else {
      context.go('/verify-email');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    final isLoginLoading =
        authState.isLoading && authState.action == AuthAction.login;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
      },
      child: Scaffold(
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
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                                'Welcome back',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Log in to continue your singing practice.',
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
                                textInputAction: TextInputAction.next,
                                onChanged: (_) {
                                  _clearLoginError();
                                },
                              ),

                              const SizedBox(height: 14),

                              AuthTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Your password',
                                obscureText: _obscurePassword,
                                validator: _validatePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _handleLogin();
                                },
                                onChanged: (_) {
                                  _clearLoginError();
                                },
                                onToggleObscure: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                obscureIcon: _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),

                              if (_loginError != null) ...[
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _loginError!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoginLoading
                                      ? null
                                      : () {
                                          context.push('/forgot-password');
                                        },
                                  child: Text(
                                    'Forgot password?',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              AuthElevatedButton(
                                label: 'Log In',
                                isLoading: isLoginLoading,
                                onPressed: _handleLogin,
                              ),

                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      mouseCursor: WidgetStateProperty.all(
                                        SystemMouseCursors.click,
                                      ),
                                      overlayColor:
                                          WidgetStateProperty.resolveWith<
                                            Color?
                                          >((states) {
                                            if (states.contains(
                                              WidgetState.hovered,
                                            )) {
                                              return Colors.white.withValues(
                                                alpha: 0.08,
                                              );
                                            }

                                            if (states.contains(
                                              WidgetState.pressed,
                                            )) {
                                              return Colors.white.withValues(
                                                alpha: 0.14,
                                              );
                                            }

                                            return null;
                                          }),
                                      foregroundColor:
                                          WidgetStateProperty.resolveWith<
                                            Color?
                                          >((states) {
                                            if (states.contains(
                                              WidgetState.hovered,
                                            )) {
                                              return Colors.white;
                                            }

                                            return null;
                                          }),
                                      padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                      ),
                                      minimumSize: WidgetStateProperty.all(
                                        Size.zero,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: isLoginLoading
                                        ? null
                                        : () {
                                            context.push('/signup');
                                          },
                                    child: Text(
                                      'Sign up',
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
      ),
    );
  }
}
