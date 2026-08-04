import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_gradient_button.dart';
import '../../../../core/widgets/tuno_music_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../presentation/auth_controller.dart';
import 'widgets/auth_navigation_link.dart';

String? _validateEmail(String? value, AppLocalizations l10n) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return l10n.emailIsRequired;
  final emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  if (!emailRegex.hasMatch(email)) return l10n.enterValidEmail;
  return null;
}

String? _validatePassword(String? value, AppLocalizations l10n) {
  final password = value ?? '';
  if (password.isEmpty) return l10n.passwordIsRequired;
  if (password.length < 6) return l10n.passwordMinLength;
  return null;
}

String? _validateName(String? value, AppLocalizations l10n) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return l10n.fullNameRequired;
  if (name.length < 2) return l10n.nameMinLength;
  return null;
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _signupError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearSignupError() {
    if (_signupError == null) return;
    setState(() => _signupError = null);
  }

  void _showError(String message) {
    if (!mounted) return;
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

  void _showComingSoon(String provider, AppLocalizations l10n) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.authComingSoon(provider)),
          backgroundColor: const Color(0xFF2A2A2A),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleSignup() async {
    final authState = ref.read(authControllerProvider);
    if (authState.isLoading && authState.action == AuthAction.signup) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _signupError = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final message = await ref
        .read(authControllerProvider.notifier)
        .signup(email: email, password: password);
    if (!mounted) return;
    if (message != null) {
      setState(() => _signupError = message);
      _showError(message);
      return;
    }
    if (!context.mounted) return;
    context.go('/verify-email');
  }

  static const LinearGradient _goldBorderGradient = LinearGradient(
    colors: [
      Color(0xFFFFF2A6),
      Color(0xFFE3B94F),
      Color(0xFFA86D16),
      Color(0xFFF4D675),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _signupButtonGradient = LinearGradient(
    colors: [Color(0xFF008BA6), Color(0xFF006D98), Color(0xFF014B75)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.52, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authState = ref.watch(authControllerProvider);
    final isSignupLoading =
        authState.isLoading && authState.action == AuthAction.signup;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 768;
            final horizontalPadding = constraints.maxWidth < 420 ? 18.0 : 28.0;
            final maxFormWidth = isDesktop ? 640.0 : double.infinity;
            final verticalPadding = 22.0;

            return Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: TunoMusicBackground(
                    variant: TunoMusicBackgroundVariant.signup,
                    showNotes: true,
                    showWaves: true,
                    opacity: 0.6,
                    child: const SizedBox.expand(),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - verticalPadding * 2,
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
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AppBackButton(
                                  iconColor: colorScheme.primary,
                                  iconSize: 22,
                                  onPressed: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/welcome');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.createAccount,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.joinTuno,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.6,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: _fullNameController,
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) => _validateName(v, l10n),
                                      onChanged: (_) => _clearSignupError(),
                                      autofillHints: const [AutofillHints.name],
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 15,
                                      ),
                                      decoration: _inputDecoration(
                                        label: l10n.fullName,
                                        hint: l10n.fullNameHint,
                                        prefixIcon: Icons.person_outline,
                                        colorScheme: colorScheme,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (v) => _validateEmail(v, l10n),
                                      onChanged: (_) => _clearSignupError(),
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 15,
                                      ),
                                      decoration: _inputDecoration(
                                        label: l10n.emailFieldLabel,
                                        hint: l10n.emailHintSignup,
                                        prefixIcon: Icons.email_outlined,
                                        colorScheme: colorScheme,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _handleSignup(),
                                      validator: (v) =>
                                          _validatePassword(v, l10n),
                                      onChanged: (_) => _clearSignupError(),
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 15,
                                      ),
                                      decoration: _inputDecoration(
                                        label: l10n.passwordFieldLabel,
                                        hint: l10n.passwordHintSignup,
                                        prefixIcon: Icons.lock_outlined,
                                        colorScheme: colorScheme,
                                        isDark: isDark,
                                        suffixWidget: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: colorScheme.onSurfaceVariant,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_signupError != null) ...[
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          _signupError!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    _buildSignupButton(isSignupLoading, l10n),
                                    const SizedBox(height: 20),
                                    _buildDividerWithLabel(l10n),
                                    const SizedBox(height: 20),
                                    _buildGoogleButton(l10n),
                                    const SizedBox(height: 12),
                                    _buildAppleButton(l10n),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildLoginFooter(l10n),
                              const SizedBox(height: 16),
                            ],
                          ),
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

  Widget _buildSignupButton(bool isLoading, AppLocalizations l10n) {
    final enabled = !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.signUp,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56),
          gradient: _goldBorderGradient,
        ),
        padding: const EdgeInsets.all(1.8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(54.2),
          child: TunoGradientButton(
            label: l10n.signUp,
            onPressed: enabled ? _handleSignup : null,
            isLoading: isLoading,
            fullWidth: true,
            height: 56,
            borderRadius: 56,
            labelFontSize: 16,
            labelFontWeight: FontWeight.w700,
            gradient: _signupButtonGradient,
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithLabel(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.orContinueWith,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific border color
    final borderColor = isDark
        ? const Color(0xFF41647D)
        : const Color(0xFFBCD3E2);

    // Subtle metallic-gold outer highlight at low opacity
    final goldHighlight = isDark
        ? const Color(0xFFD9A62E).withValues(alpha: 0.15)
        : const Color(0xFFD9A62E).withValues(alpha: 0.08);

    // Label color: light blue-grey/white for dark, navy for light
    final labelColor = isDark
        ? const Color(0xFFF7F9FC).withValues(alpha: 0.85)
        : const Color(0xFF062A5E);

    return Semantics(
      button: true,
      label: l10n.signUpWithGoogle,
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
              onTap: () => _showComingSoon('Google', l10n),
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

  Widget _buildAppleButton(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific border color
    final borderColor = isDark
        ? const Color(0xFF41647D)
        : const Color(0xFFBCD3E2);

    // Subtle metallic-gold outer highlight at low opacity
    final goldHighlight = isDark
        ? const Color(0xFFD9A62E).withValues(alpha: 0.15)
        : const Color(0xFFD9A62E).withValues(alpha: 0.08);

    // Label and icon color
    final fgColor = isDark
        ? const Color(0xFFF7F9FC).withValues(alpha: 0.85)
        : const Color(0xFF062A5E);

    return Semantics(
      button: true,
      label: l10n.signUpWithApple,
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
              onTap: () => _showComingSoon('Apple', l10n),
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

  Widget _buildLoginFooter(AppLocalizations l10n) {
    final authState = ref.watch(authControllerProvider);
    final isNavigating =
        authState.isLoading && authState.action == AuthAction.signup;

    return AuthNavigationLink(
      prefixText: l10n.alreadyHaveAccount,
      actionText: l10n.login,
      semanticLabel: l10n.goToLogin,
      isDisabled: isNavigating,
      onPressed: () => context.go('/login'),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    required bool isDark,
    Widget? suffixWidget,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: colorScheme.primary, size: 22),
      suffixIcon: suffixWidget,
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          color: colorScheme.primary.withValues(alpha: 0.8),
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
    );
  }
}
