// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'IAmOkay';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get welcomeMessage => 'Welcome to your personal safety companion.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get iAlreadyHaveAccount => 'I already have an account';

  @override
  String get poweredBy => 'Powered by';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get contacts => 'Contacts';

  @override
  String get settings => 'Settings';

  @override
  String get howAreYouFeelingToday => 'How are you feeling today?';

  @override
  String get iAmOkay => 'I am Okay';

  @override
  String get setDailyReminder => 'Set a Daily Reminder';

  @override
  String get setDailyReminderToCheckIn => 'Set a daily reminder to check in';

  @override
  String get youHaveCheckedInForToday => 'You have checked in for Today!';

  @override
  String get nextReminderIn => 'Next reminder in';

  @override
  String get nextReminderTomorrowAt => 'Next reminder tomorrow at';

  @override
  String get pauseReminder => 'Pause Reminder';

  @override
  String get resumeReminder => 'Resume Reminder';

  @override
  String get resumeReminderConfirm => 'Resume Reminder?';

  @override
  String get wouldYouLikeToStartReminders =>
      'Would you like to start receiving daily reminders again?';

  @override
  String get yesResume => 'Yes, Resume';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get custom => 'Custom';

  @override
  String get hours24 => '24 hours';

  @override
  String get days2 => '2 days';

  @override
  String get week1 => '1 week';

  @override
  String get dailyCheckInAt => 'Daily check-in at';

  @override
  String get reminderPausedUntil => 'Reminder paused until';

  @override
  String get reminderResumed => 'Reminder resumed';

  @override
  String get checkInSuccessful => 'Check-in successful! You are okay!';

  @override
  String get checkInFailed => 'Failed to check in. Please try again.';

  @override
  String get checkInFailedFromNotification =>
      'Check-in failed. Please try again from the app.';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String addUpTo3Contacts(int count) {
    return 'Add up to 3 emergency contacts ($count/3)';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get readyToReceiveAlerts => 'Ready to receive alerts';

  @override
  String get waitingForConfirmation => 'Waiting for confirmation';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutUs => 'About Us';

  @override
  String get support => 'Support';

  @override
  String get biometric => 'Biometric';

  @override
  String get permissions => 'Permissions';

  @override
  String get logOut => 'Log Out';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get contactDashboard => 'Contact Dashboard';

  @override
  String get emergencyContactFor => 'Emergency Contact For';

  @override
  String historyOf(String name) {
    return '$name\'s History';
  }

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get pleaseCheckConnection =>
      'Please check your internet connection and try again.';

  @override
  String get connectionIssue => 'Connection issue';

  @override
  String get logoutAndSignInAgain =>
      'We\'re having trouble connecting. Please log out and log in again to continue.';

  @override
  String get logoutAndSignInButton => 'Log out and sign in again';

  @override
  String get userInformation => 'User Information';

  @override
  String get actions => 'Actions';

  @override
  String get failedToLoadProfile =>
      'Failed to load profile. You may be offline.';

  @override
  String get pleaseSelectState => 'Please select a state';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get reminderTimeUpdated => 'Reminder time updated successfully!';

  @override
  String get pleaseSelectTimeFirst => 'Please select a time first';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get navigate => 'Navigate';

  @override
  String hiName(String name) {
    return 'Hi, $name';
  }

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get aliasName => 'Alias Name';

  @override
  String get country => 'Country';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get addressLine1 => 'Address Line 1';

  @override
  String get addressLine2 => 'Address Line 2';

  @override
  String get city => 'City';

  @override
  String get zipCode => 'Zip Code';

  @override
  String get state => 'State';

  @override
  String get email => 'Email';

  @override
  String get hintFirstName => 'Enter your first name';

  @override
  String get hintLastName => 'Enter your last name';

  @override
  String get hintAliasName => 'Enter your alias name';

  @override
  String get hintSelectCountry => 'Select country';

  @override
  String get hintMobileNumber => 'Enter your mobile number';

  @override
  String get hintAddressLine1 => 'Street address, P.O. box, etc.';

  @override
  String get hintAddressLine2 => 'Apartment, suite, unit, etc.';

  @override
  String get hintCity => 'Enter your city';

  @override
  String get hintZipCode => 'Zip Code';

  @override
  String get hintSelectState => 'Select State';

  @override
  String get hintEmail => 'Enter your email address';

  @override
  String get hintFullName => 'Enter full name';

  @override
  String get hintPhoneNumber => 'Enter phone number';

  @override
  String get hintContactEmail => 'Enter email address';

  @override
  String get hintOtpCode => 'Enter the 6-digit code';

  @override
  String get hintSelectRelation => 'Select relation';

  @override
  String get validationFirstNameRequired => 'First name is required';

  @override
  String get validationLastNameRequired => 'Last name is required';

  @override
  String get validationOnlyAlphabets => 'Only alphabets are allowed';

  @override
  String get validationMobileRequired => 'Mobile number is required';

  @override
  String get validationMobile10Digits =>
      'Enter a valid mobile number (8-12 digits)';

  @override
  String get validationAddressRequired => 'Address Line 1 is required';

  @override
  String get validationCityRequired => 'City is required';

  @override
  String get validationZipRequired => 'Zip Code is required';

  @override
  String get validationZip5Digits => 'Enter a valid 5-digit Zip Code';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPleaseEnterMobile => 'Please enter mobile number';

  @override
  String get validationPleaseEnterMobile10 =>
      'Please enter a valid number (8-12 digits)';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get pleaseSelectRelation => 'Please select a relation';

  @override
  String get validationPhoneRequired => 'Phone number is required';

  @override
  String get validationPhone10Digits =>
      'Enter a valid phone number (8-12 digits)';

  @override
  String get register => 'Register';

  @override
  String get signIn => 'Sign In';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue to your account';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get loginWithBiometrics => 'Login with Biometrics';

  @override
  String get tapToUseBiometrics => 'Tap to use Biometrics';

  @override
  String get otpSentMessage =>
      'We have sent a one-time password to your mobile number.';

  @override
  String get otpCode => 'OTP Code';

  @override
  String get verifyAndLogin => 'Verify & Login';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend Code in ${seconds}s';
  }

  @override
  String get editContact => 'Edit Contact';

  @override
  String get addNewContact => 'Add New Contact';

  @override
  String get relation => 'Relation';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get sendAlertsVia => 'Send alerts via';

  @override
  String get sms => 'SMS';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get consentDisclaimer =>
      'By adding this contact, you confirm they have agreed to receive automated emergency alerts from IamOkay.\n\nMessage frequency varies. Message & data rates may apply.\n\nReply STOP to opt out. Reply HELP for help.';

  @override
  String get consentDisclaimerBase =>
      'By adding this contact, you confirm they have agreed to receive automated emergency alerts from IamOkay.';

  @override
  String get consentDisclaimerSmsRates =>
      'Message frequency varies. Message & data rates may apply.\n\nReply STOP to opt out. Reply HELP for help.';

  @override
  String get consentCheckbox =>
      'I confirm this contact has consented to receive SMS alerts from IamOkay.';

  @override
  String get consentCheckboxSms =>
      'I confirm this contact has consented to receive SMS alerts from IamOkay.';

  @override
  String get consentCheckboxWhatsApp =>
      'I confirm this contact has consented to receive WhatsApp alerts from IamOkay.';

  @override
  String get phoneCannotChange =>
      'Phone number cannot be changed for verified contacts.';

  @override
  String get updateContact => 'Update Contact';

  @override
  String get addContact => 'Add Contact';

  @override
  String get addAnotherContact => 'Add Another Contact';

  @override
  String get next => 'Next';

  @override
  String get pleaseConfirmConsent =>
      'Please confirm that the contact has consented to receive alerts.';

  @override
  String get relationParent => 'Parent';

  @override
  String get relationSpouse => 'Spouse';

  @override
  String get relationChild => 'Child';

  @override
  String get relationSibling => 'Sibling';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationPartner => 'Partner';

  @override
  String get relationOther => 'Other';

  @override
  String get userNotFoundPleaseLogin =>
      'User not found locally. Please login again.';

  @override
  String get address => 'Address';

  @override
  String get user => 'User';

  @override
  String get setTimeForDailyCheckIn =>
      'Set a time for your daily safety check-in.';

  @override
  String get selectTime => 'Select Time';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get updateReminder => 'Update Reminder';

  @override
  String get permissionsRequired => 'Permissions Required';

  @override
  String get permissionsRequiredDescription =>
      'To ensure your safety and provide the best experience, we need access to the following permissions:';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDescription =>
      'To remind you to check in daily and ensure you are okay.';

  @override
  String get locationOptional => 'Location (Optional)';

  @override
  String get locationDescription =>
      'To include your current location in emergency alerts sent to your contacts.';

  @override
  String get alarms => 'Alarms';

  @override
  String get alarmsDescription =>
      'To schedule precise reminders and safety checks.';

  @override
  String get fullScreenIntent => 'Full-screen intent';

  @override
  String get fullScreenIntentDescription =>
      'To open the app when the alarm rings on the lock screen. Tap to enable in Settings.';

  @override
  String get grantPermissions => 'Grant Permissions';

  @override
  String get continueButton => 'Continue';

  @override
  String get enablePermissionsLater =>
      'You can enable permissions later in Settings if needed.';

  @override
  String get authenticateToEnableBiometric =>
      'Please authenticate to enable biometric login';

  @override
  String get biometricAuthFailed =>
      'Biometric authentication failed. Please try again.';

  @override
  String get enableBiometricLogin => 'Enable Biometric Login';

  @override
  String get biometricLoginDescription =>
      'Log in faster and more securely with your fingerprint or face.';

  @override
  String get biometricsNotAvailable =>
      'Biometrics not available on this device.';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get ourMission => 'Our Mission';

  @override
  String get aboutUsMission =>
      'IamOkay is dedicated to keeping you connected with the people who care about you. We help users stay safe by enabling simple daily check-ins and automated emergency alerts to designated contacts when needed.';

  @override
  String get howItWorks => 'How It Works';

  @override
  String get aboutUsHowItWorks =>
      'Set a daily reminder time that works for you. Check in when prompted to let your emergency contacts know you\'re okay. If you miss a check-in, your contacts can be notified so they can reach out and ensure your wellbeing.';

  @override
  String get features => 'Features';

  @override
  String get aboutUsFeatures =>
      '• Daily check-in reminders\n• Up to 3 emergency contacts\n• Optional location sharing for alerts\n• Pause reminders when needed\n• Simple, privacy-focused design';

  @override
  String get version => 'Version';

  @override
  String get appVersion => 'IamOkay v1.0.0';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get supportContactText =>
      'Email: support@iamokay.app\nWe typically respond within 24–48 hours.';

  @override
  String get faq => 'Frequently Asked Questions';

  @override
  String get faqAddContactQuestion => 'How do I add an emergency contact?';

  @override
  String get faqAddContactAnswer =>
      'Go to the Contacts tab, tap Add Contact, and enter their name, relation, and phone number. You can add up to 3 emergency contacts.';

  @override
  String get faqMissCheckInQuestion => 'What happens if I miss a check-in?';

  @override
  String get faqMissCheckInAnswer =>
      'If you don\'t check in by your reminder time, your emergency contacts may receive an alert so they can reach out to you.';

  @override
  String get faqPauseRemindersQuestion => 'Can I pause my reminders?';

  @override
  String get faqPauseRemindersAnswer =>
      'Yes. On the Home screen, use \"Pause Reminder\" to temporarily stop check-in reminders for 24 hours, 2 days, 1 week, or a custom date.';

  @override
  String get faqLocationQuestion => 'Is my location shared?';

  @override
  String get faqLocationAnswer =>
      'Location is only included in emergency alerts if you have granted location permission and it is enabled in your settings.';

  @override
  String get resources => 'Resources';

  @override
  String get supportResources =>
      '• Privacy Policy (see Settings)\n• App version and updates via your device\'s store';

  @override
  String get soon => 'soon';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get oneDay => '1 day';

  @override
  String hoursCount(int count) {
    return '$count hours';
  }

  @override
  String get oneHour => '1 hour';

  @override
  String minutesCount(int count) {
    return '$count minutes';
  }

  @override
  String get lessThanAMinute => 'less than a minute';

  @override
  String nextReminderTomorrowAtTime(String time) {
    return 'Next reminder tomorrow at $time';
  }

  @override
  String nextReminderInHms(int hours, int minutes, int seconds) {
    return 'Next reminder in ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String nextReminderInMs(int minutes, int seconds) {
    return 'Next reminder in ${minutes}m ${seconds}s';
  }

  @override
  String nextReminderInS(int seconds) {
    return 'Next reminder in ${seconds}s';
  }

  @override
  String reminderPausedUntilDate(String date) {
    return 'Reminder paused until $date';
  }

  @override
  String get paused => 'Paused';

  @override
  String resumesIn(String time) {
    return 'Resumes in $time';
  }

  @override
  String get notificationDailyCheckInTitle => 'Daily Check-in';

  @override
  String get notificationDailyCheckInBody => 'Time to check in! Are you okay?';

  @override
  String get notificationCheckInReminderTitle => 'Check-in Reminder';

  @override
  String get notificationCheckInReminderBody =>
      'You haven\'t checked in yet. Is everything okay?';

  @override
  String get notificationAlarmChannelName => 'Daily Check-in Alarm';

  @override
  String get notificationAlarmChannelDesc =>
      'Ringing alarm for daily check-in with sound and vibration';

  @override
  String get notificationChannelName => 'Daily Check-in';

  @override
  String get notificationChannelDesc => 'Reminds you to check in daily';

  @override
  String get userNotIdentifiedPleaseLogin =>
      'User not identified. Please log in again.';

  @override
  String get retry => 'Retry';

  @override
  String get noHistoryAvailableYet => 'No history available yet.';

  @override
  String get locationAvailable => 'Location available';

  @override
  String get locationNotAvailable => 'Location not available';

  @override
  String get checkInDetails => 'Check-in Details';

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String timeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get close => 'Close';

  @override
  String get couldNotOpenMaps => 'Could not open maps application';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String get selectLanguageDescription =>
      'Choose your preferred language for the app';
}
