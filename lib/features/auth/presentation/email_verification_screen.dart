import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../presentation/auth_controller.dart';
import '../presentation/widgets/auth_elevated_button.dart';

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
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final email = user?.email ?? '';
    final isVerified = user?.emailVerified ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/signup_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.30)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 420
                    ? 18.0
                    : 28.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Verify your email',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email.isNotEmpty ? 'Signed in as $email' : 'Signed in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.85,
                          ),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Open your email inbox and click the verification link to complete your sign up. After verifying, tap the button below.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.85,
                          ),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Divider(height: 1),
                      const SizedBox(height: 18),

                      if (_isCheckingOrResending) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 18),
                      ],

                      AuthElevatedButton(
                        label: 'I Have Verified',
                        isLoading: _isCheckingOrResending,
                        onPressed: () {
                          if (user == null) return;
                          if (_isCheckingOrResending) return;

                          setState(() {
                            _isCheckingOrResending = true;
                          });

                          ref
                              .read(authControllerProvider.notifier)
                              .checkEmailVerification()
                              .then((message) async {
                                if (!mounted) return;

                                if (message != null) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Email verified.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                if (!mounted) return;
                                // Let GoRouter redirect based on refreshed auth state.
                              })
                              .catchError((_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to verify email.'),
                                      backgroundColor: Colors.redAccent,
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

                      AuthElevatedButton(
                        label: 'Resend Email',
                        isLoading: _isCheckingOrResending,
                        onPressed: user == null
                            ? () {}
                            : () async {
                                if (_isCheckingOrResending) return;

                                setState(() {
                                  _isCheckingOrResending = true;
                                });

                                try {
                                  final message = await ref
                                      .read(authControllerProvider.notifier)
                                      .sendEmailVerification();

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          message ?? 'Verification email sent.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                } on Exception catch (_) {
                                  if (!mounted) return;

                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to resend verification email.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                } finally {
                                  if (!mounted) return;
                                  setState(() {
                                    _isCheckingOrResending = false;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 12),

                      OutlinedButton(
                        onPressed: _isCheckingOrResending
                            ? null
                            : () async {
                                if (_isCheckingOrResending) return;
                                setState(() {
                                  _isCheckingOrResending = true;
                                });

                                try {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .signOut();
                                } finally {
                                  if (!mounted) return;
                                  setState(() {
                                    _isCheckingOrResending = false;
                                  });
                                }

                                if (!mounted) return;
                                // Router redirect will take the user to the correct route.
                              },
                        child: const Text('Log Out'),
                      ),

                      const SizedBox(height: 10),

                      if (isVerified)
                        Text(
                          'Your email is verified.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
