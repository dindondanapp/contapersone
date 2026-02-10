// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'DinDonDan Shared Counter';

  @override
  String get createCounterCaption =>
      'Erstellen Sie einen neuen Zähler für gemeinsam genutzte Personen';

  @override
  String get createCounterButton => 'Neuen Personenzähler';

  @override
  String get capacityHint => 'Kapazität (optional)';

  @override
  String get scanQrCaption => 'Treten Sie einem vorhandenen Personenzähler bei';

  @override
  String get scanQrButton => 'QR-Code scannen';

  @override
  String get scanQrWebNotice =>
      'Bitten Sie den Ersteller des Personenzählers, Ihnen den Link zu senden, oder laden Sie die mobile Version des Shared Counter aus dem App Store oder Play Store herunter, um den QR-Code festzulegen';

  @override
  String get historyTitle => 'Vergangene Zählungen';

  @override
  String get noHistoryNotice =>
      'Ihre vergangenen Zählungen werden hier angezeigt.';

  @override
  String get historyLoadingError =>
      'Beim Laden vergangener Zählungen ist ein Fehler aufgetreten.';

  @override
  String get historyDeleteConfirmTitle => 'Zählung löschen';

  @override
  String get historyDeleteConfirmMessage =>
      'Möchten Sie die Zählung wirklich von früheren Zählungen löschen?  Die Operation ist irreversibel.';

  @override
  String get tryAgain => 'Versuch es noch einmal';

  @override
  String get delete => 'Löschen';

  @override
  String get resume => 'Weitermachen';

  @override
  String get appBarLoginInProgress => 'Login in Bearbeitung...';

  @override
  String get appBarDefault => 'Shared Counter';

  @override
  String get orDivider => '– oder –';

  @override
  String get parishSignIn => 'Reservierter Bereich für Pfarreien';

  @override
  String get parishSignOut => 'Ausloggen';

  @override
  String get createCounterErrorTitle =>
      'Der Zähler für gemeinsam genutzte Personen konnte nicht erstellt werden';

  @override
  String get createCounterErrorMessage =>
      'Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get accountErrorTitle => 'Verbindungsfehler';

  @override
  String get accountErrorMessage =>
      'Ihre Kontoinformationen konnten nicht abgerufen werden.\n\nWenn das Problem weiterhin besteht, berühren Sie \"beenden\" und versuchen Sie erneut, sich anzumelden.';

  @override
  String get networkErrorTitle => 'Verbindungsfehler';

  @override
  String get networkErrorMessage =>
      'Konnte keine Verbindung zum Server herstellen.  Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get incompleteSignUpErrorTitle => 'Unvollständige Registrierung';

  @override
  String get incompleteSignUpErrorMessage =>
      'Es scheint, dass Sie die Registrierung nicht abgeschlossen haben.\n\nUm darauf zugreifen zu können, müssen Sie noch einige Daten angeben. Tippen Sie auf \"weiter\"um den Zugriff auf die Webdienste zu beenden un die Registrierung abzuschließen.';

  @override
  String get webAppDownloadBanner =>
      'Sie verwenden die Webversions-App.  Wenn Sie ein Android- oder iOS-Gerät haben, laden Sie die native Version herunter!';

  @override
  String get infoScreenTitle => 'Informationen';

  @override
  String get infoScreenText =>
      'Shared Counter ist das einfache und effektive Instrument, um den Zugang zu Veranstaltungen, Unternehmen, religiösen Festen und vielem mehr zu zählen, selbst wenn mehrere Eingänge vorhanden sind.\n\nErstellen Sie zunächst einen neuen Personenzähler, in dem Sie optional die Kapazität angeben können. Sie können die Anzahl dann mit anderen Geräten teilen, um beispielsweise mehrere Eingänge gleichzeitig über einen einfachen Link oder einen QR-Code zu überwachen.  Sie haben immer die Gesamtzahl aller Geräte unter Kontrolle, die in Echtzeit synchronisiert sind.\n\nDer Dienst wurde speziell für die Überwachung des Zugangs zur Kirche geschaffen, ist aber jetzt für alle frei verfügbar. Wenn Sie für eine Kirche verantwortlich sind, können Sie auf den\"Reservierten Bereich für Kirche\" zugreifen, um Zugriff auf Nutzungsstatistiken und andere nützliche Dienste auf dem DinDonDan-Webportal zu erhalten.\n\nShared Counter ist ein Open-Source-Projekt, das von der DinDonDan App Association kostenlos angeboten wird.';

  @override
  String get donateButton => 'Unterstützen Sie uns mit einer Spende';

  @override
  String get singleSubcounterLabel => 'Zählung';

  @override
  String get counterTotalLabel => 'Komplette Zählung';

  @override
  String get reverseCounterTotalLabel => 'Freie Platzwahl';

  @override
  String get chartTotalLabel => 'Gesamt';

  @override
  String get notEnoughData => 'nicht genug Daten';

  @override
  String get thisEntranceDefaultLabel => 'Dieser Eingang';

  @override
  String get otherEntranceDefaultLabel => 'Anderer Eingang';

  @override
  String get editEntranceLabelTitle => 'Ändern Sie den Namen des Eingangs';

  @override
  String get editCapacityTitle => 'Ändern Sie die Kapazität';

  @override
  String get editEntranceLabelHint => 'Name des Eingangs';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get turnOnFlash => 'Blitz einschalten';

  @override
  String get turnOffFlash => 'Blitz ausschalten';

  @override
  String get switchCamera => 'Kamera wechseln';

  @override
  String get quit => 'Verlassen';

  @override
  String get continueButton => 'Weiter';

  @override
  String get shareScreenTitle => 'Teilen Sie die Anzahl';

  @override
  String get shareQrCodeCaption =>
      'Scannen Sie den QR-Code mit allen Geräten, auf die Sie zählen möchten';

  @override
  String get orShareScreenCaption => 'Oder teilen Sie den Link:';

  @override
  String get startOnThisDevice => 'Starten Sie auf diesem Gerät';

  @override
  String get shareLinkCreationErrorTitle =>
      'Der Link konnte nicht abgerufen werden';

  @override
  String get shareLinkCreationErrorMessage =>
      'Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get shareDialogMessage =>
      'Starten Sie den Zähler für gemeinsam genutzte Personen:';

  @override
  String get shareDialogSubject => 'DinDonDan Shared Counter';

  @override
  String get linkCopied => 'Die Adresse wurde in die Zwischenablage kopiert!';

  @override
  String get signInScreenTitle => 'Melden Sie sich als Kirche an';

  @override
  String get signInEmailHint => 'E-mail';

  @override
  String get signInEmailValidator => 'Geben sie ihre E-Mailadresse ein';

  @override
  String get signInPasswordHint => 'Passwort';

  @override
  String get signInPasswordValidator => 'Geben Sie Ihr Passwort ein';

  @override
  String get signInSubmit => 'Einloggen';

  @override
  String get signUpButton => 'Haben Sie kein Konto?  Jetzt registrieren!';

  @override
  String get forgotPasswordButton => 'Ich habe das Passwort vergessen';

  @override
  String get signInReservedWarning =>
      'Warnung!  Der Login ist für Pfarreien reserviert.';

  @override
  String get signInFormCaption =>
      'Melden Sie sich mit Ihrem DinDonDan-Konto an, um Zählstatistiken für Ihre Kirche zu sammeln:';

  @override
  String get signInUnknownErrorMessage =>
      'Ein unbekannter Fehler ist aufgetreten.  Bitte versuchen Sie es später erneut. Wenn das Problem weiterhin besteht, schreiben Sie an feedback@dindondan.app.';

  @override
  String get signInInvalidEmailError =>
      'Die e-mail Adresse ist ungültig. Überprüfen Sie, ob es richtig geschrieben ist, und versuchen Sie es erneut.';

  @override
  String get signInWrongPasswordError => 'Das eingegebene Passwort ist falsch.';

  @override
  String get signInUserNotFoundError =>
      'Diese Adresse stimmt mit keinem Benutzer überein.';

  @override
  String get signInUserDisabledError =>
      'Dieser Benutzer wurde deaktiviert.  Für weitere Informationen schreiben Sie an feedback@dindondan.app.';

  @override
  String get signInTooManyAttemptsError =>
      'Sie haben zu viele Versuche unternommen. Versuchen Sie später.';

  @override
  String get signInNetworkError =>
      'Die Verbindung zum Server kann nicht hergestellt werden.  Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get statsScreenTitle => 'Statistiken';

  @override
  String get lastUpdate => 'Letztes Update';

  @override
  String get peakValue => 'Höchstwert';

  @override
  String get entrances => 'Eingänge';

  @override
  String get untitled => 'Namenlos';

  @override
  String get enableVibration => 'Vibration aktivieren';

  @override
  String get disableVibration => 'Vibration deaktivieren';

  @override
  String get shareCounter => 'Teilen sich die Zählung';

  @override
  String get resetCounter => 'Zurücksetzen';

  @override
  String get resetConfirmTitle => 'Personenzähler zurücksetzen';

  @override
  String get resetConfirmMessage =>
      'Möchten Sie den Zähler wirklich zurücksetzen? Sie werden alle Daten zu dieser Zählung für alle Benutzer, einschließlich Statistiken, unwiderruflich löschen. Benutzer, mit denen Sie die Zählung geteilt haben, können sich weiterhin anmelden.';

  @override
  String second(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'vor $num Sekunden',
      one: 'vor einer Sekunde',
      zero: 'vor weniger als einer Sekunde',
    );
    return '$_temp0';
  }

  @override
  String minute(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'vor $num Minuten',
      one: 'vor einer Minute',
      zero: 'vor weniger als einer Minute',
    );
    return '$_temp0';
  }

  @override
  String hour(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'vor $num Stunden',
      one: 'vor einer Stunde',
      zero: 'vor weniger als einer Stunde',
    );
    return '$_temp0';
  }

  @override
  String day(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'vor $num Tagen',
      one: 'vor einem Tag',
      zero: 'vor weniger als einem Tag',
    );
    return '$_temp0';
  }

  @override
  String week(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'vor $num Wochen',
      one: 'vor einer Woche',
      zero: 'vor weniger als einer Woche',
    );
    return '$_temp0';
  }

  @override
  String subcounters(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num Eingänge',
      one: 'ein Eingang',
      zero: 'kein Eingang',
    );
    return '$_temp0';
  }
}
