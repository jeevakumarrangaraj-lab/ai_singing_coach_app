// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languages => 'Languages';

  @override
  String get chooseAppLanguage => 'Choose the language used throughout Tuno';

  @override
  String get systemDefault => 'System Default';

  @override
  String get useDeviceLanguage => 'Use your device language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get back => 'Back';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get practice => 'Practice';

  @override
  String get record => 'Record';

  @override
  String get progress => 'Progress';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get practicePreferences => 'Practice Preferences';

  @override
  String get audioAndRecording => 'Audio & Recording';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get aboutTuno => 'About Tuno';

  @override
  String featureComingSoon(String label) {
    return '$label will be available soon.';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmContent => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get preferences => 'Preferences';

  @override
  String get backToSettings => 'Back to Settings';

  @override
  String get coachingFeedback => 'Coaching Feedback';

  @override
  String get recordingPreferences => 'Recording Preferences';

  @override
  String get generalBehaviour => 'General Behaviour';

  @override
  String get countInBeforeRecording => 'Count-in before recording';

  @override
  String get autoSaveCompletedRecordings =>
      'Automatically save completed recordings';

  @override
  String get showHeadphoneRecommendation => 'Show headphone recommendation';

  @override
  String get confirmBeforeDeleting => 'Confirm before deleting a recording';

  @override
  String get reduceAnimations => 'Reduce animations';

  @override
  String get countInEnabled => 'Count-in enabled';

  @override
  String get countInDisabled => 'Count-in disabled';

  @override
  String get autoSaveEnabled => 'Auto-save enabled';

  @override
  String get autoSaveDisabled => 'Auto-save disabled';

  @override
  String get headphoneReminderEnabled => 'Headphone reminder enabled';

  @override
  String get headphoneReminderDisabled => 'Headphone reminder disabled';

  @override
  String get deleteConfirmationEnabled => 'Delete confirmation enabled';

  @override
  String get deleteConfirmationDisabled => 'Delete confirmation disabled';

  @override
  String get reducedAnimations => 'Reduced animations';

  @override
  String get animationsRestored => 'Animations restored';

  @override
  String get defaultPracticeMode => 'Default Practice Mode';

  @override
  String get simple => 'Simple';

  @override
  String get detailed => 'Detailed';

  @override
  String defaultModeLabel(String mode) {
    return 'Default mode: $mode';
  }

  @override
  String get audioAndVideo => 'Audio & Video';

  @override
  String get defaultRecordingType => 'Default Recording Type';

  @override
  String get audioQuality => 'Audio Quality';

  @override
  String get recordingBehaviour => 'Recording Behaviour';

  @override
  String get microphoneAccess => 'Microphone Access';

  @override
  String get noiseReduction => 'Noise Reduction';

  @override
  String get countdownBeforeRecording => 'Countdown before recording';

  @override
  String get autoPlayAfterCapture => 'Auto-play recording after capture';

  @override
  String get showHeadphonesReminder => 'Show headphones reminder';

  @override
  String get noiseReductionEnabled => 'Noise reduction enabled';

  @override
  String get noiseReductionDisabled => 'Noise reduction disabled';

  @override
  String get countdownEnabled => 'Countdown enabled';

  @override
  String get countdownDisabled => 'Countdown disabled';

  @override
  String get autoPlayEnabled => 'Auto-play enabled';

  @override
  String get autoPlayDisabled => 'Auto-play disabled';

  @override
  String get headphonesReminderEnabled => 'Headphones reminder enabled';

  @override
  String get headphonesReminderDisabled => 'Headphones reminder disabled';

  @override
  String get granted => 'Granted';

  @override
  String get notGrantedTapToAllow => 'Not granted — tap to allow';

  @override
  String get couldNotCheckPermission => 'Could not check microphone permission';

  @override
  String get microphoneGranted => 'Microphone access granted';

  @override
  String get microphoneDenied => 'Microphone access denied';

  @override
  String get couldNotRequestPermission =>
      'Could not request microphone permission';

  @override
  String get microphonePermissionDialogTitle => 'Microphone Permission';

  @override
  String get microphonePermissionDialogContent =>
      'Microphone permission has been permanently denied. Please enable it in your system settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get audio => 'Audio';

  @override
  String get video => 'Video';

  @override
  String get standard => 'Standard';

  @override
  String get high => 'High';

  @override
  String defaultRecordingTypeLabel(String type) {
    return 'Default recording type: $type';
  }

  @override
  String audioQualityLabel(String quality) {
    return 'Audio quality: $quality';
  }

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get changePassword => 'Change Password';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String get signOut => 'Sign Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get tunoSinger => 'Tuno Singer';

  @override
  String get noEmail => 'No email';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get emailNotVerified => 'Email not verified';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not verified';

  @override
  String signInWithProvider(String providers) {
    return 'Sign in with $providers';
  }

  @override
  String get password => 'Password';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get facebook => 'Facebook';

  @override
  String get displayName => 'Display name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get save => 'Save';

  @override
  String get displayNameUpdated => 'Display name updated.';

  @override
  String get emailAddressDialogTitle => 'Email Address';

  @override
  String get yourEmailIs => 'Your authenticated email address is:';

  @override
  String get emailChangeNotSupported =>
      'Changing your email is not currently supported in this version of Tuno. A verified-before-update flow will be added in a future release.';

  @override
  String get close => 'Close';

  @override
  String get noEmailOnRecord => 'No email address on record.';

  @override
  String passwordResetSent(String email) {
    return 'Password reset email sent to $email. Check your inbox.';
  }

  @override
  String get emailAlreadyVerified => 'Your email is already verified.';

  @override
  String get verificationEmailSent =>
      'Verification email sent. Check your inbox.';

  @override
  String get signOutDialogTitle => 'Sign Out';

  @override
  String get signOutDialogContent => 'Are you sure you want to sign out?';

  @override
  String get deleteAccountDialogTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is permanent and cannot be undone. All your account data will be lost.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE below to confirm:';

  @override
  String get typeDelete => 'Type DELETE';

  @override
  String get deleteFirestoreNote =>
      'Firestore data cleanup still needs a separate backend process. Your authentication account will be deleted, but any stored documents may remain.';

  @override
  String get permanentlyDelete => 'Permanently Delete';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get securityStatus => 'Security Status';

  @override
  String get emailVerificationStatus => 'Email Verification';

  @override
  String get authenticationProvider => 'Authentication Provider';

  @override
  String get noProviderData => 'No provider data';

  @override
  String get accountCreated => 'Account Created';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get verifyEmailRecommendation =>
      'Verify your email address to secure your account.';

  @override
  String get strongPasswordRecommendation =>
      'Use a strong, unique password. Consider changing it periodically.';

  @override
  String get keepEmailUpdatedRecommendation =>
      'Keep your email address up to date to receive security notifications.';

  @override
  String get passwordAndAuth => 'Password & Authentication';

  @override
  String get sendPasswordResetEmail => 'Send Password Reset Email';

  @override
  String get resetPasswordSubtitle =>
      'Receive a link to reset your password via email.';

  @override
  String get directPasswordChangeFuture =>
      'Change password directly in the app will be available in a future update.';

  @override
  String socialAuthInfo(String providers) {
    return 'You signed in with $providers. Password management is handled by your provider.';
  }

  @override
  String get appPermissions => 'App Permissions';

  @override
  String get microphone => 'Microphone';

  @override
  String get micRequiredDescription =>
      'Required for voice recording and practice features.';

  @override
  String get checking => 'Checking...';

  @override
  String get unknownStatus => 'Unknown';

  @override
  String get denied => 'Denied';

  @override
  String get permanentlyDenied => 'Permanently Denied';

  @override
  String get restricted => 'Restricted';

  @override
  String get provisional => 'Provisional';

  @override
  String openSystemSettingsLabel(String permission) {
    return 'Open system settings for $permission';
  }

  @override
  String get permissionSettings => 'Settings';

  @override
  String get privacyControls => 'Privacy Controls';

  @override
  String get analyticsNotConfigured =>
      'Analytics collection is not currently configured for Tuno. No usage data is being collected.';

  @override
  String get crashDiagnosticsNotEnabled =>
      'Crash and error diagnostics are not currently enabled. Diagnostic reports will be available when crash reporting is configured.';

  @override
  String get aiProcessingNotAvailable =>
      'Personalized AI processing is not currently available. Privacy controls for AI features will be added in a future release.';

  @override
  String get additionalPrivacyControls =>
      'Additional privacy controls will become available when these services are enabled.';

  @override
  String get dataAndAccount => 'Data & Account';

  @override
  String get exportMyData => 'Export My Data';

  @override
  String get exportDataSubtitle => 'Download a copy of your Tuno data.';

  @override
  String get signOutSubtitle => 'Sign out of your Tuno account.';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your account and all associated data.';

  @override
  String get exportDataDialogTitle => 'Export My Data';

  @override
  String get exportDataDialogContent =>
      'Data export requires a trusted backend process to compile and deliver your account data securely.';

  @override
  String get exportDataDialogFuture =>
      'This feature will be available when an export endpoint is configured on the Tuno backend server.';

  @override
  String get deleteAccountDialogContent =>
      'Account deletion requires a secure backend process to:';

  @override
  String get deleteAuthAccount => 'Delete your Auth account';

  @override
  String get deleteFirestoreDocs =>
      'Remove all Firestore documents and subcollections';

  @override
  String get deleteStorageRecordings =>
      'Delete all uploaded recordings from Storage';

  @override
  String get deleteMetadata => 'Remove any associated metadata';

  @override
  String get deleteCannotBeDoneFromApp =>
      'This cannot be done safely from the app alone. A trusted Cloud Function or Admin SDK backend is required.';

  @override
  String get contactSupportToDelete =>
      'To delete your account now, please contact Tuno support.';

  @override
  String get chooseUpdates => 'Choose which updates you want to receive';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get practiceReminders => 'Practice Reminders';

  @override
  String get aiAnalysisUpdates => 'AI Analysis Updates';

  @override
  String get streakReminders => 'Streak Reminders';

  @override
  String get coinsAndAchievements => 'Coins & Achievements';

  @override
  String get weeklyChallenges => 'Weekly Challenges';

  @override
  String get productUpdates => 'Product Updates';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get tapToChangeReminderTime => 'Tap to change reminder time';

  @override
  String get notificationDeliveryNotImplemented =>
      'Notification delivery is not yet implemented. Your preferences are saved locally and will be used once delivery is available.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get youCanChangeAnytime => 'You can change these preferences anytime.';

  @override
  String labelUnavailable(String label) {
    return '$label (unavailable)';
  }

  @override
  String enableNotificationsFirst(String label) {
    return '$label – enable notifications first';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get emptyNotificationsMessage =>
      'Practice updates, analysis results and achievements will appear here.';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get delete => 'Delete';

  @override
  String unreadCountSemantic(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get tuno => 'Tuno';

  @override
  String helloUser(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get readyToImprove => 'Ready to improve your voice today?';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get startVoicePractice => 'Start Voice Practice';

  @override
  String get recordAndGetFeedback =>
      'Record your voice and receive instant feedback.';

  @override
  String get startPractice => 'Start Practice';

  @override
  String get zeroMin => '0 min';

  @override
  String get practiceLabel => 'Practice';

  @override
  String get zeroDays => '0 days';

  @override
  String get streak => 'Streak';

  @override
  String featureComingSoonSimple(String feature) {
    return '$feature coming soon';
  }

  @override
  String get aiSingingCoach => 'AI SINGING COACH';

  @override
  String get yourPersonalAiCoach => 'Your Personal\nAI Singing Coach';

  @override
  String get practiceImproveAchieve => 'Practice • Improve • Achieve';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome Back! 👋';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get emailIsRequired => 'Email is required.';

  @override
  String get enterValidEmail => 'Enter a valid email.';

  @override
  String get passwordIsRequired => 'Password is required.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get emailFieldLabel => 'Email Address';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get loginWithGoogle => 'Login with Google. Coming soon.';

  @override
  String get loginWithApple => 'Login with Apple. Coming soon.';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get goToSignUp => 'Go to sign up';

  @override
  String get loginSuccessful => 'Login successful.';

  @override
  String authComingSoon(String provider) {
    return '$provider authentication coming soon.';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinTuno => 'Join Tuno and start your\nsinging journey';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get emailHintSignup => 'you@example.com';

  @override
  String get passwordHintSignup => 'At least 6 characters';

  @override
  String get fullNameRequired => 'Full name is required.';

  @override
  String get nameMinLength => 'Name must be at least 2 characters.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get signUpWithGoogle => 'Sign up with Google. Coming soon.';

  @override
  String get signUpWithApple => 'Sign up with Apple. Coming soon.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get enterEmailForReset =>
      'Enter your email and we\'ll send you a reset link.';

  @override
  String get email => 'Email';

  @override
  String get emailHintReset => 'you@example.com';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resetLinkSent => 'Reset link sent. Please check your email.';

  @override
  String get goBack => 'Go back';

  @override
  String get yourEmailIsNotVerified => 'Your email is not verified yet.';

  @override
  String get verifyYourEmail => 'Verify your email';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get signedIn => 'Signed in';

  @override
  String get verificationInstructions =>
      'Open your email inbox and click the verification link to complete your sign up. After verifying, tap the button below.';

  @override
  String get iHaveVerified => 'I Have Verified';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get logOut => 'Log Out';

  @override
  String get emailVerifiedSuccess => 'Email verified.';

  @override
  String get failedToVerify => 'Failed to verify email.';

  @override
  String get verificationSent => 'Verification email sent.';

  @override
  String get failedToResend => 'Failed to resend verification email.';

  @override
  String get yourEmailIsVerified => 'Your email is verified.';

  @override
  String get setupTunoExperience => 'Set up your Tuno experience';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get chooseCoachingLanguage => 'Choose your coaching language';

  @override
  String get coachingLanguageSubtitle =>
      'Select the language you prefer for coaching instructions and AI feedback.';

  @override
  String languageLabel(String label) {
    return '$label language';
  }

  @override
  String get whatIsYourExperience => 'What is your singing experience?';

  @override
  String get experienceSubtitle =>
      'This helps us personalize your practice sessions.';

  @override
  String get beginner => 'Beginner';

  @override
  String get beginnerDescription => 'I am starting my singing journey.';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get intermediateDescription => 'I understand basic pitch and rhythm.';

  @override
  String get advanced => 'Advanced';

  @override
  String get advancedDescription =>
      'I practise regularly and want detailed improvement.';

  @override
  String get professional => 'Professional';

  @override
  String get professionalDescription =>
      'I perform, teach or record professionally.';

  @override
  String experienceLabel(String label) {
    return '$label experience';
  }

  @override
  String get whatAreYourGoals => 'What are your singing goals?';

  @override
  String get goalsSubtitle =>
      'Select all that apply. You can change these later.';

  @override
  String goalLabel(String label) {
    return '$label goal';
  }

  @override
  String get yourVoiceStaysInControl => 'Your voice stays in your control';

  @override
  String get permissionEducationMessage =>
      'Tuno uses microphone access only when you choose to record a practice session. You can change this permission later in your device or browser settings.';

  @override
  String get requiredForRecording => 'Required for voice recording';

  @override
  String get requiredForRecordingDesc =>
      'Microphone access is needed to capture your singing for AI feedback.';

  @override
  String get noAutoRecord => 'Tuno will not record automatically';

  @override
  String get noAutoRecordDesc =>
      'Recording only happens when you explicitly start a practice session.';

  @override
  String get permissionCanBeChanged => 'Permission can be changed later';

  @override
  String get permissionCanBeChangedDesc =>
      'You can grant or revoke microphone access anytime in device/browser settings.';

  @override
  String get requestingPermission => 'Requesting...';

  @override
  String get enableMicrophone => 'Enable Microphone';

  @override
  String get openAppSettingsManually => 'Open App Settings Manually';

  @override
  String get microphoneGrantedMessage =>
      'Microphone access granted. You\'re ready to record!';

  @override
  String get continueWithoutMic =>
      'You can continue onboarding without microphone access. Recording will require permission when you start a practice session.';

  @override
  String get micPermissionGrantedSnackbar =>
      'Microphone access granted. You can now record your voice.';

  @override
  String get micPermissionDeniedSnackbar =>
      'Microphone access denied. You can enable it later in settings to record.';

  @override
  String get micPermissionPermanentlyDeniedSnackbar =>
      'Microphone access permanently denied. Please enable it in app settings.';

  @override
  String get micPermissionLimitedSnackbar =>
      'Limited microphone access granted. You can record but with restrictions.';

  @override
  String permissionStatusLabel(String status) {
    return 'Permission status: $status';
  }

  @override
  String get failedToRequestPermission =>
      'Failed to request permission. Please try again.';

  @override
  String get reviewYourSetup => 'Review your setup';

  @override
  String get reviewSubtitle => 'Check your selections and edit if needed.';

  @override
  String get languageSection => 'Language';

  @override
  String get experienceLevel => 'Experience Level';

  @override
  String get singingGoals => 'Singing Goals';

  @override
  String get noGoalsSelected => 'No goals selected';

  @override
  String goalsSelected(int count) {
    return '$count goal(s) selected';
  }

  @override
  String get micAccess => 'Microphone Access';

  @override
  String get checkingPermission => 'Checking permission...';

  @override
  String get permissionGranted => 'Permission granted';

  @override
  String get permissionNotGranted =>
      'Permission not granted (required for recording)';

  @override
  String get change => 'Change';

  @override
  String get edit => 'Edit';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get pleaseSignInAgain =>
      'Please sign in again to complete your setup.';

  @override
  String get notSelected => 'Not selected';

  @override
  String get setupSaveFailed =>
      'We couldn\'t save your setup. Please try again.';

  @override
  String get onboardingLanguageRequired =>
      'Please select a language to continue.';

  @override
  String get onboardingExperienceRequired =>
      'Please select your experience level to continue.';

  @override
  String get onboardingGoalRequired =>
      'Please select at least one goal to continue.';

  @override
  String get onboardingCheckFailed => 'Something went wrong. Please try again.';

  @override
  String somethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get micPermissionGrantedShort => 'Microphone permission granted.';

  @override
  String get micPermissionDeniedShort => 'Microphone permission denied.';

  @override
  String get couldNotRequestMicPermission => 'Could not request permission.';

  @override
  String get choosePracticeMode => 'Choose Practice Mode';

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get soloPractice => 'Solo Practice';

  @override
  String get soloPracticeDesc => 'Sing with your voice only';

  @override
  String get tunoExercises => 'Tuno Exercises';

  @override
  String get tunoExercisesDesc => 'Practice with guided exercises';

  @override
  String get uploadSong => 'Upload Song';

  @override
  String get uploadSongDesc => 'Upload your own track';

  @override
  String get backingTrack => 'Backing Track';

  @override
  String get backingTrackDesc => 'Sing with your own track';

  @override
  String tapToStart(String title, String description) {
    return '$title, $description. Tap to start.';
  }

  @override
  String modeNotAvailable(String title, String description) {
    return '$title, $description. Not available.';
  }

  @override
  String modeComingSoon(String title) {
    return '$title — Coming soon';
  }

  @override
  String get tunoExercisesComingSoon =>
      'Tuno Exercises will be available in a future update.';

  @override
  String get backingTracksComingSoon =>
      'Backing Tracks will be available in a future update.';

  @override
  String get voicePractice => 'Voice Practice';

  @override
  String get voicePracticeSubtitle =>
      'Record your singing and get AI-powered feedback on pitch, rhythm, and tone.';

  @override
  String get requestingMicPermission => 'Requesting microphone permission...';

  @override
  String get micPermissionRequired => 'Microphone Permission Required';

  @override
  String get enableMicInSettings =>
      'Please enable microphone access in settings to record your voice.';

  @override
  String get recording => 'Recording...';

  @override
  String get recordingSaved => 'Recording saved';

  @override
  String get readyToRecord => 'Ready to record';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get deleteAndRecordAgain => 'Delete & Record Again';

  @override
  String get reviewRecording => 'Review Recording';

  @override
  String get orTapMicAbove => 'Or tap the microphone above';

  @override
  String get discardRecordingTitle => 'Discard recording?';

  @override
  String get discardRecordingContent =>
      'Your current recording will not be saved.';

  @override
  String get keepRecording => 'Keep Recording';

  @override
  String get discardAndGoBack => 'Discard and Go Back';

  @override
  String recordingSavedDuration(String duration) {
    return 'Recording saved — $duration';
  }

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get failedToDeleteRecording =>
      'Failed to delete recording. Please try again.';

  @override
  String get startRecordingSemantic => 'Start recording';

  @override
  String get stopRecordingSemantic => 'Stop recording';

  @override
  String get reviewRecordingTitle => 'Review Recording';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get replayFromBeginning => 'Replay from beginning';

  @override
  String get forwardTenSeconds => 'Forward 10 seconds';

  @override
  String get continueToAnalysis => 'Continue to Analysis';

  @override
  String get unableToLoadAudio =>
      'Unable to load audio file. The recording may be missing or corrupted.';

  @override
  String get analysisPending => 'Analyzing...';

  @override
  String get aiAnalysisComingSoon =>
      'AI pitch analysis will be connected in the next phase.';

  @override
  String get recordingDetails => 'Recording Details';

  @override
  String get fileName => 'File Name';

  @override
  String get duration => 'Duration';

  @override
  String get recorded => 'Recorded';

  @override
  String get practiceAgain => 'Practice Again';

  @override
  String get backToReview => 'Back to Review';

  @override
  String get unableToLoadDetails =>
      'Unable to load recording details. Navigation data may be missing or invalid.';

  @override
  String get uploadReferenceSong => 'Upload Reference Song';

  @override
  String get chooseSongToPractice => 'Choose the song you want to practise.';

  @override
  String get chooseAudioFile => 'Choose an audio file';

  @override
  String get audioFileFormats => 'MP3, WAV, M4A or AAC — maximum 50 MB';

  @override
  String get selectSong => 'Select Song';

  @override
  String get selecting => 'Selecting...';

  @override
  String get remove => 'Remove';

  @override
  String get replaceSong => 'Replace Song';

  @override
  String get trackSelected =>
      'Track selected. Practice setup will be connected next.';

  @override
  String get couldNotSelectFile => 'Could not select file';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get retry => 'Retry';

  @override
  String get privacyNote =>
      'Your reference track remains on this device and is not uploaded.';

  @override
  String get tunoLogoSemanticLabel => 'Tuno logo';

  @override
  String get voiceRecordingStartFailed =>
      'Could not start recording. Please try again.';

  @override
  String get voiceRecordingStopFailed =>
      'Could not stop recording. Please try again.';

  @override
  String get voiceRecordingPlaybackFailed =>
      'Could not start playback. Please try again.';

  @override
  String get voiceRecordingPauseFailed =>
      'Could not pause playback. Please try again.';

  @override
  String get voiceRecordingResumeFailed =>
      'Could not resume playback. Please try again.';

  @override
  String get voiceRecordingSeekFailed =>
      'Could not change the playback position. Please try again.';

  @override
  String get referenceTrackUnsupportedFormat =>
      'Unsupported file format. Please choose an MP3, WAV, M4A, or AAC file.';

  @override
  String get referenceTrackFileTooLarge =>
      'File too large. Maximum allowed size is 50 MB.';

  @override
  String get referenceTrackUnreadableFile =>
      'Could not read the file content on this platform. Please try again.';

  @override
  String get referenceTrackMissingPath =>
      'Could not determine the file location. Please try again.';

  @override
  String get improvePitchAccuracy => 'Improve pitch accuracy';

  @override
  String get increaseVocalRange => 'Increase vocal range';

  @override
  String get improveBreathControl => 'Improve breath control';

  @override
  String get improveRhythmTiming => 'Improve rhythm and timing';

  @override
  String get improveVoiceStability => 'Improve voice stability';

  @override
  String get buildSingingConfidence => 'Build singing confidence';

  @override
  String get couldNotOpenSettingsManualInstructions =>
      'Could not open settings. Please enable microphone access manually.';

  @override
  String get recordingLibrary => 'Recording Library';

  @override
  String get yourSavedPracticeRecordings => 'Your saved practice recordings';

  @override
  String get searchRecordings => 'Search recordings';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get noRecordingsYet => 'No recordings yet';

  @override
  String get completePracticeToSaveFirst =>
      'Complete a practice session to save your first recording.';

  @override
  String get errorLoadingRecordings => 'Failed to load recordings';

  @override
  String get recordedOn => 'Recorded on';

  @override
  String get analysisStatus => 'Analysis';

  @override
  String get analysisNone => 'Not analyzed';

  @override
  String get analysisCompleted => 'Completed';

  @override
  String get analysisFailed => 'Failed';

  @override
  String analysisScore(String score) {
    return 'Score: $score';
  }

  @override
  String referenceTrack(String track) {
    return 'Reference: $track';
  }

  @override
  String get renameRecording => 'Rename recording';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get deleteRecording => 'Delete recording';

  @override
  String get deleteConfirmation => 'Delete this recording?';

  @override
  String get deleteConfirmationMessage =>
      'This action cannot be undone. The recording will be permanently deleted.';

  @override
  String get clearLibrary => 'Clear Library';

  @override
  String get clearLibraryConfirmation => 'Clear the entire library?';

  @override
  String get clearLibraryConfirmationMessage =>
      'This will permanently delete ALL recordings. This action cannot be undone.';

  @override
  String get playRecording => 'Play recording';

  @override
  String get saving => 'Saving...';

  @override
  String get referenceTrackLibraryTitle => 'Your Library';

  @override
  String get referenceTrackLibrarySubtitle =>
      'Choose a track for your practice';

  @override
  String get referenceTrackLibraryAddTrack => 'Add Track';

  @override
  String get referenceTrackLibraryEmptyTitle => 'Your library is empty';

  @override
  String get referenceTrackLibraryEmptySubtitle =>
      'Add an audio track to start practising';

  @override
  String get referenceTrackLibraryViewLibrary => 'View Library';

  @override
  String referenceTrackLibraryTrackSelected(String name) {
    return 'Track selected: $name';
  }

  @override
  String get referenceTrackLibraryRemove => 'Remove track';

  @override
  String get referenceTrackLibrarySaving => 'Saving library...';

  @override
  String get loadingLibrary => 'Loading library...';

  @override
  String get referenceTrackLabel => 'Reference Track';

  @override
  String get referenceTrackChange => 'Change Track';

  @override
  String get referenceTrackClear => 'Clear Selection';

  @override
  String get recordingSavedToLibrary => 'Recording saved to library';

  @override
  String get webPersistenceWarning =>
      'Web: recordings are stored in browser IndexedDB and may not survive clearing browser data. For permanent storage, use the native app.';

  @override
  String get recordingSessionOnly =>
      'Recording available for this session only. It was not saved to persistent storage.';

  @override
  String get recordingSaveQuotaExceeded =>
      'Storage quota exceeded. Please free up space and try again.';

  @override
  String get recordingSaveStorageUnavailable =>
      'Storage is unavailable. Please try again later.';

  @override
  String get recordingSaveNotFound => 'Recording not found.';

  @override
  String get recordingSaveCancelled => 'Save operation was cancelled.';

  @override
  String get recordingSavePlatformError =>
      'A platform error occurred while saving. Please try again.';

  @override
  String get recordingSaveInvalidData =>
      'Invalid recording data. Please try recording again.';

  @override
  String get recordingSaveDisposed =>
      'Save operation failed. Please try again.';

  @override
  String get recordingSavePermissionDenied =>
      'Permission denied. Please grant storage access and try again.';
}
