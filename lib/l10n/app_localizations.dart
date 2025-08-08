import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'DinDonDan Contapersone'**
  String get appTitle;

  /// No description provided for @createCounterCaption.
  ///
  /// In it, this message translates to:
  /// **'Crea un nuovo contapersone condiviso'**
  String get createCounterCaption;

  /// No description provided for @createCounterButton.
  ///
  /// In it, this message translates to:
  /// **'Crea nuovo contapersone'**
  String get createCounterButton;

  /// No description provided for @capacityHint.
  ///
  /// In it, this message translates to:
  /// **'Capienza (facoltativa)'**
  String get capacityHint;

  /// No description provided for @scanQrCaption.
  ///
  /// In it, this message translates to:
  /// **'Partecipa ad un contapersone condiviso esistente'**
  String get scanQrCaption;

  /// No description provided for @scanQrButton.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il codice QR'**
  String get scanQrButton;

  /// No description provided for @scanQrWebNotice.
  ///
  /// In it, this message translates to:
  /// **'Chiedi al creatore del contapersone di inviarti il link, oppure scarica la versione mobile di Contapersone da App Store o Play Store per inquadrare il codice QR'**
  String get scanQrWebNotice;

  /// No description provided for @historyTitle.
  ///
  /// In it, this message translates to:
  /// **'Conteggi passati'**
  String get historyTitle;

  /// No description provided for @noHistoryNotice.
  ///
  /// In it, this message translates to:
  /// **'I tuoi conteggi passati appariranno qui.'**
  String get noHistoryNotice;

  /// No description provided for @historyLoadingError.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore nel caricamento dei conteggi passati.'**
  String get historyLoadingError;

  /// No description provided for @historyDeleteConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina il conteggio'**
  String get historyDeleteConfirmTitle;

  /// No description provided for @historyDeleteConfirmMessage.
  ///
  /// In it, this message translates to:
  /// **'Vuoi davvero eliminare il conteggio dai conteggi passati? L\'operazione è irreversibile.'**
  String get historyDeleteConfirmMessage;

  /// No description provided for @tryAgain.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get tryAgain;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @resume.
  ///
  /// In it, this message translates to:
  /// **'Riprendi'**
  String get resume;

  /// No description provided for @appBarLoginInProgress.
  ///
  /// In it, this message translates to:
  /// **'Accesso in corso…'**
  String get appBarLoginInProgress;

  /// No description provided for @appBarDefault.
  ///
  /// In it, this message translates to:
  /// **'Contapersone'**
  String get appBarDefault;

  /// No description provided for @orDivider.
  ///
  /// In it, this message translates to:
  /// **'– oppure –'**
  String get orDivider;

  /// No description provided for @parishSignIn.
  ///
  /// In it, this message translates to:
  /// **'Area riservata parrocchie'**
  String get parishSignIn;

  /// No description provided for @parishSignOut.
  ///
  /// In it, this message translates to:
  /// **'Disconnetti'**
  String get parishSignOut;

  /// No description provided for @createCounterErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Impossibile creare il contapersone condiviso'**
  String get createCounterErrorTitle;

  /// No description provided for @createCounterErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Verifica la connessione di rete e riprova.'**
  String get createCounterErrorMessage;

  /// No description provided for @accountErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Errore di connessione'**
  String get accountErrorTitle;

  /// No description provided for @accountErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile ottenere i dati del tuo account.\n\nSe il problema persiste tocca \"esci\" e prova a ripetere l\'accesso.'**
  String get accountErrorMessage;

  /// No description provided for @networkErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Errore di connessione'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile connettersi al server. Controlla la connessione di rete e riprova.'**
  String get networkErrorMessage;

  /// No description provided for @incompleteSignUpErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Registrazione incompleta'**
  String get incompleteSignUpErrorTitle;

  /// No description provided for @incompleteSignUpErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Sembra che tu non abbia completato la registrazione.\n\nPer accedere devi fornire ancora alcuni dati. Tocca \"continua\" per concludere accedere ai servizi web e completare la registrazione.'**
  String get incompleteSignUpErrorMessage;

  /// No description provided for @webAppDownloadBanner.
  ///
  /// In it, this message translates to:
  /// **'Stai usando l\'app in versione web. Se hai un dispositivo Android o iOS scarica la versione nativa!'**
  String get webAppDownloadBanner;

  /// No description provided for @infoScreenTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get infoScreenTitle;

  /// No description provided for @infoScreenText.
  ///
  /// In it, this message translates to:
  /// **'Contapersone è lo strumento semplice ed efficace per contare gli accessi a eventi, esercizi commerciali, celebrazioni religiose e tanto altro, anche i presenza di ingressi multipli.\n\nPer iniziare crea un nuovo contapersone, specificando facoltativamente la capienza. Potrai poi condividere il conteggio con altri dispositivi, ad esempio per monitorare più ingressi contemporaneamente, tramite un semplice link o un codice QR. Avrai sempre sotto controllo il conteggio totale di tutti i dispositivi, sincronizzato in tempo reale.\n\nIl servizio nasce in particolare per il monitoraggio degli accessi in chiesa, ma è ora disponibile liberamente per tutti. Se sei responsabile di una parrocchia puoi accedere all\'\"Area riservata parrocchie\", per avere accesso alle statistiche di utilizzo e ad altri utili servizi sul portale web di DinDonDan.\n\nContapersone è un progetto open source offerto gratuitamente dall\'associazione DinDonDan App.'**
  String get infoScreenText;

  /// No description provided for @donateButton.
  ///
  /// In it, this message translates to:
  /// **'Sostienici con una donazione'**
  String get donateButton;

  /// No description provided for @singleSubcounterLabel.
  ///
  /// In it, this message translates to:
  /// **'Conteggio'**
  String get singleSubcounterLabel;

  /// No description provided for @counterTotalLabel.
  ///
  /// In it, this message translates to:
  /// **'Conteggio totale'**
  String get counterTotalLabel;

  /// No description provided for @reverseCounterTotalLabel.
  ///
  /// In it, this message translates to:
  /// **'Posti liberi'**
  String get reverseCounterTotalLabel;

  /// No description provided for @chartTotalLabel.
  ///
  /// In it, this message translates to:
  /// **'Totale'**
  String get chartTotalLabel;

  /// No description provided for @notEnoughData.
  ///
  /// In it, this message translates to:
  /// **'Dati non sufficienti'**
  String get notEnoughData;

  /// No description provided for @thisEntranceDefaultLabel.
  ///
  /// In it, this message translates to:
  /// **'Questo ingresso'**
  String get thisEntranceDefaultLabel;

  /// No description provided for @otherEntranceDefaultLabel.
  ///
  /// In it, this message translates to:
  /// **'Altro ingresso'**
  String get otherEntranceDefaultLabel;

  /// No description provided for @editEntranceLabelTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica nome dell\'ingresso'**
  String get editEntranceLabelTitle;

  /// No description provided for @editCapacityTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica capacità'**
  String get editCapacityTitle;

  /// No description provided for @editEntranceLabelHint.
  ///
  /// In it, this message translates to:
  /// **'Nome dell\'ingresso'**
  String get editEntranceLabelHint;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirm;

  /// No description provided for @turnOnFlash.
  ///
  /// In it, this message translates to:
  /// **'Accendi flash'**
  String get turnOnFlash;

  /// No description provided for @turnOffFlash.
  ///
  /// In it, this message translates to:
  /// **'Spegni flash'**
  String get turnOffFlash;

  /// No description provided for @switchCamera.
  ///
  /// In it, this message translates to:
  /// **'Cambia fotocamera'**
  String get switchCamera;

  /// No description provided for @quit.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get quit;

  /// No description provided for @continueButton.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get continueButton;

  /// No description provided for @shareScreenTitle.
  ///
  /// In it, this message translates to:
  /// **'Condividi il conteggio'**
  String get shareScreenTitle;

  /// No description provided for @shareQrCodeCaption.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il codice QR con tutti i dispositivi su cui vuoi eseguire il conteggio'**
  String get shareQrCodeCaption;

  /// No description provided for @orShareScreenCaption.
  ///
  /// In it, this message translates to:
  /// **'Oppure condividi il link:'**
  String get orShareScreenCaption;

  /// No description provided for @startOnThisDevice.
  ///
  /// In it, this message translates to:
  /// **'Avvia su questo dispositivo'**
  String get startOnThisDevice;

  /// No description provided for @shareLinkCreationErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Impossibile ottenere il link di condivisione'**
  String get shareLinkCreationErrorTitle;

  /// No description provided for @shareLinkCreationErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Verifica la connessione di rete e riprova.'**
  String get shareLinkCreationErrorMessage;

  /// No description provided for @shareDialogMessage.
  ///
  /// In it, this message translates to:
  /// **'Avvia il contapersone condiviso:'**
  String get shareDialogMessage;

  /// No description provided for @shareDialogSubject.
  ///
  /// In it, this message translates to:
  /// **'DinDonDan Contapersone'**
  String get shareDialogSubject;

  /// No description provided for @linkCopied.
  ///
  /// In it, this message translates to:
  /// **'L\'indirizzo è stato copiato negli appunti!'**
  String get linkCopied;

  /// No description provided for @signInScreenTitle.
  ///
  /// In it, this message translates to:
  /// **'Accedi come parrocchia'**
  String get signInScreenTitle;

  /// No description provided for @signInEmailHint.
  ///
  /// In it, this message translates to:
  /// **'E-mail'**
  String get signInEmailHint;

  /// No description provided for @signInEmailValidator.
  ///
  /// In it, this message translates to:
  /// **'Inserisci l\'indirizzo e-mail'**
  String get signInEmailValidator;

  /// No description provided for @signInPasswordHint.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get signInPasswordHint;

  /// No description provided for @signInPasswordValidator.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la password'**
  String get signInPasswordValidator;

  /// No description provided for @signInSubmit.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get signInSubmit;

  /// No description provided for @signUpButton.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Registrati ora!'**
  String get signUpButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In it, this message translates to:
  /// **'Ho dimenticato la password'**
  String get forgotPasswordButton;

  /// No description provided for @signInReservedWarning.
  ///
  /// In it, this message translates to:
  /// **'Attenzione! Il login è riservato alle parrocchie.'**
  String get signInReservedWarning;

  /// No description provided for @signInFormCaption.
  ///
  /// In it, this message translates to:
  /// **'Per raccogliere statistiche sui conteggi per la tua parrocchia accedi con il tuo account DinDonDan:'**
  String get signInFormCaption;

  /// No description provided for @signInUnknownErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Si è verificato un errore sconosciuto. Riprova più tardi e, se il problema persiste, scrivi a feedback@dindondan.app.'**
  String get signInUnknownErrorMessage;

  /// No description provided for @signInInvalidEmailError.
  ///
  /// In it, this message translates to:
  /// **'L\'indirizzo e-mail non è valido. Controlla che sia scritto correttamente e riprova.'**
  String get signInInvalidEmailError;

  /// No description provided for @signInWrongPasswordError.
  ///
  /// In it, this message translates to:
  /// **'La password inserita è errata.'**
  String get signInWrongPasswordError;

  /// No description provided for @signInUserNotFoundError.
  ///
  /// In it, this message translates to:
  /// **'Questo indirizzo non corrisponde ad alcun utente.'**
  String get signInUserNotFoundError;

  /// No description provided for @signInUserDisabledError.
  ///
  /// In it, this message translates to:
  /// **'Questo utente è stato disabilitato. Per ulteriori informazioni scrivi a feedback@dindondan.app.'**
  String get signInUserDisabledError;

  /// No description provided for @signInTooManyAttemptsError.
  ///
  /// In it, this message translates to:
  /// **'Hai effettuato troppi tentativi. Riprova più tardi.'**
  String get signInTooManyAttemptsError;

  /// No description provided for @signInNetworkError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile connettersi al server. Verifica la connessione di rete e riprova.'**
  String get signInNetworkError;

  /// No description provided for @statsScreenTitle.
  ///
  /// In it, this message translates to:
  /// **'Statistiche'**
  String get statsScreenTitle;

  /// No description provided for @lastUpdate.
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento'**
  String get lastUpdate;

  /// No description provided for @peakValue.
  ///
  /// In it, this message translates to:
  /// **'Valore di picco'**
  String get peakValue;

  /// No description provided for @entrances.
  ///
  /// In it, this message translates to:
  /// **'Ingressi'**
  String get entrances;

  /// No description provided for @untitled.
  ///
  /// In it, this message translates to:
  /// **'Senza nome'**
  String get untitled;

  /// No description provided for @enableVibration.
  ///
  /// In it, this message translates to:
  /// **'Abilita vibrazione'**
  String get enableVibration;

  /// No description provided for @disableVibration.
  ///
  /// In it, this message translates to:
  /// **'Disabilita vibrazione'**
  String get disableVibration;

  /// No description provided for @shareCounter.
  ///
  /// In it, this message translates to:
  /// **'Condividi conteggio'**
  String get shareCounter;

  /// No description provided for @resetCounter.
  ///
  /// In it, this message translates to:
  /// **'Azzera'**
  String get resetCounter;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Azzera il conteggio'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In it, this message translates to:
  /// **'Vuoi davvero azzerare il conteggio? Eliminerai in modo irreversibile tutti i dati relativi a questo conteggio per tutti gli utenti, incluse le statistiche. Gli utenti con cui hai condiviso il conteggio potranno continuare accedere.'**
  String get resetConfirmMessage;

  /// No description provided for @second.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {meno di un secondo fa} =1 {un secondo fa} other {{num} secondi fa}}'**
  String second(num num);

  /// No description provided for @minute.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {meno di un minuto fa} =1 {un minuto fa} other {{num} minuti fa}}'**
  String minute(num num);

  /// No description provided for @hour.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {meno di un\'ora fa} =1 {un\'ora fa} other {{num} ore fa}}'**
  String hour(num num);

  /// No description provided for @day.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {meno di un giorno fa} =1 {un giorno fa} other {{num} giorni fa}}'**
  String day(num num);

  /// No description provided for @week.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {meno di una settimana fa} =1 {una settimana fa} other {{num} settimane fa}}'**
  String week(num num);

  /// No description provided for @subcounters.
  ///
  /// In it, this message translates to:
  /// **'{num, plural, =0 {nessun ingresso} =1 {un ingresso} other {{num} ingressi}}'**
  String subcounters(num num);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
