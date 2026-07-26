import 'package:flutter/material.dart';

/// Types of in-app notifications supported by Tuno.
///
/// Each type maps to an icon, semantic label, accent colour scheme,
/// and a fallback destination route.
enum NotificationType {
  analysisCompleted,
  practiceReminder,
  streakReminder,
  achievementUnlocked,
  coinsEarned,
  weeklyProgress,
  weeklyChallenge,
  subscription,
  general,
}

/// UI metadata extension for [NotificationType].
///
/// Icon data and semantic labels live here rather than in the domain model
/// so the model stays pure Dart and widget-free.
extension NotificationTypeUi on NotificationType {
  /// Material icon representing this notification type.
  IconData get icon {
    switch (this) {
      case NotificationType.analysisCompleted:
        return Icons.analytics_rounded;
      case NotificationType.practiceReminder:
        return Icons.mic_rounded;
      case NotificationType.streakReminder:
        return Icons.local_fire_department_rounded;
      case NotificationType.achievementUnlocked:
        return Icons.emoji_events_rounded;
      case NotificationType.coinsEarned:
        return Icons.monetization_on_rounded;
      case NotificationType.weeklyProgress:
        return Icons.trending_up_rounded;
      case NotificationType.weeklyChallenge:
        return Icons.flag_rounded;
      case NotificationType.subscription:
        return Icons.star_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  /// Human-readable label for accessibility.
  String get semanticLabel {
    switch (this) {
      case NotificationType.analysisCompleted:
        return 'Analysis completed';
      case NotificationType.practiceReminder:
        return 'Practice reminder';
      case NotificationType.streakReminder:
        return 'Streak reminder';
      case NotificationType.achievementUnlocked:
        return 'Achievement unlocked';
      case NotificationType.coinsEarned:
        return 'Coins earned';
      case NotificationType.weeklyProgress:
        return 'Weekly progress';
      case NotificationType.weeklyChallenge:
        return 'Weekly challenge';
      case NotificationType.subscription:
        return 'Subscription';
      case NotificationType.general:
        return 'Notification';
    }
  }

  /// Whether this notification type uses the metallic-gold accent palette.
  bool get usesGoldAccent {
    switch (this) {
      case NotificationType.achievementUnlocked:
      case NotificationType.coinsEarned:
      case NotificationType.weeklyChallenge:
      case NotificationType.subscription:
        return true;
      case NotificationType.analysisCompleted:
      case NotificationType.practiceReminder:
      case NotificationType.streakReminder:
      case NotificationType.weeklyProgress:
      case NotificationType.general:
        return false;
    }
  }

  /// Fallback destination route when no specific route is provided.
  String? get fallbackRoute {
    switch (this) {
      case NotificationType.analysisCompleted:
        return null; // No generic fallback for analysis
      case NotificationType.practiceReminder:
        return '/practice/modes';
      case NotificationType.streakReminder:
        return '/home';
      case NotificationType.achievementUnlocked:
        return null;
      case NotificationType.coinsEarned:
        return null;
      case NotificationType.weeklyProgress:
        return null;
      case NotificationType.weeklyChallenge:
        return null;
      case NotificationType.subscription:
        return '/settings';
      case NotificationType.general:
        return null;
    }
  }

  /// Serialise this enum to a JSON-safe string.
  String get toJsonValue {
    return name;
  }

  /// Deserialise a [NotificationType] from its JSON string.
  /// Returns `null` for unknown values.
  static NotificationType? fromJsonValue(String value) {
    switch (value) {
      case 'analysisCompleted':
        return NotificationType.analysisCompleted;
      case 'practiceReminder':
        return NotificationType.practiceReminder;
      case 'streakReminder':
        return NotificationType.streakReminder;
      case 'achievementUnlocked':
        return NotificationType.achievementUnlocked;
      case 'coinsEarned':
        return NotificationType.coinsEarned;
      case 'weeklyProgress':
        return NotificationType.weeklyProgress;
      case 'weeklyChallenge':
        return NotificationType.weeklyChallenge;
      case 'subscription':
        return NotificationType.subscription;
      case 'general':
        return NotificationType.general;
      default:
        return null;
    }
  }
}
