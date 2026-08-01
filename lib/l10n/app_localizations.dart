import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
    Locale('hi'),
  ];

  /// Title for the Languages screen
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Subtitle on the Languages screen
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout Tuno'**
  String get chooseAppLanguage;

  /// Option label for using the system default language
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Supporting text for the system default option
  ///
  /// In en, this message translates to:
  /// **'Use your device language'**
  String get useDeviceLanguage;

  /// Option label for English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Option label for Tamil language
  ///
  /// In en, this message translates to:
  /// **'α«ñα««α«┐α«┤α»ì'**
  String get tamil;

  /// Option label for Hindi language
  ///
  /// In en, this message translates to:
  /// **'αñ╣αñ┐αñ¿αÑìαñªαÑÇ'**
  String get hindi;

  /// Accessibility label for the back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Snackbar message shown after changing the language
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// Title for the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Bottom navigation label for Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom navigation label for Practice
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// Bottom navigation label for Record
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// Bottom navigation label for Progress
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Bottom navigation label for Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings row label for Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Settings row label for Practice Preferences
  ///
  /// In en, this message translates to:
  /// **'Practice Preferences'**
  String get practicePreferences;

  /// Settings row label for Audio and Recording
  ///
  /// In en, this message translates to:
  /// **'Audio & Recording'**
  String get audioAndRecording;

  /// Settings row and screen title for Notification Preferences
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Settings row and screen title for Privacy and Security
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// Settings row label for Help and Support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Settings row label for About Tuno
  ///
  /// In en, this message translates to:
  /// **'About Tuno'**
  String get aboutTuno;

  /// Snackbar for features not yet implemented
  ///
  /// In en, this message translates to:
  /// **'{label} will be available soon.'**
  String featureComingSoon(String label);

  /// Title for the Appearance bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme option label for Light mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Theme option label for Dark mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Button text for Logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Title for the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// Content for the logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmContent;

  /// Button to cancel recording
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title for the Preferences screen
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Semantic label for back button to settings
  ///
  /// In en, this message translates to:
  /// **'Back to Settings'**
  String get backToSettings;

  /// Section title for Coaching Feedback
  ///
  /// In en, this message translates to:
  /// **'Coaching Feedback'**
  String get coachingFeedback;

  /// Section title for Recording Preferences
  ///
  /// In en, this message translates to:
  /// **'Recording Preferences'**
  String get recordingPreferences;

  /// Section title for General Behaviour
  ///
  /// In en, this message translates to:
  /// **'General Behaviour'**
  String get generalBehaviour;

  /// Toggle label for count-in before recording
  ///
  /// In en, this message translates to:
  /// **'Count-in before recording'**
  String get countInBeforeRecording;

  /// Toggle label for auto-save completed recordings
  ///
  /// In en, this message translates to:
  /// **'Automatically save completed recordings'**
  String get autoSaveCompletedRecordings;

  /// Toggle label for headphone recommendation
  ///
  /// In en, this message translates to:
  /// **'Show headphone recommendation'**
  String get showHeadphoneRecommendation;

  /// Toggle label for confirm before deleting
  ///
  /// In en, this message translates to:
  /// **'Confirm before deleting a recording'**
  String get confirmBeforeDeleting;

  /// Toggle label for reduce animations
  ///
  /// In en, this message translates to:
  /// **'Reduce animations'**
  String get reduceAnimations;

  /// Snackbar message when count-in is enabled
  ///
  /// In en, this message translates to:
  /// **'Count-in enabled'**
  String get countInEnabled;

  /// Snackbar message when count-in is disabled
  ///
  /// In en, this message translates to:
  /// **'Count-in disabled'**
  String get countInDisabled;

  /// Snackbar message when auto-save is enabled
  ///
  /// In en, this message translates to:
  /// **'Auto-save enabled'**
  String get autoSaveEnabled;

  /// Snackbar message when auto-save is disabled
  ///
  /// In en, this message translates to:
  /// **'Auto-save disabled'**
  String get autoSaveDisabled;

  /// Snackbar message when headphone reminder is enabled
  ///
  /// In en, this message translates to:
  /// **'Headphone reminder enabled'**
  String get headphoneReminderEnabled;

  /// Snackbar message when headphone reminder is disabled
  ///
  /// In en, this message translates to:
  /// **'Headphone reminder disabled'**
  String get headphoneReminderDisabled;

  /// Snackbar message when delete confirmation is enabled
  ///
  /// In en, this message translates to:
  /// **'Delete confirmation enabled'**
  String get deleteConfirmationEnabled;

  /// Snackbar message when delete confirmation is disabled
  ///
  /// In en, this message translates to:
  /// **'Delete confirmation disabled'**
  String get deleteConfirmationDisabled;

  /// Snackbar message when reduce animations is enabled
  ///
  /// In en, this message translates to:
  /// **'Reduced animations'**
  String get reducedAnimations;

  /// Snackbar message when reduce animations is disabled
  ///
  /// In en, this message translates to:
  /// **'Animations restored'**
  String get animationsRestored;

  /// Label for the default practice mode selector
  ///
  /// In en, this message translates to:
  /// **'Default Practice Mode'**
  String get defaultPracticeMode;

  /// Feedback detail option: simple
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get simple;

  /// Feedback detail option: detailed
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get detailed;

  /// Snackbar when default practice mode changes
  ///
  /// In en, this message translates to:
  /// **'Default mode: {mode}'**
  String defaultModeLabel(String mode);

  /// Title for the Audio and Video settings screen
  ///
  /// In en, this message translates to:
  /// **'Audio & Video'**
  String get audioAndVideo;

  /// Section title for default recording type
  ///
  /// In en, this message translates to:
  /// **'Default Recording Type'**
  String get defaultRecordingType;

  /// Section title for audio quality
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get audioQuality;

  /// Section title for recording behaviour
  ///
  /// In en, this message translates to:
  /// **'Recording Behaviour'**
  String get recordingBehaviour;

  /// Section title for microphone access
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get microphoneAccess;

  /// Toggle label for noise reduction
  ///
  /// In en, this message translates to:
  /// **'Noise Reduction'**
  String get noiseReduction;

  /// Toggle label for countdown before recording
  ///
  /// In en, this message translates to:
  /// **'Countdown before recording'**
  String get countdownBeforeRecording;

  /// Toggle label for auto-play after capture
  ///
  /// In en, this message translates to:
  /// **'Auto-play recording after capture'**
  String get autoPlayAfterCapture;

  /// Toggle label for headphones reminder
  ///
  /// In en, this message translates to:
  /// **'Show headphones reminder'**
  String get showHeadphonesReminder;

  /// Snackbar message when noise reduction is enabled
  ///
  /// In en, this message translates to:
  /// **'Noise reduction enabled'**
  String get noiseReductionEnabled;

  /// Snackbar message when noise reduction is disabled
  ///
  /// In en, this message translates to:
  /// **'Noise reduction disabled'**
  String get noiseReductionDisabled;

  /// Snackbar message when countdown is enabled
  ///
  /// In en, this message translates to:
  /// **'Countdown enabled'**
  String get countdownEnabled;

  /// Snackbar message when countdown is disabled
  ///
  /// In en, this message translates to:
  /// **'Countdown disabled'**
  String get countdownDisabled;

  /// Snackbar message when auto-play is enabled
  ///
  /// In en, this message translates to:
  /// **'Auto-play enabled'**
  String get autoPlayEnabled;

  /// Snackbar message when auto-play is disabled
  ///
  /// In en, this message translates to:
  /// **'Auto-play disabled'**
  String get autoPlayDisabled;

  /// Snackbar message for headphones reminder enabled
  ///
  /// In en, this message translates to:
  /// **'Headphones reminder enabled'**
  String get headphonesReminderEnabled;

  /// Snackbar message for headphones reminder disabled
  ///
  /// In en, this message translates to:
  /// **'Headphones reminder disabled'**
  String get headphonesReminderDisabled;

  /// Label for granted permission status
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// Label for not granted permission status
  ///
  /// In en, this message translates to:
  /// **'Not granted ΓÇö tap to allow'**
  String get notGrantedTapToAllow;

  /// Error message when unable to check permission
  ///
  /// In en, this message translates to:
  /// **'Could not check microphone permission'**
  String get couldNotCheckPermission;

  /// Snackbar message for microphone granted
  ///
  /// In en, this message translates to:
  /// **'Microphone access granted'**
  String get microphoneGranted;

  /// Snackbar message for microphone denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access denied'**
  String get microphoneDenied;

  /// Error message when unable to request permission
  ///
  /// In en, this message translates to:
  /// **'Could not request microphone permission'**
  String get couldNotRequestPermission;

  /// Title for microphone permission dialog
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get microphonePermissionDialogTitle;

  /// Content for microphone permission permanently denied dialog
  ///
  /// In en, this message translates to:
  /// **'Microphone permission has been permanently denied. Please enable it in your system settings.'**
  String get microphonePermissionDialogContent;

  /// Button text for Open Settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Recording type option: Audio
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Recording type option: Video
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// Audio quality option: Standard
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// Audio quality option: High
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Snackbar when recording type changes
  ///
  /// In en, this message translates to:
  /// **'Default recording type: {type}'**
  String defaultRecordingTypeLabel(String type);

  /// Snackbar when audio quality changes
  ///
  /// In en, this message translates to:
  /// **'Audio quality: {quality}'**
  String audioQualityLabel(String quality);

  /// Label for personal information settings
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Label for email address
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Label for change password action
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Label for email verification
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// Label for sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Label for delete account action
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Default display name when user has no name set
  ///
  /// In en, this message translates to:
  /// **'Tuno Singer'**
  String get tunoSinger;

  /// Text shown when user has no email
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Label for verified email status
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// Label for not verified email status
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// Short label for verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Short label for not verified status
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// Label showing sign-in provider(s)
  ///
  /// In en, this message translates to:
  /// **'Sign in with {providers}'**
  String signInWithProvider(String providers);

  /// Provider name for password-based authentication
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Provider name for Google authentication
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// Provider name for Apple authentication
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// Provider name for Facebook authentication
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// Label for display name text field
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// Hint text for display name field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Validation message for empty name
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// Button text for Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Snackbar message when display name is updated
  ///
  /// In en, this message translates to:
  /// **'Display name updated.'**
  String get displayNameUpdated;

  /// Title for the email address dialog
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressDialogTitle;

  /// Label before showing the user's email
  ///
  /// In en, this message translates to:
  /// **'Your authenticated email address is:'**
  String get yourEmailIs;

  /// Message about email change not being supported
  ///
  /// In en, this message translates to:
  /// **'Changing your email is not currently supported in this version of Tuno. A verified-before-update flow will be added in a future release.'**
  String get emailChangeNotSupported;

  /// Button text for Close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Snackbar message when no email is on record
  ///
  /// In en, this message translates to:
  /// **'No email address on record.'**
  String get noEmailOnRecord;

  /// Snackbar when password reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}. Check your inbox.'**
  String passwordResetSent(String email);

  /// Snackbar when email is already verified
  ///
  /// In en, this message translates to:
  /// **'Your email is already verified.'**
  String get emailAlreadyVerified;

  /// Snackbar when verification email is sent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get verificationEmailSent;

  /// Title for sign out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutDialogTitle;

  /// Content for sign out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutDialogContent;

  /// Title for delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountDialogTitle;

  /// Warning message in delete account dialog
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your account data will be lost.'**
  String get deleteAccountWarning;

  /// Instruction text for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Type DELETE below to confirm:'**
  String get typeDeleteToConfirm;

  /// Hint text for the delete confirmation field
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get typeDelete;

  /// Note about Firestore data cleanup in delete dialog
  ///
  /// In en, this message translates to:
  /// **'Firestore data cleanup still needs a separate backend process. Your authentication account will be deleted, but any stored documents may remain.'**
  String get deleteFirestoreNote;

  /// Button text for permanent deletion
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get permanentlyDelete;

  /// Snackbar when account is deleted
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// Section title for security status
  ///
  /// In en, this message translates to:
  /// **'Security Status'**
  String get securityStatus;

  /// Label for email verification status
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerificationStatus;

  /// Label for authentication provider
  ///
  /// In en, this message translates to:
  /// **'Authentication Provider'**
  String get authenticationProvider;

  /// Text when no provider data is available
  ///
  /// In en, this message translates to:
  /// **'No provider data'**
  String get noProviderData;

  /// Label for account creation date
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreated;

  /// Section label for security recommendations
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Security recommendation to verify email
  ///
  /// In en, this message translates to:
  /// **'Verify your email address to secure your account.'**
  String get verifyEmailRecommendation;

  /// Security recommendation for strong password
  ///
  /// In en, this message translates to:
  /// **'Use a strong, unique password. Consider changing it periodically.'**
  String get strongPasswordRecommendation;

  /// Security recommendation to keep email updated
  ///
  /// In en, this message translates to:
  /// **'Keep your email address up to date to receive security notifications.'**
  String get keepEmailUpdatedRecommendation;

  /// Section title for Password and Authentication
  ///
  /// In en, this message translates to:
  /// **'Password & Authentication'**
  String get passwordAndAuth;

  /// Label for send password reset email action
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Email'**
  String get sendPasswordResetEmail;

  /// Subtitle for password reset action
  ///
  /// In en, this message translates to:
  /// **'Receive a link to reset your password via email.'**
  String get resetPasswordSubtitle;

  /// Info message about direct password change feature
  ///
  /// In en, this message translates to:
  /// **'Change password directly in the app will be available in a future update.'**
  String get directPasswordChangeFuture;

  /// Info message for social auth users
  ///
  /// In en, this message translates to:
  /// **'You signed in with {providers}. Password management is handled by your provider.'**
  String socialAuthInfo(String providers);

  /// Section title for app permissions
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// Label for microphone permission
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// Description for microphone permission requirement
  ///
  /// In en, this message translates to:
  /// **'Required for voice recording and practice features.'**
  String get micRequiredDescription;

  /// Label when checking permission status
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// Label for unknown permission status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownStatus;

  /// Label for denied permission status
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// Label for permanently denied permission status
  ///
  /// In en, this message translates to:
  /// **'Permanently Denied'**
  String get permanentlyDenied;

  /// Label for restricted permission status
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get restricted;

  /// Label for provisional permission status
  ///
  /// In en, this message translates to:
  /// **'Provisional'**
  String get provisional;

  /// Semantic label for opening system settings for a permission
  ///
  /// In en, this message translates to:
  /// **'Open system settings for {permission}'**
  String openSystemSettingsLabel(String permission);

  /// Button text to open settings for a permission
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get permissionSettings;

  /// Section title for privacy controls
  ///
  /// In en, this message translates to:
  /// **'Privacy Controls'**
  String get privacyControls;

  /// Info message about analytics not being configured
  ///
  /// In en, this message translates to:
  /// **'Analytics collection is not currently configured for Tuno. No usage data is being collected.'**
  String get analyticsNotConfigured;

  /// Info message about crash diagnostics not being enabled
  ///
  /// In en, this message translates to:
  /// **'Crash and error diagnostics are not currently enabled. Diagnostic reports will be available when crash reporting is configured.'**
  String get crashDiagnosticsNotEnabled;

  /// Info message about AI processing not being available
  ///
  /// In en, this message translates to:
  /// **'Personalized AI processing is not currently available. Privacy controls for AI features will be added in a future release.'**
  String get aiProcessingNotAvailable;

  /// Note about additional privacy controls
  ///
  /// In en, this message translates to:
  /// **'Additional privacy controls will become available when these services are enabled.'**
  String get additionalPrivacyControls;

  /// Section title for Data and Account
  ///
  /// In en, this message translates to:
  /// **'Data & Account'**
  String get dataAndAccount;

  /// Label for export my data action
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportMyData;

  /// Subtitle for export data action
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your Tuno data.'**
  String get exportDataSubtitle;

  /// Subtitle for sign out action
  ///
  /// In en, this message translates to:
  /// **'Sign out of your Tuno account.'**
  String get signOutSubtitle;

  /// Subtitle for delete account action
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all associated data.'**
  String get deleteAccountSubtitle;

  /// Title for export data dialog
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportDataDialogTitle;

  /// Content for export data dialog
  ///
  /// In en, this message translates to:
  /// **'Data export requires a trusted backend process to compile and deliver your account data securely.'**
  String get exportDataDialogContent;

  /// Future availability note in export data dialog
  ///
  /// In en, this message translates to:
  /// **'This feature will be available when an export endpoint is configured on the Tuno backend server.'**
  String get exportDataDialogFuture;

  /// Content introduction for delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Account deletion requires a secure backend process to:'**
  String get deleteAccountDialogContent;

  /// Bullet point: delete auth account
  ///
  /// In en, this message translates to:
  /// **'Delete your Auth account'**
  String get deleteAuthAccount;

  /// Bullet point: delete Firestore docs
  ///
  /// In en, this message translates to:
  /// **'Remove all Firestore documents and subcollections'**
  String get deleteFirestoreDocs;

  /// Bullet point: delete storage recordings
  ///
  /// In en, this message translates to:
  /// **'Delete all uploaded recordings from Storage'**
  String get deleteStorageRecordings;

  /// Bullet point: delete metadata
  ///
  /// In en, this message translates to:
  /// **'Remove any associated metadata'**
  String get deleteMetadata;

  /// Info about deletion requiring backend
  ///
  /// In en, this message translates to:
  /// **'This cannot be done safely from the app alone. A trusted Cloud Function or Admin SDK backend is required.'**
  String get deleteCannotBeDoneFromApp;

  /// Instruction to contact support for deletion
  ///
  /// In en, this message translates to:
  /// **'To delete your account now, please contact Tuno support.'**
  String get contactSupportToDelete;

  /// Subtitle for notification preferences
  ///
  /// In en, this message translates to:
  /// **'Choose which updates you want to receive'**
  String get chooseUpdates;

  /// Master toggle label for allowing notifications
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// Toggle label for practice reminders
  ///
  /// In en, this message translates to:
  /// **'Practice Reminders'**
  String get practiceReminders;

  /// Toggle label for AI analysis updates
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Updates'**
  String get aiAnalysisUpdates;

  /// Toggle label for streak reminders
  ///
  /// In en, this message translates to:
  /// **'Streak Reminders'**
  String get streakReminders;

  /// Toggle label for coins and achievements notifications
  ///
  /// In en, this message translates to:
  /// **'Coins & Achievements'**
  String get coinsAndAchievements;

  /// Toggle label for weekly challenges notifications
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenges'**
  String get weeklyChallenges;

  /// Toggle label for product updates notifications
  ///
  /// In en, this message translates to:
  /// **'Product Updates'**
  String get productUpdates;

  /// Label for reminder time selector
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Tooltip for reminder time selector
  ///
  /// In en, this message translates to:
  /// **'Tap to change reminder time'**
  String get tapToChangeReminderTime;

  /// Info banner content about notification delivery not implemented
  ///
  /// In en, this message translates to:
  /// **'Notification delivery is not yet implemented. Your preferences are saved locally and will be used once delivery is available.'**
  String get notificationDeliveryNotImplemented;

  /// Button label for dismiss
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Note at bottom of notification preferences
  ///
  /// In en, this message translates to:
  /// **'You can change these preferences anytime.'**
  String get youCanChangeAnytime;

  /// Label suffix for disabled toggle
  ///
  /// In en, this message translates to:
  /// **'{label} (unavailable)'**
  String labelUnavailable(String label);

  /// Tooltip for disabled toggle when notifications are off
  ///
  /// In en, this message translates to:
  /// **'{label} ΓÇô enable notifications first'**
  String enableNotificationsFirst(String label);

  /// Title for the Notifications screen
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Empty state title when no notifications
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// Empty state description when no notifications
  ///
  /// In en, this message translates to:
  /// **'Practice updates, analysis results and achievements will appear here.'**
  String get emptyNotificationsMessage;

  /// Button to mark all notifications as read
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Relative time label for just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Relative time label for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Relative time label for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Relative time label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Relative time label for days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// Action label to mark notification as unread
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// Action label to mark notification as read
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// Action label to delete notification
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Semantic label for notification bell with unread count
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String unreadCountSemantic(int count);

  /// Tooltip for notification bell button
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Brand name shown on home screen
  ///
  /// In en, this message translates to:
  /// **'Tuno'**
  String get tuno;

  /// Greeting on home screen with user name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} ≡ƒæï'**
  String helloUser(String name);

  /// Subtitle asking user if they are ready to practice
  ///
  /// In en, this message translates to:
  /// **'Ready to improve your voice today?'**
  String get readyToImprove;

  /// Section heading for progress on home screen
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Heading on the main practice card
  ///
  /// In en, this message translates to:
  /// **'Start Voice Practice'**
  String get startVoicePractice;

  /// Description on the practice card
  ///
  /// In en, this message translates to:
  /// **'Record your voice and receive instant feedback.'**
  String get recordAndGetFeedback;

  /// Button and tooltip text for start practice
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// Placeholder practice duration
  ///
  /// In en, this message translates to:
  /// **'0 min'**
  String get zeroMin;

  /// Label under practice duration on home card
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceLabel;

  /// Placeholder streak days
  ///
  /// In en, this message translates to:
  /// **'0 days'**
  String get zeroDays;

  /// Label under streak on home card
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Simple snackbar for feature coming soon
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon'**
  String featureComingSoonSimple(String feature);

  /// Subtitle brand text on welcome screen
  ///
  /// In en, this message translates to:
  /// **'AI SINGING COACH'**
  String get aiSingingCoach;

  /// Main heading on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Your Personal\nAI Singing Coach'**
  String get yourPersonalAiCoach;

  /// Tagline on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Practice ΓÇó Improve ΓÇó Achieve'**
  String get practiceImproveAchieve;

  /// Button text on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Button text for login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Heading on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! ≡ƒæï'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailIsRequired;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get enterValidEmail;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordIsRequired;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailFieldLabel;

  /// Hint text for email input
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldLabel;

  /// Hint text for password input
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Semantic label for show password button
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Semantic label for hide password button
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Link text for forgot password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Divider label between login methods
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Semantic label for Google login button
  ///
  /// In en, this message translates to:
  /// **'Login with Google. Coming soon.'**
  String get loginWithGoogle;

  /// Semantic label for Apple login button
  ///
  /// In en, this message translates to:
  /// **'Login with Apple. Coming soon.'**
  String get loginWithApple;

  /// Prefix text for sign up navigation
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Action text for sign up navigation
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Semantic label for sign up link
  ///
  /// In en, this message translates to:
  /// **'Go to sign up'**
  String get goToSignUp;

  /// Snackbar message for successful login
  ///
  /// In en, this message translates to:
  /// **'Login successful.'**
  String get loginSuccessful;

  /// Snackbar for auth providers coming soon
  ///
  /// In en, this message translates to:
  /// **'{provider} authentication coming soon.'**
  String authComingSoon(String provider);

  /// Heading on sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Subtitle on sign up screen
  ///
  /// In en, this message translates to:
  /// **'Join Tuno and start your\nsinging journey'**
  String get joinTuno;

  /// Label for full name input
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Hint for full name input
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// Hint text for email on signup
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHintSignup;

  /// Hint text for password on signup
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHintSignup;

  /// Validation message for empty full name
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get fullNameRequired;

  /// Validation message for short name
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get nameMinLength;

  /// Prefix text for login navigation
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Semantic label for login link
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// Semantic label for Google sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google. Coming soon.'**
  String get signUpWithGoogle;

  /// Semantic label for Apple sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign up with Apple. Coming soon.'**
  String get signUpWithApple;

  /// Heading on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// Instructions on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get enterEmailForReset;

  /// Label for email field on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Hint for email on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHintReset;

  /// Button text for send reset link
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// Link text to go back to login
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// Snackbar when reset link is sent
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Please check your email.'**
  String get resetLinkSent;

  /// Semantic label for back button on login screen
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// Message shown when email verification check fails
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet.'**
  String get yourEmailIsNotVerified;

  /// Heading on email verification screen
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// Shows the signed-in email
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// Fallback when no email is shown
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// Instructions on email verification screen
  ///
  /// In en, this message translates to:
  /// **'Open your email inbox and click the verification link to complete your sign up. After verifying, tap the button below.'**
  String get verificationInstructions;

  /// Button to confirm email verification
  ///
  /// In en, this message translates to:
  /// **'I Have Verified'**
  String get iHaveVerified;

  /// Button to resend verification email
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// Button to log out from verification screen
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Snackbar when email is verified
  ///
  /// In en, this message translates to:
  /// **'Email verified.'**
  String get emailVerifiedSuccess;

  /// Error message when verification fails
  ///
  /// In en, this message translates to:
  /// **'Failed to verify email.'**
  String get failedToVerify;

  /// Snackbar when verification email is sent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get verificationSent;

  /// Error message when resend fails
  ///
  /// In en, this message translates to:
  /// **'Failed to resend verification email.'**
  String get failedToResend;

  /// Message shown when email is already verified
  ///
  /// In en, this message translates to:
  /// **'Your email is verified.'**
  String get yourEmailIsVerified;

  /// Heading on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Set up your Tuno experience'**
  String get setupTunoExperience;

  /// Step indicator text
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// Button text for continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Heading for language selection on onboarding
  ///
  /// In en, this message translates to:
  /// **'Choose your coaching language'**
  String get chooseCoachingLanguage;

  /// Subtitle for language selection
  ///
  /// In en, this message translates to:
  /// **'Select the language you prefer for coaching instructions and AI feedback.'**
  String get coachingLanguageSubtitle;

  /// Semantic label for language card
  ///
  /// In en, this message translates to:
  /// **'{label} language'**
  String languageLabel(String label);

  /// Heading for experience step
  ///
  /// In en, this message translates to:
  /// **'What is your singing experience?'**
  String get whatIsYourExperience;

  /// Subtitle for experience step
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your practice sessions.'**
  String get experienceSubtitle;

  /// Experience level label: Beginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Description for beginner level
  ///
  /// In en, this message translates to:
  /// **'I am starting my singing journey.'**
  String get beginnerDescription;

  /// Experience level label: Intermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Description for intermediate level
  ///
  /// In en, this message translates to:
  /// **'I understand basic pitch and rhythm.'**
  String get intermediateDescription;

  /// Experience level label: Advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Description for advanced level
  ///
  /// In en, this message translates to:
  /// **'I practise regularly and want detailed improvement.'**
  String get advancedDescription;

  /// Experience level label: Professional
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get professional;

  /// Description for professional level
  ///
  /// In en, this message translates to:
  /// **'I perform, teach or record professionally.'**
  String get professionalDescription;

  /// Semantic label for experience card
  ///
  /// In en, this message translates to:
  /// **'{label} experience'**
  String experienceLabel(String label);

  /// Heading for goals step
  ///
  /// In en, this message translates to:
  /// **'What are your singing goals?'**
  String get whatAreYourGoals;

  /// Subtitle for goals step
  ///
  /// In en, this message translates to:
  /// **'Select all that apply. You can change these later.'**
  String get goalsSubtitle;

  /// Semantic label for goal card
  ///
  /// In en, this message translates to:
  /// **'{label} goal'**
  String goalLabel(String label);

  /// Heading for permission education step
  ///
  /// In en, this message translates to:
  /// **'Your voice stays in your control'**
  String get yourVoiceStaysInControl;

  /// Message explaining microphone usage
  ///
  /// In en, this message translates to:
  /// **'Tuno uses microphone access only when you choose to record a practice session. You can change this permission later in your device or browser settings.'**
  String get permissionEducationMessage;

  /// Info point title: required for recording
  ///
  /// In en, this message translates to:
  /// **'Required for voice recording'**
  String get requiredForRecording;

  /// Info point description: required for recording
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to capture your singing for AI feedback.'**
  String get requiredForRecordingDesc;

  /// Info point title: no auto recording
  ///
  /// In en, this message translates to:
  /// **'Tuno will not record automatically'**
  String get noAutoRecord;

  /// Info point description: no auto recording
  ///
  /// In en, this message translates to:
  /// **'Recording only happens when you explicitly start a practice session.'**
  String get noAutoRecordDesc;

  /// Info point title: permission can be changed
  ///
  /// In en, this message translates to:
  /// **'Permission can be changed later'**
  String get permissionCanBeChanged;

  /// Info point description: permission can be changed
  ///
  /// In en, this message translates to:
  /// **'You can grant or revoke microphone access anytime in device/browser settings.'**
  String get permissionCanBeChangedDesc;

  /// Label while requesting microphone permission
  ///
  /// In en, this message translates to:
  /// **'Requesting...'**
  String get requestingPermission;

  /// Button to enable microphone permission
  ///
  /// In en, this message translates to:
  /// **'Enable Microphone'**
  String get enableMicrophone;

  /// Button to open app settings manually
  ///
  /// In en, this message translates to:
  /// **'Open App Settings Manually'**
  String get openAppSettingsManually;

  /// Message when microphone is granted
  ///
  /// In en, this message translates to:
  /// **'Microphone access granted. You\'re ready to record!'**
  String get microphoneGrantedMessage;

  /// Info about continuing without microphone
  ///
  /// In en, this message translates to:
  /// **'You can continue onboarding without microphone access. Recording will require permission when you start a practice session.'**
  String get continueWithoutMic;

  /// Snackbar when microphone is granted
  ///
  /// In en, this message translates to:
  /// **'Microphone access granted. You can now record your voice.'**
  String get micPermissionGrantedSnackbar;

  /// Snackbar when microphone is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access denied. You can enable it later in settings to record.'**
  String get micPermissionDeniedSnackbar;

  /// Snackbar when microphone is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Microphone access permanently denied. Please enable it in app settings.'**
  String get micPermissionPermanentlyDeniedSnackbar;

  /// Snackbar for limited microphone permission
  ///
  /// In en, this message translates to:
  /// **'Limited microphone access granted. You can record but with restrictions.'**
  String get micPermissionLimitedSnackbar;

  /// Fallback label for unknown permission status
  ///
  /// In en, this message translates to:
  /// **'Permission status: {status}'**
  String permissionStatusLabel(String status);

  /// Error message when permission request fails
  ///
  /// In en, this message translates to:
  /// **'Failed to request permission. Please try again.'**
  String get failedToRequestPermission;

  /// Heading for review step
  ///
  /// In en, this message translates to:
  /// **'Review your setup'**
  String get reviewYourSetup;

  /// Subtitle for review step
  ///
  /// In en, this message translates to:
  /// **'Check your selections and edit if needed.'**
  String get reviewSubtitle;

  /// Section label for language review
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// Section label for experience review
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get experienceLevel;

  /// Section label for goals review
  ///
  /// In en, this message translates to:
  /// **'Singing Goals'**
  String get singingGoals;

  /// Text when no goals are selected
  ///
  /// In en, this message translates to:
  /// **'No goals selected'**
  String get noGoalsSelected;

  /// Text showing number of selected goals
  ///
  /// In en, this message translates to:
  /// **'{count} goal(s) selected'**
  String goalsSelected(int count);

  /// Section label for microphone review
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get micAccess;

  /// Text while checking permission status
  ///
  /// In en, this message translates to:
  /// **'Checking permission...'**
  String get checkingPermission;

  /// Text when permission is granted
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get permissionGranted;

  /// Text when permission is not granted
  ///
  /// In en, this message translates to:
  /// **'Permission not granted (required for recording)'**
  String get permissionNotGranted;

  /// Button text for change action
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Button text for edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button text for completing setup
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// Snackbar when user needs to sign in again
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to complete your setup.'**
  String get pleaseSignInAgain;

  /// Text when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Error message when setup save fails
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your setup. Please try again.'**
  String get setupSaveFailed;

  /// Validation error when no language is selected during onboarding
  ///
  /// In en, this message translates to:
  /// **'Please select a language to continue.'**
  String get onboardingLanguageRequired;

  /// Validation error when no experience level is selected during onboarding
  ///
  /// In en, this message translates to:
  /// **'Please select your experience level to continue.'**
  String get onboardingExperienceRequired;

  /// Validation error when no goals are selected during onboarding
  ///
  /// In en, this message translates to:
  /// **'Please select at least one goal to continue.'**
  String get onboardingGoalRequired;

  /// Error message when onboarding completion check fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingCheckFailed;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrong(String error);

  /// Snackbar when microphone is granted from review step
  ///
  /// In en, this message translates to:
  /// **'Microphone permission granted.'**
  String get micPermissionGrantedShort;

  /// Snackbar when microphone is denied from review step
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied.'**
  String get micPermissionDeniedShort;

  /// Error when permission request fails
  ///
  /// In en, this message translates to:
  /// **'Could not request permission.'**
  String get couldNotRequestMicPermission;

  /// Title for practice mode screen
  ///
  /// In en, this message translates to:
  /// **'Choose Practice Mode'**
  String get choosePracticeMode;

  /// Subtitle for practice mode screen
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// Practice mode: Solo Practice
  ///
  /// In en, this message translates to:
  /// **'Solo Practice'**
  String get soloPractice;

  /// Description for Solo Practice mode
  ///
  /// In en, this message translates to:
  /// **'Sing with your voice only'**
  String get soloPracticeDesc;

  /// Practice mode: Tuno Exercises
  ///
  /// In en, this message translates to:
  /// **'Tuno Exercises'**
  String get tunoExercises;

  /// Description for Tuno Exercises mode
  ///
  /// In en, this message translates to:
  /// **'Practice with guided exercises'**
  String get tunoExercisesDesc;

  /// Practice mode: Upload Song
  ///
  /// In en, this message translates to:
  /// **'Upload Song'**
  String get uploadSong;

  /// Description for Upload Song mode
  ///
  /// In en, this message translates to:
  /// **'Upload your own track'**
  String get uploadSongDesc;

  /// Practice mode: Backing Track
  ///
  /// In en, this message translates to:
  /// **'Backing Track'**
  String get backingTrack;

  /// Description for Backing Track mode
  ///
  /// In en, this message translates to:
  /// **'Sing with your own track'**
  String get backingTrackDesc;

  /// Semantic label for available mode card
  ///
  /// In en, this message translates to:
  /// **'{title}, {description}. Tap to start.'**
  String tapToStart(String title, String description);

  /// Semantic label for unavailable mode card
  ///
  /// In en, this message translates to:
  /// **'{title}, {description}. Not available.'**
  String modeNotAvailable(String title, String description);

  /// Tooltip for unavailable practice mode
  ///
  /// In en, this message translates to:
  /// **'{title} ΓÇö Coming soon'**
  String modeComingSoon(String title);

  /// Snackbar when Tuno Exercises is tapped
  ///
  /// In en, this message translates to:
  /// **'Tuno Exercises will be available in a future update.'**
  String get tunoExercisesComingSoon;

  /// Snackbar when Backing Track is tapped
  ///
  /// In en, this message translates to:
  /// **'Backing Tracks will be available in a future update.'**
  String get backingTracksComingSoon;

  /// Title for voice practice screen
  ///
  /// In en, this message translates to:
  /// **'Voice Practice'**
  String get voicePractice;

  /// Subtitle for voice practice screen
  ///
  /// In en, this message translates to:
  /// **'Record your singing and get AI-powered feedback on pitch, rhythm, and tone.'**
  String get voicePracticeSubtitle;

  /// Message while requesting microphone permission
  ///
  /// In en, this message translates to:
  /// **'Requesting microphone permission...'**
  String get requestingMicPermission;

  /// Title when microphone permission is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission Required'**
  String get micPermissionRequired;

  /// Message to enable microphone
  ///
  /// In en, this message translates to:
  /// **'Please enable microphone access in settings to record your voice.'**
  String get enableMicInSettings;

  /// Status label when recording
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// Status label when recording is saved
  ///
  /// In en, this message translates to:
  /// **'Recording saved'**
  String get recordingSaved;

  /// Status label when ready to record
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get readyToRecord;

  /// Button to start recording
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// Button to stop recording
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// Button to delete and record again
  ///
  /// In en, this message translates to:
  /// **'Delete & Record Again'**
  String get deleteAndRecordAgain;

  /// Button to review recording
  ///
  /// In en, this message translates to:
  /// **'Review Recording'**
  String get reviewRecording;

  /// Instruction text below recording panel
  ///
  /// In en, this message translates to:
  /// **'Or tap the microphone above'**
  String get orTapMicAbove;

  /// Dialog title for discarding recording
  ///
  /// In en, this message translates to:
  /// **'Discard recording?'**
  String get discardRecordingTitle;

  /// Dialog content for discarding recording
  ///
  /// In en, this message translates to:
  /// **'Your current recording will not be saved.'**
  String get discardRecordingContent;

  /// Button to keep recording
  ///
  /// In en, this message translates to:
  /// **'Keep Recording'**
  String get keepRecording;

  /// Button to discard and go back
  ///
  /// In en, this message translates to:
  /// **'Discard and Go Back'**
  String get discardAndGoBack;

  /// Message showing recording saved with duration
  ///
  /// In en, this message translates to:
  /// **'Recording saved ΓÇö {duration}'**
  String recordingSavedDuration(String duration);

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// Error message when delete fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recording. Please try again.'**
  String get failedToDeleteRecording;

  /// Semantic label for start recording button
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecordingSemantic;

  /// Semantic label for stop recording button
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecordingSemantic;

  /// Title for recording review screen
  ///
  /// In en, this message translates to:
  /// **'Review Recording'**
  String get reviewRecordingTitle;

  /// Tooltip and semantics for play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Tooltip and semantics for pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Tooltip and semantics for replay button
  ///
  /// In en, this message translates to:
  /// **'Replay from beginning'**
  String get replayFromBeginning;

  /// Tooltip and semantics for forward button
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get forwardTenSeconds;

  /// Button to continue to analysis
  ///
  /// In en, this message translates to:
  /// **'Continue to Analysis'**
  String get continueToAnalysis;

  /// Error message when audio fails to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load audio file. The recording may be missing or corrupted.'**
  String get unableToLoadAudio;

  /// Title for analysis result screen
  ///
  /// In en, this message translates to:
  /// **'Analysis Pending'**
  String get analysisPending;

  /// Message about AI analysis coming soon
  ///
  /// In en, this message translates to:
  /// **'AI pitch analysis will be connected in the next phase.'**
  String get aiAnalysisComingSoon;

  /// Section title for recording details
  ///
  /// In en, this message translates to:
  /// **'Recording Details'**
  String get recordingDetails;

  /// Label for file name
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// Label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for recorded date/time
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// Button text for practice again
  ///
  /// In en, this message translates to:
  /// **'Practice Again'**
  String get practiceAgain;

  /// Button text for back to review
  ///
  /// In en, this message translates to:
  /// **'Back to Review'**
  String get backToReview;

  /// Error message when recording details cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load recording details. Navigation data may be missing or invalid.'**
  String get unableToLoadDetails;

  /// Title for reference track screen
  ///
  /// In en, this message translates to:
  /// **'Upload Reference Song'**
  String get uploadReferenceSong;

  /// Subtitle for reference track screen
  ///
  /// In en, this message translates to:
  /// **'Choose the song you want to practise.'**
  String get chooseSongToPractice;

  /// Title in the file selection card
  ///
  /// In en, this message translates to:
  /// **'Choose an audio file'**
  String get chooseAudioFile;

  /// Supported file formats and size limit
  ///
  /// In en, this message translates to:
  /// **'MP3, WAV, M4A or AAC ΓÇö maximum 50 MB'**
  String get audioFileFormats;

  /// Button to select a song
  ///
  /// In en, this message translates to:
  /// **'Select Song'**
  String get selectSong;

  /// Label while selecting a file
  ///
  /// In en, this message translates to:
  /// **'Selecting...'**
  String get selecting;

  /// Button to remove selected track
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Button to replace selected track
  ///
  /// In en, this message translates to:
  /// **'Replace Song'**
  String get replaceSong;

  /// Message when track is selected
  ///
  /// In en, this message translates to:
  /// **'Track selected. Practice setup will be connected next.'**
  String get trackSelected;

  /// Error title when file selection fails
  ///
  /// In en, this message translates to:
  /// **'Could not select file'**
  String get couldNotSelectFile;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// Button to retry file selection
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Privacy note about reference track staying on device
  ///
  /// In en, this message translates to:
  /// **'Your reference track remains on this device and is not uploaded.'**
  String get privacyNote;

  /// Semantic label for the Tuno logo on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Tuno logo'**
  String get tunoLogoSemanticLabel;

  /// Error message when recording fails to start
  ///
  /// In en, this message translates to:
  /// **'Could not start recording. Please try again.'**
  String get voiceRecordingStartFailed;

  /// Error message when recording fails to stop
  ///
  /// In en, this message translates to:
  /// **'Could not stop recording. Please try again.'**
  String get voiceRecordingStopFailed;

  /// Error message when audio playback fails to start
  ///
  /// In en, this message translates to:
  /// **'Could not start playback. Please try again.'**
  String get voiceRecordingPlaybackFailed;

  /// Error message when audio playback fails to pause
  ///
  /// In en, this message translates to:
  /// **'Could not pause playback. Please try again.'**
  String get voiceRecordingPauseFailed;

  /// Error message when audio playback fails to resume
  ///
  /// In en, this message translates to:
  /// **'Could not resume playback. Please try again.'**
  String get voiceRecordingResumeFailed;

  /// Error message when changing the playback position fails
  ///
  /// In en, this message translates to:
  /// **'Could not change the playback position. Please try again.'**
  String get voiceRecordingSeekFailed;

  /// Error message when the selected file has an unsupported format
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Please choose an MP3, WAV, M4A, or AAC file.'**
  String get referenceTrackUnsupportedFormat;

  /// Error message when the selected file exceeds the size limit
  ///
  /// In en, this message translates to:
  /// **'File too large. Maximum allowed size is 50 MB.'**
  String get referenceTrackFileTooLarge;

  /// Error message when the file content cannot be read on this platform
  ///
  /// In en, this message translates to:
  /// **'Could not read the file content on this platform. Please try again.'**
  String get referenceTrackUnreadableFile;

  /// Error message when the file location cannot be determined on this platform
  ///
  /// In en, this message translates to:
  /// **'Could not determine the file location. Please try again.'**
  String get referenceTrackMissingPath;

  /// Singing goal: improve pitch accuracy
  ///
  /// In en, this message translates to:
  /// **'Improve pitch accuracy'**
  String get improvePitchAccuracy;

  /// Singing goal: increase vocal range
  ///
  /// In en, this message translates to:
  /// **'Increase vocal range'**
  String get increaseVocalRange;

  /// Singing goal: improve breath control
  ///
  /// In en, this message translates to:
  /// **'Improve breath control'**
  String get improveBreathControl;

  /// Singing goal: improve rhythm and timing
  ///
  /// In en, this message translates to:
  /// **'Improve rhythm and timing'**
  String get improveRhythmTiming;

  /// Singing goal: improve voice stability
  ///
  /// In en, this message translates to:
  /// **'Improve voice stability'**
  String get improveVoiceStability;

  /// Singing goal: build singing confidence
  ///
  /// In en, this message translates to:
  /// **'Build singing confidence'**
  String get buildSingingConfidence;

  /// Error message when settings cannot be opened automatically
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Please enable microphone access manually.'**
  String get couldNotOpenSettingsManualInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
