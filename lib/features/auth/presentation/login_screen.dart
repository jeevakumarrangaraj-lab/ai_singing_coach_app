import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/auth_controller.dart';
import 'widgets/auth_navigation_link.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/tuno_gradient_button.dart';
import '../../../../core/widgets/tuno_microphone_emblem.dart';
import '../../../../core/widgets/tuno_music_background.dart';

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

/// Metallic-gold outer border gradient used for the login button and
/// Google/Apple buttons.
const LinearGradient _goldBorderGradient = LinearGradient(
  colors: [
    Color(0xFFFFF2A6),
    Color(0xFFE3B94F),
    Color(0xFFA86D16),
    Color(0xFFF4D675),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Login button gradient: teal → deep navy blue.
const LinearGradient _loginButtonGradient = LinearGradient(
  colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  stops: [0.0, 0.52, 1.0],
);

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

  void _showError({required String message}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: colorScheme.error,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showSuccess({required String message}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showComingSoon(String provider) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$provider authentication coming soon.'),
          backgroundColor: const Color(0xFF2A2A2A),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
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

      _showError(message: message);

      return;
    }

    _showSuccess(message: 'Login successful.');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authState = ref.watch(authControllerProvider);
    final isDark = theme.brightness == Brightness.dark;

    final isLoginLoading =
        authState.isLoading && authState.action == AuthAction.login;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 768;
            final horizontalPadding = constraints.maxWidth < 420 ? 20.0 : 28.0;
            final maxContentWidth = isDesktop ? 800.0 : double.infinity;
            final cardInternalPadding = constraints.maxWidth < 420
                ? const EdgeInsets.fromLTRB(16, 20, 16, 20)
                : const EdgeInsets.fromLTRB(24, 24, 24, 28);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Decorative background — behind everything
                IgnorePointer(
                  ignoring: true,
                  child: TunoMusicBackground(
                    variant: TunoMusicBackgroundVariant.login,
                    showNotes: true,
                    showWaves: true,
                    opacity: 0.6,
                    child: const SizedBox.expand(),
                  ),
                ),

                // Foreground scrollable content
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── 3. Back Button ──
                            _buildBackButton(colorScheme),
                            const SizedBox(height: 20),

                            // ── 4. Tuno Brand Area ──
                            _buildBrandRow(colorScheme, isDark),
                            const SizedBox(height: 28),

                            // ── 5. Heading ──
                            Text(
                              'Welcome Back! \u{1F44B}',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.tunoDarkPrimaryText
                                    : AppColors.tunoLightPrimaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Login to continue',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.tunoDarkSecondaryText
                                    : AppColors.tunoLightSecondaryText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── 6. Login Card ──
                            Container(
                              width: double.infinity,
                              padding: cardInternalPadding,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.tunoDarkBorder.withValues(
                                          alpha: 0.7,
                                        )
                                      : AppColors.tunoLightBorder.withValues(
                                          alpha: 0.6,
                                        ),
                                  width: 1,
                                ),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── 7. Email Field ──
                                  _buildEmailField(colorScheme, isDark),
                                  const SizedBox(height: 16),

                                  // ── 8. Password Field ──
                                  _buildPasswordField(colorScheme, isDark),
                                  const SizedBox(height: 4),

                                  // ── Error text ──
                                  if (_loginError != null) ...[
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        _loginError!,
                                        style: TextStyle(
                                          color: colorScheme.error,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // ── 9. Forgot Password ──
                                  _buildForgotPassword(
                                    colorScheme,
                                    isLoginLoading,
                                  ),
                                  const SizedBox(height: 20),

                                  // ── 10. Login Button ──
                                  _buildLoginButton(isLoginLoading),
                                  const SizedBox(height: 22),

                                  // ── 11. Divider ──
                                  _buildDividerWithLabel(colorScheme, isDark),
                                  const SizedBox(height: 22),

                                  // ── 12. Google & Apple Buttons ──
                                  _buildSocialButtons(isDark),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── 13. Sign-up Footer ──
                            _buildSignupFooter(isLoginLoading),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. BACK BUTTON
  // ─────────────────────────────────────────────────────────────

  Widget _buildBackButton(ColorScheme colorScheme) {
    return Semantics(
      label: 'Go back',
      child: Tooltip(
        message: 'Back',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/welcome');
              }
            },
            child: Focus(
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.tunoBackArrow.withValues(alpha: 0.30),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/welcome');
                      }
                    },
                    hoverColor: AppColors.tunoBackArrow.withValues(alpha: 0.10),
                    highlightColor: AppColors.tunoBackArrow.withValues(
                      alpha: 0.18,
                    ),
                    splashColor: AppColors.tunoBackArrow.withValues(
                      alpha: 0.25,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.tunoBackArrow,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. TUNO BRAND AREA
  // ─────────────────────────────────────────────────────────────

  Widget _buildBrandRow(ColorScheme colorScheme, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Microphone emblem — ~56px on all screen sizes
        SizedBox(
          width: 56,
          height: 56,
          child: TunoMicrophoneEmblem(diameter: 56, compact: true),
        ),
        const SizedBox(width: 14),
        // Brand text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tuno',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.tunoDarkPrimaryText
                    : AppColors.tunoLightPrimaryText,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'AI SINGING COACH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: isDark
                    ? AppColors.tunoDarkSecondaryText
                    : AppColors.tunoLightSecondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 7. EMAIL FIELD
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmailField(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Email Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.tunoDarkSecondaryText
                  : AppColors.tunoLightSecondaryText,
            ),
          ),
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _validateEmail,
          onChanged: (_) => _clearLoginError(),
          autofillHints: const [AutofillHints.email],
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.tunoCyan.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 8. PASSWORD FIELD
  // ─────────────────────────────────────────────────────────────

  Widget _buildPasswordField(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.tunoDarkSecondaryText
                  : AppColors.tunoLightSecondaryText,
            ),
          ),
        ),
        TextFormField(
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          validator: _validatePassword,
          onChanged: (_) => _clearLoginError(),
          autofillHints: const [AutofillHints.password],
          style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            suffixIcon: Semantics(
              label: _obscurePassword ? 'Show password' : 'Hide password',
              button: true,
              child: Tooltip(
                message: _obscurePassword ? 'Show password' : 'Hide password',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    hoverColor: colorScheme.onSurface.withValues(alpha: 0.08),
                    focusColor: colorScheme.onSurface.withValues(alpha: 0.12),
                    splashRadius: 22,
                  ),
                ),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.tunoCyan.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 9. FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────

  Widget _buildForgotPassword(ColorScheme colorScheme, bool isLoading) {
    return Align(
      alignment: Alignment.centerRight,
      child: Semantics(
        label: 'Reset password',
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    context.go('/forgot-password');
                  },
            child: Focus(
              child: Container(
                height: 44,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.tunoBackArrow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 10. LOGIN BUTTON
  // ─────────────────────────────────────────────────────────────

  Widget _buildLoginButton(bool isLoading) {
    final enabled = !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Login',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          gradient: _goldBorderGradient,
        ),
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(54.5),
          child: TunoGradientButton(
            label: 'Login',
            onPressed: enabled ? _handleLogin : null,
            isLoading: isLoading,
            fullWidth: true,
            height: 58,
            borderRadius: 56,
            labelFontSize: 16,
            labelFontWeight: FontWeight.w700,
            gradient: _loginButtonGradient,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 11. DIVIDER
  // ─────────────────────────────────────────────────────────────

  Widget _buildDividerWithLabel(ColorScheme colorScheme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: isDark
                  ? AppColors.tunoDarkSecondaryText
                  : AppColors.tunoLightSecondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 12. GOOGLE & APPLE BUTTONS
  // ─────────────────────────────────────────────────────────────

  Widget _buildSocialButtons(bool isDark) {
    // On narrow screens (<360px available card width), stack vertically.
    // On wider screens, show side by side.
    return LayoutBuilder(
      builder: (context, constraints) {
        final canFitSideBySide = constraints.maxWidth >= 340;

        if (canFitSideBySide) {
          return Row(
            children: [
              Expanded(child: _buildGoogleButton(isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildAppleButton(isDark)),
            ],
          );
        }

        return Column(
          children: [
            _buildGoogleButton(isDark),
            const SizedBox(height: 10),
            _buildAppleButton(isDark),
          ],
        );
      },
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    final borderColor = isDark
        ? const Color(0xFF41647D)
        : const Color(0xFFBCD3E2);
    final goldHighlight = isDark
        ? const Color(0xFFD9A62E).withValues(alpha: 0.15)
        : const Color(0xFFD9A62E).withValues(alpha: 0.08);
    final labelColor = isDark
        ? const Color(0xFFF7F9FC).withValues(alpha: 0.85)
        : const Color(0xFF062A5E);

    return Semantics(
      button: true,
      label: 'Login with Google. Coming soon.',
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: goldHighlight, width: 2.5),
        ),
        padding: const EdgeInsets.all(1.0),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: borderColor, width: 1.5),
            color: isDark ? Colors.transparent : Colors.white,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showComingSoon('Google'),
              borderRadius: BorderRadius.circular(25),
              hoverColor: isDark
                  ? borderColor.withValues(alpha: 0.15)
                  : const Color(0xFF000000).withValues(alpha: 0.04),
              focusColor: isDark
                  ? borderColor.withValues(alpha: 0.20)
                  : const Color(0xFF000000).withValues(alpha: 0.08),
              splashColor: isDark
                  ? borderColor.withValues(alpha: 0.25)
                  : const Color(0xFF000000).withValues(alpha: 0.10),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFF4285F4),
                                  Color(0xFFEA4335),
                                  Color(0xFFFBBC05),
                                  Color(0xFF34A853),
                                ],
                              ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Google',
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton(bool isDark) {
    final borderColor = isDark
        ? const Color(0xFF41647D)
        : const Color(0xFFBCD3E2);
    final goldHighlight = isDark
        ? const Color(0xFFD9A62E).withValues(alpha: 0.15)
        : const Color(0xFFD9A62E).withValues(alpha: 0.08);
    final fgColor = isDark
        ? const Color(0xFFF7F9FC).withValues(alpha: 0.85)
        : const Color(0xFF062A5E);

    return Semantics(
      button: true,
      label: 'Login with Apple. Coming soon.',
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: goldHighlight, width: 2.5),
        ),
        padding: const EdgeInsets.all(1.0),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: borderColor, width: 1.5),
            color: isDark ? Colors.transparent : Colors.white,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showComingSoon('Apple'),
              borderRadius: BorderRadius.circular(25),
              hoverColor: isDark
                  ? borderColor.withValues(alpha: 0.15)
                  : const Color(0xFF000000).withValues(alpha: 0.04),
              focusColor: isDark
                  ? borderColor.withValues(alpha: 0.20)
                  : const Color(0xFF000000).withValues(alpha: 0.08),
              splashColor: isDark
                  ? borderColor.withValues(alpha: 0.25)
                  : const Color(0xFF000000).withValues(alpha: 0.10),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apple_rounded, size: 22, color: fgColor),
                    const SizedBox(width: 10),
                    Text(
                      'Apple',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 13. SIGN-UP FOOTER
  // ─────────────────────────────────────────────────────────────

  Widget _buildSignupFooter(bool isLoading) {
    return Center(
      child: AuthNavigationLink(
        prefixText: "Don't have an account? ",
        actionText: 'Sign Up',
        semanticLabel: 'Go to sign up',
        isDisabled: isLoading,
        onPressed: () => context.go('/signup'),
      ),
    );
  }
}
