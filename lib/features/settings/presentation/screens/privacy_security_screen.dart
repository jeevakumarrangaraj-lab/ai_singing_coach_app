import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/widgets/app_back_button.dart';
import '../../../../core/widgets/dashboard_music_decorations.dart';
import '../../../auth/presentation/auth_controller.dart';

// ─────────────────────────────────────────────────────────────
//  PRIVACY & SECURITY SCREEN
// ─────────────────────────────────────────────────────────────

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  // ── Action guard flags ──
  bool _isSendingPasswordReset = false;
  bool _isSigningOut = false;

  // ── Microphone permission state ──
  PermissionStatus? _micStatus;
  bool _isCheckingMic = false;

  // ── Theme helpers ──
  Color get _accent =>
      isDark ? const Color(0xFF12B5C1) : const Color(0xFF0B96A5);

  Color get _cardColor => isDark ? const Color(0xFF061E31) : cs.surface;

  Color get _borderColor => isDark
      ? cs.outline.withValues(alpha: 0.5)
      : cs.outlineVariant.withValues(alpha: 0.7);

  Color get _dividerColor => isDark
      ? cs.outline.withValues(alpha: 0.2)
      : cs.outlineVariant.withValues(alpha: 0.4);

  Color get _goldAccent =>
      isDark ? const Color(0xFFE3B94F) : const Color(0xFFD9A62E);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  ColorScheme get cs => Theme.of(context).colorScheme;

  // ── Current authenticated user ──
  User? get _user => ref.watch(authControllerProvider).user;

  // ─────────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkMicrophoneStatus();
  }

  Future<void> _checkMicrophoneStatus() async {
    if (_isCheckingMic) return;

    setState(() => _isCheckingMic = true);

    try {
      final status = await Permission.microphone.status;
      if (mounted) {
        setState(() {
          _micStatus = status;
          _isCheckingMic = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _micStatus = null;
          _isCheckingMic = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  AUTH PROVIDER HELPERS
  // ─────────────────────────────────────────────────────────────

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

  bool get _isPasswordAccount {
    final user = _user;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'password');
  }

  // ─────────────────────────────────────────────────────────────
  //  SECURITY RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────

  List<_SecurityRecommendation> _getRecommendations() {
    final user = _user;
    final recommendations = <_SecurityRecommendation>[];

    if (user == null) return recommendations;

    // Email verification
    if (!user.emailVerified) {
      recommendations.add(
        _SecurityRecommendation(
          icon: Icons.verified_user_rounded,
          message: 'Verify your email address to secure your account.',
          severity: _RecommendationSeverity.high,
        ),
      );
    }

    // Password strength hint for password accounts
    if (_isPasswordAccount) {
      recommendations.add(
        _SecurityRecommendation(
          icon: Icons.lock_outline_rounded,
          message:
              'Use a strong, unique password. Consider changing it periodically.',
          severity: _RecommendationSeverity.info,
        ),
      );
    }

    // General recommendation
    recommendations.add(
      _SecurityRecommendation(
        icon: Icons.security_rounded,
        message:
            'Keep your email address up to date to receive security notifications.',
        severity: _RecommendationSeverity.info,
      ),
    );

    return recommendations;
  }

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = _user;
    final recommendations = _getRecommendations();

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Background decorations ──
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(animate: true),
            ),
          ),

          // ── Scrollable content ──
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

                              // ── Back button ──
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
                                    iconColor: _accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Title ──
                              Center(
                                child: Text(
                                  'Privacy & Security',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── SECTION 1: Security Status ──
                              _buildSecurityStatusSection(
                                user,
                                textTheme,
                                recommendations,
                              ),
                              const SizedBox(height: 16),

                              // ── SECTION 2: Password & Authentication ──
                              _buildPasswordAuthSection(textTheme),
                              const SizedBox(height: 16),

                              // ── SECTION 3: App Permissions ──
                              _buildAppPermissionsSection(textTheme),
                              const SizedBox(height: 16),

                              // ── SECTION 4: Privacy Controls ──
                              _buildPrivacyControlsSection(textTheme),
                              const SizedBox(height: 16),

                              // ── SECTION 5: Data & Account ──
                              _buildDataAccountSection(textTheme),

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
  //  SECTION: SECURITY STATUS
  // ─────────────────────────────────────────────────────────────

  Widget _buildSecurityStatusSection(
    User? user,
    TextTheme textTheme,
    List<_SecurityRecommendation> recommendations,
  ) {
    final providers = _getProviderNames(user);

    return _SectionCard(
      title: 'Security Status',
      accent: _accent,
      cardColor: _cardColor,
      borderColor: _borderColor,
      textTheme: textTheme,
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email verification status
          _buildStatusRow(
            icon: user?.emailVerified == true
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            iconColor: user?.emailVerified == true
                ? Colors.greenAccent
                : Colors.orangeAccent,
            label: 'Email Verification',
            value: user?.emailVerified == true ? 'Verified' : 'Not Verified',
          ),
          _sectionDivider(),

          // Authentication provider
          _buildStatusRow(
            icon: Icons.shield_rounded,
            iconColor: _accent,
            label: 'Authentication Provider',
            value: providers.isNotEmpty
                ? providers.join(', ')
                : 'No provider data',
          ),
          _sectionDivider(),

          // Account created date (if available via metadata)
          if (user?.metadata.creationTime != null)
            _buildStatusRow(
              icon: Icons.calendar_today_rounded,
              iconColor: _accent,
              label: 'Account Created',
              value: _formatDate(user!.metadata.creationTime!),
            ),

          if (user?.metadata.creationTime != null) _sectionDivider(),

          // Security Recommendations
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Recommendations',
              style: textTheme.titleSmall?.copyWith(
                fontSize: 14,
                color: _goldAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      r.icon,
                      size: 18,
                      color: r.severity == _RecommendationSeverity.high
                          ? Colors.orangeAccent
                          : _goldAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.message,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────
  //  SECTION: PASSWORD & AUTHENTICATION
  // ─────────────────────────────────────────────────────────────

  Widget _buildPasswordAuthSection(TextTheme textTheme) {
    final user = _user;

    return _SectionCard(
      title: 'Password & Authentication',
      accent: _accent,
      cardColor: _cardColor,
      borderColor: _borderColor,
      textTheme: textTheme,
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isPasswordAccount) ...[
            // Send Password Reset Email
            _buildActionRow(
              icon: Icons.lock_reset_rounded,
              label: 'Send Password Reset Email',
              subtitle: 'Receive a link to reset your password via email.',
              isLoading: _isSendingPasswordReset,
              onTap: _handlePasswordReset,
            ),

            // Direct password change (Phase A2)
            _sectionDivider(),
            _buildInfoRow(
              icon: Icons.build_rounded,
              message:
                  'Change password directly in the app will be available in a future update.',
            ),
          ] else ...[
            // Social auth account
            _buildInfoRow(
              icon: Icons.info_outline_rounded,
              message:
                  'You signed in with ${_getProviderNames(user).join(', ')}. '
                  'Password management is handled by your provider.',
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SECTION: APP PERMISSIONS
  // ─────────────────────────────────────────────────────────────

  Widget _buildAppPermissionsSection(TextTheme textTheme) {
    final micLabel = _micStatusLabel();
    final micColor = _micStatusColor();

    return _SectionCard(
      title: 'App Permissions',
      accent: _accent,
      cardColor: _cardColor,
      borderColor: _borderColor,
      textTheme: textTheme,
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Microphone permission row
          _buildPermissionRow(
            icon: Icons.mic_rounded,
            label: 'Microphone',
            statusLabel: micLabel,
            statusColor: micColor,
            isLoading: _isCheckingMic,
            canOpenSettings:
                _micStatus == PermissionStatus.denied ||
                _micStatus == PermissionStatus.permanentlyDenied,
            onOpenSettings: _openAppSettings,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              'Required for voice recording and practice features.',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _micStatusLabel() {
    if (_isCheckingMic) return 'Checking...';
    if (_micStatus == null) return 'Unknown';
    switch (_micStatus!) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  Color _micStatusColor() {
    if (_micStatus == null) return cs.onSurfaceVariant;
    switch (_micStatus!) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return Colors.greenAccent;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return Colors.orangeAccent;
      case PermissionStatus.provisional:
        return _accent;
    }
  }

  Future<void> _openAppSettings() async {
    final opened = await openAppSettings();
    if (opened) {
      // After returning from system settings, re-check the permission status
      await Future.delayed(const Duration(seconds: 1));
      await _checkMicrophoneStatus();
    }
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String label,
    required String statusLabel,
    required Color statusColor,
    required bool isLoading,
    required bool canOpenSettings,
    required VoidCallback onOpenSettings,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: _accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (canOpenSettings)
            Semantics(
              button: true,
              label: 'Open system settings for $label',
              child: Tooltip(
                message: 'Open Settings',
                child: InkWell(
                  onTap: onOpenSettings,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SECTION: PRIVACY CONTROLS
  // ─────────────────────────────────────────────────────────────

  Widget _buildPrivacyControlsSection(TextTheme textTheme) {
    return _SectionCard(
      title: 'Privacy Controls',
      accent: _accent,
      cardColor: _cardColor,
      borderColor: _borderColor,
      textTheme: textTheme,
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.analytics_outlined,
            message:
                'Analytics collection is not currently configured for Tuno. '
                'No usage data is being collected.',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.error_outline_rounded,
            message:
                'Crash and error diagnostics are not currently enabled. '
                'Diagnostic reports will be available when crash reporting is configured.',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.psychology_rounded,
            message:
                'Personalized AI processing is not currently available. '
                'Privacy controls for AI features will be added in a future release.',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accent.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: _accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Additional privacy controls will become available when these services are enabled.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SECTION: DATA & ACCOUNT
  // ─────────────────────────────────────────────────────────────

  Widget _buildDataAccountSection(TextTheme textTheme) {
    return _SectionCard(
      title: 'Data & Account',
      accent: _accent,
      cardColor: _cardColor,
      borderColor: _borderColor,
      textTheme: textTheme,
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export My Data (requires backend)
          _buildActionRow(
            icon: Icons.download_rounded,
            label: 'Export My Data',
            subtitle: 'Download a copy of your Tuno data.',
            onTap: _showExportDataInfo,
          ),
          _sectionDivider(),

          // Sign Out
          _buildActionRow(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            subtitle: 'Sign out of your Tuno account.',
            isLoading: _isSigningOut,
            onTap: _handleSignOut,
          ),
          _sectionDivider(),

          // Delete Account (requires backend)
          _buildDestructiveRow(
            icon: Icons.delete_forever_rounded,
            label: 'Delete Account',
            subtitle:
                'Permanently delete your account and all associated data.',
            onTap: _showDeleteAccountInfo,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTION ROW WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    String? subtitle,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          hoverColor: cs.primary.withValues(alpha: 0.06),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 22, color: _accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 12,
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _accent,
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded, size: 22, color: _accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestructiveRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          hoverColor: Colors.red.withValues(alpha: 0.06),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 12,
                                color: Colors.redAccent.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String message}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  ACTIONS
  // ─────────────────────────────────────────────────────────────

  /// Sends a password reset email to the authenticated user.
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

  /// Shows confirmation dialog, then signs out.
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

  /// Shows info about data export requiring backend.
  void _showExportDataInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Export My Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data export requires a trusted backend process to compile and deliver your account data securely.',
            ),
            SizedBox(height: 12),
            Text(
              'This feature will be available when an export endpoint is configured on the Tuno backend server.',
              style: TextStyle(fontSize: 13),
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

  /// Shows info about secure account deletion requiring backend.
  void _showDeleteAccountInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account deletion requires a secure backend process to:'),
            SizedBox(height: 8),
            _DeleteBullet(text: 'Delete your Auth account'),
            _DeleteBullet(
              text: 'Remove all Firestore documents and subcollections',
            ),
            _DeleteBullet(text: 'Delete all uploaded recordings from Storage'),
            _DeleteBullet(text: 'Remove any associated metadata'),
            SizedBox(height: 12),
            Text(
              'This cannot be done safely from the app alone. '
              'A trusted Cloud Function or Admin SDK backend is required.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'To delete your account now, please contact Tuno support.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  // ─────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _sectionDivider() {
    return Divider(height: 1, thickness: 1, color: _dividerColor);
  }

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

// ─────────────────────────────────────────────────────────────
//  SECTION CARD WIDGET
// ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.accent,
    required this.cardColor,
    required this.borderColor,
    required this.textTheme,
    required this.cs,
    required this.child,
  });

  final String title;
  final Color accent;
  final Color cardColor;
  final Color borderColor;
  final TextTheme textTheme;
  final ColorScheme cs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DATA CLASSES
// ─────────────────────────────────────────────────────────────

enum _RecommendationSeverity { info, high }

class _SecurityRecommendation {
  final IconData icon;
  final String message;
  final _RecommendationSeverity severity;

  const _SecurityRecommendation({
    required this.icon,
    required this.message,
    required this.severity,
  });
}

class _DeleteBullet extends StatelessWidget {
  const _DeleteBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  •  ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
