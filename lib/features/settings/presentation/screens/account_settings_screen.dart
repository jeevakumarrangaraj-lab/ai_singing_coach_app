import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/auth/presentation/auth_controller.dart';
import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';

/// Settings sub-page for managing the user's Tuno account.
///
/// Displays real Firebase user data and provides the following actions:
/// - Personal Information (display name edit)
/// - Email Address (read-only)
/// - Change Password (reset email)
/// - Email Verification
/// - Sign Out
/// - Delete Account
class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  // ── Action guard flags ──
  bool _isSendingPasswordReset = false;
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  bool _isDeleting = false;

  // ── Delete-account state ──
  bool _deleteConfirmed = false;
  final _deleteTextController = TextEditingController();

  @override
  void dispose() {
    _deleteTextController.dispose();
    super.dispose();
  }

  // ── Resolve colours based on theme ──
  Color get _accentColor =>
      isDark ? const Color(0xFF12B5C1) : const Color(0xFF0B96A5);

  Color get _cardColor => isDark ? const Color(0xFF061E31) : cs.surface;

  Color get _borderColor => isDark
      ? cs.outline.withValues(alpha: 0.5)
      : cs.outlineVariant.withValues(alpha: 0.7);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  ColorScheme get cs => Theme.of(context).colorScheme;

  // ── Current authenticated user ──
  User? get _user => ref.watch(authControllerProvider).user;

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = _user;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Background decorations (non-interactive)
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // ── Header with back button ──
                              Semantics(
                                label: 'Back to Settings',
                                button: true,
                                child: Tooltip(
                                  message: 'Back',
                                  child: AppBackButton(
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/settings');
                                      }
                                    },
                                    showOnlyIfCanPop: false,
                                    iconColor: _accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Title ──
                              Center(
                                child: Text(
                                  'Account',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Account Summary Card ──
                              _buildAccountSummaryCard(user, textTheme),
                              const SizedBox(height: 20),

                              // ── Action Cards ──
                              _buildActionCard(
                                icon: Icons.person_rounded,
                                label: 'Personal Information',
                                onTap: () =>
                                    _showPersonalInfoSheet(user, textTheme),
                              ),
                              const SizedBox(height: 12),

                              _buildActionCard(
                                icon: Icons.email_rounded,
                                label: 'Email Address',
                                trailing: Text(
                                  user?.email ?? '',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => _showEmailInfoDialog(user),
                              ),
                              const SizedBox(height: 12),

                              _buildActionCard(
                                icon: Icons.lock_outline_rounded,
                                label: 'Change Password',
                                onTap: _handlePasswordReset,
                              ),
                              const SizedBox(height: 12),

                              _buildActionCard(
                                icon: Icons.verified_user_rounded,
                                label: 'Email Verification',
                                trailing: _buildVerificationBadge(user),
                                onTap: () => _handleEmailVerification(user),
                              ),
                              const SizedBox(height: 12),

                              _buildActionCard(
                                icon: Icons.logout_rounded,
                                label: 'Sign Out',
                                onTap: _handleSignOut,
                              ),
                              const SizedBox(height: 12),

                              _buildDeleteAccountCard(),
                              const SizedBox(height: 24),
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
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ACCOUNT SUMMARY CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildAccountSummaryCard(User? user, TextTheme textTheme) {
    final providerNames = _getProviderNames(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 36,
            backgroundColor: _accentColor.withValues(alpha: 0.15),
            child: Icon(Icons.person_rounded, size: 36, color: _accentColor),
          ),
          const SizedBox(height: 14),

          // Display name
          Text(
            user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Tuno Singer',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),

          // Email
          Semantics(
            label: 'Email: ${user?.email ?? ''}',
            child: Text(
              user?.email ?? 'No email',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Verification status
          Semantics(
            label: user?.emailVerified == true
                ? 'Email verified'
                : 'Email not verified',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  user?.emailVerified == true
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: user?.emailVerified == true
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  user?.emailVerified == true ? 'Verified' : 'Not verified',
                  style: textTheme.bodySmall?.copyWith(
                    color: user?.emailVerified == true
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Provider info
          if (providerNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Sign in with ${providerNames.join(', ')}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Extract human-readable provider names from the user's provider data.
  List<String> _getProviderNames(User? user) {
    if (user == null) return [];
    return user.providerData.map((info) {
      switch (info.providerId) {
        case 'password':
          return 'Password';
        case 'google.com':
          return 'Google';
        case 'apple.com':
          return 'Apple';
        case 'facebook.com':
          return 'Facebook';
        default:
          return info.providerId;
      }
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTION CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          hoverColor: cs.primary.withValues(alpha: 0.06),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 24, color: _accentColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[trailing, const SizedBox(width: 8)],
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: _accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  VERIFICATION BADGE
  // ─────────────────────────────────────────────────────────────

  Widget _buildVerificationBadge(User? user) {
    if (user?.emailVerified == true) {
      return Semantics(
        label: 'Verified',
        child: Text(
          'Verified',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }

    if (_isSendingVerification) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: _accentColor),
      );
    }

    return const SizedBox.shrink();
  }

  // ─────────────────────────────────────────────────────────────
  //  DELETE ACCOUNT CARD (red)
  // ─────────────────────────────────────────────────────────────

  Widget _buildDeleteAccountCard() {
    return Semantics(
      button: true,
      label: 'Delete Account',
      child: Tooltip(
        message: 'Delete Account',
        child: InkWell(
          onTap: _showDeleteConfirmationDialog,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  size: 24,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Delete Account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTIONS
  // ─────────────────────────────────────────────────────────────

  /// Opens a bottom sheet to edit the display name.
  void _showPersonalInfoSheet(User? user, TextTheme textTheme) {
    final controller = TextEditingController(text: user?.displayName ?? '');
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Personal Information',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                      onFieldSubmitted: isUpdating
                          ? null
                          : (_) => _updateDisplayName(
                              ctx,
                              setSheetState,
                              controller,
                              formKey,
                            ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isUpdating
                            ? null
                            : () => _updateDisplayName(
                                ctx,
                                setSheetState,
                                controller,
                                formKey,
                              ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateDisplayName(
    BuildContext ctx,
    void Function(VoidCallback) setSheetState,
    TextEditingController controller,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) return;

    setSheetState(() => true); // isUpdating = true

    final repo = ref.read(authRepositoryProvider);
    final failure = await repo.updateDisplayName(controller.text.trim());

    if (!ctx.mounted) return;

    setSheetState(() => false); // isUpdating = false

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Reload auth state to refresh display name
    await ref.read(authRepositoryProvider).reloadCurrentUser();

    if (!ctx.mounted) return;
    Navigator.of(ctx).pop();

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Display name updated.')));
    }
  }

  /// Shows the current email address in a simple dialog.
  void _showEmailInfoDialog(User? user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Email Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your authenticated email address is:',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.email ?? 'No email',
                style: Theme.of(
                  ctx,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Changing your email is not currently supported in this version of Tuno. A verified-before-update flow will be added in a future release.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Sends a password reset email to the authenticated user's email.
  Future<void> _handlePasswordReset() async {
    if (_isSendingPasswordReset) return;
    final user = _user;
    if (user?.email == null) {
      _showSnackBar('No email address on record.');
      return;
    }

    setState(() => _isSendingPasswordReset = true);

    try {
      final failure = await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email: user!.email!);

      if (!mounted) return;

      if (failure == null) {
        _showSnackBar(
          'Password reset email sent to ${user.email}. Check your inbox.',
        );
      } else {
        _showErrorSnackBar(failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingPasswordReset = false);
      }
    }
  }

  /// Sends a verification email or shows verified status.
  Future<void> _handleEmailVerification(User? user) async {
    if (user?.emailVerified == true) {
      _showSnackBar('Your email is already verified.');
      return;
    }

    if (_isSendingVerification) return;

    setState(() => _isSendingVerification = true);

    try {
      final failure = await ref
          .read(authRepositoryProvider)
          .sendEmailVerification();

      if (!mounted) return;

      if (failure == null) {
        _showSnackBar('Verification email sent. Check your inbox.');
      } else {
        _showErrorSnackBar(failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingVerification = false);
      }
    }
  }

  /// Shows a confirmation dialog, then signs out.
  Future<void> _handleSignOut() async {
    if (_isSigningOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);

    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  /// Shows the destructive delete-account dialog requiring "DELETE" text input.
  Future<void> _showDeleteConfirmationDialog() async {
    _deleteTextController.clear();
    _deleteConfirmed = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool localConfirmed = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  const Text('Delete Account'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action is permanent and cannot be undone. '
                    'All your account data will be lost.',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Type DELETE below to confirm:',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deleteTextController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Type DELETE',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        localConfirmed = value.trim() == 'DELETE';
                        _deleteConfirmed = localConfirmed;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ Firestore data cleanup still needs a separate backend process. Your authentication account will be deleted, but any stored documents may remain.',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: localConfirmed && !_isDeleting
                      ? () => Navigator.of(ctx).pop(true)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Permanently Delete'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted || !_deleteConfirmed) return;

    // Execute deletion
    setState(() => _isDeleting = true);

    try {
      final failure = await ref.read(authRepositoryProvider).deleteUser();

      if (!mounted) return;

      if (failure == null) {
        // Auth state change will trigger router redirect
        _showSnackBar('Account deleted.');
      } else {
        _showErrorSnackBar(failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SNACKBAR HELPERS
  // ─────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }
}
