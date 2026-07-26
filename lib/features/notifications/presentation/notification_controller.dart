import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_notification.dart';

/// ─────────────────────────────────────────────────────────────
/// STATE
/// ─────────────────────────────────────────────────────────────

/// Immutable state object for the notification inbox.
class NotificationState {
  /// All notifications (unsorted).
  final List<AppNotification> notifications;

  /// Whether an async load/save operation is in flight.
  final bool isLoading;

  /// User-facing error message, or `null`.
  final String? errorMessage;

  const NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Newest-first sorted list of notifications.
  List<AppNotification> get sortedNotifications {
    final sorted = List<AppNotification>.from(notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Count of unread notifications.
  int get unreadCount {
    return notifications.where((n) => !n.isRead).length;
  }

  factory NotificationState.initial() =>
      const NotificationState(notifications: []);
}

/// ─────────────────────────────────────────────────────────────
/// CONTROLLER
/// ─────────────────────────────────────────────────────────────

/// Manages the in-app notification inbox with local persistence.
///
/// Uses SharedPreferences under the key `tuno_notifications`.
/// Follows the same Riverpod [StateNotifier] pattern used by
/// [ThemeController] and [AuthController].
class NotificationController extends StateNotifier<NotificationState> {
  /// Storage key used to persist notifications.
  static const String _storageKey = 'tuno_notifications';

  NotificationController() : super(NotificationState.initial()) {
    _loadNotifications();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Initialisation ──────────────────────────────────────────

  /// Load persisted notifications from SharedPreferences.
  ///
  /// Corrupted JSON is silently discarded and the state remains an empty list.
  /// Persistence failures are non-fatal.
  Future<void> _loadNotifications() async {
    if (_disposed) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;

      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        state = state.copyWith(isLoading: false, notifications: []);
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>?;
      if (decoded == null) {
        state = state.copyWith(isLoading: false, notifications: []);
        return;
      }

      final notifications = <AppNotification>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final parsed = AppNotification.fromJson(item);
          if (parsed != null) {
            notifications.add(parsed);
          }
        }
      }

      if (_disposed) return;
      state = state.copyWith(isLoading: false, notifications: notifications);
    } catch (e) {
      if (_disposed) return;
      // Corrupted stored data — recover with empty list.
      debugPrint('NotificationController._loadNotifications: $e');
      state = state.copyWith(isLoading: false, notifications: []);
    }
  }

  // ── Persistence helper ──────────────────────────────────────

  /// Persist the current notification list to SharedPreferences.
  ///
  /// Failures are non-fatal and only logged in debug builds.
  Future<void> _persist() async {
    if (_disposed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(
        state.notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('NotificationController._persist: $e');
    }
  }

  // ── Public API ──────────────────────────────────────────────

  /// Add a new notification. Duplicate IDs are silently ignored.
  void addNotification(AppNotification notification) {
    if (_disposed) return;

    // Prevent duplicate IDs.
    if (state.notifications.any((n) => n.id == notification.id)) return;

    state = state.copyWith(
      notifications: [...state.notifications, notification],
    );
    _persist();
  }

  /// Mark a single notification as read.
  void markAsRead(String id) {
    if (_disposed) return;

    final updated = state.notifications.map((n) {
      if (n.id == id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
    _persist();
  }

  /// Mark a single notification as unread.
  void markAsUnread(String id) {
    if (_disposed) return;

    final updated = state.notifications.map((n) {
      if (n.id == id && n.isRead) {
        return n.copyWith(isRead: false);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
    _persist();
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    if (_disposed) return;

    final hasUnread = state.notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    final updated = state.notifications.map((n) {
      return n.isRead ? n : n.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(notifications: updated);
    _persist();
  }

  /// Delete a single notification by ID.
  void deleteNotification(String id) {
    if (_disposed) return;

    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
    _persist();
  }

  /// Clear all notifications.
  void clearAll() {
    if (_disposed) return;

    state = state.copyWith(notifications: []);
    _persist();
  }

  /// Get the count of unread notifications (convenience).
  int get unreadCount => state.unreadCount;

  /// Get sorted (newest-first) notifications (convenience).
  List<AppNotification> get sortedNotifications => state.sortedNotifications;
}

/// ─────────────────────────────────────────────────────────────
/// PROVIDER
/// ─────────────────────────────────────────────────────────────

/// Riverpod provider exposing the [NotificationController].
///
/// Usage:
/// ```dart
/// final notifications = ref.watch(notificationControllerProvider);
/// final unreadCount = ref.watch(notificationControllerProvider.select(
///   (s) => s.unreadCount,
/// ));
/// ```
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController();
    });
