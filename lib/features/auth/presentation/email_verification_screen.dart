import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../presentation/auth_controller.dart';
import 'widgets/auth_elevated_button.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/tuno_music_background.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isCheckingOrResending = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final email = user?.email ?? '';
    final isVerified = user?.emailVerified ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                // Decorative background — behind everything, non-interactive
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
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppBackButton(showOnlyIfCanPop: true),
                            const SizedBox(height: 10),
                            Text(
                              l10n.verifyYourEmail,
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              email.isNotEmpty
                                  ? l10n.signedInAs(email)
                                  : l10n.signedIn,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              l10n.verificationInstructions,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Divider(
                              height: 1,
                              color: colorScheme.outline.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 18),

                            if (_isCheckingOrResending) ...[
                              Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],

                            AuthElevatedButton(
                              label: l10n.iHaveVerified,
                              isLoading: _isCheckingOrResending,
                              onPressed: _isCheckingOrResending || user == null
                                  ? null
                                  : () {
                                      setState(() {
                                        _isCheckingOrResending = true;
                                      });

                                      ref
                                          .read(authControllerProvider.notifier)
                                          .checkEmailVerification()
                                          .then((message) async {
                                            if (!mounted) return;
                                            if (!context.mounted) return;

                                            if (message != null) {
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.yourEmailIsNotVerified,
                                                    ),
                                                    backgroundColor:
                                                        colorScheme.error,
                                                  ),
                                                );
                                              return;
                                            }

                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.emailVerifiedSuccess,
                                                ),
                                              ),
                                            );

                                            if (!mounted) return;
                                            // Let GoRouter redirect based on refreshed auth state.
                                          })
                                          .catchError((_) {
                                            if (!mounted) return;
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                              ..hideCurrentSnackBar()
                                              ..showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l10n.failedToVerify,
                                                  ),
                                                  backgroundColor:
                                                      colorScheme.error,
                                                ),
                                              );
                                          })
                                          .whenComplete(() {
                                            if (!mounted) return;
                                            setState(() {
                                              _isCheckingOrResending = false;
                                            });
                                          });
                                    },
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: AuthElevatedButton(
                                label: l10n.resendEmail,
                                isLoading: _isCheckingOrResending,
                                onPressed:
                                    _isCheckingOrResending || user == null
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isCheckingOrResending = true;
                                        });

                                        try {
                                          final message = await ref
                                              .read(
                                                authControllerProvider.notifier,
                                              )
                                              .sendEmailVerification();

                                          if (!mounted) return;
                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  message ??
                                                      l10n.verificationSent,
                                                ),
                                              ),
                                            );
                                        } on Exception catch (_) {
                                          if (!mounted) return;
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.failedToResend,
                                                ),
                                                backgroundColor:
                                                    colorScheme.error,
                                              ),
                                            );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isCheckingOrResending = false;
                                            });
                                          }
                                        }
                                      },
                              ),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: _isCheckingOrResending
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isCheckingOrResending = true;
                                        });

                                        try {
                                          await ref
                                              .read(
                                                authControllerProvider.notifier,
                                              )
                                              .signOut();
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isCheckingOrResending = false;
                                            });
                                          }
                                        }

                                        if (!mounted) return;
                                        // Router redirect will take the user to the correct route.
                                      },
                                child: _isCheckingOrResending
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                colorScheme.onSurface,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        l10n.logOut,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (isVerified)
                              Text(
                                l10n.yourEmailIsVerified,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
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
}
