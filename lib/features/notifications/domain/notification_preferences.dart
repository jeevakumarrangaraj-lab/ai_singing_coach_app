/// ─────────────────────────────────────────────────────────────
/// NOTIFICATION PREFERENCES – IMMUTABLE STATE MODEL
/// ─────────────────────────────────────────────────────────────
///
/// Holds all user-configurable notification preference values.
/// Each field has a corresponding SharedPreferences key used for
/// persistence.
///
/// Safe defaults are used when no stored value exists.
///
/// Design:
///   - Fully immutable (copyWith pattern)
///   - All fields non-nullable
///   - Persistence keys are static constants
///   - No BuildContext, no widget dependencies
///   - Uses int hour/minute fields so defaults can be const
/// ─────────────────────────────────────────────────────────────
class NotificationPreferences {
  // ── SharedPreferences keys ──────────────────────────────────

  static const String keyAllowNotifications = 'tuno_notif_allow';
  static const String keyPracticeReminders = 'tuno_notif_practice';
  static const String keyAiAnalysisUpdates = 'tuno_notif_ai_analysis';
  static const String keyStreakReminders = 'tuno_notif_streak';
  static const String keyCoinsAchievements = 'tuno_notif_coins_achievements';
  static const String keyWeeklyChallenges = 'tuno_notif_weekly_challenges';
  static const String keyProductUpdates = 'tuno_notif_product_updates';
  static const String keyReminderTimeHour = 'tuno_notif_reminder_hour';
  static const String keyReminderTimeMinute = 'tuno_notif_reminder_minute';

  // ── Fields ──────────────────────────────────────────────────

  /// Master toggle — when false, all notifications are suppressed.
  final bool allowNotifications;

  /// Daily practice reminders.
  final bool practiceReminders;

  /// AI analysis/completed feedback updates.
  final bool aiAnalysisUpdates;

  /// Streak milestone reminders.
  final bool streakReminders;

  /// Coins earned & achievement unlocked notifications.
  final bool coinsAchievements;

  /// Weekly challenge updates.
  final bool weeklyChallenges;

  /// Product/feature update announcements.
  final bool productUpdates;

  /// Hour (0-23) for practice reminder time.
  final int reminderHour;

  /// Minute (0-59) for practice reminder time.
  final int reminderMinute;

  /// ── Constructor with safe defaults ─────────────────────────

  const NotificationPreferences({
    this.allowNotifications = false,
    this.practiceReminders = true,
    this.aiAnalysisUpdates = true,
    this.streakReminders = true,
    this.coinsAchievements = true,
    this.weeklyChallenges = true,
    this.productUpdates = false,
    this.reminderHour = 10,
    this.reminderMinute = 0,
  });

  /// ── copyWith ───────────────────────────────────────────────

  NotificationPreferences copyWith({
    bool? allowNotifications,
    bool? practiceReminders,
    bool? aiAnalysisUpdates,
    bool? streakReminders,
    bool? coinsAchievements,
    bool? weeklyChallenges,
    bool? productUpdates,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return NotificationPreferences(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      practiceReminders: practiceReminders ?? this.practiceReminders,
      aiAnalysisUpdates: aiAnalysisUpdates ?? this.aiAnalysisUpdates,
      streakReminders: streakReminders ?? this.streakReminders,
      coinsAchievements: coinsAchievements ?? this.coinsAchievements,
      weeklyChallenges: weeklyChallenges ?? this.weeklyChallenges,
      productUpdates: productUpdates ?? this.productUpdates,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  // ── JSON/Map (for debugging) ───────────────────────────────

  Map<String, dynamic> toMap() => {
    keyAllowNotifications: allowNotifications,
    keyPracticeReminders: practiceReminders,
    keyAiAnalysisUpdates: aiAnalysisUpdates,
    keyStreakReminders: streakReminders,
    keyCoinsAchievements: coinsAchievements,
    keyWeeklyChallenges: weeklyChallenges,
    keyProductUpdates: productUpdates,
    keyReminderTimeHour: reminderHour,
    keyReminderTimeMinute: reminderMinute,
  };

  @override
  String toString() => 'NotificationPreferences${toMap()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          allowNotifications == other.allowNotifications &&
          practiceReminders == other.practiceReminders &&
          aiAnalysisUpdates == other.aiAnalysisUpdates &&
          streakReminders == other.streakReminders &&
          coinsAchievements == other.coinsAchievements &&
          weeklyChallenges == other.weeklyChallenges &&
          productUpdates == other.productUpdates &&
          reminderHour == other.reminderHour &&
          reminderMinute == other.reminderMinute;

  @override
  int get hashCode => Object.hash(
    allowNotifications,
    practiceReminders,
    aiAnalysisUpdates,
    streakReminders,
    coinsAchievements,
    weeklyChallenges,
    productUpdates,
    reminderHour,
    reminderMinute,
  );
}
