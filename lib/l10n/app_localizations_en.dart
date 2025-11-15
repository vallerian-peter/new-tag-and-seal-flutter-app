// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tag & Seal';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeTitle => 'Welcome to Tag & Seal';

  @override
  String get welcomeSubtitle =>
      'Let\'s help you identify and secure your livestock';

  @override
  String get tagline => 'My Livestock | Tag & Seal';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get sync => 'Sync';

  @override
  String get syncData => 'Sync Data';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncTitle => 'Syncing Data';

  @override
  String get syncStarting => 'Starting sync...';

  @override
  String get syncAdditionalData => 'Syncing additional data...';

  @override
  String get syncLivestockReference => 'Syncing livestock reference data...';

  @override
  String get syncLivestockData => 'Syncing livestock data...';

  @override
  String get syncFarmData => 'Syncing farm data...';

  @override
  String get syncCompleted => 'Sync completed successfully!';

  @override
  String get syncSuccessful => 'Sync Successful';

  @override
  String get syncSuccessfulMessage =>
      'All data has been synchronized successfully. Your app is now up to date.';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncFailedMessage =>
      'Failed to synchronize data. Please check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get stepsCompleted => 'steps completed';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection and try again.';

  @override
  String get checkingNetworkConnection => 'Checking network connection...';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get connectionErrorMessage =>
      'Unable to connect to the server. Please check your internet connection and try again.';

  @override
  String get connectionTimeout => 'Connection Timeout';

  @override
  String get connectionTimeoutMessage =>
      'The server took too long to respond. Please try again.';

  @override
  String get networkError => 'Network Error';

  @override
  String get networkErrorMessage =>
      'Network error. Please check your internet connection.';

  @override
  String get authenticationFailed => 'Authentication Failed';

  @override
  String get authenticationFailedMessage =>
      'Invalid credentials. Please check your email and password.';

  @override
  String get serverError => 'Server Error';

  @override
  String get serverErrorMessage =>
      'Server error occurred. Please try again later.';

  @override
  String get serviceUnavailable => 'Service Unavailable';

  @override
  String get serviceUnavailableMessage =>
      'Service temporarily unavailable. Please try again later.';

  @override
  String get invalidServerResponse => 'Invalid Server Response';

  @override
  String get invalidServerResponseMessage =>
      'The server returned unexpected data. Please try again.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmationMessage =>
      'Are you sure you want to delete this farm?';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get optional => 'Optional';

  @override
  String get allText => 'All';

  @override
  String get userDataAvailable => 'User Data Available';

  @override
  String get foundText => 'Found';

  @override
  String get allLivestocksText => 'All Livestocks';

  @override
  String get welcomeAgain => 'Welcome Again';

  @override
  String get continueTrackingYourLivestocks =>
      'Continue tracking your livestocks with us';

  @override
  String get searchText => 'Search';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get recordsText => 'Records';

  @override
  String get allEvents => 'All Events';

  @override
  String get eventsScreenSubtitle => 'Review every farm activity log';

  @override
  String get totalLogs => 'Total Logs';

  @override
  String get eventTypes => 'Event Types';

  @override
  String get readyOffline => 'Ready Offline';

  @override
  String get unsyncedData => 'Unsynced Data';

  @override
  String get settingsAppHeaderTitle => 'App Settings';

  @override
  String get settingsAppHeaderSubtitle => 'Customize your app experience';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsLanguageRegionTitle => 'Language & Region';

  @override
  String get settingsSupportTitle => 'Support & About';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsAboutSubtitle => 'App version and information';

  @override
  String get settingsHelpSubtitle => 'Get help and support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String settingsVersionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get settingsAppDescription =>
      'A comprehensive livestock management application.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSwahili => 'Kiswahili';

  @override
  String get bluetoothWeightScale => 'Bluetooth Weight Scale';

  @override
  String get connectToMeasureWeight => 'Connect to measure weight';

  @override
  String connectedToDevice(String deviceName) {
    return 'Connected to $deviceName';
  }

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String get scanningForDevices => 'Scanning for devices...';

  @override
  String get makeBluetoothEnabledAndScaleOn =>
      'Make sure Bluetooth is enabled and the scale is on';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get scan => 'Scan';

  @override
  String availableDevices(int count) {
    return 'Available Devices ($count)';
  }

  @override
  String get connected => 'Connected';

  @override
  String get waitingForWeightData => 'Waiting for weight data...';

  @override
  String get placeOnScaleInstruction =>
      'Place livestock on the scale and wait for a stable reading';

  @override
  String get saveWeight => 'Save Weight';

  @override
  String get dashboardSyncPrompt =>
      'Tap the sync button to pull the latest farms, livestock, and logs before you start working.';

  @override
  String get bulk => 'Bulk';

  @override
  String get bulkActions => 'Bulk Actions';

  @override
  String get logsText => 'Logs';

  @override
  String get onboarding1Title => 'Track Your Livestock';

  @override
  String get onboarding1Subtitle =>
      'Efficiently manage and track all your livestock with digital tags and real-time monitoring';

  @override
  String get onboarding2Title => 'Farm Management';

  @override
  String get onboarding2Subtitle =>
      'Comprehensive farm management system to organize your farms, animals, and operations in one place';

  @override
  String get onboarding3Title => 'Health & Records';

  @override
  String get onboarding3Subtitle =>
      'Keep detailed health records, vaccinations, and breeding information for better livestock care';

  @override
  String get livestockName => 'Livestock Name';

  @override
  String get farm => 'Farm';

  @override
  String get farms => 'Farms';

  @override
  String get allFarms => 'All Farms';

  @override
  String get allFarmsDescription => 'View and manage all your farms';

  @override
  String get addFarm => 'Add Farm';

  @override
  String get farmName => 'Farm Name';

  @override
  String get farmSize => 'Farm Size';

  @override
  String get location => 'Location';

  @override
  String get livestock => 'Livestock';

  @override
  String get addLivestock => 'Add Livestock';

  @override
  String get tagId => 'Tag ID';

  @override
  String get animalName => 'Animal Name';

  @override
  String get breed => 'Breed';

  @override
  String get species => 'Species';

  @override
  String get gender => 'Gender';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get farmDataNotFound => 'Farm Data Not Found';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get keyFeatures => 'Key Features';

  @override
  String get howToUse => 'How to Use';

  @override
  String get digitalTagging => 'Digital Tagging';

  @override
  String get healthRecords => 'Health Records';

  @override
  String get analytics => 'Analytics & Reports';

  @override
  String get offlineCapability => 'Offline Capability';

  @override
  String get manageAndTrackLivestockText =>
      'Manage and track all your livestock';

  @override
  String get refresh => 'Refresh';

  @override
  String get age => 'Age';

  @override
  String get weight => 'Weight';

  @override
  String get year => 'year';

  @override
  String get years => 'years';

  @override
  String get month => 'month';

  @override
  String get months => 'months';

  @override
  String get unknownFarm => 'Unknown Farm';

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get tapForMoreDetails => 'Tap for more details';

  @override
  String get addFirstLivestockMessage =>
      'Add your first livestock to get started';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try searching with different keywords';

  @override
  String get sortAtoZ => 'Sort A to Z';

  @override
  String get sortZtoA => 'Sort Z to A';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get livestockDetails => 'Livestock Details';

  @override
  String get invalidFarmId => 'Invalid farm ID';

  @override
  String get failedToMarkFarmForDeletion => 'Failed to mark farm for deletion';

  @override
  String get errorDeletingFarm => 'Error deleting farm';

  @override
  String get tagYourLivestock => 'Tag your Livestock';

  @override
  String get keepTrackFarms => 'Keep Track of your Farms';

  @override
  String get inviteUsers => 'Invite Users and Officers';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get syncingData => 'Please wait, syncing data...';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get syncSuccess => 'Sync successful';

  @override
  String get lastSync => 'Last sync';

  @override
  String get squareKilometers => 'Square Kilometers';

  @override
  String get howItWorksTitle => 'How It Works';

  @override
  String get systemTitle => 'Tag & Seal Livestock System';

  @override
  String get systemSubtitle =>
      'A comprehensive digital solution for livestock management';

  @override
  String get digitalTaggingDesc =>
      'Tag your livestock with unique identifiers for easy tracking and management';

  @override
  String get healthRecordsDesc =>
      'Maintain complete health records including vaccinations, medications, and treatments';

  @override
  String get analyticsReports => 'Analytics & Reports';

  @override
  String get analyticsReportsDesc =>
      'Get insights into your farm performance with detailed analytics and reports';

  @override
  String get offlineCapabilityDesc =>
      'Work offline and sync your data automatically when internet is available';

  @override
  String get registerFarm => 'Register Your Farm';

  @override
  String get registerFarmDesc =>
      'Create your farm profile with location details and farm information';

  @override
  String get addLivestockDesc =>
      'Register your animals with digital tags and basic information';

  @override
  String get trackManage => 'Track & Manage';

  @override
  String get trackManageDesc =>
      'Record health events, breeding, feeding, and other activities';

  @override
  String get syncAnalyze => 'Sync & Analyze';

  @override
  String get syncAnalyzeDesc =>
      'Sync your data to the cloud and view analytics on your farm performance';

  @override
  String get gotIt => 'Got It!';

  @override
  String get enterCredentialsToContinue => 'Enter your credentials to continue';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get createAccount => 'Create Account';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get contactDetails => 'Contact Details';

  @override
  String get addressInformation => 'Address Information';

  @override
  String get additionalDetails => 'Additional Details';

  @override
  String get firstName => 'First Name';

  @override
  String get middleName => 'Middle Name';

  @override
  String get surname => 'Surname';

  @override
  String get phone1 => 'Primary Phone';

  @override
  String get phone2 => 'Secondary Phone';

  @override
  String get physicalAddress => 'Physical Address';

  @override
  String get farmerOrganizationMembership => 'Farmer Organization Membership';

  @override
  String get identityCardType => 'Identity Card Type';

  @override
  String get identityNumber => 'Identity Number';

  @override
  String get street => 'Street';

  @override
  String get schoolLevel => 'School Level';

  @override
  String get village => 'Village';

  @override
  String get ward => 'Ward';

  @override
  String get district => 'District';

  @override
  String get region => 'Region';

  @override
  String get country => 'Country';

  @override
  String get farmerType => 'Farmer Type';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get nationalId => 'National ID';

  @override
  String get passport => 'Passport';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get primary => 'Primary';

  @override
  String get secondary => 'Secondary';

  @override
  String get diploma => 'Diploma';

  @override
  String get degree => 'Degree';

  @override
  String get master => 'Master';

  @override
  String get phd => 'PhD';

  @override
  String get smallScale => 'Small Scale';

  @override
  String get mediumScale => 'Medium Scale';

  @override
  String get largeScale => 'Large Scale';

  @override
  String get commercial => 'Commercial';

  @override
  String get subsistence => 'Subsistence';

  @override
  String get pleaseSelect => 'Please select...';

  @override
  String get pleaseEnterFirstName => 'Please enter your first name';

  @override
  String get pleaseEnterSurname => 'Please enter your surname';

  @override
  String get pleaseEnterPhone => 'Please enter your phone number';

  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';

  @override
  String get pleaseSelectGender => 'Please select your gender';

  @override
  String get pleaseSelectDateOfBirth => 'Please select date of birth';

  @override
  String get pleaseEnterIdentityNumber => 'Please enter your identity number';

  @override
  String get pleaseSelectIdentityType => 'Please select identity card type';

  @override
  String get pleaseSelectSchoolLevel => 'Please select your school level';

  @override
  String get pleaseSelectFarmerType => 'Please select farmer type';

  @override
  String get personalInfoStep => 'Personal';

  @override
  String get personalInfoStepSubtitle => 'Basic info';

  @override
  String get contactInfoStep => 'Contact';

  @override
  String get contactInfoStepSubtitle => 'Phone & email';

  @override
  String get identityInfoStep => 'Identity';

  @override
  String get identityInfoStepSubtitle => 'ID details';

  @override
  String get locationInfoStep => 'Location';

  @override
  String get locationInfoStepSubtitle => 'Address';

  @override
  String get additionalInfoStep => 'Additional';

  @override
  String get additionalInfoStepSubtitle => 'Final details';

  @override
  String get enterFirstName => 'Enter your first name';

  @override
  String get enterMiddleName => 'Enter your middle name (optional)';

  @override
  String get enterSurname => 'Enter your surname';

  @override
  String get selectDateOfBirth => 'Select your date of birth';

  @override
  String get selectGender => 'Select your gender';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterAlternatePhone => 'Enter alternate phone (optional)';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPhysicalAddress => 'Enter your physical address';

  @override
  String get selectIdType => 'Select ID type';

  @override
  String get enterIdNumber => 'Enter your ID number';

  @override
  String get selectEducationLevel => 'Select education level';

  @override
  String get selectCountry => 'Select country';

  @override
  String get selectRegion => 'Select region';

  @override
  String get selectDistrict => 'Select district';

  @override
  String get selectWard => 'Select ward';

  @override
  String get selectVillage => 'Select village';

  @override
  String get selectStreet => 'Select street';

  @override
  String get selectFarmerType => 'Select farmer type';

  @override
  String get enterOrganizationName => 'Enter organization name (optional)';

  @override
  String get individual => 'Individual';

  @override
  String get organization => 'Organization';

  @override
  String get voterId => 'Voter ID';

  @override
  String get other => 'Other';

  @override
  String get certificate => 'Certificate';

  @override
  String get tanzania => 'Tanzania';

  @override
  String get reviewInfoMessage =>
      'Please review all information before submitting. You will receive a confirmation email after successful registration.';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get surnameRequired => 'Surname is required';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get validPhoneRequired => 'Enter a valid phone number';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get validEmailRequired => 'Enter a valid email address';

  @override
  String get physicalAddressRequired => 'Physical address is required';

  @override
  String get genderRequired => 'Gender is required';

  @override
  String get dateOfBirthRequired => 'Date of birth is required';

  @override
  String get identityTypeRequired => 'Identity card type is required';

  @override
  String get identityNumberRequired => 'Identity number is required';

  @override
  String get educationLevelRequired => 'Education level is required';

  @override
  String get countryRequired => 'Country is required';

  @override
  String get regionRequired => 'Region is required';

  @override
  String get districtRequired => 'District is required';

  @override
  String get wardRequired => 'Ward is required';

  @override
  String get villageRequired => 'Village is required';

  @override
  String get streetRequired => 'Street is required';

  @override
  String get farmerTypeRequired => 'Farmer type is required';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get english => 'English';

  @override
  String get kiswahili => 'Kiswahili';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Choose how you would like to receive your password reset instructions';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailAddressSwahili => 'Barua Pepe';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberSwahili => 'Namba ya Simu';

  @override
  String get recoverViaEmail => 'Recover via Email';

  @override
  String get recoverViaPhone => 'Recover via Phone';

  @override
  String get noInternetConnectionMessage =>
      'Please check your network settings and try again';

  @override
  String get connectionLost => 'Connection Lost';

  @override
  String get connectionLostMessage =>
      'Connection was lost during the operation. Please try again.';

  @override
  String get fetchingData => 'Fetching Data';

  @override
  String get loadingLocations => 'Loading Locations...';

  @override
  String get locationsLoadedSuccessfully => 'Locations loaded successfully';

  @override
  String get failedToLoadLocations => 'Failed to load locations';

  @override
  String get creatingAccount => 'Creating your account...';

  @override
  String get registrationSuccessful =>
      'Registration successful! Welcome to Tag & Seal.';

  @override
  String get continueText => 'Continue';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get loggingIn => 'Logging you in...';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get loggingOut => 'Logging you out...';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get start => 'Start';

  @override
  String get livestocks => 'Livestocks';

  @override
  String get events => 'Events';

  @override
  String get userProfile => 'User Profile';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get qrScanner => 'QR Scanner';

  @override
  String get qrScannerDescription =>
      'Scanner functionality will be implemented here';

  @override
  String get dashboardScreen => 'Dashboard Screen';

  @override
  String get allLivestocksScreen => 'All Livestocks Screen';

  @override
  String get allEventsScreen => 'All Events Screen';

  @override
  String get userProfileScreen => 'User Profile Screen';

  @override
  String get farmer => 'Farmer';

  @override
  String get homeText => 'Home';

  @override
  String get vaccinesText => 'Vaccines';

  @override
  String get invitedUsersText => 'Invited Users';

  @override
  String get invitedOfficersText => 'Invited Officers';

  @override
  String get farmManagementText => 'Farm Management';

  @override
  String get createNewFarmText => 'Create New Farm';

  @override
  String get inviteOfficerText => 'Invite Officer';

  @override
  String get inviteFarmUserText => 'Invite Farm User';

  @override
  String get collaborateText => 'Collaborate';

  @override
  String get setNewFarmText => 'Set New Farm';

  @override
  String get addExtensionOfficerText => 'Add Extension Officer';

  @override
  String get farmsText => 'Farms';

  @override
  String get welcomeText => 'Welcome';

  @override
  String get darkModeText => 'Dark Mode';

  @override
  String get registerNewFarm => 'Register New Farm';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get farmNameReferenceDetails => 'Farm name and reference details';

  @override
  String get sizeMeasurements => 'Size & Location';

  @override
  String get farmMeasurementsCoordinates => 'Farm measurements and coordinates';

  @override
  String get addressLegal => 'Address & Legal';

  @override
  String get physicalLocationLegalStatus =>
      'Physical location and legal status';

  @override
  String get farmDetails => 'Farm Details';

  @override
  String get enterFarmName => 'Enter farm name';

  @override
  String get farmNameRequired => 'Farm name is required';

  @override
  String get farmNameMinLength => 'Farm name must be at least 3 characters';

  @override
  String get referenceNumber => 'Reference Number';

  @override
  String get enterReferenceNumber => 'Enter reference number';

  @override
  String get referenceNumberRequired => 'Reference number is required';

  @override
  String get regionalRegistrationNumber => 'Regional Registration Number';

  @override
  String get enterRegionalRegNumber => 'Enter regional registration number';

  @override
  String get regionalRegNumberRequired =>
      'Regional registration number is required';

  @override
  String get ensureReferenceAccuracy =>
      'Ensure all reference numbers are accurate and match official records.';

  @override
  String get farmMeasurements => 'Farm Measurements';

  @override
  String get enterSize => 'Enter size';

  @override
  String get sizeRequired => 'Size required';

  @override
  String get enterValidNumber => 'Enter valid number';

  @override
  String get sizeMustBePositive => 'Size must be greater than 0';

  @override
  String get unit => 'Unit';

  @override
  String get selectUnit => 'Select';

  @override
  String get unitRequired => 'Unit required';

  @override
  String get acres => 'Acres';

  @override
  String get hectares => 'Hectares';

  @override
  String get squareMeters => 'Square Meters';

  @override
  String get gpsCoordinates => 'GPS Coordinates';

  @override
  String get latitude => 'Latitude';

  @override
  String get latitudeExample => 'e.g. -6.7924';

  @override
  String get latitudeRequired => 'Latitude is required';

  @override
  String get enterValidLatitude => 'Enter valid latitude';

  @override
  String get latitudeRange => 'Latitude must be between -90 and 90';

  @override
  String get longitude => 'Longitude';

  @override
  String get longitudeExample => 'e.g. 39.2083';

  @override
  String get longitudeRequired => 'Longitude is required';

  @override
  String get enterValidLongitude => 'Enter valid longitude';

  @override
  String get longitudeRange => 'Longitude must be between -180 and 180';

  @override
  String get getCurrentLocation => 'Get Current Location';

  @override
  String get useGpsAutoFill =>
      'Tap here to use your device GPS to auto-fill coordinates';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get legalInformation => 'Legal Information';

  @override
  String get legalStatus => 'Legal Status';

  @override
  String get selectLegalStatus => 'Select legal status';

  @override
  String get legalStatusRequired => 'Legal status is required';

  @override
  String get owned => 'Owned';

  @override
  String get leased => 'Leased';

  @override
  String get rented => 'Rented';

  @override
  String get cooperative => 'Cooperative';

  @override
  String get reviewBeforeSubmit =>
      'Review all information before submitting. You can edit later if needed.';

  @override
  String get farmRegisteredSuccessfully => 'Farm registered successfully!';

  @override
  String get farmRegistrationFailed => 'Farm registration failed';

  @override
  String get farmUpdatedSuccessfully => 'Farm updated successfully!';

  @override
  String get farmUpdateFailed => 'Farm update failed';

  @override
  String get confirmRegisterFarm =>
      'Are you sure you want to register this farm?';

  @override
  String get confirmUpdateFarm => 'Are you sure you want to update this farm?';

  @override
  String get gpsCoordinatesRetrieved =>
      'GPS coordinates retrieved successfully!';

  @override
  String get fetchingGpsCoordinates => 'Fetching GPS coordinates...';

  @override
  String get loadingFarms => 'Loading farms...';

  @override
  String get farmLoadedSuccessfully => 'Farm loaded successfully';

  @override
  String get farmLoadFailed => 'Failed to load farm';

  @override
  String get farmsLoadedSuccessfully => 'Farms loaded successfully';

  @override
  String get farmsLoadFailed => 'Failed to load farms';

  @override
  String get loadingFarmWithLivestock => 'Loading farm with livestock...';

  @override
  String get farmWithLivestockLoadedSuccessfully =>
      'Farm with livestock loaded successfully';

  @override
  String get eventsLoadedSuccessfully => 'Events loaded successfully';

  @override
  String get allEventsLoadedSuccessfully => 'All events loaded successfully';

  @override
  String get eventsLoadFailed => 'Failed to load events. Please try again.';

  @override
  String get feedingLogSaved => 'Feeding log saved successfully';

  @override
  String get feedingLogSaveFailed =>
      'Failed to save feeding log. Please try again.';

  @override
  String get feeding => 'Feeding';

  @override
  String get addFeeding => 'Add Feeding';

  @override
  String get feedingDetailsSubtitle =>
      'Capture feeding details for accurate records';

  @override
  String get feedingNotesSubtitle => 'Provide optional context and notes';

  @override
  String get feedingDetails => 'Feeding Details';

  @override
  String get feedingType => 'Feeding Type';

  @override
  String get selectFeedingType => 'Select feeding type';

  @override
  String get feedingTypeRequired => 'Feeding type is required';

  @override
  String get amount => 'Amount';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get nextFeedingTime => 'Next feeding time';

  @override
  String get enterNextFeedingTime => 'Select next feeding time';

  @override
  String get nextFeedingTimeRequired => 'Next feeding time is required';

  @override
  String get previousWeight => 'Old weight';

  @override
  String get currentWeight => 'New weight';

  @override
  String get updatedAt => 'Updated at';

  @override
  String get nextAdministrationDate => 'Next administration date';

  @override
  String get dose => 'Dose';

  @override
  String get quantity => 'Quantity';

  @override
  String get createdAt => 'Created at';

  @override
  String get ensureFeedingDetailsAccuracy =>
      'Ensure the feeding information is accurate before saving.';

  @override
  String get ensureWeightDetailsAccuracy =>
      'Ensure the weight information is accurate before saving.';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get remarks => 'Remarks';

  @override
  String get enterRemarksOptional => 'Enter remarks (optional)';

  @override
  String get feedingNotesInfo =>
      'Use notes to record any special observations made during feeding.';

  @override
  String get confirmUpdateFeeding =>
      'Are you sure you want to update this feeding log?';

  @override
  String get confirmSaveFeeding =>
      'Are you sure you want to save this feeding log?';

  @override
  String get confirmSaveWeightChange =>
      'Are you sure you want to save this weight change?';

  @override
  String get confirmUpdateWeightChange =>
      'Are you sure you want to update this weight change?';

  @override
  String get recordsAndLogs => 'Records and Logs';

  @override
  String get insemination => 'Insemination';

  @override
  String get pregnancy => 'Pregnancy';

  @override
  String get deworming => 'Deworming';

  @override
  String get addDeworming => 'Add Deworming';

  @override
  String get dewormingDetails => 'Deworming Details';

  @override
  String get dosageDetails => 'Dosage Details';

  @override
  String get administrationRoute => 'Administration route';

  @override
  String get selectAdministrationRoute => 'Select administration route';

  @override
  String get administrationRouteRequired => 'Administration route is required';

  @override
  String get medicine => 'Medicine';

  @override
  String get selectMedicine => 'Select medicine';

  @override
  String get medicineRequired => 'Medicine is required';

  @override
  String get treatmentProvider => 'Treatment provider';

  @override
  String get selectTreatmentProvider => 'Select treatment provider';

  @override
  String get treatmentProviderNone => 'No provider';

  @override
  String get treatmentProviderVet => 'Veterinarian';

  @override
  String get treatmentProviderExtensionOfficer => 'Extension officer';

  @override
  String get medicalLicenseNumber => 'License number';

  @override
  String get enterMedicalLicenseNumber => 'Enter license number';

  @override
  String get medicalLicenseNumberRequired => 'License number is required';

  @override
  String get medicalLicenseNumberInvalid =>
      'License number must contain digits only';

  @override
  String get vetLicense => 'Vet license';

  @override
  String get extensionOfficerLicense => 'Extension officer license';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get quantityRequired => 'Quantity is required';

  @override
  String get enterDose => 'Enter dose';

  @override
  String get doseRequired => 'Dose is required';

  @override
  String get ensureDewormingDetailsAccuracy =>
      'Ensure the deworming information is accurate before saving.';

  @override
  String get weightChange => 'Weight Change';

  @override
  String get disposalTransfer => 'Disposal / Transfer';

  @override
  String get calving => 'Calving';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get dryoff => 'Dryoff';

  @override
  String get medication => 'Medication';

  @override
  String get milking => 'Milking';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get logContextMissing =>
      'Cannot open this log because farm or livestock details are missing.';

  @override
  String get selectFarm => 'Select farm';

  @override
  String get farmRequired => 'Farm is required';

  @override
  String get selectLivestock => 'Select livestock';

  @override
  String get livestockRequired => 'Livestock is required';

  @override
  String get weightLogSaved => 'Weight change log saved successfully';

  @override
  String get weightLogSaveFailed =>
      'Failed to save weight change log. Please try again.';

  @override
  String get dewormingLogSaved => 'Deworming log saved successfully';

  @override
  String get dewormingLogSaveFailed =>
      'Failed to save deworming log. Please try again.';

  @override
  String get medicationDetails => 'Medication details';

  @override
  String get medicationDetailsSubtitle =>
      'Capture dosage, disease, and scheduling information.';

  @override
  String get addMedication => 'Add medication log';

  @override
  String get medicationLogSaved => 'Medication log saved successfully';

  @override
  String get medicationLogSaveFailed =>
      'Failed to save medication log. Please try again.';

  @override
  String get medicationContextInfo =>
      'Provide context about this medication treatment.';

  @override
  String get quantityUnit => 'Quantity unit';

  @override
  String get selectQuantityUnit => 'Select quantity unit';

  @override
  String get withdrawalPeriod => 'Withdrawal period';

  @override
  String get enterWithdrawalPeriodOptional =>
      'Enter withdrawal period (optional)';

  @override
  String get withdrawalUnit => 'Withdrawal unit';

  @override
  String get selectWithdrawalUnit => 'Select withdrawal unit';

  @override
  String get diseaseOptionsMissing =>
      'Diseases not available. Sync reference data first.';

  @override
  String get diseaseId => 'Disease';

  @override
  String get selectDisease => 'Select disease';

  @override
  String get medicationDate => 'Medication date';

  @override
  String get selectMedicationDate => 'Select medication date';

  @override
  String get medicationNotesInfo =>
      'Provide any additional notes about this medication.';

  @override
  String get confirmUpdateMedication => 'Update medication record?';

  @override
  String get confirmSaveMedication => 'Save medication record?';

  @override
  String get quantityUnitMl => 'ml';

  @override
  String get quantityUnitL => 'L';

  @override
  String get quantityUnitMg => 'mg';

  @override
  String get quantityUnitG => 'g';

  @override
  String get quantityUnitKg => 'kg';

  @override
  String get withdrawalUnitMinutes => 'minutes';

  @override
  String get withdrawalUnitHours => 'hours';

  @override
  String get withdrawalUnitDays => 'days';

  @override
  String get withdrawalUnitWeeks => 'weeks';

  @override
  String get withdrawalUnitMonths => 'months';

  @override
  String get withdrawalUnitYears => 'years';

  @override
  String get vaccinationDetails => 'Vaccination details';

  @override
  String get vaccinationDetailsSubtitle =>
      'Record vaccine, disease, and schedule info.';

  @override
  String get addVaccination => 'Add vaccination log';

  @override
  String get vaccinationNumber => 'Vaccination number';

  @override
  String get enterVaccinationNumber => 'Enter vaccination number';

  @override
  String get selectVaccine => 'Select vaccine';

  @override
  String get vaccinationStatus => 'Vaccination status';

  @override
  String get vaccinationContextInfo =>
      'Provide context about this vaccination event.';

  @override
  String get vaccinationPersonnelDetails => 'Personnel details';

  @override
  String get enterVetLicenseOptional => 'Enter vet license (optional)';

  @override
  String get enterExtensionOfficerLicenseOptional =>
      'Enter extension officer license (optional)';

  @override
  String get vaccinationNotesInfo => 'Add remarks about this vaccination.';

  @override
  String get confirmUpdateVaccination => 'Update vaccination log?';

  @override
  String get confirmSaveVaccination => 'Save vaccination log?';

  @override
  String get vaccinationLogSaved => 'Vaccination log saved successfully';

  @override
  String get vaccinationLogSaveFailed =>
      'Failed to save vaccination log. Please try again.';

  @override
  String get vaccineOptionsMissing =>
      'Vaccines not available. Sync vaccine reference data first.';

  @override
  String get addDisposal => 'Add disposal log';

  @override
  String get disposalDetails => 'Disposal details';

  @override
  String get disposalDetailsSubtitle =>
      'Capture why and how the livestock was disposed.';

  @override
  String get disposalContextInfo =>
      'Provide the method, reason, and any supporting notes.';

  @override
  String get disposalReasons => 'Disposal reasons';

  @override
  String get enterDisposalReasons => 'Enter reasons for disposal';

  @override
  String get disposalTypeOptionsMissing =>
      'Disposal types unavailable. Sync reference data.';

  @override
  String get disposalTypeId => 'Disposal type';

  @override
  String get selectDisposalType => 'Select disposal type';

  @override
  String get disposalTypeRequired => 'Disposal type is required';

  @override
  String get disposalStatus => 'Disposal status';

  @override
  String get disposalNotesInfo => 'Add any remarks related to this disposal.';

  @override
  String get confirmUpdateDisposal => 'Update disposal log?';

  @override
  String get confirmSaveDisposal => 'Save disposal log?';

  @override
  String get disposalLogSaved => 'Disposal log saved successfully';

  @override
  String get disposalLogSaveFailed =>
      'Failed to save disposal log. Please try again.';

  @override
  String get addMilking => 'Add milking log';

  @override
  String get milkingDetailsSubtitle =>
      'Capture session details for this milking event.';

  @override
  String get milkingNotesSubtitle =>
      'Provide lab readings and quality observations.';

  @override
  String get milkingMethod => 'Milking method';

  @override
  String get milkingMethodRequired => 'Milking method is required';

  @override
  String get session => 'Session';

  @override
  String get statusActive => 'Active';

  @override
  String get statusNotActive => 'Not active';

  @override
  String get ensureMilkingDetailsAccuracy =>
      'Ensure the milking details are accurate before saving.';

  @override
  String get lactometerReading => 'Lactometer reading';

  @override
  String get solids => 'Solids';

  @override
  String get solidNonFat => 'Solids non-fat';

  @override
  String get protein => 'Protein';

  @override
  String get correctedLactometerReading => 'Corrected lactometer reading';

  @override
  String get totalSolids => 'Total solids';

  @override
  String get colonyFormingUnits => 'Colony forming units';

  @override
  String get acidity => 'Acidity';

  @override
  String get milkingNotesInfo =>
      'Record lab analysis, quality metrics, or remarks.';

  @override
  String get confirmUpdateMilking => 'Update milking log?';

  @override
  String get confirmSaveMilking => 'Save milking log?';

  @override
  String get milkingLogSaveFailed =>
      'Failed to save milking log. Please try again.';

  @override
  String get addPregnancy => 'Add pregnancy log';

  @override
  String get pregnancyDetailsSubtitle =>
      'Record pregnancy test outcomes and status.';

  @override
  String get pregnancyNotesSubtitle =>
      'Provide notes about this pregnancy check.';

  @override
  String get testResult => 'Test result';

  @override
  String get testResultRequired => 'Test result is required';

  @override
  String get numberOfMonths => 'Number of months';

  @override
  String get testDate => 'Test date';

  @override
  String get testDateRequired => 'Test date is required';

  @override
  String get ensurePregnancyDetailsAccuracy =>
      'Ensure pregnancy information is accurate before saving.';

  @override
  String get pregnancyNotesInfo =>
      'Add notes about symptoms, vet observations, or remarks.';

  @override
  String get confirmUpdatePregnancy => 'Update pregnancy log?';

  @override
  String get confirmSavePregnancy => 'Save pregnancy log?';

  @override
  String get pregnancyLogSaveFailed =>
      'Failed to save pregnancy log. Please try again.';

  @override
  String get transfer => 'Transfer';

  @override
  String get addTransfer => 'Add transfer log';

  @override
  String get transferDetails => 'Transfer details';

  @override
  String get transferDetailsSubtitle =>
      'Track livestock movement between farms.';

  @override
  String get transferContextInfo =>
      'Provide the destination farm and transporter information.';

  @override
  String get toFarmUuidLabel => 'Destination farm UUID';

  @override
  String get enterToFarmUuid => 'Enter destination farm UUID';

  @override
  String get toFarmUuidRequired => 'Destination farm UUID is required';

  @override
  String get transferToFarmUuidWarning =>
      'Ensure the destination farm exists before saving.';

  @override
  String get transporterIdLabel => 'Transporter ID';

  @override
  String get enterTransporterId => 'Enter transporter identifier';

  @override
  String get reason => 'Reason';

  @override
  String get enterTransferReason => 'Enter reason for transfer';

  @override
  String get transferPriceLabel => 'Transfer price';

  @override
  String get enterTransferPrice => 'Enter price (optional)';

  @override
  String get transferCurrencyLabel => 'Currency';

  @override
  String get selectTransferCurrency => 'Select currency';

  @override
  String get currencyTsh => 'TZS';

  @override
  String get currencyUsd => 'USD';

  @override
  String get currencyGbp => 'GBP';

  @override
  String get currencyEur => 'EUR';

  @override
  String get transferDateLabel => 'Transfer date';

  @override
  String get selectTransferDate => 'Select transfer date';

  @override
  String get transferDateRequired => 'Transfer date is required';

  @override
  String get transferStatusLabel => 'Transfer status';

  @override
  String get confirmUpdateTransfer => 'Update transfer log?';

  @override
  String get confirmSaveTransfer => 'Save transfer log?';

  @override
  String get invalidTransporterId => 'Transporter ID must be alphanumeric.';

  @override
  String get transferLogSaveFailed =>
      'Failed to save transfer log. Please try again.';

  @override
  String get addDryoff => 'Add dryoff log';

  @override
  String get dryoffDetailsSubtitle => 'Record the planned dryoff window.';

  @override
  String get dryoffNotesSubtitle => 'Capture any feeding or management notes.';

  @override
  String get startDate => 'Start date';

  @override
  String get startDateRequired => 'Start date is required';

  @override
  String get endDate => 'End date';

  @override
  String get ensureDryoffDetailsAccuracy =>
      'Ensure the dryoff details are accurate before saving.';

  @override
  String get dryoffNotesInfo =>
      'Add remarks about feed changes, health checks, or reminders.';

  @override
  String get confirmUpdateDryoff => 'Update dryoff log?';

  @override
  String get confirmSaveDryoff => 'Save dryoff log?';

  @override
  String get dryoffLogSaveFailed =>
      'Failed to save dryoff log. Please try again.';

  @override
  String get confirmSaveDeworming =>
      'Are you sure you want to save this deworming log?';

  @override
  String get confirmUpdateDeworming =>
      'Are you sure you want to update this deworming log?';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get bulkOperationInProgress =>
      'Saving records for all selected livestock...';

  @override
  String get addInsemination => 'Add insemination log';

  @override
  String get inseminationDetailsSubtitle =>
      'Record heat cycle, service type, and straw details.';

  @override
  String get inseminationNotesSubtitle =>
      'Capture remarks about semen quality or procedures.';

  @override
  String get lastHeatDate => 'Last heat date';

  @override
  String get heatType => 'Heat type';

  @override
  String get heatTypeRequired => 'Heat type is required';

  @override
  String get inseminationService => 'Insemination service';

  @override
  String get inseminationServiceRequired => 'Insemination service is required';

  @override
  String get semenStrawType => 'Semen straw type';

  @override
  String get semenStrawTypeRequired => 'Semen straw type is required';

  @override
  String get inseminationDate => 'Insemination date';

  @override
  String get ensureInseminationDetailsAccuracy =>
      'Ensure insemination details are accurate before saving.';

  @override
  String get bullCode => 'Bull code';

  @override
  String get bullBreed => 'Bull breed';

  @override
  String get semenProductionDate => 'Semen production date';

  @override
  String get productionCountry => 'Production country';

  @override
  String get semenBatchNumber => 'Batch number';

  @override
  String get internationalId => 'International ID';

  @override
  String get aiCode => 'AI code';

  @override
  String get manufacturerName => 'Manufacturer name';

  @override
  String get semenSupplier => 'Semen supplier';

  @override
  String get inseminationNotesInfo =>
      'Add notes about handling, technician, or follow-up plans.';

  @override
  String get confirmUpdateInsemination => 'Update insemination log?';

  @override
  String get confirmSaveInsemination => 'Save insemination log?';

  @override
  String get inseminationLogSaveFailed =>
      'Failed to save insemination log. Please try again.';

  @override
  String get farmWithLivestockLoadFailed =>
      'Failed to load farm with livestock';

  @override
  String get noFarmFound => 'No farm found';

  @override
  String get noFarmsFound => 'No farms found';

  @override
  String get addCalving => 'Add calving log';

  @override
  String get calvingDetailsSubtitle =>
      'Record calving outcomes and supporting details.';

  @override
  String get calvingNotesSubtitle =>
      'Capture observations, issues, or follow-up actions.';

  @override
  String get calvingProblem => 'Calving problem';

  @override
  String get reproductiveProblem => 'Reproductive problem';

  @override
  String get calvingType => 'Calving type';

  @override
  String get calvingTypeRequired => 'Calving type is required';

  @override
  String get ensureCalvingDetailsAccuracy =>
      'Ensure calving information is accurate before saving.';

  @override
  String get calvingNotesInfo =>
      'Add notes about calves, complications, or support provided.';

  @override
  String get confirmUpdateCalving => 'Update calving log?';

  @override
  String get confirmSaveCalving => 'Save calving log?';

  @override
  String get calvingLogSaveFailed =>
      'Failed to save calving log. Please try again.';

  @override
  String get noLivestockFound => 'No livestock found';

  @override
  String get total => 'Total';

  @override
  String get tryDifferentSearchTerm => 'Try searching with a different term';

  @override
  String get timeoutError => 'Timeout Error';

  @override
  String get timeoutErrorMessage =>
      'Connection timeout. The server took too long to respond. Please try again.';

  @override
  String get invalidRequest => 'Invalid Request';

  @override
  String get invalidRequestMessage =>
      'Invalid request. Please check your information and try again.';

  @override
  String get serviceNotFound => 'Service Not Found';

  @override
  String get serviceNotFoundMessage =>
      'Service not found. Please try again later.';

  @override
  String get genericError => 'An error occurred. Please try again.';

  @override
  String get addVaccine => 'Add vaccine';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get select => 'Select';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get notActive => 'Not Active';

  @override
  String get identificationNumber => 'ID Number';

  @override
  String get enterIdentificationNumber => 'Enter identification number';

  @override
  String get identificationNumberExists =>
      'Another livestock already uses this identification number. Please enter a unique ID.';

  @override
  String get identificationNumberRequired =>
      'Identification number is required';

  @override
  String get dummyTagId => 'Dummy Tag ID';

  @override
  String get enterDummyTagId => 'Enter dummy tag ID (optional)';

  @override
  String get barcodeTagId => 'Barcode Tag ID';

  @override
  String get enterBarcodeTagId => 'Enter barcode tag ID (optional)';

  @override
  String get rfidTagId => 'RFID Tag ID';

  @override
  String get enterRfidTagId => 'Enter RFID tag ID (optional)';

  @override
  String get livestockType => 'Livestock Type';

  @override
  String get livestockTypeRequired => 'Livestock type is required';

  @override
  String get pleaseSelectLivestockType => 'Please select livestock type';

  @override
  String get speciesRequired => 'Species is required';

  @override
  String get pleaseSelectSpecies => 'Please select species';

  @override
  String get breedRequired => 'Breed is required';

  @override
  String get pleaseSelectBreed => 'Please select breed';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightRequired => 'Weight is required';

  @override
  String get enterValidWeight => 'Enter valid weight';

  @override
  String get enterWeightOrBluetooth => 'Enter weight or use Bluetooth';

  @override
  String get dateEnteredFarmRequired => 'Date entered farm is required';

  @override
  String get motherOptional => 'Mother (Optional)';

  @override
  String get fatherOptional => 'Father (Optional)';

  @override
  String get obtainedMethod => 'Obtained Method';

  @override
  String get physicalDetails => 'Physical Details';

  @override
  String get additionalInfo => 'Additional Info';

  @override
  String get enterLivestockName => 'Enter livestock name';

  @override
  String get pleaseSelectFarm => 'Please select a farm';

  @override
  String get pleaseSelectDateEnteredFarm =>
      'Please select date first entered to farm';

  @override
  String get confirmUpdateLivestock =>
      'Are you sure you want to update this livestock?';

  @override
  String get confirmRegisterLivestock =>
      'Are you sure you want to register this livestock?';

  @override
  String get livestockUpdatedSuccessfully => 'Livestock updated successfully';

  @override
  String get livestockRegisteredSuccessfully =>
      'Livestock registered successfully';

  @override
  String get failedToSaveLivestock => 'Failed to save livestock';

  @override
  String get farmLocation => 'Farm Location';

  @override
  String get selectWhereLocated => 'Select where this livestock is located';

  @override
  String get basicDetails => 'Basic Details';

  @override
  String get enterNameAndId =>
      'Enter livestock name and primary identification';

  @override
  String get tagIdentification => 'Tag Identification';

  @override
  String get optionalEnterTagIds => 'Optional: Enter tag IDs for tracking';

  @override
  String get livestockClassification => 'Livestock Classification';

  @override
  String get selectTypeSpeciesBreed => 'Select type, species, and breed';

  @override
  String get physicalCharacteristics => 'Physical Characteristics';

  @override
  String get enterGenderWeightBirth => 'Enter gender, weight, and birth date';

  @override
  String get parentageInformation => 'Parentage Information';

  @override
  String get optionalSelectParents => 'Optional: Select mother and father';

  @override
  String get acquisitionDetails => 'Acquisition Details';

  @override
  String get howAndWhenObtained => 'How and when livestock was obtained';

  @override
  String get livestockStatus => 'Livestock Status';

  @override
  String get setCurrentStatus => 'Set the current status of this livestock';

  @override
  String get farmNameAndIdentification => 'Farm, name, and identification';

  @override
  String get typeSpeciesBreedCharacteristics =>
      'Type, species, breed, and characteristics';

  @override
  String get parentsMethodAndDates => 'Parents, method, and dates';

  @override
  String get actions => 'Actions';

  @override
  String get editLivestock => 'Edit Livestock';

  @override
  String get deleteLivestock => 'Delete Livestock';

  @override
  String get confirmDelete => 'Are you sure you want to delete';

  @override
  String get deletedSuccessfully => 'deleted successfully';

  @override
  String get failedToDelete => 'Failed to delete';

  @override
  String get disposal => 'Disposal';

  @override
  String get notProvided => 'Not provided';

  @override
  String get role => 'Role';

  @override
  String get unsyncedDataWarning =>
      'You have unsynced data. Sync before logging out to avoid losing recent changes.';

  @override
  String get noUnsyncedDataMessage =>
      'No unsynced data found. It is safe to log out.';

  @override
  String get syncAndLogout => 'Sync & Logout';

  @override
  String get syncingBeforeLogout =>
      'Syncing pending data before logging out...';

  @override
  String get addNotification => 'Add notification';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get upcomingToday => 'Today';

  @override
  String get upcomingNotifications => 'Upcoming';

  @override
  String get allNotifications => 'All notifications';

  @override
  String get notificationTitle => 'Notification title';

  @override
  String get enterNotificationTitle => 'Enter a notification title';

  @override
  String get notificationDescription => 'Description';

  @override
  String get enterNotificationDescription => 'Enter a description';

  @override
  String get optionalFieldHint => 'Optional';

  @override
  String get scheduleDate => 'Schedule date';

  @override
  String get scheduleTime => 'Schedule time';

  @override
  String get saveNotification => 'Save notification';

  @override
  String get notificationChipToday => 'Today';

  @override
  String get notificationChipUpcoming => 'Upcoming';

  @override
  String get markCompleted => 'Mark completed';

  @override
  String get deleteNotification => 'Delete notification';

  @override
  String notificationScheduledOn(String dateLabel) {
    return 'Scheduled on $dateLabel';
  }

  @override
  String get selectAlarmSound => 'Alarm sound';

  @override
  String alarmSoundSelected(String soundName) {
    return 'Current sound: $soundName';
  }

  @override
  String get chooseSound => 'Choose audio';

  @override
  String get previewSound => 'Preview';

  @override
  String get stopPreview => 'Stop preview';

  @override
  String get loopSound => 'Loop sound until stopped';

  @override
  String get vibrateDevice => 'Vibrate device';

  @override
  String get alarmVolume => 'Alarm volume';

  @override
  String get previewSoundFailed => 'Unable to preview sound';

  @override
  String get stopAlarm => 'Stop alarm';

  @override
  String get repeatDailyLabel => 'Repeat every day';

  @override
  String get repeatDailyHint => 'Alarm will ring at this time daily.';

  @override
  String get selectTimeLabel => 'Alarm time';

  @override
  String get selectTimeHint => 'Tap to choose a daily time';

  @override
  String get selectTimeRequired => 'Please select a time';

  @override
  String get scanUnsupportedDevice =>
      'Scanning is not supported on this device.';

  @override
  String get scanPermissionDenied => 'Camera permission denied.';

  @override
  String get scanPermissionRationaleTitle => 'Camera access required';

  @override
  String get scanPermissionRationaleMessage =>
      'Tag scanning needs camera access. Please allow permission to continue.';

  @override
  String get scanPermissionNotNow => 'Not now';

  @override
  String get scanPermissionAllow => 'Allow';

  @override
  String get scanPermissionSettingsTitle => 'Permission required';

  @override
  String get scanPermissionSettingsMessage =>
      'Enable camera permission in settings to continue scanning.';

  @override
  String get scanPermissionGoToSettings => 'Open settings';

  @override
  String get scanOptionQr => 'QR code';

  @override
  String get scanOptionQrDescription => 'Scan QR code tags';

  @override
  String get scanOptionBarcode => 'Barcode';

  @override
  String get scanOptionBarcodeDescription => 'Scan printed barcodes';

  @override
  String get scanOptionRfid => 'RFID';

  @override
  String get scanOptionRfidDescription => 'Use RFID reader';

  @override
  String get scanTagsTitle => 'Scan tags';

  @override
  String get scanTagsSubtitle => 'Choose how you want to scan';

  @override
  String get scanStartButton => 'Start scanning';

  @override
  String scanResultNotFound(String tag) {
    return 'No livestock found for tag $tag';
  }

  @override
  String get scanRfidPlaceholder => 'Enter RFID code';

  @override
  String get scanManualPlaceholder => 'Enter tag manually';

  @override
  String get scanManualConfirm => 'Confirm tag';

  @override
  String get vaccineSavedSuccessfully => 'Vaccine saved successfully';

  @override
  String get vaccineSaveFailed => 'Failed to save vaccine. Please try again.';

  @override
  String get vaccineUpdatedSuccessfully => 'Vaccine updated successfully';

  @override
  String get vaccineDetails => 'Vaccine details';

  @override
  String get vaccineDetailsSubtitle => 'Provide accurate vaccine information';

  @override
  String get vaccineType => 'Vaccine type';

  @override
  String get selectVaccineType => 'Select vaccine type';

  @override
  String get vaccineTypesMissing =>
      'Vaccine types missing. Sync reference data first.';

  @override
  String get vaccineTypeRequired => 'Vaccine type is required';

  @override
  String get formulationLiveAttenuated => 'Live attenuated';

  @override
  String get formulationInactivated => 'Inactivated';

  @override
  String get lotNumber => 'Lot number';

  @override
  String get enterLotNumber => 'Enter lot number';

  @override
  String get formulationType => 'Formulation type';

  @override
  String get selectFormulationType => 'Select formulation type';

  @override
  String get doseAmount => 'Dose amount';

  @override
  String get enterDoseAmount => 'Enter dose amount';

  @override
  String get doseUnit => 'Dose unit';

  @override
  String get selectDoseUnit => 'Select dose unit';

  @override
  String get vaccineSchedule => 'Schedule';

  @override
  String get selectVaccineSchedule => 'Select schedule';

  @override
  String get vaccineStatus => 'Vaccine status';

  @override
  String get selectStatus => 'Select status';

  @override
  String get ensureVaccineDetailsAccuracy =>
      'Ensure the vaccine details are accurate before saving.';

  @override
  String get confirmUpdateVaccine => 'Update vaccine details?';

  @override
  String get confirmSaveVaccine => 'Save this vaccine?';

  @override
  String get vaccineScheduleRegular => 'Regular schedule';

  @override
  String get vaccineScheduleBooster => 'Booster';

  @override
  String get vaccineScheduleSeasonal => 'Seasonal';

  @override
  String get vaccineScheduleEmergency => 'Emergency';

  @override
  String get bluetoothNotSupported =>
      'Bluetooth is not supported on this device';

  @override
  String get bluetoothPermissionsRequired =>
      'Bluetooth permissions are required to scan for devices. Please grant permissions when prompted.';

  @override
  String get bluetoothPermissionsPermanentlyDenied =>
      'Bluetooth permissions were permanently denied. Please enable them in app settings.';

  @override
  String get bluetoothTurnOnRequired =>
      'Please turn on Bluetooth to scan for devices';

  @override
  String get bluetoothTurnOnInstructions =>
      'Go to your device settings and turn on Bluetooth, then try again.';

  @override
  String get bluetoothUnknownError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get makeSureScaleOn => 'Make sure your scale is turned on';

  @override
  String get enableBluetooth => 'Enable Bluetooth';

  @override
  String get bluetoothLocationRequired =>
      'Location services are required for Bluetooth scanning on Android. Please enable location services in your device settings.';
}
