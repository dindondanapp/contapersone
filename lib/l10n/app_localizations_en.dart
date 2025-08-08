// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DinDonDan Shared Counter';

  @override
  String get createCounterCaption => 'Create a new shared counter';

  @override
  String get createCounterButton => 'Create counter';

  @override
  String get capacityHint => 'Capacity (optional)';

  @override
  String get scanQrCaption => 'Join an existing shared counter';

  @override
  String get scanQrButton => 'Scan QR code';

  @override
  String get scanQrWebNotice => 'Ask the creator of the counter to send you the link, or download the mobile version of Shared Counter from the App Store or Play Store to scan the QR code';

  @override
  String get historyTitle => 'Past counters';

  @override
  String get noHistoryNotice => 'Your past counters will appear here.';

  @override
  String get historyLoadingError => 'An error occurred while loading past counters';

  @override
  String get historyDeleteConfirmTitle => 'Delete counter';

  @override
  String get historyDeleteConfirmMessage => 'Do you really want to delete this counter from past counters? This operation cannot be undone.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get delete => 'Delete';

  @override
  String get resume => 'Resume';

  @override
  String get appBarLoginInProgress => 'Signing in…';

  @override
  String get appBarDefault => 'Shared Counter';

  @override
  String get orDivider => '– or –';

  @override
  String get parishSignIn => 'Reserved area for churches';

  @override
  String get parishSignOut => 'Sign out';

  @override
  String get createCounterErrorTitle => 'Could not create a shared counter';

  @override
  String get createCounterErrorMessage => 'Please check your Internet connection and try again.';

  @override
  String get accountErrorTitle => 'Connection error';

  @override
  String get accountErrorMessage => 'Your account information could not be retrieved.\n\nIf the problem persists, tap \"sign out\" and try again.';

  @override
  String get networkErrorTitle => 'Connection error';

  @override
  String get networkErrorMessage => 'Could not connect to the server. Please check your internet connection and try again.';

  @override
  String get incompleteSignUpErrorTitle => 'Incomplete sign up';

  @override
  String get incompleteSignUpErrorMessage => 'It appears that you have not completed the sign up procedure.\n\nTo sign in you must provide more details. Tap \"continue\" to be redirected to the web services and complete the registration.';

  @override
  String get webAppDownloadBanner => 'You are using the web app version of Shared Counter. If you have an Android or iOS device, download the native app!';

  @override
  String get infoScreenTitle => 'About Shared Counter';

  @override
  String get infoScreenText => 'Shared Counter is the simple and effective tool for counting visitors to events, local businesses, religious functions and much more, even with multiple entrances.\n\nTo begin, create a new counter, optionally specifying the capacity. You can then share the counter with other devices, for example to monitor multiple entrances at the same time, via a simple link or QR code. You will always have under control the total count of all devices, synchronized in real time.\n\nThe service was created in particular for monitoring access to the churches, but is now freely available. If you are in charge of a church you can access the\"Reserved area for churches\", to benefit from usage statistics and other useful services on the DinDonDan Web Services.\n\nShared Counter is an open source project offered and maintained by the DinDonDan App association.';

  @override
  String get donateButton => 'Support us with a donation';

  @override
  String get singleSubcounterLabel => 'Count';

  @override
  String get counterTotalLabel => 'Total count';

  @override
  String get reverseCounterTotalLabel => 'Vacancies';

  @override
  String get chartTotalLabel => 'Total';

  @override
  String get notEnoughData => 'Not Enough Data';

  @override
  String get thisEntranceDefaultLabel => 'This entrance';

  @override
  String get otherEntranceDefaultLabel => 'Other entrance';

  @override
  String get editEntranceLabelTitle => 'Change entrance name';

  @override
  String get editCapacityTitle => 'Change capacity';

  @override
  String get editEntranceLabelHint => 'Name of the entrance';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get turnOnFlash => 'Turn on flash';

  @override
  String get turnOffFlash => 'Turn off flash';

  @override
  String get switchCamera => 'Change camera';

  @override
  String get quit => 'Quit';

  @override
  String get continueButton => 'Continue';

  @override
  String get shareScreenTitle => 'Share this counter';

  @override
  String get shareQrCodeCaption => 'Scan the QR code on all the devices you want to count on';

  @override
  String get orShareScreenCaption => 'Or share the link:';

  @override
  String get startOnThisDevice => 'Start on this device';

  @override
  String get shareLinkCreationErrorTitle => 'Could not generate the share link';

  @override
  String get shareLinkCreationErrorMessage => 'Please check your internet connection and try again.';

  @override
  String get shareDialogMessage => 'Start the shared counter:';

  @override
  String get shareDialogSubject => 'DinDonDan Shared Counter';

  @override
  String get linkCopied => 'The address has been copied to the clipboard!';

  @override
  String get signInScreenTitle => 'Sign in as a Church';

  @override
  String get signInEmailHint => 'E-mail';

  @override
  String get signInEmailValidator => 'Enter your e-mail address';

  @override
  String get signInPasswordHint => 'Password';

  @override
  String get signInPasswordValidator => 'Enter your password';

  @override
  String get signInSubmit => 'Sign in';

  @override
  String get signUpButton => 'Don\'t have an account yet? Sign up now!';

  @override
  String get forgotPasswordButton => 'I forgot the password';

  @override
  String get signInReservedWarning => 'Warning! Sign in is reserved for churches.';

  @override
  String get signInFormCaption => 'To collect count statistics for your church sign in with your DinDonDan account:';

  @override
  String get signInUnknownErrorMessage => 'An unknown error has occurred. Please try again later and if the problem persists write to feedback@dindondan.app.';

  @override
  String get signInInvalidEmailError => 'Invalid e-mail address. Please check and try again.';

  @override
  String get signInWrongPasswordError => 'Incorrect password.';

  @override
  String get signInUserNotFoundError => 'This address does not match any account.';

  @override
  String get signInUserDisabledError => 'This account has been disabled. For more information write to feedback@dindondan.app.';

  @override
  String get signInTooManyAttemptsError => 'You have made too many attempts. Try again later.';

  @override
  String get signInNetworkError => 'Unable to connect to server. Please check your internet connection and try again.';

  @override
  String get statsScreenTitle => 'Statistics';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get peakValue => 'Peak value';

  @override
  String get entrances => 'Entrances';

  @override
  String get untitled => 'Untitled';

  @override
  String get enableVibration => 'Enable vibration';

  @override
  String get disableVibration => 'Disable vibration';

  @override
  String get shareCounter => 'Share counter';

  @override
  String get resetCounter => 'Reset';

  @override
  String get resetConfirmTitle => 'Reset counter';

  @override
  String get resetConfirmMessage => 'Do you really want to reset the counter? All data about this counter, including statistics, will be permanently deleted for all users. The users you shared this counter with will still have access.';

  @override
  String second(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num seconds ago',
      one: 'one second ago',
      zero: 'less than one second ago',
    );
    return '$_temp0';
  }

  @override
  String minute(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num minutes ago',
      one: 'one minute ago',
      zero: 'less than one minute ago',
    );
    return '$_temp0';
  }

  @override
  String hour(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num hours ago',
      one: 'one hour ago',
      zero: 'less than one hour ago',
    );
    return '$_temp0';
  }

  @override
  String day(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num days ago',
      one: 'one day ago',
      zero: 'less than one day ago',
    );
    return '$_temp0';
  }

  @override
  String week(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num weeks ago',
      one: 'one week ago',
      zero: 'less than one week ago',
    );
    return '$_temp0';
  }

  @override
  String subcounters(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num entrances',
      one: 'one entrance',
      zero: 'no entrance',
    );
    return '$_temp0';
  }
}
