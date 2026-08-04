import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../presentation/auth_controller.dart';
import 'widgets/auth_elevated_button.dart';
import 'widgets/auth_text_field.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_music_background.dart';

String? _validateEmail(String? value, AppLocalizations l10n) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return l10n.emailIsRequired;
  }

  if (!email.contains('@')) {
    return l10n.enterValidEmail;
  }

  final parts = email.split('@');

  if (parts.length != 2 ||
      parts.first.isEmpty ||
      parts.last.isEmpty ||
      !parts.last.contains('.')) {
    return l10n.enterValidEmail;
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 18.0 : 28.0;
            final verticalPadding = 22.0;
            final minHeight = (constraints.maxHeight - verticalPadding * 2)
                .clamp(0.0, double.infinity);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Decorative shared auth background — behind everything
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
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              AppBackButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/login');
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.resetPassword,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.enterEmailForReset,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 26),
                              AuthTextField(
                                controller: _emailController,
                                labelText: l10n.email,
                                hintText: l10n.emailHintReset,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    _validateEmail(value, l10n),
                              ),
                              const SizedBox(height: 22),
                              AuthElevatedButton(
                                label: l10n.sendResetLink,
                                isLoading:
                                    authState.isLoading &&
                                    authState.action ==
                                        AuthAction.forgotPassword,
                                onPressed: () async {
                                  final valid =
                                      _formKey.currentState?.validate() ??
                                      false;
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
                                        backgroundColor: colorScheme.error,
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.resetLinkSent),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text(
                                  l10n.backToLogin,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
