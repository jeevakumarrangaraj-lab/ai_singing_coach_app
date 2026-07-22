import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PermissionEducationStep extends ConsumerStatefulWidget {
  const PermissionEducationStep({super.key});

  @override
  ConsumerState<PermissionEducationStep> createState() =>
      _PermissionEducationStepState();
}

class _PermissionEducationStepState
    extends ConsumerState<PermissionEducationStep> {
  PermissionStatus? _permissionStatus;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final recorder = AudioRecorder();
      final hasPermission = await recorder.hasPermission();
      if (mounted) {
        setState(() {
          _permissionStatus = hasPermission
              ? PermissionStatus.granted
              : PermissionStatus.denied;
        });
      }
    } catch (_) {
      // Fallback to permission_handler
      final status = await Permission.microphone.status;
      if (mounted) {
        setState(() {
          _permissionStatus = status;
        });
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      final recorder = AudioRecorder();
      final granted = await recorder.hasPermission();

      if (!granted) {
        // Try requesting via record package first
        final status = await Permission.microphone.request();
        if (mounted) {
          setState(() {
            _permissionStatus = status;
            _isRequesting = false;
          });
          _showPermissionResultSnackBar(status);
        }
        return;
      }

      if (mounted) {
        setState(() {
          _permissionStatus = PermissionStatus.granted;
          _isRequesting = false;
        });
        _showPermissionResultSnackBar(PermissionStatus.granted);
      }
    } catch (error) {
      // Fallback to permission_handler
      try {
        final status = await Permission.microphone.request();
        if (mounted) {
          setState(() {
            _permissionStatus = status;
            _isRequesting = false;
          });
          _showPermissionResultSnackBar(status);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isRequesting = false;
          });
          _showErrorSnackBar('Failed to request permission. Please try again.');
        }
      }
    }
  }

  Future<void> _openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar(
          'Could not open settings. Please enable microphone access manually.',
        );
      }
    }
  }

  void _showPermissionResultSnackBar(PermissionStatus status) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    String message;
    Color backgroundColor;

    switch (status) {
      case PermissionStatus.granted:
        message = 'Microphone access granted. You can now record your voice.';
        backgroundColor = colorScheme.primary;
        break;
      case PermissionStatus.denied:
        message =
            'Microphone access denied. You can enable it later in settings to record.';
        backgroundColor = colorScheme.error;
        break;
      case PermissionStatus.permanentlyDenied:
        message =
            'Microphone access permanently denied. Please enable it in app settings.';
        backgroundColor = colorScheme.error;
        break;
      case PermissionStatus.limited:
        message =
            'Limited microphone access granted. You can record but with restrictions.';
        backgroundColor = colorScheme.secondary;
        break;
      default:
        message = 'Permission status: ${status.name}';
        backgroundColor = colorScheme.onSurfaceVariant;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: status == PermissionStatus.permanentlyDenied
            ? SnackBarAction(
                label: 'Open Settings',
                textColor: colorScheme.onPrimary,
                onPressed: _openSettings,
              )
            : null,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isRequesting = _isRequesting;
    final isGranted = _permissionStatus == PermissionStatus.granted;
    final isPermanentlyDenied =
        _permissionStatus == PermissionStatus.permanentlyDenied;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Microphone icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(
                color: isGranted
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.mic_rounded,
              size: 40,
              color: isGranted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Your voice stays in your control',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Message
        Text(
          'Tuno uses microphone access only when you choose to record a practice session. '
          'You can change this permission later in your device or browser settings.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Three info points in a card
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoPoint(
                  icon: Icons.mic_rounded,
                  title: 'Required for voice recording',
                  description:
                      'Microphone access is needed to capture your singing for AI feedback.',
                ),
                const SizedBox(height: 16),
                _buildInfoPoint(
                  icon: Icons.security_rounded,
                  title: 'Tuno will not record automatically',
                  description:
                      'Recording only happens when you explicitly start a practice session.',
                ),
                const SizedBox(height: 16),
                _buildInfoPoint(
                  icon: Icons.settings_rounded,
                  title: 'Permission can be changed later',
                  description:
                      'You can grant or revoke microphone access anytime in device/browser settings.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Permission action buttons
        if (!isGranted) ...[
          FilledButton.icon(
            onPressed: isRequesting ? null : _requestMicrophonePermission,
            icon: isRequesting
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    isPermanentlyDenied
                        ? Icons.settings_rounded
                        : Icons.mic_rounded,
                    size: 22,
                  ),
            label: Text(
              isRequesting
                  ? 'Requesting...'
                  : isPermanentlyDenied
                  ? 'Open Settings'
                  : 'Enable Microphone',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          if (isPermanentlyDenied) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open App Settings Manually'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ] else ...[
          // Permission granted state
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Microphone access granted. You\'re ready to record!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Note about continuing without permission
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can continue onboarding without microphone access. '
                    'Recording will require permission when you start a practice session.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPoint({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
