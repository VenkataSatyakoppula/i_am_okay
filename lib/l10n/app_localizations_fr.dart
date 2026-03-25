// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'IAmOkay';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get welcomeMessage =>
      'Bienvenue dans votre compagnon de sécurité personnel.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get iAlreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get poweredBy => 'Propulsé par';

  @override
  String get home => 'Accueil';

  @override
  String get history => 'Historique';

  @override
  String get contacts => 'Contacts';

  @override
  String get settings => 'Paramètres';

  @override
  String get howAreYouFeelingToday => 'Comment vous sentez-vous aujourd\'hui ?';

  @override
  String get iAmOkay => 'Je vais bien';

  @override
  String get setDailyReminder => 'Définir un rappel quotidien';

  @override
  String get setDailyReminderToCheckIn =>
      'Définir un rappel quotidien pour vous connecter';

  @override
  String get youHaveCheckedInForToday =>
      'Vous avez effectué votre pointage aujourd\'hui !';

  @override
  String get nextReminderIn => 'Prochain rappel dans';

  @override
  String get nextReminderTomorrowAt => 'Prochain rappel demain à';

  @override
  String get pauseReminder => 'Mettre en pause le rappel';

  @override
  String get resumeReminder => 'Reprendre le rappel';

  @override
  String get resumeReminderConfirm => 'Reprendre le rappel ?';

  @override
  String get wouldYouLikeToStartReminders =>
      'Souhaitez-vous recommencer à recevoir des rappels quotidiens ?';

  @override
  String get yesResume => 'Oui, reprendre';

  @override
  String get no => 'Non';

  @override
  String get cancel => 'Annuler';

  @override
  String get custom => 'Personnalisé';

  @override
  String get hours24 => '24 heures';

  @override
  String get days2 => '2 jours';

  @override
  String get week1 => '1 semaine';

  @override
  String get dailyCheckInAt => 'Pointage quotidien à';

  @override
  String get reminderPausedUntil => 'Rappel en pause jusqu\'au';

  @override
  String get reminderResumed => 'Rappel repris';

  @override
  String get checkInSuccessful => 'Pointage réussi ! Vous allez bien !';

  @override
  String get checkInFailed => 'Échec du pointage. Veuillez réessayer.';

  @override
  String get checkInFailedFromNotification =>
      'Échec du pointage. Veuillez réessayer depuis l\'application.';

  @override
  String get emergencyContacts => 'Contacts d\'urgence';

  @override
  String addUpTo3Contacts(int count) {
    return 'Ajouter jusqu\'à 3 contacts d\'urgence ($count/3)';
  }

  @override
  String get refresh => 'Actualiser';

  @override
  String get readyToReceiveAlerts => 'Prêt à recevoir les alertes';

  @override
  String get waitingForConfirmation => 'En attente de confirmation';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get dailyReminder => 'Rappel quotidien';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutUs => 'À propos';

  @override
  String get support => 'Assistance';

  @override
  String get biometric => 'Biométrie';

  @override
  String get permissions => 'Autorisations';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get goToLogin => 'Aller à la connexion';

  @override
  String get contactDashboard => 'Tableau de bord des contacts';

  @override
  String get emergencyContactFor => 'Contact d\'urgence pour';

  @override
  String historyOf(String name) {
    return 'Historique de $name';
  }

  @override
  String get somethingWentWrong =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get pleaseCheckConnection =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get connectionIssue => 'Problème de connexion';

  @override
  String get logoutAndSignInAgain =>
      'Nous avons des difficultés à nous connecter. Veuillez vous déconnecter et vous reconnecter pour continuer.';

  @override
  String get logoutAndSignInButton => 'Se déconnecter et se reconnecter';

  @override
  String get userInformation => 'Informations utilisateur';

  @override
  String get actions => 'Actions';

  @override
  String get failedToLoadProfile =>
      'Échec du chargement du profil. Vous êtes peut-être hors ligne.';

  @override
  String get pleaseSelectState => 'Veuillez sélectionner un état';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String get reminderTimeUpdated => 'Heure du rappel mise à jour avec succès !';

  @override
  String get pleaseSelectTimeFirst =>
      'Veuillez d\'abord sélectionner une heure';

  @override
  String get errorLoadingHistory =>
      'Erreur lors du chargement de l\'historique';

  @override
  String get navigate => 'Naviguer';

  @override
  String hiName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get aliasName => 'Alias';

  @override
  String get country => 'Pays';

  @override
  String get mobileNumber => 'Numéro de téléphone';

  @override
  String get addressLine1 => 'Adresse ligne 1';

  @override
  String get addressLine2 => 'Adresse ligne 2';

  @override
  String get city => 'Ville';

  @override
  String get zipCode => 'Code postal';

  @override
  String get state => 'État';

  @override
  String get email => 'Email';

  @override
  String get hintFirstName => 'Entrez votre prénom';

  @override
  String get hintLastName => 'Entrez votre nom de famille';

  @override
  String get hintAliasName => 'Entrez votre alias';

  @override
  String get hintSelectCountry => 'Sélectionnez le pays';

  @override
  String get hintMobileNumber => 'Entrez votre numéro de téléphone';

  @override
  String get hintAddressLine1 => 'Adresse, boîte postale, etc.';

  @override
  String get hintAddressLine2 => 'Appartement, suite, unité, etc.';

  @override
  String get hintCity => 'Entrez votre ville';

  @override
  String get hintZipCode => 'Code postal';

  @override
  String get hintSelectState => 'Sélectionnez l\'état';

  @override
  String get hintEmail => 'Entrez votre adresse email';

  @override
  String get hintFullName => 'Entrez le nom complet';

  @override
  String get hintPhoneNumber => 'Entrez le numéro de téléphone';

  @override
  String get hintContactEmail => 'Entrez l\'adresse email';

  @override
  String get hintOtpCode => 'Entrez le code à 6 chiffres';

  @override
  String get hintSelectRelation => 'Sélectionnez la relation';

  @override
  String get validationFirstNameRequired => 'Le prénom est requis';

  @override
  String get validationLastNameRequired => 'Le nom de famille est requis';

  @override
  String get validationOnlyAlphabets => 'Seules les lettres sont autorisées';

  @override
  String get validationMobileRequired => 'Le numéro de téléphone est requis';

  @override
  String get validationMobile10Digits =>
      'Entrez un numéro valide (8 à 12 chiffres)';

  @override
  String get validationAddressRequired => 'L\'adresse ligne 1 est requise';

  @override
  String get validationCityRequired => 'La ville est requise';

  @override
  String get validationZipRequired => 'Le code postal est requis';

  @override
  String get validationZip5Digits =>
      'Entrez un code postal valide à 5 chiffres';

  @override
  String get validationEmailInvalid => 'Entrez une adresse email valide';

  @override
  String get validationPleaseEnterMobile =>
      'Veuillez entrer le numéro de téléphone';

  @override
  String get validationPleaseEnterMobile10 =>
      'Veuillez entrer un numéro valide (8 à 12 chiffres)';

  @override
  String get validationNameRequired => 'Le nom est requis';

  @override
  String get pleaseSelectRelation => 'Veuillez sélectionner une relation';

  @override
  String get validationPhoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get validationPhone10Digits =>
      'Entrez un numéro valide (8 à 12 chiffres)';

  @override
  String get register => 'S\'inscrire';

  @override
  String get signIn => 'Se connecter';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToContinue => 'Connectez-vous pour accéder à votre compte';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get loginWithBiometrics => 'Connexion par biométrie';

  @override
  String get tapToUseBiometrics => 'Appuyez pour utiliser la biométrie';

  @override
  String get otpSentMessage =>
      'Nous avons envoyé un mot de passe à usage unique à votre numéro de téléphone.';

  @override
  String get otpCode => 'Code OTP';

  @override
  String get verifyAndLogin => 'Vérifier et se connecter';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String resendCodeIn(int seconds) {
    return 'Renvoyer le code dans ${seconds}s';
  }

  @override
  String get editContact => 'Modifier le contact';

  @override
  String get addNewContact => 'Ajouter un nouveau contact';

  @override
  String get relation => 'Relation';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get sendAlertsVia => 'Envoyer les alertes via';

  @override
  String get sms => 'SMS';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get consentDisclaimer =>
      'En ajoutant ce contact, vous confirmez qu\'il a accepté de recevoir des alertes d\'urgence automatiques de IamOkay.\n\nLa fréquence des messages varie. Des frais de messagerie et de données peuvent s\'appliquer.\n\nRépondez STOP pour vous désinscrire. Répondez HELP pour l\'aide.';

  @override
  String get consentDisclaimerBase =>
      'En ajoutant ce contact, vous confirmez qu\'il a accepté de recevoir des alertes d\'urgence automatiques de IamOkay.';

  @override
  String get consentDisclaimerSmsRates =>
      'La fréquence des messages varie. Des frais de messagerie et de données peuvent s\'appliquer.\n\nRépondez STOP pour vous désinscrire. Répondez HELP pour l\'aide.';

  @override
  String get consentCheckbox =>
      'Je confirme que ce contact a consenti à recevoir des alertes SMS de IamOkay.';

  @override
  String get consentCheckboxSms =>
      'Je confirme que ce contact a consenti à recevoir des alertes SMS de IamOkay.';

  @override
  String get consentCheckboxWhatsApp =>
      'Je confirme que ce contact a consenti à recevoir des alertes WhatsApp de IamOkay.';

  @override
  String get phoneCannotChange =>
      'Le numéro de téléphone ne peut pas être modifié pour les contacts vérifiés.';

  @override
  String get updateContact => 'Mettre à jour le contact';

  @override
  String get addContact => 'Ajouter le contact';

  @override
  String get addAnotherContact => 'Ajouter un autre contact';

  @override
  String get next => 'Suivant';

  @override
  String get pleaseConfirmConsent =>
      'Veuillez confirmer que le contact a consenti à recevoir les alertes.';

  @override
  String get relationParent => 'Parent';

  @override
  String get relationSpouse => 'Conjoint(e)';

  @override
  String get relationChild => 'Enfant';

  @override
  String get relationSibling => 'Frère/Sœur';

  @override
  String get relationFriend => 'Ami(e)';

  @override
  String get relationPartner => 'Partenaire';

  @override
  String get relationOther => 'Autre';

  @override
  String get userNotFoundPleaseLogin =>
      'Utilisateur introuvable localement. Veuillez vous reconnecter.';

  @override
  String get address => 'Adresse';

  @override
  String get user => 'Utilisateur';

  @override
  String get setTimeForDailyCheckIn =>
      'Définissez une heure pour votre pointage de sécurité quotidien.';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String get setReminder => 'Définir le rappel';

  @override
  String get updateReminder => 'Mettre à jour le rappel';

  @override
  String get permissionsRequired => 'Autorisations requises';

  @override
  String get permissionsRequiredDescription =>
      'Pour assurer votre sécurité et offrir la meilleure expérience, nous avons besoin d\'accéder aux autorisations suivantes :';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDescription =>
      'Pour vous rappeler de vous connecter quotidiennement et vous assurer que vous allez bien.';

  @override
  String get locationOptional => 'Localisation (optionnel)';

  @override
  String get locationDescription =>
      'Pour inclure votre position actuelle dans les alertes d\'urgence envoyées à vos contacts.';

  @override
  String get alarms => 'Alarmes';

  @override
  String get alarmsDescription =>
      'Pour planifier des rappels et des contrôles de sécurité précis.';

  @override
  String get fullScreenIntent => 'Intention plein écran';

  @override
  String get fullScreenIntentDescription =>
      'Pour ouvrir l\'application lorsque l\'alarme sonne sur l\'écran de verrouillage. Appuyez pour activer dans Paramètres.';

  @override
  String get grantPermissions => 'Accorder les autorisations';

  @override
  String get continueButton => 'Continuer';

  @override
  String get enablePermissionsLater =>
      'Vous pouvez activer les autorisations plus tard dans Paramètres si nécessaire.';

  @override
  String get authenticateToEnableBiometric =>
      'Veuillez vous authentifier pour activer la connexion biométrique';

  @override
  String get biometricAuthFailed =>
      'L\'authentification biométrique a échoué. Veuillez réessayer.';

  @override
  String get enableBiometricLogin => 'Activer la connexion biométrique';

  @override
  String get biometricLoginDescription =>
      'Connectez-vous plus rapidement et en toute sécurité avec votre empreinte digitale ou votre visage.';

  @override
  String get biometricsNotAvailable =>
      'La biométrie n\'est pas disponible sur cet appareil.';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get ourMission => 'Notre mission';

  @override
  String get aboutUsMission =>
      'IamOkay est dédié à vous garder en contact avec les personnes qui tiennent à vous. Nous aidons les utilisateurs à rester en sécurité en permettant des pointages quotidiens simples et des alertes d\'urgence automatiques aux contacts désignés en cas de besoin.';

  @override
  String get howItWorks => 'Comment ça marche';

  @override
  String get aboutUsHowItWorks =>
      'Définissez une heure de rappel quotidien qui vous convient. Connectez-vous lorsque vous y êtes invité pour informer vos contacts d\'urgence que vous allez bien. Si vous manquez un pointage, vos contacts peuvent être notifiés afin qu\'ils puissent vous contacter et s\'assurer de votre bien-être.';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get aboutUsFeatures =>
      '• Rappels de pointage quotidiens\n• Jusqu\'à 3 contacts d\'urgence\n• Partage de localisation optionnel pour les alertes\n• Mettre en pause les rappels si nécessaire\n• Conception simple et axée sur la confidentialité';

  @override
  String get version => 'Version';

  @override
  String get appVersion => 'IamOkay v1.0.0';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get supportContactText =>
      'Email : support@iamokay.app\nNous répondons généralement sous 24 à 48 heures.';

  @override
  String get faq => 'Questions fréquemment posées';

  @override
  String get faqAddContactQuestion => 'Comment ajouter un contact d\'urgence ?';

  @override
  String get faqAddContactAnswer =>
      'Allez dans l\'onglet Contacts, appuyez sur Ajouter un contact et entrez son nom, sa relation et son numéro de téléphone. Vous pouvez ajouter jusqu\'à 3 contacts d\'urgence.';

  @override
  String get faqMissCheckInQuestion =>
      'Que se passe-t-il si je manque un pointage ?';

  @override
  String get faqMissCheckInAnswer =>
      'Si vous ne vous connectez pas à l\'heure de votre rappel, vos contacts d\'urgence peuvent recevoir une alerte afin de pouvoir vous contacter.';

  @override
  String get faqPauseRemindersQuestion =>
      'Puis-je mettre en pause mes rappels ?';

  @override
  String get faqPauseRemindersAnswer =>
      'Oui. Sur l\'écran d\'accueil, utilisez « Mettre en pause le rappel » pour arrêter temporairement les rappels de pointage pendant 24 heures, 2 jours, 1 semaine ou une date personnalisée.';

  @override
  String get faqLocationQuestion => 'Ma localisation est-elle partagée ?';

  @override
  String get faqLocationAnswer =>
      'La localisation n\'est incluse dans les alertes d\'urgence que si vous avez accordé l\'autorisation de localisation et qu\'elle est activée dans vos paramètres.';

  @override
  String get resources => 'Ressources';

  @override
  String get supportResources =>
      '• Politique de confidentialité (voir Paramètres)\n• Version de l\'application et mises à jour via le magasin de votre appareil';

  @override
  String get soon => 'bientôt';

  @override
  String daysCount(int count) {
    return '$count jours';
  }

  @override
  String get oneDay => '1 jour';

  @override
  String hoursCount(int count) {
    return '$count heures';
  }

  @override
  String get oneHour => '1 heure';

  @override
  String minutesCount(int count) {
    return '$count minutes';
  }

  @override
  String get lessThanAMinute => 'moins d\'une minute';

  @override
  String nextReminderTomorrowAtTime(String time) {
    return 'Prochain rappel demain à $time';
  }

  @override
  String nextReminderInHms(int hours, int minutes, int seconds) {
    return 'Prochain rappel dans ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String nextReminderInMs(int minutes, int seconds) {
    return 'Prochain rappel dans ${minutes}m ${seconds}s';
  }

  @override
  String nextReminderInS(int seconds) {
    return 'Prochain rappel dans ${seconds}s';
  }

  @override
  String reminderPausedUntilDate(String date) {
    return 'Rappel en pause jusqu\'au $date';
  }

  @override
  String get paused => 'En pause';

  @override
  String resumesIn(String time) {
    return 'Reprend dans $time';
  }

  @override
  String get notificationDailyCheckInTitle => 'Pointage quotidien';

  @override
  String get notificationDailyCheckInBody =>
      'C\'est l\'heure de vous connecter ! Vous allez bien ?';

  @override
  String get notificationCheckInReminderTitle => 'Rappel de pointage';

  @override
  String get notificationCheckInReminderBody =>
      'Vous ne vous êtes pas encore connecté. Tout va bien ?';

  @override
  String get notificationAlarmChannelName => 'Alarme de pointage quotidien';

  @override
  String get notificationAlarmChannelDesc =>
      'Alarme sonore pour le pointage quotidien avec son et vibration';

  @override
  String get notificationAlarmStopButton => 'Arrêter';

  @override
  String get notificationChannelName => 'Pointage quotidien';

  @override
  String get notificationChannelDesc =>
      'Vous rappelle de vous connecter quotidiennement';

  @override
  String get userNotIdentifiedPleaseLogin =>
      'Utilisateur non identifié. Veuillez vous reconnecter.';

  @override
  String get retry => 'Réessayer';

  @override
  String get noHistoryAvailableYet =>
      'Aucun historique disponible pour le moment.';

  @override
  String get locationAvailable => 'Localisation disponible';

  @override
  String get locationNotAvailable => 'Localisation non disponible';

  @override
  String get checkInDetails => 'Détails du pointage';

  @override
  String statusLabel(String status) {
    return 'Statut : $status';
  }

  @override
  String dateLabel(String date) {
    return 'Date : $date';
  }

  @override
  String timeLabel(String time) {
    return 'Heure : $time';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date à $time';
  }

  @override
  String get close => 'Fermer';

  @override
  String get couldNotOpenMaps =>
      'Impossible d\'ouvrir l\'application de cartes';

  @override
  String get selectLanguage => 'Sélectionnez votre langue';

  @override
  String get selectLanguageDescription =>
      'Choisissez la langue de votre choix pour l\'application';
}
