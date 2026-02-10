// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Compteur Partagé DinDonDan';

  @override
  String get createCounterCaption => 'Créer un nouveau compteur partagé';

  @override
  String get createCounterButton => 'Créer un compteur';

  @override
  String get capacityHint => 'Capacité (optionnel)';

  @override
  String get scanQrCaption => 'Rejoindre un compteur partagé existant';

  @override
  String get scanQrButton => 'Scanner le code QR';

  @override
  String get scanQrWebNotice =>
      'Demandez au créateur du compteur de vous envoyer le lien, ou téléchargez la version mobile de Compteur Partagé depuis l\'App Store ou le Play Store pour scanner le code QR';

  @override
  String get historyTitle => 'Compteurs passés';

  @override
  String get noHistoryNotice => 'Vos compteurs passés apparaîtront ici.';

  @override
  String get historyLoadingError =>
      'Une erreur s\'est produite lors du chargement des compteurs passés';

  @override
  String get historyDeleteConfirmTitle => 'Supprimer le compteur';

  @override
  String get historyDeleteConfirmMessage =>
      'Voulez-vous vraiment supprimer ce compteur des compteurs passés ? Cette opération est irréversible.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get delete => 'Supprimer';

  @override
  String get resume => 'Reprendre';

  @override
  String get appBarLoginInProgress => 'Connexion en cours…';

  @override
  String get appBarDefault => 'Compteur Partagé';

  @override
  String get orDivider => '– ou –';

  @override
  String get parishSignIn => 'Espace réservé aux églises';

  @override
  String get parishSignOut => 'Se déconnecter';

  @override
  String get createCounterErrorTitle =>
      'Impossible de créer un compteur partagé';

  @override
  String get createCounterErrorMessage =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get accountErrorTitle => 'Erreur de connexion';

  @override
  String get accountErrorMessage =>
      'Les informations de votre compte n\'ont pas pu être récupérées.\n\nSi le problème persiste, appuyez sur \"se déconnecter\" et réessayez.';

  @override
  String get networkErrorTitle => 'Erreur de connexion';

  @override
  String get networkErrorMessage =>
      'Impossible de se connecter au serveur. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get incompleteSignUpErrorTitle => 'Inscription incomplète';

  @override
  String get incompleteSignUpErrorMessage =>
      'Il semble que vous n\'ayez pas terminé la procédure d\'inscription.\n\nPour vous connecter, vous devez fournir plus de détails. Appuyez sur \"continuer\" pour être redirigé vers les services web et terminer l\'inscription.';

  @override
  String get webAppDownloadBanner =>
      'Vous utilisez la version web de Compteur Partagé. Si vous avez un appareil Android ou iOS, téléchargez l\'application native !';

  @override
  String get infoScreenTitle => 'À propos de Compteur Partagé';

  @override
  String get infoScreenText =>
      'Compteur Partagé est l\'outil simple et efficace pour compter les visiteurs d\'événements, commerces locaux, fonctions religieuses et bien plus encore, même avec plusieurs entrées.\n\nPour commencer, créez un nouveau compteur, en spécifiant éventuellement la capacité. Vous pouvez ensuite partager le compteur avec d\'autres appareils, par exemple pour surveiller plusieurs entrées en même temps, via un simple lien ou un code QR. Vous aurez toujours le contrôle du total des comptes de tous les appareils, synchronisés en temps réel.\n\nLe service a été créé en particulier pour surveiller l\'accès aux églises, mais est maintenant librement disponible. Si vous êtes responsable d\'une église, vous pouvez accéder à l\'\"Espace réservé aux églises\", pour bénéficier de statistiques d\'utilisation et d\'autres services utiles sur les services web DinDonDan.\n\nCompteur Partagé est un projet open source offert et maintenu par l\'association DinDonDan App.';

  @override
  String get donateButton => 'Soutenez-nous avec un don';

  @override
  String get singleSubcounterLabel => 'Compter';

  @override
  String get counterTotalLabel => 'Total';

  @override
  String get reverseCounterTotalLabel => 'Places disponibles';

  @override
  String get chartTotalLabel => 'Total';

  @override
  String get notEnoughData => 'Pas assez de données';

  @override
  String get thisEntranceDefaultLabel => 'Cette entrée';

  @override
  String get otherEntranceDefaultLabel => 'Autre entrée';

  @override
  String get editEntranceLabelTitle => 'Modifier le nom de l\'entrée';

  @override
  String get editCapacityTitle => 'Modifier la capacité';

  @override
  String get editEntranceLabelHint => 'Nom de l\'entrée';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get turnOnFlash => 'Allumer le flash';

  @override
  String get turnOffFlash => 'Éteindre le flash';

  @override
  String get switchCamera => 'Changer de caméra';

  @override
  String get quit => 'Quitter';

  @override
  String get continueButton => 'Continuer';

  @override
  String get shareScreenTitle => 'Partager ce compteur';

  @override
  String get shareQrCodeCaption =>
      'Scannez le code QR sur tous les appareils que vous souhaitez utiliser pour compter';

  @override
  String get orShareScreenCaption => 'Ou partagez le lien :';

  @override
  String get startOnThisDevice => 'Commencer sur cet appareil';

  @override
  String get shareLinkCreationErrorTitle =>
      'Impossible de générer le lien de partage';

  @override
  String get shareLinkCreationErrorMessage =>
      'Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get shareDialogMessage => 'Commencez le compteur partagé :';

  @override
  String get shareDialogSubject => 'Compteur Partagé DinDonDan';

  @override
  String get linkCopied => 'L\'adresse a été copiée dans le presse-papiers !';

  @override
  String get signInScreenTitle => 'Se connecter en tant qu\'église';

  @override
  String get signInEmailHint => 'E-mail';

  @override
  String get signInEmailValidator => 'Entrez votre adresse e-mail';

  @override
  String get signInPasswordHint => 'Mot de passe';

  @override
  String get signInPasswordValidator => 'Entrez votre mot de passe';

  @override
  String get signInSubmit => 'Se connecter';

  @override
  String get signUpButton =>
      'Vous n\'avez pas encore de compte ? Inscrivez-vous maintenant !';

  @override
  String get forgotPasswordButton => 'J\'ai oublié mon mot de passe';

  @override
  String get signInReservedWarning =>
      'Attention ! La connexion est réservée aux églises.';

  @override
  String get signInFormCaption =>
      'Pour collecter des statistiques de comptage pour votre église, connectez-vous avec votre compte DinDonDan :';

  @override
  String get signInUnknownErrorMessage =>
      'Une erreur inconnue s\'est produite. Veuillez réessayer plus tard et si le problème persiste, écrivez à feedback@dindondan.app.';

  @override
  String get signInInvalidEmailError =>
      'Adresse e-mail invalide. Veuillez vérifier et réessayer.';

  @override
  String get signInWrongPasswordError => 'Mot de passe incorrect.';

  @override
  String get signInUserNotFoundError =>
      'Cette adresse ne correspond à aucun compte.';

  @override
  String get signInUserDisabledError =>
      'Ce compte a été désactivé. Pour plus d\'informations, écrivez à feedback@dindondan.app.';

  @override
  String get signInTooManyAttemptsError =>
      'Vous avez fait trop de tentatives. Réessayez plus tard.';

  @override
  String get signInNetworkError =>
      'Impossible de se connecter au serveur. Veuillez vérifier votre connexion Internet et réessayer.';

  @override
  String get statsScreenTitle => 'Statistiques';

  @override
  String get lastUpdate => 'Dernière mise à jour';

  @override
  String get peakValue => 'Valeur maximale';

  @override
  String get entrances => 'Entrées';

  @override
  String get untitled => 'Sans titre';

  @override
  String get enableVibration => 'Activer la vibration';

  @override
  String get disableVibration => 'Désactiver la vibration';

  @override
  String get shareCounter => 'Partager le compteur';

  @override
  String get resetCounter => 'Réinitialiser';

  @override
  String get resetConfirmTitle => 'Réinitialiser le compteur';

  @override
  String get resetConfirmMessage =>
      'Voulez-vous vraiment réinitialiser le compteur ? Toutes les données concernant ce compteur, y compris les statistiques, seront définitivement supprimées pour tous les utilisateurs. Les utilisateurs avec qui vous avez partagé ce compteur auront toujours accès.';

  @override
  String second(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'il y a $num secondes',
      one: 'il y a une seconde',
      zero: 'il y a moins d\'une seconde',
    );
    return '$_temp0';
  }

  @override
  String minute(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'il y a $num minutes',
      one: 'il y a une minute',
      zero: 'il y a moins d\'une minute',
    );
    return '$_temp0';
  }

  @override
  String hour(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'il y a $num heures',
      one: 'il y a une heure',
      zero: 'il y a moins d\'une heure',
    );
    return '$_temp0';
  }

  @override
  String day(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'il y a $num jours',
      one: 'il y a un jour',
      zero: 'il y a moins d\'un jour',
    );
    return '$_temp0';
  }

  @override
  String week(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'il y a $num semaines',
      one: 'il y a une semaine',
      zero: 'il y a moins d\'une semaine',
    );
    return '$_temp0';
  }

  @override
  String subcounters(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num entrées',
      one: 'une entrée',
      zero: 'aucune entrée',
    );
    return '$_temp0';
  }
}
