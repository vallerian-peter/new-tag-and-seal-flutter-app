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

  /// No description provided for @save.
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

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @unsyncedDataWarning.
  ///
  /// In en, this message translates to:
  /// **'You have unsynced changes. What would you like to do?'**
  String get unsyncedDataWarning;

  /// No description provided for @noUnsyncedDataMessage.
  ///
  /// In en, this message translates to:
  /// **'All data is synced. You can safely logout.'**
  String get noUnsyncedDataMessage;

  /// No description provided for @syncAndLogout.
  ///
  /// In en, this message translates to:
  /// **'Sync & logout'**
  String get syncAndLogout;

  /// No description provided for @syncingBeforeLogout.
  ///
  /// In en, this message translates to:
  /// **'Syncing your data before logging out...'**
  String get syncingBeforeLogout;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
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

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not Provoded'**
  String get notProvided;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @recordsText.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsText;

  /// No description provided for @logsText.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsText;

  /// No description provided for @bulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get bulk;

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

  /// Label for displaying the farm unique identifier
  ///
  /// In en, this message translates to:
  /// **'Farm UUID'**
  String get farmUuidLabel;

  /// Snack bar message shown when a value is copied
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

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

  /// No description provided for @upcomingToday.
  ///
  /// In en, this message translates to:
  /// **'Upcoming today'**
  String get upcomingToday;

  /// No description provided for @upcomingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Upcoming notifications'**
  String get upcomingNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get allNotifications;

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

  /// No description provided for @addNotification.
  ///
  /// In en, this message translates to:
  /// **'Add notification'**
  String get addNotification;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationTitle;

  /// No description provided for @enterNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get enterNotificationTitle;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get notificationDescription;

  /// No description provided for @enterNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get enterNotificationDescription;

  /// No description provided for @scheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get scheduleDate;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get scheduleTime;

  /// No description provided for @saveNotification.
  ///
  /// In en, this message translates to:
  /// **'Save notification'**
  String get saveNotification;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @optionalFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalFieldHint;

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
  /// **'Scheduled on {date}'**
  String notificationScheduledOn(String date);

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

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

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

  /// No description provided for @offlineCapability.
  ///
  /// In en, this message translates to:
  /// **'Offline Capability'**
  String get offlineCapability;

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

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorksTitle;

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

  /// No description provided for @healthRecordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain complete health records including vaccinations, medications, and treatments'**
  String get healthRecordsDesc;

  /// No description provided for @analyticsReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analyticsReports;

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

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All events'**
  String get allEvents;

  /// No description provided for @eventsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review every log recorded across your farms.'**
  String get eventsScreenSubtitle;

  /// No description provided for @totalLogs.
  ///
  /// In en, this message translates to:
  /// **'Total logs'**
  String get totalLogs;

  /// No description provided for @eventTypes.
  ///
  /// In en, this message translates to:
  /// **'Event types'**
  String get eventTypes;

  /// No description provided for @readyOffline.
  ///
  /// In en, this message translates to:
  /// **'Ready offline'**
  String get readyOffline;

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

  /// No description provided for @milkingMethod.
  ///
  /// In en, this message translates to:
  /// **'Milking Method'**
  String get milkingMethod;

  /// No description provided for @lactometerReading.
  ///
  /// In en, this message translates to:
  /// **'Lactometer Reading'**
  String get lactometerReading;

  /// No description provided for @solids.
  ///
  /// In en, this message translates to:
  /// **'Solids'**
  String get solids;

  /// No description provided for @solidNonFat.
  ///
  /// In en, this message translates to:
  /// **'Solid Non-Fat'**
  String get solidNonFat;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @correctedLactometerReading.
  ///
  /// In en, this message translates to:
  /// **'Corrected Lactometer Reading'**
  String get correctedLactometerReading;

  /// No description provided for @totalSolids.
  ///
  /// In en, this message translates to:
  /// **'Total Solids'**
  String get totalSolids;

  /// No description provided for @colonyFormingUnits.
  ///
  /// In en, this message translates to:
  /// **'Colony Forming Units'**
  String get colonyFormingUnits;

  /// No description provided for @acidity.
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidity;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get testResult;

  /// No description provided for @numberOfMonths.
  ///
  /// In en, this message translates to:
  /// **'Number of Months'**
  String get numberOfMonths;

  /// No description provided for @testDate.
  ///
  /// In en, this message translates to:
  /// **'Test Date'**
  String get testDate;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @calvingType.
  ///
  /// In en, this message translates to:
  /// **'Calving Type'**
  String get calvingType;

  /// No description provided for @calvingProblem.
  ///
  /// In en, this message translates to:
  /// **'Calving Problem'**
  String get calvingProblem;

  /// No description provided for @reproductiveProblem.
  ///
  /// In en, this message translates to:
  /// **'Reproductive Problem'**
  String get reproductiveProblem;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @heatType.
  ///
  /// In en, this message translates to:
  /// **'Heat Type'**
  String get heatType;

  /// No description provided for @inseminationService.
  ///
  /// In en, this message translates to:
  /// **'Insemination Service'**
  String get inseminationService;

  /// No description provided for @semenStrawType.
  ///
  /// In en, this message translates to:
  /// **'Semen Straw Type'**
  String get semenStrawType;

  /// No description provided for @inseminationDate.
  ///
  /// In en, this message translates to:
  /// **'Insemination Date'**
  String get inseminationDate;

  /// No description provided for @bullCode.
  ///
  /// In en, this message translates to:
  /// **'Bull Code'**
  String get bullCode;

  /// No description provided for @bullBreed.
  ///
  /// In en, this message translates to:
  /// **'Bull Breed'**
  String get bullBreed;

  /// No description provided for @semenProductionDate.
  ///
  /// In en, this message translates to:
  /// **'Semen Production Date'**
  String get semenProductionDate;

  /// No description provided for @productionCountry.
  ///
  /// In en, this message translates to:
  /// **'Production Country'**
  String get productionCountry;

  /// No description provided for @semenBatchNumber.
  ///
  /// In en, this message translates to:
  /// **'Semen Batch Number'**
  String get semenBatchNumber;

  /// No description provided for @internationalId.
  ///
  /// In en, this message translates to:
  /// **'International ID'**
  String get internationalId;

  /// No description provided for @aiCode.
  ///
  /// In en, this message translates to:
  /// **'AI Code'**
  String get aiCode;

  /// No description provided for @manufacturerName.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Name'**
  String get manufacturerName;

  /// No description provided for @semenSupplier.
  ///
  /// In en, this message translates to:
  /// **'Semen Supplier'**
  String get semenSupplier;

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

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight Change'**
  String get weightChange;

  /// No description provided for @disposal.
  ///
  /// In en, this message translates to:
  /// **'Disposal'**
  String get disposal;

  /// No description provided for @calving.
  ///
  /// In en, this message translates to:
  /// **'Calving'**
  String get calving;

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

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

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

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @addVaccination.
  ///
  /// In en, this message translates to:
  /// **'Add vaccination'**
  String get addVaccination;

  /// No description provided for @vaccinationDetails.
  ///
  /// In en, this message translates to:
  /// **'Vaccination details'**
  String get vaccinationDetails;

  /// No description provided for @vaccinationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture vaccination log information'**
  String get vaccinationDetailsSubtitle;

  /// No description provided for @vaccinationNumber.
  ///
  /// In en, this message translates to:
  /// **'Vaccination number'**
  String get vaccinationNumber;

  /// No description provided for @enterVaccinationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter vaccination number (optional)'**
  String get enterVaccinationNumber;

  /// No description provided for @selectVaccine.
  ///
  /// In en, this message translates to:
  /// **'Select vaccine'**
  String get selectVaccine;

  /// No description provided for @vaccineOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'No vaccines available. Please add vaccines first.'**
  String get vaccineOptionsMissing;

  /// No description provided for @diseaseId.
  ///
  /// In en, this message translates to:
  /// **'Disease ID'**
  String get diseaseId;

  /// No description provided for @enterDiseaseIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter disease ID (optional)'**
  String get enterDiseaseIdOptional;

  /// No description provided for @selectDisease.
  ///
  /// In en, this message translates to:
  /// **'Select disease'**
  String get selectDisease;

  /// No description provided for @diseaseOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'No diseases available. Please sync to download disease data.'**
  String get diseaseOptionsMissing;

  /// No description provided for @vaccinationStatus.
  ///
  /// In en, this message translates to:
  /// **'Vaccination status'**
  String get vaccinationStatus;

  /// No description provided for @vaccinationContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Select the farm and livestock to log this vaccination.'**
  String get vaccinationContextInfo;

  /// No description provided for @vaccinationPersonnelDetails.
  ///
  /// In en, this message translates to:
  /// **'Personnel details'**
  String get vaccinationPersonnelDetails;

  /// No description provided for @vaccinationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record vet or extension officer details for auditing.'**
  String get vaccinationNotesInfo;

  /// No description provided for @confirmSaveVaccination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this vaccination log?'**
  String get confirmSaveVaccination;

  /// No description provided for @confirmUpdateVaccination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this vaccination log?'**
  String get confirmUpdateVaccination;

  /// No description provided for @invalidDiseaseId.
  ///
  /// In en, this message translates to:
  /// **'Invalid disease ID.'**
  String get invalidDiseaseId;

  /// No description provided for @vaccinationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save vaccination log.'**
  String get vaccinationLogSaveFailed;

  /// No description provided for @vaccinationLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Vaccination log saved successfully.'**
  String get vaccinationLogSaved;

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

  /// No description provided for @addMilking.
  ///
  /// In en, this message translates to:
  /// **'Add milking'**
  String get addMilking;

  /// No description provided for @milkingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture milking measurements for this livestock'**
  String get milkingDetailsSubtitle;

  /// No description provided for @milkingNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record laboratory metrics and additional notes'**
  String get milkingNotesSubtitle;

  /// No description provided for @milkingMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'Milking method is required'**
  String get milkingMethodRequired;

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
  /// **'Ensure the milking information is accurate before saving.'**
  String get ensureMilkingDetailsAccuracy;

  /// No description provided for @milkingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record measurements such as solids and lactometer readings (optional).'**
  String get milkingNotesInfo;

  /// No description provided for @confirmSaveMilking.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this milking log?'**
  String get confirmSaveMilking;

  /// No description provided for @confirmUpdateMilking.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this milking log?'**
  String get confirmUpdateMilking;

  /// No description provided for @milkingLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Milking log saved successfully.'**
  String get milkingLogSaved;

  /// No description provided for @milkingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save milking log.'**
  String get milkingLogSaveFailed;

  /// No description provided for @addPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Add pregnancy'**
  String get addPregnancy;

  /// No description provided for @pregnancyDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture pregnancy diagnosis details'**
  String get pregnancyDetailsSubtitle;

  /// No description provided for @pregnancyNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add remarks about the pregnancy (optional)'**
  String get pregnancyNotesSubtitle;

  /// No description provided for @testResultRequired.
  ///
  /// In en, this message translates to:
  /// **'Test result is required'**
  String get testResultRequired;

  /// No description provided for @testDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Test date is required'**
  String get testDateRequired;

  /// No description provided for @ensurePregnancyDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the pregnancy information is accurate before saving.'**
  String get ensurePregnancyDetailsAccuracy;

  /// No description provided for @pregnancyNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record any additional notes from the pregnancy diagnosis.'**
  String get pregnancyNotesInfo;

  /// No description provided for @confirmSavePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this pregnancy log?'**
  String get confirmSavePregnancy;

  /// No description provided for @confirmUpdatePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this pregnancy log?'**
  String get confirmUpdatePregnancy;

  /// No description provided for @pregnancyLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy log saved successfully.'**
  String get pregnancyLogSaved;

  /// No description provided for @pregnancyLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save pregnancy log.'**
  String get pregnancyLogSaveFailed;

  /// No description provided for @addCalving.
  ///
  /// In en, this message translates to:
  /// **'Add calving'**
  String get addCalving;

  /// No description provided for @calvingDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture calving timelines and outcomes'**
  String get calvingDetailsSubtitle;

  /// No description provided for @calvingNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add remarks about the calving process'**
  String get calvingNotesSubtitle;

  /// No description provided for @calvingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Calving type is required'**
  String get calvingTypeRequired;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date is required'**
  String get startDateRequired;

  /// No description provided for @ensureCalvingDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the calving information is accurate before saving.'**
  String get ensureCalvingDetailsAccuracy;

  /// No description provided for @calvingNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record any reproductive or calving complications.'**
  String get calvingNotesInfo;

  /// No description provided for @confirmSaveCalving.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this calving log?'**
  String get confirmSaveCalving;

  /// No description provided for @confirmUpdateCalving.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this calving log?'**
  String get confirmUpdateCalving;

  /// No description provided for @calvingLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Calving log saved successfully.'**
  String get calvingLogSaved;

  /// No description provided for @calvingLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save calving log.'**
  String get calvingLogSaveFailed;

  /// No description provided for @addDryoff.
  ///
  /// In en, this message translates to:
  /// **'Add dryoff'**
  String get addDryoff;

  /// No description provided for @dryoffDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture dryoff schedules for this livestock'**
  String get dryoffDetailsSubtitle;

  /// No description provided for @dryoffNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add remarks about the dryoff process'**
  String get dryoffNotesSubtitle;

  /// No description provided for @ensureDryoffDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the dryoff information is accurate before saving.'**
  String get ensureDryoffDetailsAccuracy;

  /// No description provided for @dryoffNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record notes about the dryoff (optional).'**
  String get dryoffNotesInfo;

  /// No description provided for @confirmSaveDryoff.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this dryoff log?'**
  String get confirmSaveDryoff;

  /// No description provided for @confirmUpdateDryoff.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this dryoff log?'**
  String get confirmUpdateDryoff;

  /// No description provided for @dryoffLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Dryoff log saved successfully.'**
  String get dryoffLogSaved;

  /// No description provided for @dryoffLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save dryoff log.'**
  String get dryoffLogSaveFailed;

  /// No description provided for @addInsemination.
  ///
  /// In en, this message translates to:
  /// **'Add insemination'**
  String get addInsemination;

  /// No description provided for @inseminationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture insemination services and heat details'**
  String get inseminationDetailsSubtitle;

  /// No description provided for @inseminationNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add insemination batch and supplier notes'**
  String get inseminationNotesSubtitle;

  /// No description provided for @lastHeatDate.
  ///
  /// In en, this message translates to:
  /// **'Last heat date'**
  String get lastHeatDate;

  /// No description provided for @heatTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Heat type is required'**
  String get heatTypeRequired;

  /// No description provided for @inseminationServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Insemination service is required'**
  String get inseminationServiceRequired;

  /// No description provided for @semenStrawTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Semen straw type is required'**
  String get semenStrawTypeRequired;

  /// No description provided for @ensureInseminationDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the insemination information is accurate before saving.'**
  String get ensureInseminationDetailsAccuracy;

  /// No description provided for @inseminationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Record batch, supplier, and bull details (optional).'**
  String get inseminationNotesInfo;

  /// No description provided for @confirmSaveInsemination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this insemination log?'**
  String get confirmSaveInsemination;

  /// No description provided for @confirmUpdateInsemination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this insemination log?'**
  String get confirmUpdateInsemination;

  /// No description provided for @inseminationLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Insemination log saved successfully.'**
  String get inseminationLogSaved;

  /// No description provided for @inseminationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save insemination log.'**
  String get inseminationLogSaveFailed;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get addMedication;

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Medication details'**
  String get medicationDetails;

  /// No description provided for @medicationDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture treatment details for this livestock'**
  String get medicationDetailsSubtitle;

  /// No description provided for @medicationContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Select the farm and livestock before recording the medication.'**
  String get medicationContextInfo;

  /// No description provided for @medicationNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes about the treatment (optional).'**
  String get medicationNotesInfo;

  /// No description provided for @quantityAmount.
  ///
  /// In en, this message translates to:
  /// **'Quantity amount'**
  String get quantityAmount;

  /// No description provided for @quantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get quantityUnit;

  /// No description provided for @selectQuantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Select unit'**
  String get selectQuantityUnit;

  /// No description provided for @quantityUnitMl.
  ///
  /// In en, this message translates to:
  /// **'Milliliters (ml)'**
  String get quantityUnitMl;

  /// No description provided for @quantityUnitL.
  ///
  /// In en, this message translates to:
  /// **'Liters (l)'**
  String get quantityUnitL;

  /// No description provided for @quantityUnitMg.
  ///
  /// In en, this message translates to:
  /// **'Milligrams (mg)'**
  String get quantityUnitMg;

  /// No description provided for @quantityUnitG.
  ///
  /// In en, this message translates to:
  /// **'Grams (g)'**
  String get quantityUnitG;

  /// No description provided for @quantityUnitKg.
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get quantityUnitKg;

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

  /// No description provided for @withdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal amount'**
  String get withdrawalAmount;

  /// No description provided for @withdrawalUnit.
  ///
  /// In en, this message translates to:
  /// **'Period unit'**
  String get withdrawalUnit;

  /// No description provided for @selectWithdrawalUnit.
  ///
  /// In en, this message translates to:
  /// **'Select period unit'**
  String get selectWithdrawalUnit;

  /// No description provided for @withdrawalUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get withdrawalUnitMinutes;

  /// No description provided for @withdrawalUnitHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get withdrawalUnitHours;

  /// No description provided for @withdrawalUnitDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get withdrawalUnitDays;

  /// No description provided for @withdrawalUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get withdrawalUnitWeeks;

  /// No description provided for @withdrawalUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get withdrawalUnitMonths;

  /// No description provided for @withdrawalUnitYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get withdrawalUnitYears;

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

  /// No description provided for @confirmSaveMedication.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this medication log?'**
  String get confirmSaveMedication;

  /// No description provided for @confirmUpdateMedication.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this medication log?'**
  String get confirmUpdateMedication;

  /// No description provided for @medicationLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Medication log saved successfully.'**
  String get medicationLogSaved;

  /// No description provided for @medicationLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save medication log.'**
  String get medicationLogSaveFailed;

  /// No description provided for @addDisposal.
  ///
  /// In en, this message translates to:
  /// **'Add disposal'**
  String get addDisposal;

  /// No description provided for @disposalDetails.
  ///
  /// In en, this message translates to:
  /// **'Disposal details'**
  String get disposalDetails;

  /// No description provided for @disposalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture the reason and status of the disposal'**
  String get disposalDetailsSubtitle;

  /// No description provided for @disposalContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Select the farm and livestock before recording the disposal.'**
  String get disposalContextInfo;

  /// No description provided for @disposalReasons.
  ///
  /// In en, this message translates to:
  /// **'Reasons'**
  String get disposalReasons;

  /// No description provided for @enterDisposalReasons.
  ///
  /// In en, this message translates to:
  /// **'Enter reasons'**
  String get enterDisposalReasons;

  /// No description provided for @disposalTypeId.
  ///
  /// In en, this message translates to:
  /// **'Disposal type'**
  String get disposalTypeId;

  /// No description provided for @enterDisposalTypeIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter disposal type (optional)'**
  String get enterDisposalTypeIdOptional;

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

  /// No description provided for @disposalTypeOptionsMissing.
  ///
  /// In en, this message translates to:
  /// **'No disposal types available. Please sync to download reference data.'**
  String get disposalTypeOptionsMissing;

  /// No description provided for @disposalStatus.
  ///
  /// In en, this message translates to:
  /// **'Disposal status'**
  String get disposalStatus;

  /// No description provided for @confirmSaveDisposal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this disposal log?'**
  String get confirmSaveDisposal;

  /// No description provided for @confirmUpdateDisposal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this disposal log?'**
  String get confirmUpdateDisposal;

  /// No description provided for @disposalNotesInfo.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes about the disposal (optional).'**
  String get disposalNotesInfo;

  /// No description provided for @disposalLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Disposal log saved successfully.'**
  String get disposalLogSaved;

  /// No description provided for @disposalLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save disposal log.'**
  String get disposalLogSaveFailed;

  /// No description provided for @invalidDisposalTypeId.
  ///
  /// In en, this message translates to:
  /// **'Invalid disposal type.'**
  String get invalidDisposalTypeId;

  /// No description provided for @addTransfer.
  ///
  /// In en, this message translates to:
  /// **'Add transfer'**
  String get addTransfer;

  /// No description provided for @editTransfer.
  ///
  /// In en, this message translates to:
  /// **'Edit transfer'**
  String get editTransfer;

  /// No description provided for @transferDetails.
  ///
  /// In en, this message translates to:
  /// **'Transfer details'**
  String get transferDetails;

  /// No description provided for @transferDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide destination farm, transporter details, and remarks.'**
  String get transferDetailsSubtitle;

  /// No description provided for @transferContextInfo.
  ///
  /// In en, this message translates to:
  /// **'Transfers track livestock movements between farms. Ensure the destination farm UUID is correct before saving.'**
  String get transferContextInfo;

  /// No description provided for @toFarmUuidLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination farm identity'**
  String get toFarmUuidLabel;

  /// No description provided for @enterToFarmUuid.
  ///
  /// In en, this message translates to:
  /// **'Enter destination farm identity'**
  String get enterToFarmUuid;

  /// No description provided for @toFarmUuidRequired.
  ///
  /// In en, this message translates to:
  /// **'Destination farm identity is required'**
  String get toFarmUuidRequired;

  /// No description provided for @transferToFarmUuidWarning.
  ///
  /// In en, this message translates to:
  /// **'Enter the exact farm identity of the destination farm (Utambulisho wa shamba jingine). You can copy it from the farm details.'**
  String get transferToFarmUuidWarning;

  /// No description provided for @transporterIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Transporter ID (optional)'**
  String get transporterIdLabel;

  /// No description provided for @enterTransporterId.
  ///
  /// In en, this message translates to:
  /// **'Enter transporter ID (optional)'**
  String get enterTransporterId;

  /// No description provided for @invalidTransporterId.
  ///
  /// In en, this message translates to:
  /// **'Transporter ID must be a number'**
  String get invalidTransporterId;

  /// No description provided for @enterTransferReason.
  ///
  /// In en, this message translates to:
  /// **'Enter transfer reason (optional)'**
  String get enterTransferReason;

  /// No description provided for @transferPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer price (optional)'**
  String get transferPriceLabel;

  /// No description provided for @enterTransferPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price paid (optional)'**
  String get enterTransferPrice;

  /// No description provided for @transferDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer date & time'**
  String get transferDateLabel;

  /// No description provided for @selectTransferDate.
  ///
  /// In en, this message translates to:
  /// **'Select transfer date & time'**
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
  /// **'Tshs'**
  String get currencyTsh;

  /// No description provided for @currencyUsd.
  ///
  /// In en, this message translates to:
  /// **'USD (\$)'**
  String get currencyUsd;

  /// No description provided for @currencyGbp.
  ///
  /// In en, this message translates to:
  /// **'GBP (£)'**
  String get currencyGbp;

  /// No description provided for @currencyEur.
  ///
  /// In en, this message translates to:
  /// **'EUR (€)'**
  String get currencyEur;

  /// No description provided for @confirmSaveTransfer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this transfer log?'**
  String get confirmSaveTransfer;

  /// No description provided for @confirmUpdateTransfer.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this transfer log?'**
  String get confirmUpdateTransfer;

  /// No description provided for @transferLogSaved.
  ///
  /// In en, this message translates to:
  /// **'Transfer log saved successfully.'**
  String get transferLogSaved;

  /// No description provided for @transferLogSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save transfer log. Please try again.'**
  String get transferLogSaveFailed;

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

  /// No description provided for @bulkActions.
  ///
  /// In en, this message translates to:
  /// **'Bulk actions'**
  String get bulkActions;

  /// No description provided for @addVaccine.
  ///
  /// In en, this message translates to:
  /// **'Add vaccine'**
  String get addVaccine;

  /// No description provided for @vaccineDetails.
  ///
  /// In en, this message translates to:
  /// **'Vaccine details'**
  String get vaccineDetails;

  /// No description provided for @vaccineDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide the vaccine information'**
  String get vaccineDetailsSubtitle;

  /// No description provided for @vaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get vaccine;

  /// No description provided for @lotNumber.
  ///
  /// In en, this message translates to:
  /// **'Lot number'**
  String get lotNumber;

  /// No description provided for @enterLotNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter lot number (optional)'**
  String get enterLotNumber;

  /// No description provided for @formulationType.
  ///
  /// In en, this message translates to:
  /// **'Formulation type'**
  String get formulationType;

  /// No description provided for @enterFormulationType.
  ///
  /// In en, this message translates to:
  /// **'Enter formulation type (optional)'**
  String get enterFormulationType;

  /// No description provided for @selectFormulationType.
  ///
  /// In en, this message translates to:
  /// **'Select formulation type'**
  String get selectFormulationType;

  /// No description provided for @formulationLiveAttenuated.
  ///
  /// In en, this message translates to:
  /// **'Live attenuated'**
  String get formulationLiveAttenuated;

  /// No description provided for @formulationInactivated.
  ///
  /// In en, this message translates to:
  /// **'Inactivated vaccine'**
  String get formulationInactivated;

  /// No description provided for @doseAmount.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get doseAmount;

  /// No description provided for @enterDoseAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter dose (optional)'**
  String get enterDoseAmount;

  /// No description provided for @doseUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get doseUnit;

  /// No description provided for @selectDoseUnit.
  ///
  /// In en, this message translates to:
  /// **'Select unit'**
  String get selectDoseUnit;

  /// No description provided for @vaccineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get vaccineSchedule;

  /// No description provided for @enterVaccineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Enter schedule (optional)'**
  String get enterVaccineSchedule;

  /// No description provided for @selectVaccineSchedule.
  ///
  /// In en, this message translates to:
  /// **'Select schedule'**
  String get selectVaccineSchedule;

  /// No description provided for @vaccineScheduleRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular schedule'**
  String get vaccineScheduleRegular;

  /// No description provided for @vaccineScheduleBooster.
  ///
  /// In en, this message translates to:
  /// **'Booster schedule'**
  String get vaccineScheduleBooster;

  /// No description provided for @vaccineScheduleSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal program'**
  String get vaccineScheduleSeasonal;

  /// No description provided for @vaccineScheduleEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency schedule'**
  String get vaccineScheduleEmergency;

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

  /// No description provided for @vaccineTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Vaccine type is required'**
  String get vaccineTypeRequired;

  /// No description provided for @vaccineTypesMissing.
  ///
  /// In en, this message translates to:
  /// **'No vaccine types available. Please sync to download reference data.'**
  String get vaccineTypesMissing;

  /// No description provided for @ensureVaccineDetailsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Ensure the vaccine information is accurate before saving.'**
  String get ensureVaccineDetailsAccuracy;

  /// No description provided for @confirmSaveVaccine.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this vaccine?'**
  String get confirmSaveVaccine;

  /// No description provided for @confirmUpdateVaccine.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update this vaccine?'**
  String get confirmUpdateVaccine;

  /// No description provided for @vaccineSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vaccine saved successfully'**
  String get vaccineSavedSuccessfully;

  /// No description provided for @vaccineUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vaccine updated successfully'**
  String get vaccineUpdatedSuccessfully;

  /// No description provided for @vaccineSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save vaccine'**
  String get vaccineSaveFailed;

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

  /// No description provided for @status.
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

  /// No description provided for @identificationNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Identification number is required'**
  String get identificationNumberRequired;

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

  /// No description provided for @scanOptionBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get scanOptionBarcode;

  /// No description provided for @scanOptionQr.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get scanOptionQr;

  /// No description provided for @scanTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Tags'**
  String get scanTagsTitle;

  /// No description provided for @scanTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a tag type to scan and keep it within the frame.'**
  String get scanTagsSubtitle;

  /// No description provided for @scanOptionQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan printed QR stickers.'**
  String get scanOptionQrDescription;

  /// No description provided for @scanOptionBarcodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan barcodes from ear tags or documents.'**
  String get scanOptionBarcodeDescription;

  /// No description provided for @scanOptionRfid.
  ///
  /// In en, this message translates to:
  /// **'RFID Tag'**
  String get scanOptionRfid;

  /// No description provided for @scanOptionRfidDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the RFID reader to capture tags instantly.'**
  String get scanOptionRfidDescription;

  /// No description provided for @scanRfidPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Connect an RFID reader to capture tags automatically.'**
  String get scanRfidPlaceholder;

  /// No description provided for @scanManualPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter tag value'**
  String get scanManualPlaceholder;

  /// No description provided for @scanManualConfirm.
  ///
  /// In en, this message translates to:
  /// **'Search tag'**
  String get scanManualConfirm;

  /// No description provided for @scanStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start scan'**
  String get scanStartButton;

  /// No description provided for @scanResultFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag matched'**
  String get scanResultFoundTitle;

  /// No description provided for @scanResultFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Livestock {name} found on {farm}.'**
  String scanResultFoundSubtitle(Object name, Object farm);

  /// No description provided for @scanResultFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get scanResultFarm;

  /// No description provided for @scanResultBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get scanResultBarcode;

  /// No description provided for @scanResultRfid.
  ///
  /// In en, this message translates to:
  /// **'RFID'**
  String get scanResultRfid;

  /// No description provided for @scanResultNotFound.
  ///
  /// In en, this message translates to:
  /// **'No livestock found for tag {value}.'**
  String scanResultNotFound(Object value);

  /// No description provided for @scanPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan tags.'**
  String get scanPermissionDenied;

  /// No description provided for @scanPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Enable it in Settings to continue scanning.'**
  String get scanPermissionPermanentlyDenied;

  /// No description provided for @scanUnsupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Scanning is not supported on this device.'**
  String get scanUnsupportedDevice;

  /// No description provided for @scanPermissionRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get scanPermissionRationaleTitle;

  /// No description provided for @scanPermissionRationaleMessage.
  ///
  /// In en, this message translates to:
  /// **'We need your camera to scan QR and barcode tags.'**
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
  /// **'Camera permission required'**
  String get scanPermissionSettingsTitle;

  /// No description provided for @scanPermissionSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is disabled. Open Settings to enable it before scanning.'**
  String get scanPermissionSettingsMessage;

  /// No description provided for @scanPermissionGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scanPermissionGoToSettings;
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
