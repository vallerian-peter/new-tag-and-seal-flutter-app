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
  /// **'Identification Number'**
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
