import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IAmOkay'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your personal safety companion.'**
  String get welcomeMessage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @iAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get iAlreadyHaveAccount;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howAreYouFeelingToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeelingToday;

  /// No description provided for @iAmOkay.
  ///
  /// In en, this message translates to:
  /// **'I am Okay'**
  String get iAmOkay;

  /// No description provided for @setDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Set a Daily Reminder'**
  String get setDailyReminder;

  /// No description provided for @setDailyReminderToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Set a daily reminder to check in'**
  String get setDailyReminderToCheckIn;

  /// No description provided for @youHaveCheckedInForToday.
  ///
  /// In en, this message translates to:
  /// **'You have checked in for Today!'**
  String get youHaveCheckedInForToday;

  /// No description provided for @nextReminderIn.
  ///
  /// In en, this message translates to:
  /// **'Next reminder in'**
  String get nextReminderIn;

  /// No description provided for @nextReminderTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Next reminder tomorrow at'**
  String get nextReminderTomorrowAt;

  /// No description provided for @pauseReminder.
  ///
  /// In en, this message translates to:
  /// **'Pause Reminder'**
  String get pauseReminder;

  /// No description provided for @resumeReminder.
  ///
  /// In en, this message translates to:
  /// **'Resume Reminder'**
  String get resumeReminder;

  /// No description provided for @resumeReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Resume Reminder?'**
  String get resumeReminderConfirm;

  /// No description provided for @wouldYouLikeToStartReminders.
  ///
  /// In en, this message translates to:
  /// **'Would you like to start receiving daily reminders again?'**
  String get wouldYouLikeToStartReminders;

  /// No description provided for @yesResume.
  ///
  /// In en, this message translates to:
  /// **'Yes, Resume'**
  String get yesResume;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @hours24.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get hours24;

  /// No description provided for @days2.
  ///
  /// In en, this message translates to:
  /// **'2 days'**
  String get days2;

  /// No description provided for @week1.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get week1;

  /// No description provided for @dailyCheckInAt.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in at'**
  String get dailyCheckInAt;

  /// No description provided for @reminderPausedUntil.
  ///
  /// In en, this message translates to:
  /// **'Reminder paused until'**
  String get reminderPausedUntil;

  /// No description provided for @reminderResumed.
  ///
  /// In en, this message translates to:
  /// **'Reminder resumed'**
  String get reminderResumed;

  /// No description provided for @checkInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Check-in successful! You are okay!'**
  String get checkInSuccessful;

  /// No description provided for @checkInFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check in. Please try again.'**
  String get checkInFailed;

  /// No description provided for @checkInFailedFromNotification.
  ///
  /// In en, this message translates to:
  /// **'Check-in failed. Please try again from the app.'**
  String get checkInFailedFromNotification;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @addUpTo3Contacts.
  ///
  /// In en, this message translates to:
  /// **'Add up to 3 emergency contacts ({count}/3)'**
  String addUpTo3Contacts(int count);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @readyToReceiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Ready to receive alerts'**
  String get readyToReceiveAlerts;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get waitingForConfirmation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @contactDashboard.
  ///
  /// In en, this message translates to:
  /// **'Contact Dashboard'**
  String get contactDashboard;

  /// No description provided for @emergencyContactFor.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact For'**
  String get emergencyContactFor;

  /// No description provided for @historyOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s History'**
  String historyOf(String name);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @pleaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get pleaseCheckConnection;

  /// No description provided for @connectionIssue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get connectionIssue;

  /// No description provided for @logoutAndSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'We\'re having trouble connecting. Please log out and log in again to continue.'**
  String get logoutAndSignInAgain;

  /// No description provided for @logoutAndSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Log out and sign in again'**
  String get logoutAndSignInButton;

  /// No description provided for @userInformation.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformation;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile. You may be offline.'**
  String get failedToLoadProfile;

  /// No description provided for @pleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'State or province is required'**
  String get pleaseSelectState;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @reminderTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder time updated successfully!'**
  String get reminderTimeUpdated;

  /// No description provided for @pleaseSelectTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a time first'**
  String get pleaseSelectTimeFirst;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get errorLoadingHistory;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @hiName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String hiName(String name);

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @aliasName.
  ///
  /// In en, this message translates to:
  /// **'Alias Name'**
  String get aliasName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get zipCode;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State / province'**
  String get state;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @hintFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get hintFirstName;

  /// No description provided for @hintLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get hintLastName;

  /// No description provided for @hintAliasName.
  ///
  /// In en, this message translates to:
  /// **'Enter your alias name'**
  String get hintAliasName;

  /// No description provided for @hintSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get hintSelectCountry;

  /// No description provided for @hintMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get hintMobileNumber;

  /// No description provided for @hintAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Street address, P.O. box, etc.'**
  String get hintAddressLine1;

  /// No description provided for @hintAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Apartment, suite, unit, etc.'**
  String get hintAddressLine2;

  /// No description provided for @hintCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get hintCity;

  /// No description provided for @hintZipCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get hintZipCode;

  /// No description provided for @hintSelectState.
  ///
  /// In en, this message translates to:
  /// **'State, province, or region'**
  String get hintSelectState;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get hintEmail;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get hintFullName;

  /// No description provided for @hintPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get hintPhoneNumber;

  /// No description provided for @hintContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get hintContactEmail;

  /// No description provided for @hintOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get hintOtpCode;

  /// No description provided for @hintSelectRelation.
  ///
  /// In en, this message translates to:
  /// **'Select relation'**
  String get hintSelectRelation;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get validationFirstNameRequired;

  /// No description provided for @validationLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get validationLastNameRequired;

  /// No description provided for @validationOnlyAlphabets.
  ///
  /// In en, this message translates to:
  /// **'Only alphabets are allowed'**
  String get validationOnlyAlphabets;

  /// No description provided for @validationMobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get validationMobileRequired;

  /// No description provided for @validationMobile10Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number (8-12 digits)'**
  String get validationMobile10Digits;

  /// No description provided for @validationAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1 is required'**
  String get validationAddressRequired;

  /// No description provided for @validationCityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get validationCityRequired;

  /// No description provided for @validationZipRequired.
  ///
  /// In en, this message translates to:
  /// **'Postal code is required'**
  String get validationZipRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPleaseEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get validationPleaseEnterMobile;

  /// No description provided for @validationPleaseEnterMobile10.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number (8-12 digits)'**
  String get validationPleaseEnterMobile10;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @pleaseSelectRelation.
  ///
  /// In en, this message translates to:
  /// **'Please select a relation'**
  String get pleaseSelectRelation;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhone10Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (8-12 digits)'**
  String get validationPhone10Digits;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your account'**
  String get signInToContinue;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @loginWithBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Login with Biometrics'**
  String get loginWithBiometrics;

  /// No description provided for @tapToUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Tap to use Biometrics'**
  String get tapToUseBiometrics;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We have sent a one-time password to your mobile number.'**
  String get otpSentMessage;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @verifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verifyAndLogin;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend Code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @addNewContact.
  ///
  /// In en, this message translates to:
  /// **'Add New Contact'**
  String get addNewContact;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @sendAlertsVia.
  ///
  /// In en, this message translates to:
  /// **'Send alerts via'**
  String get sendAlertsVia;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @consentDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By adding this contact, you confirm they have agreed to receive automated emergency alerts from IamOkay.\n\nMessage frequency varies. Message & data rates may apply.\n\nReply STOP to opt out. Reply HELP for help.'**
  String get consentDisclaimer;

  /// No description provided for @consentDisclaimerBase.
  ///
  /// In en, this message translates to:
  /// **'By adding this contact, you confirm they have agreed to receive automated emergency alerts from IamOkay.'**
  String get consentDisclaimerBase;

  /// No description provided for @consentDisclaimerSmsRates.
  ///
  /// In en, this message translates to:
  /// **'Message frequency varies. Message & data rates may apply.\n\nReply STOP to opt out. Reply HELP for help.'**
  String get consentDisclaimerSmsRates;

  /// No description provided for @consentCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm this contact has consented to receive SMS alerts from IamOkay.'**
  String get consentCheckbox;

  /// No description provided for @consentCheckboxSms.
  ///
  /// In en, this message translates to:
  /// **'I confirm this contact has consented to receive SMS alerts from IamOkay.'**
  String get consentCheckboxSms;

  /// No description provided for @consentCheckboxWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'I confirm this contact has consented to receive WhatsApp alerts from IamOkay.'**
  String get consentCheckboxWhatsApp;

  /// No description provided for @phoneCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed for verified contacts.'**
  String get phoneCannotChange;

  /// No description provided for @updateContact.
  ///
  /// In en, this message translates to:
  /// **'Update Contact'**
  String get updateContact;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @addAnotherContact.
  ///
  /// In en, this message translates to:
  /// **'Add Another Contact'**
  String get addAnotherContact;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pleaseConfirmConsent.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that the contact has consented to receive alerts.'**
  String get pleaseConfirmConsent;

  /// No description provided for @relationParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relationParent;

  /// No description provided for @relationSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationSpouse;

  /// No description provided for @relationChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relationChild;

  /// No description provided for @relationSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationSibling;

  /// No description provided for @relationFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationFriend;

  /// No description provided for @relationPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get relationPartner;

  /// No description provided for @relationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationOther;

  /// No description provided for @userNotFoundPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'User not found locally. Please login again.'**
  String get userNotFoundPleaseLogin;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @setTimeForDailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Set a time for your daily safety check-in.'**
  String get setTimeForDailyCheckIn;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @updateReminder.
  ///
  /// In en, this message translates to:
  /// **'Update Reminder'**
  String get updateReminder;

  /// No description provided for @permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get permissionsRequired;

  /// No description provided for @permissionsRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'To ensure your safety and provide the best experience, we need access to the following permissions:'**
  String get permissionsRequiredDescription;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'To remind you to check in daily and ensure you are okay.'**
  String get notificationsDescription;

  /// No description provided for @locationOptional.
  ///
  /// In en, this message translates to:
  /// **'Location (Optional)'**
  String get locationOptional;

  /// No description provided for @locationDescription.
  ///
  /// In en, this message translates to:
  /// **'To include your current location in emergency alerts sent to your contacts.'**
  String get locationDescription;

  /// No description provided for @alarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarms;

  /// No description provided for @alarmsDescription.
  ///
  /// In en, this message translates to:
  /// **'To schedule precise reminders and safety checks.'**
  String get alarmsDescription;

  /// No description provided for @fullScreenIntent.
  ///
  /// In en, this message translates to:
  /// **'Full-screen intent'**
  String get fullScreenIntent;

  /// No description provided for @fullScreenIntentDescription.
  ///
  /// In en, this message translates to:
  /// **'To open the app when the alarm rings on the lock screen. Tap to enable in Settings.'**
  String get fullScreenIntentDescription;

  /// No description provided for @grantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enablePermissionsLater.
  ///
  /// In en, this message translates to:
  /// **'You can enable permissions later in Settings if needed.'**
  String get enablePermissionsLater;

  /// No description provided for @authenticateToEnableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to enable biometric login'**
  String get authenticateToEnableBiometric;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed. Please try again.'**
  String get biometricAuthFailed;

  /// No description provided for @enableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get enableBiometricLogin;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'Log in faster and more securely with your fingerprint or face.'**
  String get biometricLoginDescription;

  /// No description provided for @biometricsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device.'**
  String get biometricsNotAvailable;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @aboutUsMission.
  ///
  /// In en, this message translates to:
  /// **'IamOkay is dedicated to keeping you connected with the people who care about you. We help users stay safe by enabling simple daily check-ins and automated emergency alerts to designated contacts when needed.'**
  String get aboutUsMission;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @aboutUsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'Set a daily reminder time that works for you. Check in when prompted to let your emergency contacts know you\'re okay. If you miss a check-in, your contacts can be notified so they can reach out and ensure your wellbeing.'**
  String get aboutUsHowItWorks;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @aboutUsFeatures.
  ///
  /// In en, this message translates to:
  /// **'• Daily check-in reminders\n• Up to 3 emergency contacts\n• Optional location sharing for alerts\n• Pause reminders when needed\n• Simple, privacy-focused design'**
  String get aboutUsFeatures;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'IamOkay v1.0.0'**
  String get appVersion;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @supportContactText.
  ///
  /// In en, this message translates to:
  /// **'Email: support@iamokay.app\nWe typically respond within 24–48 hours.'**
  String get supportContactText;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faq;

  /// No description provided for @faqAddContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I add an emergency contact?'**
  String get faqAddContactQuestion;

  /// No description provided for @faqAddContactAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Contacts tab, tap Add Contact, and enter their name, relation, and phone number. You can add up to 3 emergency contacts.'**
  String get faqAddContactAnswer;

  /// No description provided for @faqMissCheckInQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens if I miss a check-in?'**
  String get faqMissCheckInQuestion;

  /// No description provided for @faqMissCheckInAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t check in by your reminder time, your emergency contacts may receive an alert so they can reach out to you.'**
  String get faqMissCheckInAnswer;

  /// No description provided for @faqPauseRemindersQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I pause my reminders?'**
  String get faqPauseRemindersQuestion;

  /// No description provided for @faqPauseRemindersAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. On the Home screen, use \"Pause Reminder\" to temporarily stop check-in reminders for 24 hours, 2 days, 1 week, or a custom date.'**
  String get faqPauseRemindersAnswer;

  /// No description provided for @faqLocationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is my location shared?'**
  String get faqLocationQuestion;

  /// No description provided for @faqLocationAnswer.
  ///
  /// In en, this message translates to:
  /// **'Location is only included in emergency alerts if you have granted location permission and it is enabled in your settings.'**
  String get faqLocationAnswer;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @supportResources.
  ///
  /// In en, this message translates to:
  /// **'• Privacy Policy (see Settings)\n• App version and updates via your device\'s store'**
  String get supportResources;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get soon;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// No description provided for @hoursCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hoursCount(int count);

  /// No description provided for @oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutesCount(int count);

  /// No description provided for @lessThanAMinute.
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get lessThanAMinute;

  /// No description provided for @nextReminderTomorrowAtTime.
  ///
  /// In en, this message translates to:
  /// **'Next reminder tomorrow at {time}'**
  String nextReminderTomorrowAtTime(String time);

  /// No description provided for @nextReminderInHms.
  ///
  /// In en, this message translates to:
  /// **'Next reminder in {hours}h {minutes}m {seconds}s'**
  String nextReminderInHms(int hours, int minutes, int seconds);

  /// No description provided for @nextReminderInMs.
  ///
  /// In en, this message translates to:
  /// **'Next reminder in {minutes}m {seconds}s'**
  String nextReminderInMs(int minutes, int seconds);

  /// No description provided for @nextReminderInS.
  ///
  /// In en, this message translates to:
  /// **'Next reminder in {seconds}s'**
  String nextReminderInS(int seconds);

  /// No description provided for @reminderPausedUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder paused until {date}'**
  String reminderPausedUntilDate(String date);

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @resumesIn.
  ///
  /// In en, this message translates to:
  /// **'Resumes in {time}'**
  String resumesIn(String time);

  /// No description provided for @notificationDailyCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get notificationDailyCheckInTitle;

  /// No description provided for @notificationDailyCheckInBody.
  ///
  /// In en, this message translates to:
  /// **'Time to check in! Are you okay?'**
  String get notificationDailyCheckInBody;

  /// No description provided for @notificationCheckInReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in Reminder'**
  String get notificationCheckInReminderTitle;

  /// No description provided for @notificationCheckInReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t checked in yet. Is everything okay?'**
  String get notificationCheckInReminderBody;

  /// No description provided for @notificationAlarmChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in Alarm'**
  String get notificationAlarmChannelName;

  /// No description provided for @notificationAlarmChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Ringing alarm for daily check-in with sound and vibration'**
  String get notificationAlarmChannelDesc;

  /// No description provided for @notificationAlarmStopButton.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get notificationAlarmStopButton;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to check in daily'**
  String get notificationChannelDesc;

  /// No description provided for @userNotIdentifiedPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'User not identified. Please log in again.'**
  String get userNotIdentifiedPleaseLogin;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noHistoryAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No history available yet.'**
  String get noHistoryAvailableYet;

  /// No description provided for @locationAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location available'**
  String get locationAvailable;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get locationNotAvailable;

  /// No description provided for @checkInDetails.
  ///
  /// In en, this message translates to:
  /// **'Check-in Details'**
  String get checkInDetails;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String timeLabel(String time);

  /// No description provided for @dateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @couldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open maps application'**
  String get couldNotOpenMaps;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app'**
  String get selectLanguageDescription;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
