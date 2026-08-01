import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/dashboard_music_decorations.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../practice/presentation/practice_router.dart';
import '../../domain/app_notification.dart';
import '../../domain/notification_type.dart';
import '../notification_controller.dart';

/// ─────────────────────────────────────────────────────────────
/// NOTIFICATIONS SCREEN
/// ─────────────────────────────────────────────────────────────
///
/// Route: `/notifications`
///
/// Displays the in-app notification inbox matching the Tuno reference design.
/// Light/dark theme: see [AppColors] for the exact palette values.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Shared Tuno dashboard music decorations ──
          Positioned.fill(
            child: const IgnorePointer(
              ignoring: true,
              child: DashboardMusicDecorations(animate: true),
            ),
          ),

          // ── SafeArea scrollable content ──
          SafeArea(
            child: Stack(
              children: [
                // ── Scrollable notification page content ──
                LayoutBuilder(
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

                                  // ── Header ──
                                  _buildHeader(context, cs, textTheme, l10n),

                                  const SizedBox(height: 20),

                                  // ── Content ──
                                  if (state.notifications.isEmpty)
                                    _buildEmptyState(
                                      context,
                                      cs,
                                      textTheme,
                                      isDark,
                                      l10n,
                                    )
                                  else
                                    _buildNotificationList(
                                      context,
                                      cs,
                                      textTheme,
                                      isDark,
                                      state,
                                      l10n,
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

                // ── Back button positioned at top-left corner ──
                Positioned(
                  left: 20,
                  top: 16,
                  child: Semantics(
                    button: true,
                    label: l10n.back,
                    child: Tooltip(
                      message: l10n.back,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          hoverColor: cs.onSurface.withValues(alpha: 0.06),
                          focusColor: cs.onSurface.withValues(alpha: 0.10),
                          splashColor: cs.onSurface.withValues(alpha: 0.12),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 22,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
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
  // HEADER
  // ─────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        const Spacer(),
        Text(
          l10n.notificationsTitle,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final accentColor = isDark
        ? const Color(0xFF12B5C1)
        : const Color(0xFF0B96A5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),

            // Large themed notification icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0B2B42).withValues(alpha: 0.6)
                    : cs.primaryContainer.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 44,
                color: accentColor.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              l10n.allCaughtUp,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              l10n.emptyNotificationsMessage,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // "Start Practice" outlined button
            Semantics(
              button: true,
              label: l10n.startPractice,
              child: Tooltip(
                message: l10n.startPractice,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(PracticeRoutes.practiceModes),
                    icon: Icon(Icons.mic_rounded, size: 20, color: accentColor),
                    label: Text(
                      l10n.startPractice,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: cs.outline.withValues(alpha: 0.7),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATION LIST
  // ─────────────────────────────────────────────────────────────

  Widget _buildNotificationList(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
    NotificationState state,
    AppLocalizations l10n,
  ) {
    final notifications = state.sortedNotifications;
    final hasUnread = state.unreadCount > 0;

    return Column(
      children: [
        // ── List of notification cards ──
        ...notifications.map(
          (notification) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NotificationCard(
              notification: notification,
              isDark: isDark,
              l10n: l10n,
              onTap: () => _handleNotificationTap(notification),
              onDelete: () {
                ref
                    .read(notificationControllerProvider.notifier)
                    .deleteNotification(notification.id);
              },
              onMarkRead: () {
                ref
                    .read(notificationControllerProvider.notifier)
                    .markAsRead(notification.id);
              },
              onMarkUnread: () {
                ref
                    .read(notificationControllerProvider.notifier)
                    .markAsUnread(notification.id);
              },
            ),
          ),
        ),

        // ── "Mark all as read" button ──
        if (hasUnread) ...[
          const SizedBox(height: 12),
          _buildMarkAllReadButton(context, cs, textTheme, isDark, l10n),
        ],

        // Bottom padding for safe area
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      ref
          .read(notificationControllerProvider.notifier)
          .markAsRead(notification.id);
    }

    final route = notification.destinationRoute;
    if (route != null && route.isNotEmpty) {
      context.push(route);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MARK ALL AS READ BUTTON
  // ─────────────────────────────────────────────────────────────

  Widget _buildMarkAllReadButton(
    BuildContext context,
    ColorScheme cs,
    TextTheme textTheme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final accentColor = isDark
        ? const Color(0xFF12B5C1)
        : const Color(0xFF0B96A5);

    return Semantics(
      button: true,
      label: l10n.markAllAsRead,
      child: Tooltip(
        message: l10n.markAllAsRead,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(notificationControllerProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all_rounded, size: 20),
            label: Text(
              l10n.markAllAsRead,
              style: textTheme.titleSmall?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// NOTIFICATION CARD
// ─────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isDark,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
    required this.onMarkRead,
    required this.onMarkUnread,
  });

  final AppNotification notification;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkRead;
  final VoidCallback onMarkUnread;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final usesGold = notification.type.usesGoldAccent;

    // Accent colours
    Color iconContainerColor;
    Color iconColor;

    if (usesGold) {
      iconContainerColor = isDark
          ? const Color(0xFF1A2E15).withValues(alpha: 0.6)
          : const Color(0xFFFFF8EA);
      iconColor = isDark ? const Color(0xFFE3B94F) : const Color(0xFFB8860B);
    } else {
      // Cyan/teal
      iconContainerColor = isDark
          ? const Color(0xFF0B2B42).withValues(alpha: 0.7)
          : const Color(0xFFE0F7F7);
      iconColor = isDark ? const Color(0xFF12B5C1) : const Color(0xFF008BA6);
    }

    // Card colours
    final cardColor = isDark
        ? const Color(0xFF061E31)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF17445B).withValues(alpha: 0.5)
        : const Color(0xFFD8E7F1).withValues(alpha: 0.7);

    final unreadColor = isDark
        ? const Color(0xFF12B5C1)
        : const Color(0xFF008BA6);

    return Dismissible(
      key: ValueKey('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 28,
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: Semantics(
        button: true,
        label:
            '${notification.type.semanticLabel}: ${notification.title}. '
            '${notification.isRead ? "Read" : "Unread"}',
        child: Tooltip(
          message: notification.title,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: onTap,
              onLongPress: () => _showActionSheet(context, l10n),
              borderRadius: BorderRadius.circular(18),
              hoverColor: cs.onSurface.withValues(alpha: 0.04),
              focusColor: cs.onSurface.withValues(alpha: 0.08),
              splashColor: cs.onSurface.withValues(alpha: 0.10),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Circular icon area ──
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconContainerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.type.icon,
                        size: 22,
                        color: iconColor,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ── Title, message, timestamp ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            notification.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),

                          // Message
                          Text(
                            notification.message,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Relative timestamp
                          Text(
                            _formatRelativeTime(notification.createdAt, l10n),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ── Unread indicator ──
                    if (!notification.isRead)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: unreadColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 9),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Long-press action sheet ─────────────────────────────────

  void _showActionSheet(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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
                  notification.title,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Mark as read / unread
                ListTile(
                  leading: Icon(
                    notification.isRead
                        ? Icons.mark_email_unread_rounded
                        : Icons.mark_email_read_rounded,
                    color: cs.primary,
                  ),
                  title: Text(
                    notification.isRead ? l10n.markAsUnread : l10n.markAsRead,
                    style: Theme.of(
                      ctx,
                    ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    if (notification.isRead) {
                      onMarkUnread();
                    } else {
                      onMarkRead();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                // Delete
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                  title: Text(
                    l10n.delete,
                    style: Theme.of(
                      ctx,
                    ).textTheme.bodyLarge?.copyWith(color: cs.error),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onDelete();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Relative timestamp formatting ───────────────────────────

  String _formatRelativeTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.isNegative) {
      // Future dates (shouldn't happen but handle gracefully)
      return l10n.justNow;
    }

    if (diff.inSeconds < 60) {
      return l10n.justNow;
    }

    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return l10n.minutesAgo(m);
    }

    if (diff.inHours < 24) {
      final h = diff.inHours;
      return l10n.hoursAgo(h);
    }

    if (diff.inDays == 1) {
      return l10n.yesterday;
    }

    if (diff.inDays < 30) {
      return l10n.daysAgo(diff.inDays);
    }

    // Fallback to short date (unlocalized — no matching ARB key)
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}
