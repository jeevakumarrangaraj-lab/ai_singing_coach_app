import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../l10n/app_localizations.dart';

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
          _showErrorSnackBar(
            AppLocalizations.of(context)!.failedToRequestPermission,
          );
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
          AppLocalizations.of(context)!.couldNotOpenSettingsManualInstructions,
        );
      }
    }
  }

  void _showPermissionResultSnackBar(PermissionStatus status) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String message;
    Color backgroundColor;

    switch (status) {
      case PermissionStatus.granted:
        message = l10n.micPermissionGrantedSnackbar;
        backgroundColor = colorScheme.primary;
        break;
      case PermissionStatus.denied:
        message = l10n.micPermissionDeniedSnackbar;
        backgroundColor = colorScheme.error;
        break;
      case PermissionStatus.permanentlyDenied:
        message = l10n.micPermissionPermanentlyDeniedSnackbar;
        backgroundColor = colorScheme.error;
        break;
      case PermissionStatus.limited:
        message = l10n.micPermissionLimitedSnackbar;
        backgroundColor = colorScheme.secondary;
        break;
      default:
        message = l10n.permissionStatusLabel(status.name);
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
                label: l10n.openSettings,
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
    final l10n = AppLocalizations.of(context)!;

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
          l10n.yourVoiceStaysInControl,
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
          l10n.permissionEducationMessage,
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
                  title: l10n.requiredForRecording,
                  description: l10n.requiredForRecordingDesc,
                ),
                const SizedBox(height: 16),
                _buildInfoPoint(
                  icon: Icons.security_rounded,
                  title: l10n.noAutoRecord,
                  description: l10n.noAutoRecordDesc,
                ),
                const SizedBox(height: 16),
                _buildInfoPoint(
                  icon: Icons.settings_rounded,
                  title: l10n.permissionCanBeChanged,
                  description: l10n.permissionCanBeChangedDesc,
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
                  ? l10n.requestingPermission
                  : isPermanentlyDenied
                  ? l10n.openSettings
                  : l10n.enableMicrophone,
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
              label: Text(l10n.openAppSettingsManually),
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
                    l10n.microphoneGrantedMessage,
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
                    l10n.continueWithoutMic,
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
