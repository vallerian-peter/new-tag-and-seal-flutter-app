import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
    Locale('sw'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Tag & Seal'**
  String get appName;

  /// Welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tag & Seal'**
  String get welcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s help you identify and secure your livestock'**
  String get welcomeSubtitle;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'My Livestock | Tag & Seal'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Sync button text
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Sync data button text
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// Syncing in progress text
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Sync dialog title
  ///
  /// In en, this message translates to:
  /// **'Syncing Data'**
  String get syncTitle;

  /// Sync starting message
  ///
  /// In en, this message translates to:
  /// **'Starting sync...'**
  String get syncStarting;

  /// Syncing additional data message
  ///
  /// In en, this message translates to:
  /// **'Syncing additional data...'**
  String get syncAdditionalData;

  /// Syncing livestock reference data message
  ///
  /// In en, this message translates to:
  /// **'Syncing livestock reference data...'**
  String get syncLivestockReference;

  /// Syncing livestock data message
  ///
  /// In en, this message translates to:
  /// **'Syncing livestock data...'**
  String get syncLivestockData;

  /// Syncing farm data message
  ///
  /// In en, this message translates to:
  /// **'Syncing farm data...'**
  String get syncFarmData;

  /// Sync completed message
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully!'**
  String get syncCompleted;

  /// Sync success dialog title
  ///
  /// In en, this message translates to:
  /// **'Sync Successful'**
  String get syncSuccessful;

  /// Sync success dialog message
  ///
  /// In en, this message translates to:
  /// **'All data has been synchronized successfully. Your app is now up to date.'**
  String get syncSuccessfulMessage;

  /// Sync failed dialog title
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// Sync failed dialog message
  ///
  /// In en, this message translates to:
  /// **'Failed to synchronize data. Please check your internet connection and try again.'**
  String get syncFailedMessage;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Steps completed text
  ///
  /// In en, this message translates to:
  /// **'steps completed'**
  String get stepsCompleted;

  /// No internet connection error title
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// Check internet connection error message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternetConnection;

  /// Checking network connection progress message
  ///
  /// In en, this message translates to:
  /// **'Checking network connection...'**
  String get checkingNetworkConnection;

  /// Connection error title
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get connectionErrorMessage;

  /// Connection timeout title
  ///
  /// In en, this message translates to:
  /// **'Connection Timeout'**
  String get connectionTimeout;

  /// Connection timeout message
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Please try again.'**
  String get connectionTimeoutMessage;

  /// Network error title
  ///
  /// In en, this message translates to:
  /// **'Network Error'**
  String get networkError;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkErrorMessage;

  /// Authentication failed title
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed'**
  String get authenticationFailed;

  /// Authentication failed message
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your email and password.'**
  String get authenticationFailedMessage;

  /// Server error title
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get serverErrorMessage;

  /// Service unavailable title
  ///
  /// In en, this message translates to:
  /// **'Service Unavailable'**
  String get serviceUnavailable;

  /// Service unavailable message
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Please try again later.'**
  String get serviceUnavailableMessage;

  /// Invalid server response title
  ///
  /// In en, this message translates to:
  /// **'Invalid Server Response'**
  String get invalidServerResponse;

  /// Invalid server response message
  ///
  /// In en, this message translates to:
  /// **'The server returned unexpected data. Please try again.'**
  String get invalidServerResponseMessage;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this farm?'**
  String get deleteConfirmationMessage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @allText.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allText;

  /// No description provided for @userDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'User Data Available'**
  String get userDataAvailable;

  /// No description provided for @foundText.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get foundText;

  /// No description provided for @allLivestocksText.
  ///
  /// In en, this message translates to:
  /// **'All Livestocks'**
  String get allLivestocksText;

  /// No description provided for @welcomeAgain.
  ///
  /// In en, this message translates to:
  /// **'Welcome Again'**
  String get welcomeAgain;

  /// No description provided for @continueTrackingYourLivestocks.
  ///
  /// In en, this message translates to:
  /// **'Continue tracking your livestocks with us'**
  String get continueTrackingYourLivestocks;

  /// No description provided for @searchText.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchText;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerText.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerText;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Change password screen title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Current password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// New password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get enterConfirmPassword;

  /// Current password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// New password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password minimum length validation error (8 characters)
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// New password must be different validation error
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password change confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your password? You will receive an SMS notification after the change.'**
  String get passwordChangeConfirmation;

  /// Password change success dialog title
  ///
  /// In en, this message translates to:
  /// **'Password Changed'**
  String get passwordChangedSuccessfully;

  /// Password change success dialog message
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully. You will receive an SMS notification shortly.'**
  String get passwordChangeSuccessMessage;

  /// Password change info message
  ///
  /// In en, this message translates to:
  /// **'You will receive an SMS notification on your registered phone number after successfully changing your password.'**
  String get passwordChangeInfo;

  /// Change password screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new secure password. You will receive an SMS notification after the change.'**
  String get changePasswordSubtitle;

  /// Updating password loading message
  ///
  /// In en, this message translates to:
  /// **'Updating password...'**
  String get updatingPassword;

  /// Updating profile loading message
  ///
  /// In en, this message translates to:
  /// **'Updating profile...'**
  String get updatingProfile;

  /// Internet connection check error message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get pleaseCheckYourInternetConnection;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Account settings section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// Edit profile button text
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Confirm profile update dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update your profile?'**
  String get confirmUpdateProfile;

  /// Profile update success dialog title
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdated;

  /// Profile update success dialog message
  ///
  /// In en, this message translates to:
  /// **'Your profile has been updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @recordsText.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsText;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// No description provided for @eventsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review every farm activity log'**
  String get eventsScreenSubtitle;

  /// No description provided for @totalLogs.
  ///
  /// In en, this message translates to:
  /// **'Total Logs'**
  String get totalLogs;

  /// No description provided for @eventTypes.
  ///
  /// In en, this message translates to:
  /// **'Event Types'**
  String get eventTypes;

  /// No description provided for @readyOffline.
  ///
  /// In en, this message translates to:
  /// **'Ready Offline'**
  String get readyOffline;

  /// No description provided for @unsyncedData.
  ///
  /// In en, this message translates to:
  /// **'Unsynced Data'**
  String get unsyncedData;

  /// No description provided for @settingsAppHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsAppHeaderTitle;

  /// No description provided for @settingsAppHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get settingsAppHeaderSubtitle;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsLanguageRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get settingsLanguageRegionTitle;

  /// No description provided for @settingsSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & About'**
  String get settingsSupportTitle;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeLight;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get settingsHelpSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsOfServiceSubtitle;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String settingsVersionLabel(String version);

  /// Version and build section title
  ///
  /// In en, this message translates to:
  /// **'Version & Build'**
  String get settingsVersionBuildTitle;

  /// Version display subtitle
  ///
  /// In en, this message translates to:
  /// **'App version information'**
  String get versionSubtitle;

  /// No description provided for @settingsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive livestock management application.'**
  String get settingsAppDescription;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get settingsLanguageSwahili;

  /// No description provided for @bluetoothWeightScale.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Weight Scale'**
  String get bluetoothWeightScale;

  /// No description provided for @connectToMeasureWeight.
  ///
  /// In en, this message translates to:
  /// **'Connect to measure weight'**
  String get connectToMeasureWeight;

  /// No description provided for @connectedToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connected to {deviceName}'**
  String connectedToDevice(String deviceName);

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get unknownDevice;

  /// No description provided for @scanningForDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices...'**
  String get scanningForDevices;

  /// No description provided for @makeBluetoothEnabledAndScaleOn.
  ///
  /// In en, this message translates to:
  /// **'Make sure Bluetooth is enabled and the scale is on'**
  String get makeBluetoothEnabledAndScaleOn;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @availableDevices.
  ///
  /// In en, this message translates to:
  /// **'Available Devices ({count})'**
  String availableDevices(int count);

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @waitingForWeightData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for weight data...'**
  String get waitingForWeightData;

  /// No description provided for @placeOnScaleInstruction.
  ///
  /// In en, this message translates to:
  /// **'Place livestock on the scale and wait for a stable reading'**
  String get placeOnScaleInstruction;

  /// No description provided for @saveWeight.
  ///
  /// In en, this message translates to:
  /// **'Save Weight'**
  String get saveWeight;

  /// No description provided for @dashboardSyncPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the sync button to pull the latest farms, livestock, and logs before you start working.'**
  String get dashboardSyncPrompt;

  /// No description provided for @bulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get bulk;

  /// No description provided for @bulkActions.
  ///
  /// In en, this message translates to:
  /// **'Bulk Actions'**
  String get bulkActions;

  /// No description provided for @logsText.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsText;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Livestock'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Efficiently manage and track all your livestock with digital tags and real-time monitoring'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Farm Management'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive farm management system to organize your farms, animals, and operations in one place'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Health & Records'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep detailed health records, vaccinations, and breeding information for better livestock care'**
  String get onboarding3Subtitle;

  /// No description provided for @livestockName.
  ///
  /// In en, this message translates to:
  /// **'Livestock Name'**
  String get livestockName;

  /// No description provided for @farm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farm;

  /// No description provided for @farms.
  ///
  /// In en, this message translates to:
  /// **'Farms'**
  String get farms;

  /// No description provided for @allFarms.
  ///
  /// In en, this message translates to:
  /// **'All Farms'**
  String get allFarms;

  /// No description provided for @allFarmsDescription.
  ///
  /// In en, this message translates to:
  /// **'View and manage all your farms'**
  String get allFarmsDescription;

  /// No description provided for @addFarm.
  ///
  /// In en, this message translates to:
  /// **'Add Farm'**
  String get addFarm;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @farmSize.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farmSize;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @livestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get livestock;

  /// No description provided for @addLivestock.
  ///
  /// In en, this message translates to:
  /// **'Add Livestock'**
  String get addLivestock;

  /// No description provided for @tagId.
  ///
  /// In en, this message translates to:
  /// **'Tag ID'**
  String get tagId;

  /// No description provided for @animalName.
  ///
  /// In en, this message translates to:
  /// **'Animal Name'**
  String get animalName;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @farmDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Farm Data Not Found'**
  String get farmDataNotFound;

  /// No description provided for @fullNameText.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameText;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorksTitle;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @digitalTagging.
  ///
  /// In en, this message translates to:
  /// **'Digital Tagging'**
  String get digitalTagging;

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analytics;

  /// No description provided for @analyticsReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analyticsReports;

  /// No description provided for @offlineCapability.
  ///
  /// In en, this message translates to:
  /// **'Offline Capability'**
  String get offlineCapability;

  /// No description provided for @livestockTraceabilitySystemText.
  ///
  /// In en, this message translates to:
  /// **'Livestock Traceability System'**
  String get livestockTraceabilitySystemText;

  /// No description provided for @purposeText.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purposeText;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @systemTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag & Seal Livestock System'**
  String get systemTitle;

  /// No description provided for @systemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive digital solution for livestock management'**
  String get systemSubtitle;

  /// No description provided for @digitalTaggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Tag your livestock with unique identifiers for easy tracking and management'**
  String get digitalTaggingDesc;

  /// Health records description
  ///
  /// In en, this message translates to:
  /// **'Maintain detailed health records including vaccinations, medications, treatments, and medical history'**
  String get healthRecordsDesc;

  /// No description provided for @analyticsReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get insights into your farm performance with detailed analytics and reports'**
  String get analyticsReportsDesc;

  /// No description provided for @offlineCapabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Work offline and sync your data automatically when internet is available'**
  String get offlineCapabilityDesc;

  /// No description provided for @registerFarm.
  ///
  /// In en, this message translates to:
  /// **'Register Your Farm'**
  String get registerFarm;

  /// No description provided for @registerFarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your farm profile with location details and farm information'**
  String get registerFarmDesc;

  /// No description provided for @addLivestockDesc.
  ///
  /// In en, this message translates to:
  /// **'Register your animals with digital tags and basic information'**
  String get addLivestockDesc;

  /// No description provided for @trackManage.
  ///
  /// In en, this message translates to:
  /// **'Track & Manage'**
  String get trackManage;

  /// No description provided for @trackManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Record health events, breeding, feeding, and other activities'**
  String get trackManageDesc;

  /// No description provided for @syncAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Sync & Analyze'**
  String get syncAnalyze;

  /// No description provided for @syncAnalyzeDesc.
  ///
  /// In en, this message translates to:
  /// **'Sync your data to the cloud and view analytics on your farm performance'**
  String get syncAnalyzeDesc;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It!'**
  String get gotIt;

  /// No description provided for @manageAndTrackLivestockText.
  ///
  /// In en, this message translates to:
  /// **'Manage and track all your livestock'**
  String get manageAndTrackLivestockText;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @unknownFarm.
  ///
  /// In en, this message translates to:
  /// **'Unknown Farm'**
  String get unknownFarm;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// No description provided for @tapForMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for more details'**
  String get tapForMoreDetails;

  /// No description provided for @addFirstLivestockMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first livestock to get started'**
  String get addFirstLivestockMessage;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @sortAtoZ.
  ///
  /// In en, this message translates to:
  /// **'Sort A to Z'**
  String get sortAtoZ;

  /// No description provided for @sortZtoA.
  ///
  /// In en, this message translates to:
  /// **'Sort Z to A'**
  String get sortZtoA;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @livestockDetails.
  ///
  /// In en, this message translates to:
  /// **'Livestock Details'**
  String get livestockDetails;

  /// No description provided for @invalidFarmId.
  ///
  /// In en, this message translates to:
  /// **'Invalid farm ID'**
  String get invalidFarmId;

  /// No description provided for @failedToMarkFarmForDeletion.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark farm for deletion'**
  String get failedToMarkFarmForDeletion;

  /// No description provided for @errorDeletingFarm.
  ///
  /// In en, this message translates to:
  /// **'Error deleting farm'**
  String get errorDeletingFarm;

  /// No description provided for @tagYourLivestock.
  ///
  /// In en, this message translates to:
  /// **'Tag your Livestock'**
  String get tagYourLivestock;

  /// No description provided for @keepTrackFarms.
  ///
  /// In en, this message translates to:
  /// **'Keep Track of your Farms'**
  String get keepTrackFarms;

  /// No description provided for @inviteUsers.
  ///
  /// In en, this message translates to:
  /// **'Invite Users and Officers'**
  String get inviteUsers;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Please wait, syncing data...'**
  String get syncingData;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync successful'**
  String get syncSuccess;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// No description provided for @squareKilometers.
  ///
  /// In en, this message translates to:
  /// **'Square Kilometers'**
  String get squareKilometers;

  /// No description provided for @enterCredentialsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get enterCredentialsToContinue;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @addressInformation.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get addressInformation;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleName;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @phone1.
  ///
  /// In en, this message translates to:
  /// **'Primary Phone'**
  String get phone1;

  /// No description provided for @phone2.
  ///
  /// In en, this message translates to:
  /// **'Secondary Phone'**
  String get phone2;

  /// No description provided for @physicalAddress.
  ///
  /// In en, this message translates to:
  /// **'Physical Address'**
  String get physicalAddress;

  /// No description provided for @farmerOrganizationMembership.
  ///
  /// In en, this message translates to:
  /// **'Farmer Organization Membership'**
  String get farmerOrganizationMembership;

  /// No description provided for @identityCardType.
  ///
  /// In en, this message translates to:
  /// **'Identity Card Type'**
  String get identityCardType;

  /// No description provided for @identityNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity Number'**
  String get identityNumber;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @schoolLevel.
  ///
  /// In en, this message translates to:
  /// **'School Level'**
  String get schoolLevel;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @ward.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get ward;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @farmerType.
  ///
  /// In en, this message translates to:
  /// **'Farmer Type'**
  String get farmerType;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// No description provided for @secondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get secondaryColor;

  /// No description provided for @selectPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Select Primary Color'**
  String get selectPrimaryColor;

  /// No description provided for @selectSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Select Secondary Color'**
  String get selectSecondaryColor;

  /// No description provided for @colorInformation.
  ///
  /// In en, this message translates to:
  /// **'Color Information'**
  String get colorInformation;

  /// No description provided for @colorInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select primary and secondary colors (optional)'**
  String get colorInformationSubtitle;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorGray;

  /// No description provided for @colorGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get colorGrey;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorTan.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorTan;

  /// No description provided for @colorBeige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get colorBeige;

  /// No description provided for @colorCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get colorCream;

  /// No description provided for @colorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get colorGold;

  /// No description provided for @colorSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get colorSilver;

  /// No description provided for @colorMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get colorMixed;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @secondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// No description provided for @diploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get diploma;

  /// No description provided for @degree.
  ///
  /// In en, this message translates to:
  /// **'Degree'**
  String get degree;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @phd.
  ///
  /// In en, this message translates to:
  /// **'PhD'**
  String get phd;

  /// No description provided for @smallScale.
  ///
  /// In en, this message translates to:
  /// **'Small Scale'**
  String get smallScale;

  /// No description provided for @mediumScale.
  ///
  /// In en, this message translates to:
  /// **'Medium Scale'**
  String get mediumScale;

  /// No description provided for @largeScale.
  ///
  /// In en, this message translates to:
  /// **'Large Scale'**
  String get largeScale;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @subsistence.
  ///
  /// In en, this message translates to:
  /// **'Subsistence'**
  String get subsistence;

  /// No description provided for @pleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select...'**
  String get pleaseSelect;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterSurname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your surname'**
  String get pleaseEnterSurname;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get pleaseSelectGender;

  /// No description provided for @pleaseSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get pleaseSelectDateOfBirth;

  /// No description provided for @pleaseEnterIdentityNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your identity number'**
  String get pleaseEnterIdentityNumber;

  /// No description provided for @pleaseSelectIdentityType.
  ///
  /// In en, this message translates to:
  /// **'Please select identity card type'**
  String get pleaseSelectIdentityType;

  /// No description provided for @pleaseSelectSchoolLevel.
  ///
  /// In en, this message translates to:
  /// **'Please select your school level'**
  String get pleaseSelectSchoolLevel;

  /// No description provided for @pleaseSelectFarmerType.
  ///
  /// In en, this message translates to:
  /// **'Please select farmer type'**
  String get pleaseSelectFarmerType;

  /// No description provided for @personalInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalInfoStep;

  /// No description provided for @personalInfoStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get personalInfoStepSubtitle;

  /// No description provided for @contactInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactInfoStep;

  /// No description provided for @contactInfoStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Phone & email'**
  String get contactInfoStepSubtitle;

  /// No description provided for @identityInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identityInfoStep;

  /// No description provided for @identityInfoStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ID details'**
  String get identityInfoStepSubtitle;

  /// No description provided for @locationInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationInfoStep;

  /// No description provided for @locationInfoStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get locationInfoStepSubtitle;

  /// No description provided for @additionalInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get additionalInfoStep;

  /// No description provided for @additionalInfoStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Final details'**
  String get additionalInfoStepSubtitle;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterMiddleName.
  ///
  /// In en, this message translates to:
  /// **'Enter your middle name (optional)'**
  String get enterMiddleName;

  /// No description provided for @enterSurname.
  ///
  /// In en, this message translates to:
  /// **'Enter your surname'**
  String get enterSurname;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get selectGender;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterAlternatePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter alternate phone (optional)'**
  String get enterAlternatePhone;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPhysicalAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your physical address'**
  String get enterPhysicalAddress;

  /// No description provided for @selectIdType.
  ///
  /// In en, this message translates to:
  /// **'Select ID type'**
  String get selectIdType;

  /// No description provided for @enterIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your ID number'**
  String get enterIdNumber;

  /// No description provided for @selectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Select education level'**
  String get selectEducationLevel;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegion;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select district'**
  String get selectDistrict;

  /// No description provided for @selectWard.
  ///
  /// In en, this message translates to:
  /// **'Select ward'**
  String get selectWard;

  /// No description provided for @selectVillage.
  ///
  /// In en, this message translates to:
  /// **'Select village'**
  String get selectVillage;

  /// No description provided for @selectStreet.
  ///
  /// In en, this message translates to:
  /// **'Select street'**
  String get selectStreet;

  /// No description provided for @selectFarmerType.
  ///
  /// In en, this message translates to:
  /// **'Select farmer type'**
  String get selectFarmerType;

  /// No description provided for @enterOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Enter organization name (optional)'**
  String get enterOrganizationName;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @voterId.
  ///
  /// In en, this message translates to:
  /// **'Voter ID'**
  String get voterId;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificate;

  /// No description provided for @tanzania.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get tanzania;

  /// No description provided for @reviewInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Please review all information before submitting. You will receive a confirmation email after successful registration.'**
  String get reviewInfoMessage;

  /// No description provided for @confirmRegister.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to register?'**
  String get confirmRegister;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @surnameRequired.
  ///
  /// In en, this message translates to:
  /// **'Surname is required'**
  String get surnameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @validPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validPhoneRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @physicalAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Physical address is required'**
  String get physicalAddressRequired;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Gender is required'**
  String get genderRequired;

  /// No description provided for @dateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateOfBirthRequired;

  /// No description provided for @identityTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Identity card type is required'**
  String get identityTypeRequired;

  /// No description provided for @identityNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Identity number is required'**
  String get identityNumberRequired;

  /// No description provided for @educationLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Education level is required'**
  String get educationLevelRequired;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryRequired;

  /// No description provided for @regionRequired.
  ///
  /// In en, this message translates to:
  /// **'Region is required'**
  String get regionRequired;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get districtRequired;

  /// No description provided for @wardRequired.
  ///
  /// In en, this message translates to:
  /// **'Ward is required'**
  String get wardRequired;

  /// No description provided for @villageRequired.
  ///
  /// In en, this message translates to:
  /// **'Village is required'**
  String get villageRequired;

  /// No description provided for @streetRequired.
  ///
  /// In en, this message translates to:
  /// **'Street is required'**
  String get streetRequired;

  /// No description provided for @farmerTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Farmer type is required'**
  String get farmerTypeRequired;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kiswahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get kiswahili;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like to receive your password reset instructions'**
  String get forgotPasswordDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailAddressSwahili.
  ///
  /// In en, this message translates to:
  /// **'Barua Pepe'**
  String get emailAddressSwahili;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberSwahili.
  ///
  /// In en, this message translates to:
  /// **'Namba ya Simu'**
  String get phoneNumberSwahili;

  /// No description provided for @recoverViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Recover via Email'**
  String get recoverViaEmail;

  /// No description provided for @recoverViaPhone.
  ///
  /// In en, this message translates to:
  /// **'Recover via Phone'**
  String get recoverViaPhone;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get enterYourPhone;

  /// No description provided for @otpWillBeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 6-digit OTP code to your email address'**
  String get otpWillBeSentToEmail;

  /// No description provided for @otpWillBeSentToPhone.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 6-digit OTP code to your phone number'**
  String get otpWillBeSentToPhone;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpExpiresIn10Minutes.
  ///
  /// In en, this message translates to:
  /// **'OTP code expires in 10 minutes'**
  String get otpExpiresIn10Minutes;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOtpCode;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to'**
  String get otpSentTo;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @pleaseEnterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 6-digit OTP'**
  String get pleaseEnterCompleteOtp;

  /// No description provided for @otpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccessfully;

  /// No description provided for @failedToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get failedToResendOtp;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! You can now login with your new password.'**
  String get passwordResetSuccessfully;

  /// No description provided for @failedToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password'**
  String get failedToResetPassword;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noInternetConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings and try again'**
  String get noInternetConnectionMessage;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLost;

  /// No description provided for @connectionLostMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection was lost during the operation. Please try again.'**
  String get connectionLostMessage;

  /// No description provided for @fetchingData.
  ///
  /// In en, this message translates to:
  /// **'Fetching Data'**
  String get fetchingData;

  /// No description provided for @loadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Loading Locations...'**
  String get loadingLocations;

  /// No description provided for @locationsLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Locations loaded successfully'**
  String get locationsLoadedSuccessfully;

  /// No description provided for @failedToLoadLocations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load locations'**
  String get failedToLoadLocations;

  /// No description provided for @editFarmUserText.
  ///
  /// In en, this message translates to:
  /// **'Update Farm User'**
  String get editFarmUserText;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating your account...'**
  String get creatingAccount;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to Tag & Seal.'**
  String get registrationSuccessful;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging you in...'**
  String get loggingIn;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging you out...'**
  String get loggingOut;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @livestocks.
  ///
  /// In en, this message translates to:
  /// **'Livestocks'**
  String get livestocks;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @qrScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get qrScanner;

  /// No description provided for @qrScannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Scanner functionality will be implemented here'**
  String get qrScannerDescription;

  /// No description provided for @dashboardScreen.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Screen'**
  String get dashboardScreen;

  /// No description provided for @allLivestocksScreen.
  ///
  /// In en, this message translates to:
  /// **'All Livestocks Screen'**
  String get allLivestocksScreen;

  /// No description provided for @allEventsScreen.
  ///
  /// In en, this message translates to:
  /// **'All Events Screen'**
  String get allEventsScreen;

  /// No description provided for @userProfileScreen.
  ///
  /// In en, this message translates to:
  /// **'User Profile Screen'**
  String get userProfileScreen;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @homeText.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeText;

  /// No description provided for @vaccinesText.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccinesText;

  /// No description provided for @invitedUsersText.
  ///
  /// In en, this message translates to:
  /// **'Invited Users'**
  String get invitedUsersText;

  /// No description provided for @invitedOfficersText.
  ///
  /// In en, this message translates to:
  /// **'Invited Officers'**
  String get invitedOfficersText;

  /// No description provided for @farmManagementText.
  ///
  /// In en, this message translates to:
  /// **'Farm Management'**
  String get farmManagementText;

  /// No description provided for @createNewFarmText.
  ///
  /// In en, this message translates to:
  /// **'Create New Farm'**
  String get createNewFarmText;

  /// No description provided for @inviteOfficerText.
  ///
  /// In en, this message translates to:
  /// **'Invite Officer'**
  String get inviteOfficerText;

  /// No description provided for @inviteFarmUserText.
  ///
  /// In en, this message translates to:
  /// **'Invite Farm User'**
  String get inviteFarmUserText;

  /// No description provided for @collaborateText.
  ///
  /// In en, this message translates to:
  /// **'Collaborate'**
  String get collaborateText;

  /// No description provided for @setNewFarmText.
  ///
  /// In en, this message translates to:
  /// **'Set New Farm'**
  String get setNewFarmText;

  /// No description provided for @addExtensionOfficerText.
  ///
  /// In en, this message translates to:
  /// **'Add Extension Officer'**
  String get addExtensionOfficerText;

  /// Title for the invited extension officers list screen
  ///
  /// In en, this message translates to:
  /// **'Invited Extension Officers'**
  String get invitedExtensionOfficers;

  /// No description provided for @farmsText.
  ///
  /// In en, this message translates to:
  /// **'Farms'**
  String get farmsText;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeText;

  /// No description provided for @darkModeText.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeText;

  /// No description provided for @registerNewFarm.
  ///
  /// In en, this message translates to:
  /// **'Register New Farm'**
  String get registerNewFarm;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @farmNameReferenceDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm name and reference details'**
  String get farmNameReferenceDetails;

  /// No description provided for @sizeMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Size & Location'**
  String get sizeMeasurements;

  /// No description provided for @farmMeasurementsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Farm measurements and coordinates'**
  String get farmMeasurementsCoordinates;

  /// No description provided for @addressLegal.
  ///
  /// In en, this message translates to:
  /// **'Address & Legal'**
  String get addressLegal;

  /// No description provided for @physicalLocationLegalStatus.
  ///
  /// In en, this message translates to:
  /// **'Physical location and legal status'**
  String get physicalLocationLegalStatus;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm Details'**
  String get farmDetails;

  /// No description provided for @enterFarmName.
  ///
  /// In en, this message translates to:
  /// **'Enter farm name'**
  String get enterFarmName;

  /// No description provided for @farmNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm name is required'**
  String get farmNameRequired;

  /// No description provided for @farmNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Farm name must be at least 3 characters'**
  String get farmNameMinLength;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get referenceNumber;

  /// No description provided for @enterReferenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter reference number'**
  String get enterReferenceNumber;

  /// No description provided for @referenceNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Reference number is required'**
  String get referenceNumberRequired;

  /// No description provided for @regionalRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Regional Registration Number'**
  String get regionalRegistrationNumber;

  /// No description provided for @enterRegionalRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter regional registration number'**
  String get enterRegionalRegNumber;

  /// No description provided for @regionalRegNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Regional registration number is required'**
  String get regionalRegNumberRequired;

  /// No description provided for @ensureReferenceAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure all reference numbers are accurate and match official records.'**
  String get ensureReferenceAccuracy;

  /// No description provided for @farmMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Farm Measurements'**
  String get farmMeasurements;

  /// No description provided for @enterSize.
  ///
  /// In en, this message translates to:
  /// **'Enter size'**
  String get enterSize;

  /// No description provided for @sizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Size required'**
  String get sizeRequired;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter valid number'**
  String get enterValidNumber;

  /// No description provided for @sizeMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Size must be greater than 0'**
  String get sizeMustBePositive;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectUnit;

  /// No description provided for @unitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit required'**
  String get unitRequired;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @hectares.
  ///
  /// In en, this message translates to:
  /// **'Hectares'**
  String get hectares;

  /// No description provided for @squareMeters.
  ///
  /// In en, this message translates to:
  /// **'Square Meters'**
  String get squareMeters;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS Coordinates'**
  String get gpsCoordinates;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @latitudeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. -6.7924'**
  String get latitudeExample;

  /// No description provided for @latitudeRequired.
  ///
  /// In en, this message translates to:
  /// **'Latitude is required'**
  String get latitudeRequired;

  /// No description provided for @enterValidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Enter valid latitude'**
  String get enterValidLatitude;

  /// No description provided for @latitudeRange.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get latitudeRange;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @longitudeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 39.2083'**
  String get longitudeExample;

  /// No description provided for @longitudeRequired.
  ///
  /// In en, this message translates to:
  /// **'Longitude is required'**
  String get longitudeRequired;

  /// No description provided for @enterValidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Enter valid longitude'**
  String get enterValidLongitude;

  /// No description provided for @longitudeRange.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get longitudeRange;

  /// No description provided for @getCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get getCurrentLocation;

  /// No description provided for @useGpsAutoFill.
  ///
  /// In en, this message translates to:
  /// **'Tap here to use your device GPS to auto-fill coordinates'**
  String get useGpsAutoFill;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @legalInformation.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInformation;

  /// No description provided for @legalStatus.
  ///
  /// In en, this message translates to:
  /// **'Legal Status'**
  String get legalStatus;

  /// No description provided for @selectLegalStatus.
  ///
  /// In en, this message translates to:
  /// **'Select legal status'**
  String get selectLegalStatus;

  /// No description provided for @legalStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Legal status is required'**
  String get legalStatusRequired;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @leased.
  ///
  /// In en, this message translates to:
  /// **'Leased'**
  String get leased;

  /// No description provided for @rented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get rented;

  /// No description provided for @cooperative.
  ///
  /// In en, this message translates to:
  /// **'Cooperative'**
  String get cooperative;

  /// No description provided for @reviewBeforeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review all information before submitting. You can edit later if needed.'**
  String get reviewBeforeSubmit;

  /// No description provided for @farmRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm registered successfully!'**
  String get farmRegisteredSuccessfully;

  /// No description provided for @farmRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Farm registration failed'**
  String get farmRegistrationFailed;

  /// No description provided for @farmUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm updated successfully!'**
  String get farmUpdatedSuccessfully;

  /// No description provided for @farmUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Farm update failed'**
  String get farmUpdateFailed;

  /// No description provided for @confirmRegisterFarm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to register this farm?'**
  String get confirmRegisterFarm;

  /// No description provided for @confirmUpdateFarm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this farm?'**
  String get confirmUpdateFarm;

  /// No description provided for @gpsCoordinatesRetrieved.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates retrieved successfully!'**
  String get gpsCoordinatesRetrieved;

  /// No description provided for @fetchingGpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Fetching GPS coordinates...'**
  String get fetchingGpsCoordinates;

  /// No description provided for @loadingFarms.
  ///
  /// In en, this message translates to:
  /// **'Loading farms...'**
  String get loadingFarms;

  /// No description provided for @farmLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm loaded successfully'**
  String get farmLoadedSuccessfully;

  /// No description provided for @farmLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farm'**
  String get farmLoadFailed;

  /// No description provided for @farmsLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farms loaded successfully'**
  String get farmsLoadedSuccessfully;

  /// No description provided for @farmsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farms'**
  String get farmsLoadFailed;

  /// No description provided for @loadingFarmWithLivestock.
  ///
  /// In en, this message translates to:
  /// **'Loading farm with livestock...'**
  String get loadingFarmWithLivestock;

  /// No description provided for @farmWithLivestockLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm with livestock loaded successfully'**
  String get farmWithLivestockLoadedSuccessfully;

  /// No description provided for @eventsLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Events loaded successfully'**
  String get eventsLoadedSuccessfully;

  /// No description provided for @allEventsLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'All events loaded successfully'**
  String get allEventsLoadedSuccessfully;

  /// No description provided for @eventsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load events. Please try again.'**
  String get eventsLoadFailed;

  /// No description provided for @feedingLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Feeding log saved successfully'**
  String get feedingLogSaved;

  /// No description provided for @feedingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save feeding log. Please try again.'**
  String get feedingLogSaveFailed;

  /// No description provided for @birthEventSaved.
  ///
  /// In en, this message translates to:
  /// **'Birth event saved successfully'**
  String get birthEventSaved;

  /// No description provided for @birthEventUpdated.
  ///
  /// In en, this message translates to:
  /// **'Birth event updated successfully'**
  String get birthEventUpdated;

  /// No description provided for @birthEventSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save birth event. Please try again.'**
  String get birthEventSaveFailed;

  /// No description provided for @birthEventUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update birth event. Please try again.'**
  String get birthEventUpdateFailed;

  /// No description provided for @abortedPregnancySaved.
  ///
  /// In en, this message translates to:
  /// **'Aborted pregnancy saved successfully'**
  String get abortedPregnancySaved;

  /// No description provided for @abortedPregnancyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Aborted pregnancy updated successfully'**
  String get abortedPregnancyUpdated;

  /// No description provided for @abortedPregnancySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save aborted pregnancy. Please try again.'**
  String get abortedPregnancySaveFailed;

  /// No description provided for @abortedPregnancyUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update aborted pregnancy. Please try again.'**
  String get abortedPregnancyUpdateFailed;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @addFeeding.
  ///
  /// In en, this message translates to:
  /// **'Add Feeding'**
  String get addFeeding;

  /// No description provided for @feedingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture feeding details for accurate records'**
  String get feedingDetailsSubtitle;

  /// No description provided for @feedingNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide optional context and notes'**
  String get feedingNotesSubtitle;

  /// No description provided for @feedingDetails.
  ///
  /// In en, this message translates to:
  /// **'Feeding Details'**
  String get feedingDetails;

  /// No description provided for @feedingType.
  ///
  /// In en, this message translates to:
  /// **'Feeding Type'**
  String get feedingType;

  /// No description provided for @selectFeedingType.
  ///
  /// In en, this message translates to:
  /// **'Select feeding type'**
  String get selectFeedingType;

  /// No description provided for @feedingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Feeding type is required'**
  String get feedingTypeRequired;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @nextFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'Next feeding time'**
  String get nextFeedingTime;

  /// No description provided for @enterNextFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'Select next feeding time'**
  String get enterNextFeedingTime;

  /// No description provided for @nextFeedingTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Next feeding time is required'**
  String get nextFeedingTimeRequired;

  /// No description provided for @feedingReminder.
  ///
  /// In en, this message translates to:
  /// **'Feeding Reminder'**
  String get feedingReminder;

  /// No description provided for @timeToFeedLivestock.
  ///
  /// In en, this message translates to:
  /// **'Time to feed livestock'**
  String get timeToFeedLivestock;

  /// No description provided for @previousWeight.
  ///
  /// In en, this message translates to:
  /// **'Old weight'**
  String get previousWeight;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'New weight'**
  String get currentWeight;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at'**
  String get updatedAt;

  /// No description provided for @nextAdministrationDate.
  ///
  /// In en, this message translates to:
  /// **'Next administration date'**
  String get nextAdministrationDate;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @ensureFeedingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the feeding information is accurate before saving.'**
  String get ensureFeedingDetailsAccuracy;

  /// No description provided for @ensureWeightDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the weight information is accurate before saving.'**
  String get ensureWeightDetailsAccuracy;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @enterRemarksOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter remarks (optional)'**
  String get enterRemarksOptional;

  /// No description provided for @feedingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Use notes to record any special observations made during feeding.'**
  String get feedingNotesInfo;

  /// No description provided for @confirmUpdateFeeding.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this feeding log?'**
  String get confirmUpdateFeeding;

  /// No description provided for @confirmSaveFeeding.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this feeding log?'**
  String get confirmSaveFeeding;

  /// No description provided for @confirmSaveWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this weight change?'**
  String get confirmSaveWeightChange;

  /// No description provided for @confirmUpdateWeightChange.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this weight change?'**
  String get confirmUpdateWeightChange;

  /// No description provided for @recordsAndLogs.
  ///
  /// In en, this message translates to:
  /// **'Records and Logs'**
  String get recordsAndLogs;

  /// No description provided for @insemination.
  ///
  /// In en, this message translates to:
  /// **'Insemination'**
  String get insemination;

  /// No description provided for @pregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get pregnancy;

  /// No description provided for @deworming.
  ///
  /// In en, this message translates to:
  /// **'Deworming'**
  String get deworming;

  /// No description provided for @addDeworming.
  ///
  /// In en, this message translates to:
  /// **'Add Deworming'**
  String get addDeworming;

  /// No description provided for @dewormingDetails.
  ///
  /// In en, this message translates to:
  /// **'Deworming Details'**
  String get dewormingDetails;

  /// No description provided for @dosageDetails.
  ///
  /// In en, this message translates to:
  /// **'Dosage Details'**
  String get dosageDetails;

  /// No description provided for @administrationRoute.
  ///
  /// In en, this message translates to:
  /// **'Administration route'**
  String get administrationRoute;

  /// No description provided for @selectAdministrationRoute.
  ///
  /// In en, this message translates to:
  /// **'Select administration route'**
  String get selectAdministrationRoute;

  /// No description provided for @administrationRouteRequired.
  ///
  /// In en, this message translates to:
  /// **'Administration route is required'**
  String get administrationRouteRequired;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @selectMedicine.
  ///
  /// In en, this message translates to:
  /// **'Select medicine'**
  String get selectMedicine;

  /// No description provided for @medicineRequired.
  ///
  /// In en, this message translates to:
  /// **'Medicine is required'**
  String get medicineRequired;

  /// No description provided for @treatmentProvider.
  ///
  /// In en, this message translates to:
  /// **'Treatment provider'**
  String get treatmentProvider;

  /// No description provided for @selectTreatmentProvider.
  ///
  /// In en, this message translates to:
  /// **'Select treatment provider'**
  String get selectTreatmentProvider;

  /// No description provided for @treatmentProviderNone.
  ///
  /// In en, this message translates to:
  /// **'No provider'**
  String get treatmentProviderNone;

  /// No description provided for @treatmentProviderVet.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get treatmentProviderVet;

  /// No description provided for @treatmentProviderExtensionOfficer.
  ///
  /// In en, this message translates to:
  /// **'Extension officer'**
  String get treatmentProviderExtensionOfficer;

  /// No description provided for @medicalLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License number'**
  String get medicalLicenseNumber;

  /// No description provided for @enterMedicalLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter license number'**
  String get enterMedicalLicenseNumber;

  /// No description provided for @medicalLicenseNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'License number is required'**
  String get medicalLicenseNumberRequired;

  /// No description provided for @medicalLicenseNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'License number must contain digits only'**
  String get medicalLicenseNumberInvalid;

  /// No description provided for @vetLicense.
  ///
  /// In en, this message translates to:
  /// **'Vet license'**
  String get vetLicense;

  /// No description provided for @extensionOfficerLicense.
  ///
  /// In en, this message translates to:
  /// **'Extension officer license'**
  String get extensionOfficerLicense;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @enterDose.
  ///
  /// In en, this message translates to:
  /// **'Enter dose'**
  String get enterDose;

  /// No description provided for @doseRequired.
  ///
  /// In en, this message translates to:
  /// **'Dose is required'**
  String get doseRequired;

  /// No description provided for @ensureDewormingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the deworming information is accurate before saving.'**
  String get ensureDewormingDetailsAccuracy;

  /// No description provided for @dewormingReminder.
  ///
  /// In en, this message translates to:
  /// **'Deworming Reminder'**
  String get dewormingReminder;

  /// No description provided for @timeToDewormLivestock.
  ///
  /// In en, this message translates to:
  /// **'Time to deworm livestock'**
  String get timeToDewormLivestock;

  /// Treatment reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Treatment Reminder'**
  String get treatmentReminder;

  /// Treatment reminder notification description
  ///
  /// In en, this message translates to:
  /// **'Time to treat livestock'**
  String get timeToTreatLivestock;

  /// Notification title for prepuce (sheath) condition follow-up reminder
  ///
  /// In en, this message translates to:
  /// **'Prepuce follow-up'**
  String get prepuceConditionFollowUpReminder;

  /// Notification body for prepuce condition follow-up reminder
  ///
  /// In en, this message translates to:
  /// **'Scheduled follow-up for this animal\'s prepuce (sheath) condition.'**
  String get prepuceConditionFollowUpReminderBody;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight Change'**
  String get weightChange;

  /// No description provided for @disposalTransfer.
  ///
  /// In en, this message translates to:
  /// **'Disposal / Transfer'**
  String get disposalTransfer;

  /// No description provided for @calving.
  ///
  /// In en, this message translates to:
  /// **'Calving'**
  String get calving;

  /// No description provided for @farrowing.
  ///
  /// In en, this message translates to:
  /// **'Farrowing'**
  String get farrowing;

  /// No description provided for @birthEvent.
  ///
  /// In en, this message translates to:
  /// **'Birth Event'**
  String get birthEvent;

  /// No description provided for @abortedPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Aborted Pregnancy'**
  String get abortedPregnancy;

  /// No description provided for @birthType.
  ///
  /// In en, this message translates to:
  /// **'Birth Type'**
  String get birthType;

  /// No description provided for @birthProblem.
  ///
  /// In en, this message translates to:
  /// **'Birth Problem'**
  String get birthProblem;

  /// No description provided for @abortionDate.
  ///
  /// In en, this message translates to:
  /// **'Abortion Date'**
  String get abortionDate;

  /// No description provided for @lessThanAMonth.
  ///
  /// In en, this message translates to:
  /// **'Less than a month'**
  String get lessThanAMonth;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @dryoff.
  ///
  /// In en, this message translates to:
  /// **'Dryoff'**
  String get dryoff;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// Treatment label
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// Add treatment log button
  ///
  /// In en, this message translates to:
  /// **'Add treatment log'**
  String get addTreatment;

  /// Next medication date label
  ///
  /// In en, this message translates to:
  /// **'Next medication date'**
  String get nextMedicationDate;

  /// Select next medication date hint
  ///
  /// In en, this message translates to:
  /// **'Select next medication date'**
  String get selectNextMedicationDate;

  /// Treatment log saved success message
  ///
  /// In en, this message translates to:
  /// **'Treatment log saved successfully'**
  String get treatmentLogSaved;

  /// Treatment log save failed error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save treatment log. Please try again.'**
  String get treatmentLogSaveFailed;

  /// No description provided for @milking.
  ///
  /// In en, this message translates to:
  /// **'Milking'**
  String get milking;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @logContextMissing.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this log because farm or livestock details are missing.'**
  String get logContextMissing;

  /// No description provided for @selectFarm.
  ///
  /// In en, this message translates to:
  /// **'Select farm'**
  String get selectFarm;

  /// No description provided for @farmRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm is required'**
  String get farmRequired;

  /// No description provided for @selectLivestock.
  ///
  /// In en, this message translates to:
  /// **'Select livestock'**
  String get selectLivestock;

  /// No description provided for @livestockRequired.
  ///
  /// In en, this message translates to:
  /// **'Livestock is required'**
  String get livestockRequired;

  /// No description provided for @weightLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight change log saved successfully'**
  String get weightLogSaved;

  /// No description provided for @weightLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save weight change log. Please try again.'**
  String get weightLogSaveFailed;

  /// No description provided for @dewormingLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Deworming log saved successfully'**
  String get dewormingLogSaved;

  /// No description provided for @dewormingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save deworming log. Please try again.'**
  String get dewormingLogSaveFailed;

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Medication details'**
  String get medicationDetails;

  /// No description provided for @medicationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture dosage, disease, and scheduling information.'**
  String get medicationDetailsSubtitle;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add medication log'**
  String get addMedication;

  /// No description provided for @medicationLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Medication log saved successfully'**
  String get medicationLogSaved;

  /// No description provided for @medicationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save medication log. Please try again.'**
  String get medicationLogSaveFailed;

  /// No description provided for @medicationContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide context about this medication treatment.'**
  String get medicationContextInfo;

  /// No description provided for @quantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Quantity unit'**
  String get quantityUnit;

  /// No description provided for @selectQuantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Select quantity unit'**
  String get selectQuantityUnit;

  /// No description provided for @withdrawalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal period'**
  String get withdrawalPeriod;

  /// No description provided for @enterWithdrawalPeriodOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter withdrawal period (optional)'**
  String get enterWithdrawalPeriodOptional;

  /// No description provided for @withdrawalUnit.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal unit'**
  String get withdrawalUnit;

  /// No description provided for @selectWithdrawalUnit.
  ///
  /// In en, this message translates to:
  /// **'Select withdrawal unit'**
  String get selectWithdrawalUnit;

  /// No description provided for @diseaseOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'Diseases not available. Sync reference data first.'**
  String get diseaseOptionsMissing;

  /// No description provided for @diseaseId.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get diseaseId;

  /// No description provided for @selectDisease.
  ///
  /// In en, this message translates to:
  /// **'Select disease'**
  String get selectDisease;

  /// The date when the event actually occurred
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get eventDate;

  /// Hint text for event date picker
  ///
  /// In en, this message translates to:
  /// **'Select when the event occurred'**
  String get selectEventDate;

  /// No description provided for @medicationDate.
  ///
  /// In en, this message translates to:
  /// **'Medication date'**
  String get medicationDate;

  /// No description provided for @selectMedicationDate.
  ///
  /// In en, this message translates to:
  /// **'Select medication date'**
  String get selectMedicationDate;

  /// No description provided for @medicationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide any additional notes about this medication.'**
  String get medicationNotesInfo;

  /// No description provided for @confirmUpdateMedication.
  ///
  /// In en, this message translates to:
  /// **'Update medication record?'**
  String get confirmUpdateMedication;

  /// No description provided for @confirmSaveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save medication record?'**
  String get confirmSaveMedication;

  /// Confirmation message for updating treatment record
  ///
  /// In en, this message translates to:
  /// **'Update treatment record?'**
  String get confirmUpdateTreatment;

  /// Confirmation message for saving treatment record
  ///
  /// In en, this message translates to:
  /// **'Save treatment record?'**
  String get confirmSaveTreatment;

  /// No description provided for @quantityUnitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get quantityUnitMl;

  /// No description provided for @quantityUnitL.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get quantityUnitL;

  /// No description provided for @quantityUnitMg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get quantityUnitMg;

  /// No description provided for @quantityUnitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get quantityUnitG;

  /// No description provided for @quantityUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get quantityUnitKg;

  /// No description provided for @withdrawalUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get withdrawalUnitMinutes;

  /// No description provided for @withdrawalUnitHours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get withdrawalUnitHours;

  /// No description provided for @withdrawalUnitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get withdrawalUnitDays;

  /// No description provided for @withdrawalUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get withdrawalUnitWeeks;

  /// No description provided for @withdrawalUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get withdrawalUnitMonths;

  /// No description provided for @withdrawalUnitYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get withdrawalUnitYears;

  /// No description provided for @vaccinationDetails.
  ///
  /// In en, this message translates to:
  /// **'Vaccination details'**
  String get vaccinationDetails;

  /// No description provided for @vaccinationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record vaccine, disease, and schedule info.'**
  String get vaccinationDetailsSubtitle;

  /// No description provided for @addVaccination.
  ///
  /// In en, this message translates to:
  /// **'Add vaccination log'**
  String get addVaccination;

  /// No description provided for @vaccinationNumber.
  ///
  /// In en, this message translates to:
  /// **'Vaccination number'**
  String get vaccinationNumber;

  /// No description provided for @enterVaccinationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter vaccination number'**
  String get enterVaccinationNumber;

  /// No description provided for @selectVaccine.
  ///
  /// In en, this message translates to:
  /// **'Select vaccine'**
  String get selectVaccine;

  /// No description provided for @vaccinationStatus.
  ///
  /// In en, this message translates to:
  /// **'Vaccination status'**
  String get vaccinationStatus;

  /// No description provided for @vaccinationContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide context about this vaccination event.'**
  String get vaccinationContextInfo;

  /// No description provided for @vaccinationPersonnelDetails.
  ///
  /// In en, this message translates to:
  /// **'Personnel details'**
  String get vaccinationPersonnelDetails;

  /// No description provided for @enterVetLicenseOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter vet license (optional)'**
  String get enterVetLicenseOptional;

  /// No description provided for @enterExtensionOfficerLicenseOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter extension officer license (optional)'**
  String get enterExtensionOfficerLicenseOptional;

  /// No description provided for @vaccinationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add remarks about this vaccination.'**
  String get vaccinationNotesInfo;

  /// No description provided for @confirmUpdateVaccination.
  ///
  /// In en, this message translates to:
  /// **'Update vaccination log?'**
  String get confirmUpdateVaccination;

  /// No description provided for @confirmSaveVaccination.
  ///
  /// In en, this message translates to:
  /// **'Save vaccination log?'**
  String get confirmSaveVaccination;

  /// No description provided for @vaccinationLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Vaccination log saved successfully'**
  String get vaccinationLogSaved;

  /// No description provided for @vaccinationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save vaccination log. Please try again.'**
  String get vaccinationLogSaveFailed;

  /// No description provided for @vaccineOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'Vaccines not available. Sync vaccine reference data first.'**
  String get vaccineOptionsMissing;

  /// No description provided for @vaccineRequired.
  ///
  /// In en, this message translates to:
  /// **'Vaccine is required'**
  String get vaccineRequired;

  /// No description provided for @addDisposal.
  ///
  /// In en, this message translates to:
  /// **'Add disposal log'**
  String get addDisposal;

  /// No description provided for @disposalDetails.
  ///
  /// In en, this message translates to:
  /// **'Disposal details'**
  String get disposalDetails;

  /// No description provided for @disposalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture why and how the livestock was disposed.'**
  String get disposalDetailsSubtitle;

  /// No description provided for @disposalContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide the method, reason, and any supporting notes.'**
  String get disposalContextInfo;

  /// No description provided for @disposalReasons.
  ///
  /// In en, this message translates to:
  /// **'Disposal reasons'**
  String get disposalReasons;

  /// No description provided for @enterDisposalReasons.
  ///
  /// In en, this message translates to:
  /// **'Enter reasons for disposal'**
  String get enterDisposalReasons;

  /// No description provided for @disposalTypeOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'Disposal types unavailable. Sync reference data.'**
  String get disposalTypeOptionsMissing;

  /// No description provided for @disposalTypeId.
  ///
  /// In en, this message translates to:
  /// **'Disposal type'**
  String get disposalTypeId;

  /// No description provided for @selectDisposalType.
  ///
  /// In en, this message translates to:
  /// **'Select disposal type'**
  String get selectDisposalType;

  /// No description provided for @disposalTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Disposal type is required'**
  String get disposalTypeRequired;

  /// No description provided for @disposalStatus.
  ///
  /// In en, this message translates to:
  /// **'Disposal status'**
  String get disposalStatus;

  /// No description provided for @disposalNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add any remarks related to this disposal.'**
  String get disposalNotesInfo;

  /// No description provided for @confirmUpdateDisposal.
  ///
  /// In en, this message translates to:
  /// **'Update disposal log?'**
  String get confirmUpdateDisposal;

  /// No description provided for @confirmSaveDisposal.
  ///
  /// In en, this message translates to:
  /// **'Save disposal log?'**
  String get confirmSaveDisposal;

  /// No description provided for @disposalLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Disposal log saved successfully'**
  String get disposalLogSaved;

  /// No description provided for @disposalLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save disposal log. Please try again.'**
  String get disposalLogSaveFailed;

  /// No description provided for @addMilking.
  ///
  /// In en, this message translates to:
  /// **'Add milking log'**
  String get addMilking;

  /// No description provided for @milkingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture session details for this milking event.'**
  String get milkingDetailsSubtitle;

  /// No description provided for @milkingNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide lab readings and quality observations.'**
  String get milkingNotesSubtitle;

  /// No description provided for @milkingMethod.
  ///
  /// In en, this message translates to:
  /// **'Milking method'**
  String get milkingMethod;

  /// No description provided for @milkingMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Milking method is required'**
  String get milkingMethodRequired;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusNotActive.
  ///
  /// In en, this message translates to:
  /// **'Not active'**
  String get statusNotActive;

  /// No description provided for @ensureMilkingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the milking details are accurate before saving.'**
  String get ensureMilkingDetailsAccuracy;

  /// No description provided for @lactometerReading.
  ///
  /// In en, this message translates to:
  /// **'Lactometer reading'**
  String get lactometerReading;

  /// No description provided for @solids.
  ///
  /// In en, this message translates to:
  /// **'Solids'**
  String get solids;

  /// No description provided for @solidNonFat.
  ///
  /// In en, this message translates to:
  /// **'Solids non-fat'**
  String get solidNonFat;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @correctedLactometerReading.
  ///
  /// In en, this message translates to:
  /// **'Corrected lactometer reading'**
  String get correctedLactometerReading;

  /// No description provided for @totalSolids.
  ///
  /// In en, this message translates to:
  /// **'Total solids'**
  String get totalSolids;

  /// No description provided for @colonyFormingUnits.
  ///
  /// In en, this message translates to:
  /// **'Colony forming units'**
  String get colonyFormingUnits;

  /// No description provided for @acidity.
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidity;

  /// No description provided for @milkingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record lab analysis, quality metrics, or remarks.'**
  String get milkingNotesInfo;

  /// No description provided for @confirmUpdateMilking.
  ///
  /// In en, this message translates to:
  /// **'Update milking log?'**
  String get confirmUpdateMilking;

  /// No description provided for @confirmSaveMilking.
  ///
  /// In en, this message translates to:
  /// **'Save milking log?'**
  String get confirmSaveMilking;

  /// No description provided for @milkingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save milking log. Please try again.'**
  String get milkingLogSaveFailed;

  /// No description provided for @addPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Add pregnancy log'**
  String get addPregnancy;

  /// No description provided for @pregnancyDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record pregnancy test outcomes and status.'**
  String get pregnancyDetailsSubtitle;

  /// No description provided for @pregnancyNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide notes about this pregnancy check.'**
  String get pregnancyNotesSubtitle;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test result'**
  String get testResult;

  /// No description provided for @testResultRequired.
  ///
  /// In en, this message translates to:
  /// **'Test result is required'**
  String get testResultRequired;

  /// No description provided for @numberOfMonths.
  ///
  /// In en, this message translates to:
  /// **'Number of months'**
  String get numberOfMonths;

  /// No description provided for @testDate.
  ///
  /// In en, this message translates to:
  /// **'Test date'**
  String get testDate;

  /// No description provided for @testDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Test date is required'**
  String get testDateRequired;

  /// No description provided for @ensurePregnancyDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure pregnancy information is accurate before saving.'**
  String get ensurePregnancyDetailsAccuracy;

  /// No description provided for @pregnancyNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add notes about symptoms, vet observations, or remarks.'**
  String get pregnancyNotesInfo;

  /// No description provided for @confirmUpdatePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Update pregnancy log?'**
  String get confirmUpdatePregnancy;

  /// No description provided for @confirmSavePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Save pregnancy log?'**
  String get confirmSavePregnancy;

  /// No description provided for @pregnancyLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save pregnancy log. Please try again.'**
  String get pregnancyLogSaveFailed;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @addTransfer.
  ///
  /// In en, this message translates to:
  /// **'Add transfer log'**
  String get addTransfer;

  /// No description provided for @transferDetails.
  ///
  /// In en, this message translates to:
  /// **'Transfer details'**
  String get transferDetails;

  /// No description provided for @transferDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track livestock movement between farms.'**
  String get transferDetailsSubtitle;

  /// No description provided for @transferContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Provide the destination farm and transporter information.'**
  String get transferContextInfo;

  /// No description provided for @toFarmUuidLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination farm UUID'**
  String get toFarmUuidLabel;

  /// No description provided for @fromFarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Source farm'**
  String get fromFarmLabel;

  /// No description provided for @toFarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination farm'**
  String get toFarmLabel;

  /// No description provided for @enterToFarmUuid.
  ///
  /// In en, this message translates to:
  /// **'Enter destination farm UUID'**
  String get enterToFarmUuid;

  /// No description provided for @toFarmUuidRequired.
  ///
  /// In en, this message translates to:
  /// **'Destination farm UUID is required'**
  String get toFarmUuidRequired;

  /// No description provided for @transferToFarmUuidWarning.
  ///
  /// In en, this message translates to:
  /// **'Ensure the destination farm exists before saving.'**
  String get transferToFarmUuidWarning;

  /// No description provided for @transporterIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Transporter ID'**
  String get transporterIdLabel;

  /// No description provided for @enterTransporterId.
  ///
  /// In en, this message translates to:
  /// **'Enter transporter identifier'**
  String get enterTransporterId;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @enterTransferReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for transfer'**
  String get enterTransferReason;

  /// No description provided for @transferPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer price'**
  String get transferPriceLabel;

  /// No description provided for @enterTransferPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price (optional)'**
  String get enterTransferPrice;

  /// No description provided for @transferCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get transferCurrencyLabel;

  /// No description provided for @selectTransferCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get selectTransferCurrency;

  /// No description provided for @currencyTsh.
  ///
  /// In en, this message translates to:
  /// **'TZS'**
  String get currencyTsh;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currencyUsd;

  /// No description provided for @currencyGbp.
  ///
  /// In en, this message translates to:
  /// **'GBP'**
  String get currencyGbp;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'EUR'**
  String get currencyEur;

  /// No description provided for @transferDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer date'**
  String get transferDateLabel;

  /// No description provided for @selectTransferDate.
  ///
  /// In en, this message translates to:
  /// **'Select transfer date'**
  String get selectTransferDate;

  /// No description provided for @transferDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Transfer date is required'**
  String get transferDateRequired;

  /// No description provided for @transferStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer status'**
  String get transferStatusLabel;

  /// No description provided for @confirmUpdateTransfer.
  ///
  /// In en, this message translates to:
  /// **'Update transfer log?'**
  String get confirmUpdateTransfer;

  /// No description provided for @confirmSaveTransfer.
  ///
  /// In en, this message translates to:
  /// **'Save transfer log?'**
  String get confirmSaveTransfer;

  /// No description provided for @invalidTransporterId.
  ///
  /// In en, this message translates to:
  /// **'Transporter ID must be alphanumeric.'**
  String get invalidTransporterId;

  /// No description provided for @transferLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save transfer log. Please try again.'**
  String get transferLogSaveFailed;

  /// No description provided for @addDryoff.
  ///
  /// In en, this message translates to:
  /// **'Add dryoff log'**
  String get addDryoff;

  /// No description provided for @dryoffDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record the planned dryoff window.'**
  String get dryoffDetailsSubtitle;

  /// No description provided for @dryoffNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture any feeding or management notes.'**
  String get dryoffNotesSubtitle;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date is required'**
  String get startDateRequired;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @ensureDryoffDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the dryoff details are accurate before saving.'**
  String get ensureDryoffDetailsAccuracy;

  /// No description provided for @dryoffNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add remarks about feed changes, health checks, or reminders.'**
  String get dryoffNotesInfo;

  /// No description provided for @confirmUpdateDryoff.
  ///
  /// In en, this message translates to:
  /// **'Update dryoff log?'**
  String get confirmUpdateDryoff;

  /// No description provided for @confirmSaveDryoff.
  ///
  /// In en, this message translates to:
  /// **'Save dryoff log?'**
  String get confirmSaveDryoff;

  /// No description provided for @dryoffLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save dryoff log. Please try again.'**
  String get dryoffLogSaveFailed;

  /// No description provided for @confirmSaveDeworming.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this deworming log?'**
  String get confirmSaveDeworming;

  /// No description provided for @confirmUpdateDeworming.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this deworming log?'**
  String get confirmUpdateDeworming;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @bulkOperationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving records for all selected livestock...'**
  String get bulkOperationInProgress;

  /// No description provided for @addInsemination.
  ///
  /// In en, this message translates to:
  /// **'Add insemination log'**
  String get addInsemination;

  /// No description provided for @inseminationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record heat cycle, service type, and straw details.'**
  String get inseminationDetailsSubtitle;

  /// No description provided for @inseminationNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture remarks about semen quality or procedures.'**
  String get inseminationNotesSubtitle;

  /// No description provided for @lastHeatDate.
  ///
  /// In en, this message translates to:
  /// **'Last heat date'**
  String get lastHeatDate;

  /// No description provided for @heatType.
  ///
  /// In en, this message translates to:
  /// **'Heat type'**
  String get heatType;

  /// No description provided for @heatTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Heat type is required'**
  String get heatTypeRequired;

  /// No description provided for @inseminationService.
  ///
  /// In en, this message translates to:
  /// **'Insemination service'**
  String get inseminationService;

  /// No description provided for @inseminationServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Insemination service is required'**
  String get inseminationServiceRequired;

  /// No description provided for @semenStrawType.
  ///
  /// In en, this message translates to:
  /// **'Semen straw type'**
  String get semenStrawType;

  /// No description provided for @semenStrawTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Semen straw type is required'**
  String get semenStrawTypeRequired;

  /// No description provided for @inseminationDate.
  ///
  /// In en, this message translates to:
  /// **'Insemination date'**
  String get inseminationDate;

  /// No description provided for @ensureInseminationDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure insemination details are accurate before saving.'**
  String get ensureInseminationDetailsAccuracy;

  /// No description provided for @bullCode.
  ///
  /// In en, this message translates to:
  /// **'Bull code'**
  String get bullCode;

  /// No description provided for @bullBreed.
  ///
  /// In en, this message translates to:
  /// **'Bull breed'**
  String get bullBreed;

  /// No description provided for @semenProductionDate.
  ///
  /// In en, this message translates to:
  /// **'Semen production date'**
  String get semenProductionDate;

  /// No description provided for @productionCountry.
  ///
  /// In en, this message translates to:
  /// **'Production country'**
  String get productionCountry;

  /// No description provided for @semenBatchNumber.
  ///
  /// In en, this message translates to:
  /// **'Batch number'**
  String get semenBatchNumber;

  /// No description provided for @internationalId.
  ///
  /// In en, this message translates to:
  /// **'International ID'**
  String get internationalId;

  /// No description provided for @aiCode.
  ///
  /// In en, this message translates to:
  /// **'AI code'**
  String get aiCode;

  /// No description provided for @manufacturerName.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer name'**
  String get manufacturerName;

  /// No description provided for @semenSupplier.
  ///
  /// In en, this message translates to:
  /// **'Semen supplier'**
  String get semenSupplier;

  /// No description provided for @inseminationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add notes about handling, technician, or follow-up plans.'**
  String get inseminationNotesInfo;

  /// No description provided for @confirmUpdateInsemination.
  ///
  /// In en, this message translates to:
  /// **'Update insemination log?'**
  String get confirmUpdateInsemination;

  /// No description provided for @confirmSaveInsemination.
  ///
  /// In en, this message translates to:
  /// **'Save insemination log?'**
  String get confirmSaveInsemination;

  /// No description provided for @inseminationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save insemination log. Please try again.'**
  String get inseminationLogSaveFailed;

  /// No description provided for @farmWithLivestockLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load farm with livestock'**
  String get farmWithLivestockLoadFailed;

  /// No description provided for @noFarmFound.
  ///
  /// In en, this message translates to:
  /// **'No farm found'**
  String get noFarmFound;

  /// No description provided for @noFarmsFound.
  ///
  /// In en, this message translates to:
  /// **'No farms found'**
  String get noFarmsFound;

  /// No description provided for @addCalving.
  ///
  /// In en, this message translates to:
  /// **'Add calving log'**
  String get addCalving;

  /// No description provided for @calvingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record calving outcomes and supporting details.'**
  String get calvingDetailsSubtitle;

  /// No description provided for @calvingNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture observations, issues, or follow-up actions.'**
  String get calvingNotesSubtitle;

  /// No description provided for @calvingProblem.
  ///
  /// In en, this message translates to:
  /// **'Calving problem'**
  String get calvingProblem;

  /// No description provided for @reproductiveProblem.
  ///
  /// In en, this message translates to:
  /// **'Reproductive problem'**
  String get reproductiveProblem;

  /// No description provided for @calvingType.
  ///
  /// In en, this message translates to:
  /// **'Calving type'**
  String get calvingType;

  /// No description provided for @calvingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Calving type is required'**
  String get calvingTypeRequired;

  /// No description provided for @farrowingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Farrowing type is required'**
  String get farrowingTypeRequired;

  /// No description provided for @ensureCalvingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure calving information is accurate before saving.'**
  String get ensureCalvingDetailsAccuracy;

  /// No description provided for @ensureFarrowingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure farrowing information is accurate before saving.'**
  String get ensureFarrowingDetailsAccuracy;

  /// No description provided for @calvingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add notes about calves, complications, or support provided.'**
  String get calvingNotesInfo;

  /// No description provided for @farrowingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add notes about piglets, complications, or support provided.'**
  String get farrowingNotesInfo;

  /// No description provided for @confirmUpdateCalving.
  ///
  /// In en, this message translates to:
  /// **'Update calving log?'**
  String get confirmUpdateCalving;

  /// No description provided for @confirmSaveCalving.
  ///
  /// In en, this message translates to:
  /// **'Save calving log?'**
  String get confirmSaveCalving;

  /// No description provided for @confirmUpdateFarrowing.
  ///
  /// In en, this message translates to:
  /// **'Update farrowing log?'**
  String get confirmUpdateFarrowing;

  /// No description provided for @confirmSaveFarrowing.
  ///
  /// In en, this message translates to:
  /// **'Save farrowing log?'**
  String get confirmSaveFarrowing;

  /// No description provided for @calvingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save calving log. Please try again.'**
  String get calvingLogSaveFailed;

  /// No description provided for @noLivestockFound.
  ///
  /// In en, this message translates to:
  /// **'No livestock found'**
  String get noLivestockFound;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @registerLivestockHowTitle.
  ///
  /// In en, this message translates to:
  /// **'Register livestock'**
  String get registerLivestockHowTitle;

  /// No description provided for @registerLivestockSingleOption.
  ///
  /// In en, this message translates to:
  /// **'Single animal'**
  String get registerLivestockSingleOption;

  /// No description provided for @registerLivestockSingleOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Full form with tags and one ID'**
  String get registerLivestockSingleOptionDesc;

  /// No description provided for @registerPigletLitterOption.
  ///
  /// In en, this message translates to:
  /// **'Piglet litter'**
  String get registerPigletLitterOption;

  /// No description provided for @registerPigletLitterOptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Same details for many piglets; IDs like YYYYMMDD-01'**
  String get registerPigletLitterOptionDesc;

  /// No description provided for @pigletBulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Register piglet litter'**
  String get pigletBulkTitle;

  /// App bar when finishing a birth log and litter in one flow
  ///
  /// In en, this message translates to:
  /// **'Complete birth & offspring'**
  String get pigletBulkCompleteBirthFlowTitle;

  /// Info when user arrived from birth event form with litter
  ///
  /// In en, this message translates to:
  /// **'The birth log will be saved together with the offspring when you tap Register all on the preview step. Review and adjust details below, then confirm.'**
  String get pigletBulkDeferredBirthHint;

  /// No description provided for @pigletBulkStepCommonTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared details'**
  String get pigletBulkStepCommonTitle;

  /// No description provided for @pigletBulkStepCommonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Farm, type, litter size, dates, parents'**
  String get pigletBulkStepCommonSubtitle;

  /// No description provided for @pigletBulkStepPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get pigletBulkStepPreviewTitle;

  /// No description provided for @pigletBulkStepPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generated IDs and sex per piglet'**
  String get pigletBulkStepPreviewSubtitle;

  /// No description provided for @pigletBulkNumberOfPiglets.
  ///
  /// In en, this message translates to:
  /// **'Number of piglets'**
  String get pigletBulkNumberOfPiglets;

  /// No description provided for @pigletBulkInvalidCount.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number from 1 to {max}.'**
  String pigletBulkInvalidCount(int max);

  /// No description provided for @pigletBulkNamePrefix.
  ///
  /// In en, this message translates to:
  /// **'Name prefix'**
  String get pigletBulkNamePrefix;

  /// No description provided for @pigletBulkNamePrefixHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Piglet (combined with number or nickname)'**
  String get pigletBulkNamePrefixHint;

  /// No description provided for @pigletBulkPreviewInfo.
  ///
  /// In en, this message translates to:
  /// **'Each ID uses the date of birth as YYYYMMDD plus a sequence (01, 02, …). Young stages stay not identified until you add tags later.'**
  String get pigletBulkPreviewInfo;

  /// No description provided for @pigletBulkNicknameOptional.
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional)'**
  String get pigletBulkNicknameOptional;

  /// No description provided for @pigletBulkRegisterAll.
  ///
  /// In en, this message translates to:
  /// **'Register all'**
  String get pigletBulkRegisterAll;

  /// No description provided for @pigletBulkSelectSexEach.
  ///
  /// In en, this message translates to:
  /// **'Choose male or female for every piglet.'**
  String get pigletBulkSelectSexEach;

  /// No description provided for @pigletBulkQuickSexTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick sex split'**
  String get pigletBulkQuickSexTitle;

  /// No description provided for @pigletBulkQuickSexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter how many piglets are female, male, or unknown across the full litter (alive and dead). The three numbers must add up to {alive}.'**
  String pigletBulkQuickSexSubtitle(int alive);

  /// No description provided for @pigletBulkQuickSexCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get pigletBulkQuickSexCountLabel;

  /// No description provided for @pigletBulkApplySexSplit.
  ///
  /// In en, this message translates to:
  /// **'Apply to list'**
  String get pigletBulkApplySexSplit;

  /// No description provided for @pigletBulkSexCountMismatch.
  ///
  /// In en, this message translates to:
  /// **'Female + male + unknown must equal {expected} (all piglet rows). You entered {actual}.'**
  String pigletBulkSexCountMismatch(int expected, int actual);

  /// No description provided for @pigletBulkQuickSexOrderNote.
  ///
  /// In en, this message translates to:
  /// **'Order: first N rows = female, then male, then unknown across all rows (alive and dead). You can still change any row below.'**
  String get pigletBulkQuickSexOrderNote;

  /// No description provided for @pigletBulkPreviewSaveAllNote.
  ///
  /// In en, this message translates to:
  /// **'Every row—including dead at birth—is saved as livestock first. Disposals are created only after that, using the saved animal records.'**
  String get pigletBulkPreviewSaveAllNote;

  /// No description provided for @pigletBulkQuickFillSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick fill'**
  String get pigletBulkQuickFillSectionTitle;

  /// No description provided for @pigletBulkQuickFillSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk-set fields that differ per piglet. This does not change litter size. You can still edit any row below.'**
  String get pigletBulkQuickFillSectionSubtitle;

  /// No description provided for @pigletBulkQuickNicknameTitle.
  ///
  /// In en, this message translates to:
  /// **'Nicknames'**
  String get pigletBulkQuickNicknameTitle;

  /// No description provided for @pigletBulkQuickNicknameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fills \"Name prefix 1\", \"Name prefix 2\", … using the name prefix from the previous step (same as default display names).'**
  String get pigletBulkQuickNicknameSubtitle;

  /// No description provided for @pigletBulkApplyNicknamePattern.
  ///
  /// In en, this message translates to:
  /// **'Fill name sequence'**
  String get pigletBulkApplyNicknamePattern;

  /// No description provided for @pigletBulkQuickWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weights (kg)'**
  String get pigletBulkQuickWeightTitle;

  /// No description provided for @pigletBulkQuickWeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply one weight for all live piglets and one for all dead-at-birth. Row boxes below override these; leave empty on a row to use the registration weight from step 1.'**
  String get pigletBulkQuickWeightSubtitle;

  /// No description provided for @pigletBulkWeightAliveHint.
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get pigletBulkWeightAliveHint;

  /// No description provided for @pigletBulkWeightDeadHint.
  ///
  /// In en, this message translates to:
  /// **'Dead at birth'**
  String get pigletBulkWeightDeadHint;

  /// No description provided for @pigletBulkApplyWeights.
  ///
  /// In en, this message translates to:
  /// **'Apply weights to rows'**
  String get pigletBulkApplyWeights;

  /// No description provided for @pigletBulkWeightPerRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get pigletBulkWeightPerRowLabel;

  /// No description provided for @pigletBulkWeightPerRowHint.
  ///
  /// In en, this message translates to:
  /// **'Optional; uses step 1 if empty'**
  String get pigletBulkWeightPerRowHint;

  /// No description provided for @pigletBulkBatchSizeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Expected {expected} animals to save but got {actual}. Nothing was partially disposed; try again or contact support.'**
  String pigletBulkBatchSizeMismatch(int expected, int actual);

  /// No description provided for @pigletBulkQuickFillFooterNote.
  ///
  /// In en, this message translates to:
  /// **'Sex split applies to alive rows only, in list order. Names and weights apply to every row unless you skip the action.'**
  String get pigletBulkQuickFillFooterNote;

  /// No description provided for @pigletBulkIdConflict.
  ///
  /// In en, this message translates to:
  /// **'Some generated IDs already exist. Change the birth date or remove existing records, then try again.'**
  String get pigletBulkIdConflict;

  /// No description provided for @pigletBulkConflictingIds.
  ///
  /// In en, this message translates to:
  /// **'Taken: {ids}'**
  String pigletBulkConflictingIds(String ids);

  /// No description provided for @pigletBulkConfirmRegister.
  ///
  /// In en, this message translates to:
  /// **'Register {count} piglets now? They are saved on this device and will sync when online.'**
  String pigletBulkConfirmRegister(int count);

  /// No description provided for @pigletBulkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered {count} piglets.'**
  String pigletBulkSuccess(int count);

  /// No description provided for @pigletBulkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not register the litter. Please try again.'**
  String get pigletBulkFailed;

  /// No description provided for @pigletDefaultNamePrefix.
  ///
  /// In en, this message translates to:
  /// **'Piglet'**
  String get pigletDefaultNamePrefix;

  /// No description provided for @pigletBulkSavingMessage.
  ///
  /// In en, this message translates to:
  /// **'Registering piglets…'**
  String get pigletBulkSavingMessage;

  /// No description provided for @pigletBulkCountRangeHint.
  ///
  /// In en, this message translates to:
  /// **'1–{max}'**
  String pigletBulkCountRangeHint(int max);

  /// No description provided for @pigletBulkBirthEventLitterHint.
  ///
  /// In en, this message translates to:
  /// **'If the birth event includes total born and dead counts, selecting it fills the litter size and marks dead piglets on the next step.'**
  String get pigletBulkBirthEventLitterHint;

  /// No description provided for @pigletBulkSaveCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Save check'**
  String get pigletBulkSaveCheckTitle;

  /// No description provided for @pigletBulkStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get pigletBulkStatusReady;

  /// No description provided for @pigletBulkStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get pigletBulkStatusRequired;

  /// No description provided for @pigletBulkStatusNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get pigletBulkStatusNotApplicable;

  /// No description provided for @pigletBulkMotherRequiredForBirthFlow.
  ///
  /// In en, this message translates to:
  /// **'Mother must remain selected for this birth flow.'**
  String get pigletBulkMotherRequiredForBirthFlow;

  /// No description provided for @pigletBulkLitterTotal.
  ///
  /// In en, this message translates to:
  /// **'{totalBorn} born'**
  String pigletBulkLitterTotal(int totalBorn);

  /// No description provided for @pigletBulkLitterTotalDead.
  ///
  /// In en, this message translates to:
  /// **'{totalBorn} born, {deadCount} dead'**
  String pigletBulkLitterTotalDead(int totalBorn, int deadCount);

  /// No description provided for @pigletBulkPreviewAliveDeadSummary.
  ///
  /// In en, this message translates to:
  /// **'{alive} alive at birth · {dead} dead at birth (last IDs in the list).'**
  String pigletBulkPreviewAliveDeadSummary(int alive, int dead);

  /// No description provided for @pigletBulkDeadAtBirthChip.
  ///
  /// In en, this message translates to:
  /// **'Dead at birth'**
  String get pigletBulkDeadAtBirthChip;

  /// No description provided for @pigletBulkDisposalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Disposal for dead at birth'**
  String get pigletBulkDisposalSectionTitle;

  /// No description provided for @pigletBulkDisposalSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required when registering stillborn piglets. A disposal log is created for each.'**
  String get pigletBulkDisposalSectionSubtitle;

  /// No description provided for @pigletBulkDisposalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Disposal type'**
  String get pigletBulkDisposalTypeLabel;

  /// No description provided for @pigletBulkSelectDisposalTypeForDead.
  ///
  /// In en, this message translates to:
  /// **'Select a disposal type for dead-at-birth piglets.'**
  String get pigletBulkSelectDisposalTypeForDead;

  /// No description provided for @pigletBulkDeadDisposalReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (e.g. stillborn / birth mortality)'**
  String get pigletBulkDeadDisposalReasonHint;

  /// No description provided for @pigletDeadAtBirthDisposalReasonDefault.
  ///
  /// In en, this message translates to:
  /// **'Dead at birth (litter registration)'**
  String get pigletDeadAtBirthDisposalReasonDefault;

  /// No description provided for @pigletBulkGenderOptionalDead.
  ///
  /// In en, this message translates to:
  /// **'Sex (optional)'**
  String get pigletBulkGenderOptionalDead;

  /// No description provided for @pigletBulkSuccessDisposals.
  ///
  /// In en, this message translates to:
  /// **'Also logged {count} disposal records for stillborn piglets.'**
  String pigletBulkSuccessDisposals(int count);

  /// No description provided for @pigletBulkDisposalPartialFailure.
  ///
  /// In en, this message translates to:
  /// **'Livestock was saved but some disposal logs failed. Check records and add disposals manually if needed.'**
  String get pigletBulkDisposalPartialFailure;

  /// No description provided for @pigletGenderUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pigletGenderUnknown;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Timeout Error'**
  String get timeoutError;

  /// No description provided for @timeoutErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. The server took too long to respond. Please try again.'**
  String get timeoutErrorMessage;

  /// No description provided for @invalidRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid Request'**
  String get invalidRequest;

  /// No description provided for @invalidRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your information and try again.'**
  String get invalidRequestMessage;

  /// No description provided for @serviceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get serviceNotFound;

  /// No description provided for @serviceNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Service not found. Please try again later.'**
  String get serviceNotFoundMessage;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericError;

  /// Error message when email is already taken during registration
  ///
  /// In en, this message translates to:
  /// **'This email address is already registered. Please use a different email or try logging in.'**
  String get emailAlreadyTaken;

  /// Error message when username is already taken during registration
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose a different username.'**
  String get usernameAlreadyTaken;

  /// Error message when both email and username are already taken during registration
  ///
  /// In en, this message translates to:
  /// **'Both email and username are already taken. Please use different credentials or try logging in.'**
  String get emailAndUsernameAlreadyTaken;

  /// No description provided for @addVaccine.
  ///
  /// In en, this message translates to:
  /// **'Add vaccine'**
  String get addVaccine;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Generic status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @notActive.
  ///
  /// In en, this message translates to:
  /// **'Not Active'**
  String get notActive;

  /// No description provided for @identificationNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get identificationNumber;

  /// No description provided for @enterIdentificationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter identification number'**
  String get enterIdentificationNumber;

  /// No description provided for @identificationNumberExists.
  ///
  /// In en, this message translates to:
  /// **'Another livestock already uses this identification number. Please enter a unique ID.'**
  String get identificationNumberExists;

  /// No description provided for @identificationNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Identification number is required'**
  String get identificationNumberRequired;

  /// No description provided for @rfidTagIdExists.
  ///
  /// In en, this message translates to:
  /// **'Another livestock already uses this RFID Tag ID.'**
  String get rfidTagIdExists;

  /// No description provided for @barcodeTagIdExists.
  ///
  /// In en, this message translates to:
  /// **'Another livestock already uses this Barcode Tag ID.'**
  String get barcodeTagIdExists;

  /// No description provided for @dummyTagId.
  ///
  /// In en, this message translates to:
  /// **'Dummy Tag ID'**
  String get dummyTagId;

  /// No description provided for @enterDummyTagId.
  ///
  /// In en, this message translates to:
  /// **'Enter dummy tag ID (optional)'**
  String get enterDummyTagId;

  /// No description provided for @barcodeTagId.
  ///
  /// In en, this message translates to:
  /// **'Barcode Tag ID'**
  String get barcodeTagId;

  /// No description provided for @enterBarcodeTagId.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode tag ID (optional)'**
  String get enterBarcodeTagId;

  /// No description provided for @rfidTagId.
  ///
  /// In en, this message translates to:
  /// **'RFID Tag ID'**
  String get rfidTagId;

  /// No description provided for @enterRfidTagId.
  ///
  /// In en, this message translates to:
  /// **'Enter RFID tag ID (optional)'**
  String get enterRfidTagId;

  /// No description provided for @livestockType.
  ///
  /// In en, this message translates to:
  /// **'Livestock Type'**
  String get livestockType;

  /// No description provided for @livestockTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Livestock type is required'**
  String get livestockTypeRequired;

  /// No description provided for @pleaseSelectLivestockType.
  ///
  /// In en, this message translates to:
  /// **'Please select livestock type'**
  String get pleaseSelectLivestockType;

  /// No description provided for @noStagesForThisType.
  ///
  /// In en, this message translates to:
  /// **'No stages for this type'**
  String get noStagesForThisType;

  /// No description provided for @speciesRequired.
  ///
  /// In en, this message translates to:
  /// **'Species is required'**
  String get speciesRequired;

  /// No description provided for @pleaseSelectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Please select species'**
  String get pleaseSelectSpecies;

  /// No description provided for @breedRequired.
  ///
  /// In en, this message translates to:
  /// **'Breed is required'**
  String get breedRequired;

  /// No description provided for @pleaseSelectBreed.
  ///
  /// In en, this message translates to:
  /// **'Please select breed'**
  String get pleaseSelectBreed;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @weightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight is required'**
  String get weightRequired;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter valid weight'**
  String get enterValidWeight;

  /// No description provided for @enterWeightOrBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Enter weight or use Bluetooth'**
  String get enterWeightOrBluetooth;

  /// No description provided for @dateEnteredFarmRequired.
  ///
  /// In en, this message translates to:
  /// **'Date entered farm is required'**
  String get dateEnteredFarmRequired;

  /// No description provided for @motherOptional.
  ///
  /// In en, this message translates to:
  /// **'Mother (Optional)'**
  String get motherOptional;

  /// No description provided for @fatherOptional.
  ///
  /// In en, this message translates to:
  /// **'Father (Optional)'**
  String get fatherOptional;

  /// No description provided for @filterByMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get filterByMother;

  /// No description provided for @filterByFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get filterByFather;

  /// No description provided for @parentFilterChildrenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} children'**
  String parentFilterChildrenCount(int count);

  /// No description provided for @obtainedMethod.
  ///
  /// In en, this message translates to:
  /// **'Obtained Method'**
  String get obtainedMethod;

  /// No description provided for @physicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Physical Details'**
  String get physicalDetails;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Info'**
  String get additionalInfo;

  /// No description provided for @enterLivestockName.
  ///
  /// In en, this message translates to:
  /// **'Enter livestock name'**
  String get enterLivestockName;

  /// No description provided for @pleaseSelectFarm.
  ///
  /// In en, this message translates to:
  /// **'Please select a farm'**
  String get pleaseSelectFarm;

  /// No description provided for @pleaseSelectDateEnteredFarm.
  ///
  /// In en, this message translates to:
  /// **'Please select date first entered to farm'**
  String get pleaseSelectDateEnteredFarm;

  /// No description provided for @confirmUpdateLivestock.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this livestock?'**
  String get confirmUpdateLivestock;

  /// No description provided for @confirmRegisterLivestock.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to register this livestock?'**
  String get confirmRegisterLivestock;

  /// No description provided for @livestockUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Livestock updated successfully'**
  String get livestockUpdatedSuccessfully;

  /// No description provided for @livestockRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Livestock registered successfully'**
  String get livestockRegisteredSuccessfully;

  /// No description provided for @failedToSaveLivestock.
  ///
  /// In en, this message translates to:
  /// **'Failed to save livestock'**
  String get failedToSaveLivestock;

  /// No description provided for @farmLocation.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocation;

  /// No description provided for @selectWhereLocated.
  ///
  /// In en, this message translates to:
  /// **'Select where this livestock is located'**
  String get selectWhereLocated;

  /// No description provided for @basicDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get basicDetails;

  /// No description provided for @enterNameAndId.
  ///
  /// In en, this message translates to:
  /// **'Enter livestock name and primary identification'**
  String get enterNameAndId;

  /// No description provided for @tagIdentification.
  ///
  /// In en, this message translates to:
  /// **'Tag Identification'**
  String get tagIdentification;

  /// No description provided for @optionalEnterTagIds.
  ///
  /// In en, this message translates to:
  /// **'Optional: Enter tag IDs for tracking'**
  String get optionalEnterTagIds;

  /// No description provided for @livestockClassification.
  ///
  /// In en, this message translates to:
  /// **'Livestock Classification'**
  String get livestockClassification;

  /// No description provided for @selectTypeSpeciesBreed.
  ///
  /// In en, this message translates to:
  /// **'Select type, species, and breed'**
  String get selectTypeSpeciesBreed;

  /// No description provided for @physicalCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Physical Characteristics'**
  String get physicalCharacteristics;

  /// No description provided for @enterGenderWeightBirth.
  ///
  /// In en, this message translates to:
  /// **'Enter gender, weight, and birth date'**
  String get enterGenderWeightBirth;

  /// No description provided for @parentageInformation.
  ///
  /// In en, this message translates to:
  /// **'Parentage Information'**
  String get parentageInformation;

  /// No description provided for @optionalSelectParents.
  ///
  /// In en, this message translates to:
  /// **'Optional: Select mother and father'**
  String get optionalSelectParents;

  /// No description provided for @acquisitionDetails.
  ///
  /// In en, this message translates to:
  /// **'Acquisition Details'**
  String get acquisitionDetails;

  /// No description provided for @howAndWhenObtained.
  ///
  /// In en, this message translates to:
  /// **'How and when livestock was obtained'**
  String get howAndWhenObtained;

  /// No description provided for @livestockStatus.
  ///
  /// In en, this message translates to:
  /// **'Livestock Status'**
  String get livestockStatus;

  /// No description provided for @setCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Set the current status of this livestock'**
  String get setCurrentStatus;

  /// No description provided for @farmNameAndIdentification.
  ///
  /// In en, this message translates to:
  /// **'Farm, name, and identification'**
  String get farmNameAndIdentification;

  /// No description provided for @typeSpeciesBreedCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Type, species, breed, and characteristics'**
  String get typeSpeciesBreedCharacteristics;

  /// No description provided for @parentsMethodAndDates.
  ///
  /// In en, this message translates to:
  /// **'Parents, method, and dates'**
  String get parentsMethodAndDates;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @editLivestock.
  ///
  /// In en, this message translates to:
  /// **'Edit Livestock'**
  String get editLivestock;

  /// No description provided for @deleteLivestock.
  ///
  /// In en, this message translates to:
  /// **'Delete Livestock'**
  String get deleteLivestock;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get confirmDelete;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @disposal.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get disposal;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @unsyncedDataWarning.
  ///
  /// In en, this message translates to:
  /// **'You have unsynced data. Sync before logging out to avoid losing recent changes.'**
  String get unsyncedDataWarning;

  /// No description provided for @noUnsyncedDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No unsynced data found. It is safe to log out.'**
  String get noUnsyncedDataMessage;

  /// No description provided for @syncAndLogout.
  ///
  /// In en, this message translates to:
  /// **'Sync & Logout'**
  String get syncAndLogout;

  /// No description provided for @syncingBeforeLogout.
  ///
  /// In en, this message translates to:
  /// **'Syncing pending data before logging out...'**
  String get syncingBeforeLogout;

  /// No description provided for @changeFarm.
  ///
  /// In en, this message translates to:
  /// **'Change Farm'**
  String get changeFarm;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @addNotification.
  ///
  /// In en, this message translates to:
  /// **'Add notification'**
  String get addNotification;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @upcomingToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get upcomingToday;

  /// No description provided for @upcomingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get allNotifications;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification title'**
  String get notificationTitle;

  /// No description provided for @enterNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a notification title'**
  String get enterNotificationTitle;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get notificationDescription;

  /// No description provided for @enterNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get enterNotificationDescription;

  /// No description provided for @optionalFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalFieldHint;

  /// No description provided for @scheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Schedule date'**
  String get scheduleDate;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Schedule time'**
  String get scheduleTime;

  /// No description provided for @saveNotification.
  ///
  /// In en, this message translates to:
  /// **'Save notification'**
  String get saveNotification;

  /// Option to enter value manually
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get manualInput;

  /// Option to choose value from list
  ///
  /// In en, this message translates to:
  /// **'Choose from list'**
  String get chooseFromList;

  /// No description provided for @notificationChipToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationChipToday;

  /// No description provided for @notificationChipUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get notificationChipUpcoming;

  /// Label for this week time period
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Unit for volume measurement
  ///
  /// In en, this message translates to:
  /// **'Litres'**
  String get litres;

  /// Title for milking summary section
  ///
  /// In en, this message translates to:
  /// **'Milking Summary'**
  String get milkingSummary;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;

  /// No description provided for @notificationScheduledOn.
  ///
  /// In en, this message translates to:
  /// **'Scheduled on {dateLabel}'**
  String notificationScheduledOn(String dateLabel);

  /// No description provided for @selectAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get selectAlarmSound;

  /// No description provided for @alarmSoundSelected.
  ///
  /// In en, this message translates to:
  /// **'Current sound: {soundName}'**
  String alarmSoundSelected(String soundName);

  /// No description provided for @chooseSound.
  ///
  /// In en, this message translates to:
  /// **'Choose audio'**
  String get chooseSound;

  /// No description provided for @previewSound.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSound;

  /// No description provided for @stopPreview.
  ///
  /// In en, this message translates to:
  /// **'Stop preview'**
  String get stopPreview;

  /// No description provided for @loopSound.
  ///
  /// In en, this message translates to:
  /// **'Loop sound until stopped'**
  String get loopSound;

  /// No description provided for @vibrateDevice.
  ///
  /// In en, this message translates to:
  /// **'Vibrate device'**
  String get vibrateDevice;

  /// No description provided for @alarmVolume.
  ///
  /// In en, this message translates to:
  /// **'Alarm volume'**
  String get alarmVolume;

  /// No description provided for @previewSoundFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to preview sound'**
  String get previewSoundFailed;

  /// No description provided for @stopAlarm.
  ///
  /// In en, this message translates to:
  /// **'Stop alarm'**
  String get stopAlarm;

  /// No description provided for @repeatDailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat every day'**
  String get repeatDailyLabel;

  /// No description provided for @repeatDailyHint.
  ///
  /// In en, this message translates to:
  /// **'Alarm will ring at this time daily.'**
  String get repeatDailyHint;

  /// No description provided for @selectTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Alarm time'**
  String get selectTimeLabel;

  /// No description provided for @selectTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a daily time'**
  String get selectTimeHint;

  /// No description provided for @selectTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a time'**
  String get selectTimeRequired;

  /// No description provided for @scanUnsupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Scanning is not supported on this device.'**
  String get scanUnsupportedDevice;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied.'**
  String get scanPermissionDenied;

  /// No description provided for @scanPermissionRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access required'**
  String get scanPermissionRationaleTitle;

  /// No description provided for @scanPermissionRationaleMessage.
  ///
  /// In en, this message translates to:
  /// **'Tag scanning needs camera access. Please allow permission to continue.'**
  String get scanPermissionRationaleMessage;

  /// No description provided for @scanPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get scanPermissionNotNow;

  /// No description provided for @scanPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get scanPermissionAllow;

  /// No description provided for @scanPermissionSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get scanPermissionSettingsTitle;

  /// No description provided for @scanPermissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable camera permission in settings to continue scanning.'**
  String get scanPermissionSettingsMessage;

  /// No description provided for @scanPermissionGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanPermissionGoToSettings;

  /// No description provided for @scanOptionQr.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get scanOptionQr;

  /// No description provided for @scanOptionQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code tags'**
  String get scanOptionQrDescription;

  /// No description provided for @scanOptionBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get scanOptionBarcode;

  /// No description provided for @scanOptionBarcodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan printed barcodes'**
  String get scanOptionBarcodeDescription;

  /// No description provided for @scanOptionRfid.
  ///
  /// In en, this message translates to:
  /// **'RFID'**
  String get scanOptionRfid;

  /// No description provided for @scanOptionRfidDescription.
  ///
  /// In en, this message translates to:
  /// **'Use RFID reader'**
  String get scanOptionRfidDescription;

  /// No description provided for @scanTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan tags'**
  String get scanTagsTitle;

  /// No description provided for @scanTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to scan'**
  String get scanTagsSubtitle;

  /// No description provided for @scanStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get scanStartButton;

  /// No description provided for @scanResultNotFound.
  ///
  /// In en, this message translates to:
  /// **'No livestock found for tag {tag}'**
  String scanResultNotFound(String tag);

  /// No description provided for @scanRfidPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter RFID code'**
  String get scanRfidPlaceholder;

  /// No description provided for @scanManualPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter tag manually'**
  String get scanManualPlaceholder;

  /// No description provided for @scanManualConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm tag'**
  String get scanManualConfirm;

  /// Bluetooth RFID scanner title
  ///
  /// In en, this message translates to:
  /// **'Bluetooth RFID Scanner'**
  String get scanBluetoothRfidScannerTitle;

  /// Button text to connect Bluetooth RFID scanner
  ///
  /// In en, this message translates to:
  /// **'Connect Bluetooth RFID Scanner'**
  String get scanConnectBluetoothRfidScanner;

  /// Description text for Bluetooth RFID scanner
  ///
  /// In en, this message translates to:
  /// **'Connect your Bluetooth RFID scanner to scan tags'**
  String get scanBluetoothRfidScannerDescription;

  /// No description provided for @vaccineSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vaccine saved successfully'**
  String get vaccineSavedSuccessfully;

  /// No description provided for @vaccineSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save vaccine. Please try again.'**
  String get vaccineSaveFailed;

  /// No description provided for @vaccineUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vaccine updated successfully'**
  String get vaccineUpdatedSuccessfully;

  /// No description provided for @vaccineDetails.
  ///
  /// In en, this message translates to:
  /// **'Vaccine details'**
  String get vaccineDetails;

  /// No description provided for @vaccineDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate vaccine information'**
  String get vaccineDetailsSubtitle;

  /// No description provided for @vaccineType.
  ///
  /// In en, this message translates to:
  /// **'Vaccine type'**
  String get vaccineType;

  /// No description provided for @selectVaccineType.
  ///
  /// In en, this message translates to:
  /// **'Select vaccine type'**
  String get selectVaccineType;

  /// No description provided for @vaccineTypesMissing.
  ///
  /// In en, this message translates to:
  /// **'Vaccine types missing. Sync reference data first.'**
  String get vaccineTypesMissing;

  /// No description provided for @vaccineTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Vaccine type is required'**
  String get vaccineTypeRequired;

  /// No description provided for @formulationLiveAttenuated.
  ///
  /// In en, this message translates to:
  /// **'Live attenuated'**
  String get formulationLiveAttenuated;

  /// No description provided for @formulationInactivated.
  ///
  /// In en, this message translates to:
  /// **'Inactivated'**
  String get formulationInactivated;

  /// No description provided for @lotNumber.
  ///
  /// In en, this message translates to:
  /// **'Lot number'**
  String get lotNumber;

  /// No description provided for @enterLotNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter lot number'**
  String get enterLotNumber;

  /// No description provided for @formulationType.
  ///
  /// In en, this message translates to:
  /// **'Formulation type'**
  String get formulationType;

  /// No description provided for @selectFormulationType.
  ///
  /// In en, this message translates to:
  /// **'Select formulation type'**
  String get selectFormulationType;

  /// No description provided for @doseAmount.
  ///
  /// In en, this message translates to:
  /// **'Dose amount'**
  String get doseAmount;

  /// No description provided for @enterDoseAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter dose amount'**
  String get enterDoseAmount;

  /// No description provided for @doseUnit.
  ///
  /// In en, this message translates to:
  /// **'Dose unit'**
  String get doseUnit;

  /// No description provided for @selectDoseUnit.
  ///
  /// In en, this message translates to:
  /// **'Select dose unit'**
  String get selectDoseUnit;

  /// No description provided for @vaccineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get vaccineSchedule;

  /// No description provided for @selectVaccineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Select schedule'**
  String get selectVaccineSchedule;

  /// No description provided for @vaccineStatus.
  ///
  /// In en, this message translates to:
  /// **'Vaccine status'**
  String get vaccineStatus;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select status'**
  String get selectStatus;

  /// No description provided for @ensureVaccineDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the vaccine details are accurate before saving.'**
  String get ensureVaccineDetailsAccuracy;

  /// No description provided for @confirmUpdateVaccine.
  ///
  /// In en, this message translates to:
  /// **'Update vaccine details?'**
  String get confirmUpdateVaccine;

  /// No description provided for @confirmSaveVaccine.
  ///
  /// In en, this message translates to:
  /// **'Save this vaccine?'**
  String get confirmSaveVaccine;

  /// No description provided for @vaccineScheduleRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular schedule'**
  String get vaccineScheduleRegular;

  /// No description provided for @vaccineScheduleBooster.
  ///
  /// In en, this message translates to:
  /// **'Booster'**
  String get vaccineScheduleBooster;

  /// No description provided for @vaccineScheduleSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get vaccineScheduleSeasonal;

  /// No description provided for @vaccineScheduleEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get vaccineScheduleEmergency;

  /// No description provided for @farmUserSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm user saved successfully'**
  String get farmUserSavedSuccessfully;

  /// No description provided for @farmUserSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save farm user. Please try again.'**
  String get farmUserSaveFailed;

  /// No description provided for @farmUserUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm user updated successfully'**
  String get farmUserUpdatedSuccessfully;

  /// No description provided for @confirmSaveFarmUser.
  ///
  /// In en, this message translates to:
  /// **'Save this farm user?'**
  String get confirmSaveFarmUser;

  /// No description provided for @bluetoothNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is not supported on this device'**
  String get bluetoothNotSupported;

  /// No description provided for @bluetoothPermissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permissions are required to scan for devices. Please grant permissions when prompted.'**
  String get bluetoothPermissionsRequired;

  /// No description provided for @bluetoothPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permissions were permanently denied. Please enable them in app settings.'**
  String get bluetoothPermissionsPermanentlyDenied;

  /// No description provided for @bluetoothTurnOnRequired.
  ///
  /// In en, this message translates to:
  /// **'Please turn on Bluetooth to scan for devices'**
  String get bluetoothTurnOnRequired;

  /// No description provided for @bluetoothTurnOnInstructions.
  ///
  /// In en, this message translates to:
  /// **'Go to your device settings and turn on Bluetooth, then try again.'**
  String get bluetoothTurnOnInstructions;

  /// No description provided for @bluetoothUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get bluetoothUnknownError;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @makeSureScaleOn.
  ///
  /// In en, this message translates to:
  /// **'Make sure your scale is turned on'**
  String get makeSureScaleOn;

  /// No description provided for @enableBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Enable Bluetooth'**
  String get enableBluetooth;

  /// No description provided for @bluetoothLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location services are required for Bluetooth scanning on Android. Please enable location services in your device settings.'**
  String get bluetoothLocationRequired;

  /// Error message shown when a non-farmer user tries to access farmer-only features
  ///
  /// In en, this message translates to:
  /// **'Not a farmer. Access denied.'**
  String get notAFarmer;

  /// Error message shown when a non-farm user tries to access farm user-only features
  ///
  /// In en, this message translates to:
  /// **'Not a farm user. Access denied.'**
  String get notAFarmUser;

  /// Error message shown when user doesn't have the required role
  ///
  /// In en, this message translates to:
  /// **'Access denied. Required role: {role}.'**
  String accessDeniedRequiredRole(String role);

  /// Error message shown when a non-farmer/non-farm-manager tries to create livestock
  ///
  /// In en, this message translates to:
  /// **'Only farmers and farm managers can create livestock.'**
  String get notAFarmerOrFarmManager;

  /// Error message shown when a non-farmer/non-farm-manager tries to edit or delete livestock
  ///
  /// In en, this message translates to:
  /// **'Only farmers and farm managers can manage livestock.'**
  String get notAFarmerOrFarmManagerManage;

  /// Error message shown when a non-farmer/non-farm-manager tries to edit livestock
  ///
  /// In en, this message translates to:
  /// **'Only farmers and farm managers can edit livestock.'**
  String get notAFarmerOrFarmManagerEdit;

  /// Error message shown when a non-farmer/non-farm-manager tries to delete livestock
  ///
  /// In en, this message translates to:
  /// **'Only farmers and farm managers can delete livestock.'**
  String get notAFarmerOrFarmManagerDelete;

  /// Error message shown when a user without proper role tries to add vaccines
  ///
  /// In en, this message translates to:
  /// **'Only farmers, farm managers, and vaccination users can add vaccines.'**
  String get notAFarmerFarmManagerOrVaccinationUser;

  /// Error message shown when a user doesn't have permission to access a specific log type
  ///
  /// In en, this message translates to:
  /// **'Only farmers, farm managers, and authorized users can access {logType} logs.'**
  String logTypeAccessDenied(String logType);

  /// Message shown when trying to add logs to a livestock that has been disposed (notActive status)
  ///
  /// In en, this message translates to:
  /// **'This livestock is not active. Logs cannot be added for disposed livestock.'**
  String get livestockNotActiveCannotAddLogs;

  /// Title for forced sync dialog when unsynced data count is high
  ///
  /// In en, this message translates to:
  /// **'Sync Required'**
  String get syncRequired;

  /// Message for forced sync dialog
  ///
  /// In en, this message translates to:
  /// **'You have {count} unsynced items. Please sync your data to ensure all information is up to date.'**
  String syncRequiredMessage(int count);

  /// Button text for forced sync dialog
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Link text to Extension Officer login
  ///
  /// In en, this message translates to:
  /// **'Enter as Extension Officer?'**
  String get enterAsExtensionOfficer;

  /// Extension Officer login screen title
  ///
  /// In en, this message translates to:
  /// **'Extension Officer Login'**
  String get extensionOfficerLogin;

  /// Subtitle for extension officer login screen
  ///
  /// In en, this message translates to:
  /// **'Access farms you\'ve been invited to'**
  String get extensionOfficerLoginSubtitle;

  /// Error message when extension officer is not found
  ///
  /// In en, this message translates to:
  /// **'Extension officer not found with this email'**
  String get extensionOfficerNotFound;

  /// Message prompting user to search extension officer before inviting
  ///
  /// In en, this message translates to:
  /// **'Please search and verify the extension officer first'**
  String get pleaseSearchExtensionOfficerFirst;

  /// Success message when extension officer is found
  ///
  /// In en, this message translates to:
  /// **'Extension Officer Found'**
  String get extensionOfficerFound;

  /// Label for access code field
  ///
  /// In en, this message translates to:
  /// **'Access Code'**
  String get accessCode;

  /// Hint text for access code field
  ///
  /// In en, this message translates to:
  /// **'Access code will be generated after invitation'**
  String get accessCodeWillBeGenerated;

  /// Loading message when creating invite
  ///
  /// In en, this message translates to:
  /// **'Creating invitation...'**
  String get creatingInvite;

  /// Success message when extension officer is invited
  ///
  /// In en, this message translates to:
  /// **'Extension officer invited successfully'**
  String get extensionOfficerInvitedSuccessfully;

  /// Loading state text for inviting
  ///
  /// In en, this message translates to:
  /// **'Inviting...'**
  String get inviting;

  /// Loading state text for searching
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Hint text for extension officer email field
  ///
  /// In en, this message translates to:
  /// **'Enter extension officer email'**
  String get enterExtensionOfficerEmail;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Invite button text
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Phone label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Specialization field label
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Message shown when access code is copied
  ///
  /// In en, this message translates to:
  /// **'Access code copied to clipboard'**
  String get accessCodeCopied;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Farmer Access Number field label
  ///
  /// In en, this message translates to:
  /// **'Farmer Access Number'**
  String get farmerAccessNumber;

  /// Farmer Access Number field hint
  ///
  /// In en, this message translates to:
  /// **'Enter farmer access number'**
  String get enterFarmerAccessNumber;

  /// Farmer Access Number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter farmer access number'**
  String get pleaseEnterFarmerAccessNumber;

  /// Bills list title
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// Singular bill label
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get bill;

  /// Empty state for bills screen
  ///
  /// In en, this message translates to:
  /// **'No bills found'**
  String get noBillsFound;

  /// Formatted bill number
  ///
  /// In en, this message translates to:
  /// **'Bill #{number}'**
  String billNumber(String number);

  /// Generic notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Short quantity format
  ///
  /// In en, this message translates to:
  /// **'x{count}'**
  String quantityShort(int count);

  /// Bill subject type label
  ///
  /// In en, this message translates to:
  /// **'Subject type'**
  String get subjectType;

  /// Bill subject label
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// Dialog title for creating a bill
  ///
  /// In en, this message translates to:
  /// **'Create Bill'**
  String get createBill;

  /// Number of livestock included in the bill
  ///
  /// In en, this message translates to:
  /// **'Number of livestock'**
  String get numberOfLivestock;

  /// Snack message after bill created
  ///
  /// In en, this message translates to:
  /// **'Bill created successfully'**
  String get billCreatedSuccessfully;

  /// Hint text for number input
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get enterNumber;

  /// Hint text for optional notes field
  ///
  /// In en, this message translates to:
  /// **'Enter notes (optional)'**
  String get enterNotesOptional;

  /// Error message when bill creation fails
  ///
  /// In en, this message translates to:
  /// **'Bill creation failed'**
  String get billCreationFailed;

  /// Label for bill details section in dialog
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetails;

  /// Title for payment confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// Income and expenditures report title
  ///
  /// In en, this message translates to:
  /// **'Income and Expenditures Report'**
  String get incomeExpenditureReport;

  /// Generated on label
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get generatedOn;

  /// Date range label
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// All time label
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No data message in report screen
  ///
  /// In en, this message translates to:
  /// **'No records found for selected period'**
  String get noRecordsFoundForSelectedPeriod;

  /// Paid status label
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// Role-based access denied message for report screen
  ///
  /// In en, this message translates to:
  /// **'Access denied. Farmer or Farm Manager only.'**
  String get accessDeniedFarmerOrFarmManagerOnly;

  /// Tooltip/title for report action menu
  ///
  /// In en, this message translates to:
  /// **'Report actions'**
  String get reportActions;

  /// Print report action
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// Download report action
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// Success message when report pdf is downloaded
  ///
  /// In en, this message translates to:
  /// **'Report downloaded'**
  String get reportDownloaded;

  /// Menu: record a manual finance expense
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addManualExpense;

  /// Title for manual expense form
  ///
  /// In en, this message translates to:
  /// **'Record expense'**
  String get manualExpenseTitle;

  /// Subtitle under manual expense header
  ///
  /// In en, this message translates to:
  /// **'Record purchases and costs not tied to bills or transfers'**
  String get manualExpenseDetailsSubtitle;

  /// Stepper step 1 title
  ///
  /// In en, this message translates to:
  /// **'Expense details'**
  String get manualExpenseBasicStep;

  /// Stepper step 2 title
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get manualExpenseAdditionalStep;

  /// Stepper step 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Quantity, status, and notes'**
  String get manualExpenseAdditionalStepSubtitle;

  /// After saving manual expense
  ///
  /// In en, this message translates to:
  /// **'Expense saved locally. Sync to update the server.'**
  String get manualExpenseSavedSuccessfully;

  /// Manual expense save error
  ///
  /// In en, this message translates to:
  /// **'Could not save expense. Please try again.'**
  String get manualExpenseSaveFailed;

  /// Confirm save manual expense
  ///
  /// In en, this message translates to:
  /// **'Save this expense to your records?'**
  String get confirmSaveManualExpense;

  /// Label for expense description
  ///
  /// In en, this message translates to:
  /// **'What was purchased'**
  String get expenseSubject;

  /// Hint for expense description
  ///
  /// In en, this message translates to:
  /// **'e.g. Feed, fuel, equipment'**
  String get expenseSubjectHint;

  /// Validation expense description
  ///
  /// In en, this message translates to:
  /// **'Please describe the expense'**
  String get expenseSubjectRequired;

  /// Total cost label
  ///
  /// In en, this message translates to:
  /// **'Total amount (TZS)'**
  String get expenseAmount;

  /// Total cost hint
  ///
  /// In en, this message translates to:
  /// **'Enter total cost'**
  String get expenseAmountHint;

  /// Validation amount
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount greater than zero'**
  String get expenseAmountRequired;

  /// Expense date label
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expenseDate;

  /// Validation date
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get expenseDateRequired;

  /// Open date picker
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectExpenseDate;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get expenseQuantity;

  /// Quantity hint
  ///
  /// In en, this message translates to:
  /// **'Units or items (defaults to 1)'**
  String get expenseQuantityHint;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get expenseNotes;

  /// Notes hint
  ///
  /// In en, this message translates to:
  /// **'Optional details'**
  String get expenseNotesHint;

  /// Paid vs pending
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get expensePaymentStatus;

  /// Payment status hint
  ///
  /// In en, this message translates to:
  /// **'Select payment status'**
  String get selectExpensePaymentStatus;

  /// Footer info on manual expense form
  ///
  /// In en, this message translates to:
  /// **'Ensure amounts and dates are correct for your income and expenditure report.'**
  String get manualExpenseAccuracyNote;

  /// Placeholder when a report/PDF table cell has no value
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get reportTableCellPlaceholder;

  /// Section title with number of income/expenditure rows
  ///
  /// In en, this message translates to:
  /// **'Expense entries ({count})'**
  String incomeReportExpenseEntriesSectionTitle(int count);

  /// PDF column: bill number or expense reference
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get incomeReportPdfColumnReference;

  /// PDF column: expense date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get incomeReportPdfColumnDate;

  /// PDF column: expense description
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get incomeReportPdfColumnSubject;

  /// PDF column: quantity
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get incomeReportPdfColumnQuantity;

  /// PDF column: payment status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get incomeReportPdfColumnStatus;

  /// About Us page title
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Last updated label
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// App purpose description
  ///
  /// In en, this message translates to:
  /// **'Tag & Seal is a comprehensive livestock traceability and management system designed to help farmers efficiently track, manage, and monitor their livestock operations. Our platform enables digital tagging, health record management, and real-time analytics for better farm decision-making.'**
  String get appPurpose;

  /// Developed by label
  ///
  /// In en, this message translates to:
  /// **'Developed By'**
  String get developedBy;

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'Climb Up Limited'**
  String get companyName;

  /// Managing director label
  ///
  /// In en, this message translates to:
  /// **'Managing Director'**
  String get managingDirector;

  /// Director name
  ///
  /// In en, this message translates to:
  /// **'Emmanuel Ngallah'**
  String get directorName;

  /// Company description
  ///
  /// In en, this message translates to:
  /// **'Climb Up Limited is a technology company empowering agriculture, utilities, and enterprise ecosystems through transformative ICT solutions built for Africa\'s realities and tomorrow\'s challenges. We specialize in livestock traceability, agricultural value chains, and utility management, delivering innovative platforms that optimize operations in real-time while advancing environmental stewardship.'**
  String get companyDescription;

  /// Compliance section title
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// Livestock Act compliance text
  ///
  /// In en, this message translates to:
  /// **'Livestock Act Compliance'**
  String get livestockAct;

  /// Traceability regulations text
  ///
  /// In en, this message translates to:
  /// **'Traceability Regulations'**
  String get traceabilityRegulations;

  /// ISO standards text
  ///
  /// In en, this message translates to:
  /// **'ISO Standards'**
  String get isoStandards;

  /// Farm registration feature
  ///
  /// In en, this message translates to:
  /// **'Farm Registration'**
  String get farmRegistration;

  /// Farm registration description
  ///
  /// In en, this message translates to:
  /// **'Register and manage multiple farms with detailed information and location tracking'**
  String get farmRegistrationDesc;

  /// Animal tracking feature
  ///
  /// In en, this message translates to:
  /// **'Animal Tracking'**
  String get animalTracking;

  /// Animal tracking description
  ///
  /// In en, this message translates to:
  /// **'Track individual animals with digital tags, RFID, barcodes, and comprehensive identification'**
  String get animalTrackingDesc;

  /// Reports and analytics description
  ///
  /// In en, this message translates to:
  /// **'Generate comprehensive reports and analytics for better farm management and decision-making'**
  String get reportsAnalyticsDesc;

  /// Support page title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Contact us label
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Support email address
  ///
  /// In en, this message translates to:
  /// **'info@climbup.co.tz'**
  String get supportEmail;

  /// Support phone number
  ///
  /// In en, this message translates to:
  /// **'+255 652 433 633 | +255 739 633 433'**
  String get supportPhone;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Company address
  ///
  /// In en, this message translates to:
  /// **'55 Ally Sykes, Kawe Beach, Kinondoni'**
  String get companyAddress;

  /// Working hours label
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// Working hours value
  ///
  /// In en, this message translates to:
  /// **'8.00am - 5.00pm'**
  String get workingHoursValue;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// FAQ question 1
  ///
  /// In en, this message translates to:
  /// **'How do I register my farm?'**
  String get faq1;

  /// FAQ answer 1
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard, tap \'Create New Farm\', fill in your farm details, and submit. Your farm will be registered and ready to use.'**
  String get faq1Answer;

  /// FAQ question 2
  ///
  /// In en, this message translates to:
  /// **'How do I add livestock?'**
  String get faq2;

  /// FAQ answer 2
  ///
  /// In en, this message translates to:
  /// **'Navigate to Livestock tab, tap the \'+\' button, fill in livestock details including tag ID, name, breed, and other information, then save.'**
  String get faq2Answer;

  /// FAQ question 3
  ///
  /// In en, this message translates to:
  /// **'How does offline mode work?'**
  String get faq3;

  /// FAQ answer 3
  ///
  /// In en, this message translates to:
  /// **'The app works offline. All data is stored locally and automatically syncs when you have internet connection. Tap the sync button to manually sync data.'**
  String get faq3Answer;

  /// FAQ question 4
  ///
  /// In en, this message translates to:
  /// **'How do I sync my data?'**
  String get faq4;

  /// FAQ answer 4
  ///
  /// In en, this message translates to:
  /// **'Tap the sync button (refresh icon) in the Dashboard. The app will upload local changes and download updates from the server.'**
  String get faq4Answer;

  /// Need more help text
  ///
  /// In en, this message translates to:
  /// **'Need More Help?'**
  String get needMoreHelp;

  /// Contact support message
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or need assistance, please contact our support team.'**
  String get contactSupportMessage;

  /// Privacy policy last updated date
  ///
  /// In en, this message translates to:
  /// **'Last Updated: January 2024'**
  String get privacyPolicyLastUpdated;

  /// Privacy policy introduction section
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyPolicyIntroduction;

  /// Privacy policy introduction text
  ///
  /// In en, this message translates to:
  /// **'Tag & Seal respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'**
  String get privacyPolicyIntroductionText;

  /// Privacy policy information we collect section
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privacyPolicyInformationWeCollect;

  /// Privacy policy information we collect text
  ///
  /// In en, this message translates to:
  /// **'We collect information that you provide directly to us, including farm details, livestock data, health records, and user account information. We also collect device information, location data (with your permission), and usage statistics to improve our services.'**
  String get privacyPolicyInformationWeCollectText;

  /// Privacy policy how we use information section
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get privacyPolicyHowWeUseInformation;

  /// Privacy policy how we use information text
  ///
  /// In en, this message translates to:
  /// **'We use the collected information to provide, maintain, and improve our services, process your requests, send you notifications, and ensure compliance with livestock regulations. We do not sell your personal information to third parties.'**
  String get privacyPolicyHowWeUseInformationText;

  /// Privacy policy data security section
  ///
  /// In en, this message translates to:
  /// **'Data Security'**
  String get privacyPolicyDataSecurity;

  /// Privacy policy data security text
  ///
  /// In en, this message translates to:
  /// **'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Your data is encrypted both in transit and at rest, and we regularly review our security practices.'**
  String get privacyPolicyDataSecurityText;

  /// Privacy policy your rights section
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyPolicyYourRights;

  /// Privacy policy your rights text
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, update, or delete your personal information at any time. You can also request a copy of your data or withdraw consent for data processing. To exercise these rights, please contact us using the information provided below.'**
  String get privacyPolicyYourRightsText;

  /// Privacy policy contact us section
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyPolicyContactUs;

  /// Privacy policy contact us text
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at info@climbup.co.tz or through the app\'s support section.'**
  String get privacyPolicyContactUsText;

  /// Terms of service last updated date
  ///
  /// In en, this message translates to:
  /// **'Last Updated: January 2024'**
  String get termsOfServiceLastUpdated;

  /// Terms of service introduction section
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get termsOfServiceIntroduction;

  /// Terms of service introduction text
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tag & Seal. These Terms of Service govern your use of our mobile application and services. By accessing or using our app, you agree to be bound by these terms.'**
  String get termsOfServiceIntroductionText;

  /// Terms of service acceptance section
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsOfServiceAcceptance;

  /// Terms of service acceptance text
  ///
  /// In en, this message translates to:
  /// **'By downloading, installing, or using Tag & Seal, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree, please do not use our services.'**
  String get termsOfServiceAcceptanceText;

  /// Terms of service user accounts section
  ///
  /// In en, this message translates to:
  /// **'User Accounts'**
  String get termsOfServiceUserAccounts;

  /// Terms of service user accounts text
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account. We reserve the right to suspend or terminate accounts that violate these terms.'**
  String get termsOfServiceUserAccountsText;

  /// Terms of service use of service section
  ///
  /// In en, this message translates to:
  /// **'Use of Service'**
  String get termsOfServiceUseOfService;

  /// Terms of service use of service text
  ///
  /// In en, this message translates to:
  /// **'You agree to use Tag & Seal only for lawful purposes and in accordance with these Terms. You may not use the service to violate any laws, infringe on others\' rights, transmit harmful code, or interfere with the operation of the service.'**
  String get termsOfServiceUseOfServiceText;

  /// Terms of service intellectual property section
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get termsOfServiceIntellectualProperty;

  /// Terms of service intellectual property text
  ///
  /// In en, this message translates to:
  /// **'All content, features, and functionality of Tag & Seal, including but not limited to text, graphics, logos, and software, are owned by CLIMB UP LTD and are protected by copyright, trademark, and other intellectual property laws.'**
  String get termsOfServiceIntellectualPropertyText;

  /// Terms of service limitation of liability section
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get termsOfServiceLimitationOfLiability;

  /// Terms of service limitation of liability text
  ///
  /// In en, this message translates to:
  /// **'Tag & Seal is provided \'as is\' without warranties of any kind. We are not liable for any damages arising from your use of the service, including but not limited to data loss, business interruption, or indirect damages.'**
  String get termsOfServiceLimitationOfLiabilityText;

  /// Terms of service changes to terms section
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get termsOfServiceChangesToTerms;

  /// Terms of service changes to terms text
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these Terms of Service at any time. We will notify users of significant changes through the app or via email. Continued use of the service after changes constitutes acceptance of the new terms.'**
  String get termsOfServiceChangesToTermsText;

  /// Confirmation message for marking bill as paid
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this bill as paid?'**
  String get markBillAsPaidConfirmation;

  /// Button text to mark bill as paid
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// Success message after marking bill as paid
  ///
  /// In en, this message translates to:
  /// **'Bill marked as paid successfully'**
  String get billMarkedAsPaid;

  /// Title for milking trend graph
  ///
  /// In en, this message translates to:
  /// **'Milking Trend'**
  String get milkingTrend;

  /// Title for multi-farm milking trend graph
  ///
  /// In en, this message translates to:
  /// **'Milking Trend by Farm'**
  String get milkingTrendByFarm;

  /// Time period filter for last 6 months
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get last6Months;

  /// Time period filter for previous day
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Time period filter for current month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Time period filter for last 6 years
  ///
  /// In en, this message translates to:
  /// **'Last 6 Years'**
  String get last6Years;

  /// Time period filter for last year
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get lastYear;

  /// Average value label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Maximum value label
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// Confirmation dialog question when changing livestock status from lost to active
  ///
  /// In en, this message translates to:
  /// **'Is Livestock Found?'**
  String get isLivestockFound;

  /// Success message when livestock is found and disposal records are removed
  ///
  /// In en, this message translates to:
  /// **'Livestock status updated to active. Disposal records removed.'**
  String get livestockStatusUpdatedAndDisposalRemoved;

  /// Title for the confirmation dialog when marking lost livestock as found
  ///
  /// In en, this message translates to:
  /// **'Mark Livestock as Found'**
  String get markLivestockAsFound;

  /// Description in the confirmation dialog explaining that the livestock was lost
  ///
  /// In en, this message translates to:
  /// **'This livestock was previously marked as lost. If the livestock has been found, you can mark it as active again.'**
  String get livestockFoundConfirmationDescription;

  /// Label indicating that the livestock was marked as lost
  ///
  /// In en, this message translates to:
  /// **'Livestock was marked as Lost'**
  String get livestockWasMarkedAsLost;

  /// Description of what will happen when user confirms
  ///
  /// In en, this message translates to:
  /// **'By confirming, the livestock status will be changed to active and the disposal record will be removed.'**
  String get livestockFoundActionDescription;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Copyright text suffix
  ///
  /// In en, this message translates to:
  /// **'All Rights Reserved'**
  String get copyrightText;

  /// No description provided for @teethClipping.
  ///
  /// In en, this message translates to:
  /// **'Teeth clipping'**
  String get teethClipping;

  /// No description provided for @tailDocking.
  ///
  /// In en, this message translates to:
  /// **'Tail docking'**
  String get tailDocking;

  /// No description provided for @ironInjection.
  ///
  /// In en, this message translates to:
  /// **'Iron injection'**
  String get ironInjection;

  /// No description provided for @livestockMarking.
  ///
  /// In en, this message translates to:
  /// **'Livestock marking'**
  String get livestockMarking;

  /// No description provided for @stageChange.
  ///
  /// In en, this message translates to:
  /// **'Stage change'**
  String get stageChange;

  /// No description provided for @procedureMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get procedureMethod;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @markingType.
  ///
  /// In en, this message translates to:
  /// **'Marking type'**
  String get markingType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @fromStage.
  ///
  /// In en, this message translates to:
  /// **'From stage'**
  String get fromStage;

  /// No description provided for @toStage.
  ///
  /// In en, this message translates to:
  /// **'To stage'**
  String get toStage;

  /// No description provided for @selectFromStage.
  ///
  /// In en, this message translates to:
  /// **'Select from stage'**
  String get selectFromStage;

  /// No description provided for @selectToStage.
  ///
  /// In en, this message translates to:
  /// **'Select to stage'**
  String get selectToStage;

  /// No description provided for @selectProcedureMethod.
  ///
  /// In en, this message translates to:
  /// **'Select method'**
  String get selectProcedureMethod;

  /// No description provided for @eventDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Event date is required'**
  String get eventDateRequired;

  /// No description provided for @husbandryRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields'**
  String get husbandryRequiredFields;

  /// No description provided for @husbandryFromToStageMismatch.
  ///
  /// In en, this message translates to:
  /// **'From and To stage cannot be the same'**
  String get husbandryFromToStageMismatch;

  /// No description provided for @eventLogSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get eventLogSavedSuccessfully;

  /// No description provided for @saleWeight.
  ///
  /// In en, this message translates to:
  /// **'Sale weight (kg)'**
  String get saleWeight;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePrice;

  /// No description provided for @buyerName.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerName;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get stage;

  /// No description provided for @identificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Identification status'**
  String get identificationStatus;

  /// No description provided for @identified.
  ///
  /// In en, this message translates to:
  /// **'Identified'**
  String get identified;

  /// No description provided for @notIdentified.
  ///
  /// In en, this message translates to:
  /// **'Not identified'**
  String get notIdentified;

  /// No description provided for @birthEventOptional.
  ///
  /// In en, this message translates to:
  /// **'Birth event (optional)'**
  String get birthEventOptional;

  /// Helper text below optional birth event field in Add Livestock form
  ///
  /// In en, this message translates to:
  /// **'Link this animal to a recorded birth event (farrowing/calving). Leave empty for purchased, transferred, donated, or other non-birth registrations.'**
  String get birthEventOptionalHelper;

  /// Reminder that Add Livestock is not only for newborn animals
  ///
  /// In en, this message translates to:
  /// **'Add Livestock is for all animals: newborn, purchased, transferred, donated, and more.'**
  String get addLivestockAllTypesReminder;

  /// No description provided for @totalBorn.
  ///
  /// In en, this message translates to:
  /// **'Total born'**
  String get totalBorn;

  /// No description provided for @aliveCount.
  ///
  /// In en, this message translates to:
  /// **'Alive count'**
  String get aliveCount;

  /// No description provided for @alive.
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get alive;

  /// No description provided for @deadCount.
  ///
  /// In en, this message translates to:
  /// **'Dead count'**
  String get deadCount;

  /// No description provided for @dead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get dead;

  /// No description provided for @enterTotalBornOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter total born (optional)'**
  String get enterTotalBornOptional;

  /// No description provided for @enterAliveCountOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter alive count (optional)'**
  String get enterAliveCountOptional;

  /// No description provided for @enterDeadCountOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter dead count (optional)'**
  String get enterDeadCountOptional;

  /// No description provided for @valueMustBeZeroOrMore.
  ///
  /// In en, this message translates to:
  /// **'Value must be 0 or more'**
  String get valueMustBeZeroOrMore;

  /// No description provided for @aliveDeadExceedTotalBorn.
  ///
  /// In en, this message translates to:
  /// **'Alive + dead cannot exceed total born.'**
  String get aliveDeadExceedTotalBorn;

  /// No description provided for @deadCountDefaultsToZero.
  ///
  /// In en, this message translates to:
  /// **'Defaults to 0 (max = total born)'**
  String get deadCountDefaultsToZero;

  /// No description provided for @aliveCountDerivedNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated as total born minus dead.'**
  String get aliveCountDerivedNote;

  /// No description provided for @enterTotalBornToPreviewAlive.
  ///
  /// In en, this message translates to:
  /// **'Enter total born to preview alive count.'**
  String get enterTotalBornToPreviewAlive;

  /// No description provided for @deadCountExceedsTotalBorn.
  ///
  /// In en, this message translates to:
  /// **'Dead count cannot exceed total born.'**
  String get deadCountExceedsTotalBorn;

  /// Dialog title after saving a farrowing event
  ///
  /// In en, this message translates to:
  /// **'Register Piglets?'**
  String get farrowingPigletRegisterPromptTitle;

  /// Dialog body after saving farrowing
  ///
  /// In en, this message translates to:
  /// **'The farrowing event has been saved. Would you like to register the piglets from this litter now?'**
  String get farrowingPigletRegisterPromptMessage;

  /// No description provided for @farrowingPigletRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register Piglets'**
  String get farrowingPigletRegisterNow;

  /// No description provided for @farrowingPigletRegisterSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get farrowingPigletRegisterSkip;

  /// No description provided for @calvingRegisterPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Calves?'**
  String get calvingRegisterPromptTitle;

  /// No description provided for @calvingRegisterPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'The calving event has been saved. Would you like to register the calves from this birth now?'**
  String get calvingRegisterPromptMessage;

  /// No description provided for @calvingRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register Calves'**
  String get calvingRegisterNow;

  /// No description provided for @birthEventRegisterPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Offspring?'**
  String get birthEventRegisterPromptTitle;

  /// No description provided for @birthEventRegisterPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'The birth event has been saved. Would you like to register the offspring from this birth now?'**
  String get birthEventRegisterPromptMessage;

  /// No description provided for @birthEventRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register Offspring'**
  String get birthEventRegisterNow;

  /// No description provided for @prepuceConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepuce (sheath) condition'**
  String get prepuceConditionTitle;

  /// No description provided for @prepuceConditionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition type'**
  String get prepuceConditionTypeLabel;

  /// No description provided for @prepuceConditionSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get prepuceConditionSeverityLabel;

  /// No description provided for @prepuceConditionClinicalSignsLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinical signs'**
  String get prepuceConditionClinicalSignsLabel;

  /// No description provided for @prepuceConditionTreatmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Treatment given'**
  String get prepuceConditionTreatmentLabel;

  /// No description provided for @prepuceConditionCauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Cause / risk (optional)'**
  String get prepuceConditionCauseLabel;

  /// No description provided for @prepuceConditionBreedingLabel.
  ///
  /// In en, this message translates to:
  /// **'Breeding status'**
  String get prepuceConditionBreedingLabel;

  /// No description provided for @prepuceConditionReportedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported by'**
  String get prepuceConditionReportedByLabel;

  /// No description provided for @prepuceConditionAttendedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Attended by (optional)'**
  String get prepuceConditionAttendedByLabel;

  /// No description provided for @prepuceConditionHealingLabel.
  ///
  /// In en, this message translates to:
  /// **'Healing status (optional)'**
  String get prepuceConditionHealingLabel;

  /// No description provided for @prepuceConditionFollowUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow-up date (optional)'**
  String get prepuceConditionFollowUpLabel;

  /// No description provided for @prepuceConditionDrugNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug name (optional)'**
  String get prepuceConditionDrugNameLabel;

  /// No description provided for @prepuceConditionRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Route (optional)'**
  String get prepuceConditionRouteLabel;

  /// No description provided for @prepuceConditionDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (optional)'**
  String get prepuceConditionDurationLabel;

  /// No description provided for @prepuceConditionVetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Vet name (optional)'**
  String get prepuceConditionVetNameLabel;

  /// No description provided for @prepuceConditionVetContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Vet contact (optional)'**
  String get prepuceConditionVetContactLabel;

  /// No description provided for @prepuceConditionFollowUpHint.
  ///
  /// In en, this message translates to:
  /// **'Select follow-up date'**
  String get prepuceConditionFollowUpHint;

  /// No description provided for @prepuceConditionTreatmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one treatment'**
  String get prepuceConditionTreatmentRequired;

  /// No description provided for @prepuceConditionSelectCodes.
  ///
  /// In en, this message translates to:
  /// **'Select options above'**
  String get prepuceConditionSelectCodes;

  /// No description provided for @viewEvents.
  ///
  /// In en, this message translates to:
  /// **'View events'**
  String get viewEvents;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
