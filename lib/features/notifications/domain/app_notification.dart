import 'notification_type.dart';

/// Immutable in-app notification model.
///
/// Designed to be serialised to/from JSON for persistence via SharedPreferences.
/// Only lightweight metadata is stored — no audio bytes, recording data, or
/// file content is included.
class AppNotification {
  /// Unique identifier (e.g. UUID or Firestore document ID).
  final String id;

  /// Category of this notification.
  final NotificationType type;

  /// Short, bold headline.
  final String title;

  /// Supporting detail text.
  final String message;

  /// When the notification was created.
  final DateTime createdAt;

  /// Whether the user has seen / opened this notification.
  final bool isRead;

  /// Optional route to navigate to when tapped.
  final String? destinationRoute;

  /// Optional extra data to pass along with the route.
  final Map<String, dynamic>? routeExtra;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.destinationRoute,
    this.routeExtra,
  });

  /// Create a copy with optionally updated fields.
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? destinationRoute,
    Map<String, dynamic>? routeExtra,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      destinationRoute: destinationRoute ?? this.destinationRoute,
      routeExtra: routeExtra ?? this.routeExtra,
    );
  }

  // ── Serialisation ──────────────────────────────────────────

  /// Convert to a JSON-safe map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJsonValue,
      'title': title,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      if (destinationRoute != null) 'destinationRoute': destinationRoute,
      if (routeExtra != null) 'routeExtra': routeExtra,
    };
  }

  /// Deserialise from a JSON map.
  ///
  /// Returns `null` when the map is malformed or the stored type is unknown.
  static AppNotification? fromJson(Map<String, dynamic> json) {
    try {
      final rawType = json['type'] as String?;
      if (rawType == null) return null;

      final type = NotificationTypeUi.fromJsonValue(rawType);
      if (type == null) return null;

      final id = json['id'] as String?;
      if (id == null || id.isEmpty) return null;

      final title = json['title'] as String? ?? '';
      final message = json['message'] as String? ?? '';
      final createdAtMillis = json['createdAt'] as int?;
      if (createdAtMillis == null) return null;

      return AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
        isRead: json['isRead'] as bool? ?? false,
        destinationRoute: json['destinationRoute'] as String?,
        routeExtra: json['routeExtra'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Equality & hash ────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.message == message &&
        other.createdAt == createdAt &&
        other.isRead == isRead &&
        other.destinationRoute == destinationRoute;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      title,
      message,
      createdAt,
      isRead,
      destinationRoute,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, title: $title, '
        'isRead: $isRead, createdAt: $createdAt)';
  }
}
