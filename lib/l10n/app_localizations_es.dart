// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DinDonDan Shared Counter';

  @override
  String get createCounterCaption => 'Crea un nuevo contador compartido';

  @override
  String get createCounterButton => 'Crea un nuevo contador';

  @override
  String get capacityHint => 'Capacidad (opcional)';

  @override
  String get scanQrCaption => 'Únete a un contador compartido existente';

  @override
  String get scanQrButton => 'Escanea el código QR';

  @override
  String get scanQrWebNotice => 'Pídale al creador del contador que le envíe el link o descargue la versión móvil del Shared Counter de la App Store o Play Store para enmarcar el código QR';

  @override
  String get historyTitle => 'Conteos pasados';

  @override
  String get noHistoryNotice => 'Tus contadores pasados aparecerán aquí.';

  @override
  String get historyLoadingError => 'Se produjo un error al cargar los contadores pasados.';

  @override
  String get historyDeleteConfirmTitle => 'Eliminar el contador';

  @override
  String get historyDeleteConfirmMessage => '¿Realmente desea eliminar el contador de contadores pasados ? La operación es irreversible. ';

  @override
  String get tryAgain => 'Intenta otra vez';

  @override
  String get delete => 'Elimina';

  @override
  String get resume => 'Resume';

  @override
  String get appBarLoginInProgress => 'Acceso en curso ...';

  @override
  String get appBarDefault => 'Shared Counter';

  @override
  String get orDivider => '– o –';

  @override
  String get parishSignIn => 'Área reservada para parroquias';

  @override
  String get parishSignOut => 'Cerrar sesión';

  @override
  String get createCounterErrorTitle => 'No se pudo crear el contador compartido';

  @override
  String get createCounterErrorMessage => 'Comprueba tu conexión de red y vuelve a intentarlo.';

  @override
  String get accountErrorTitle => 'Error de conexión';

  @override
  String get accountErrorMessage => 'No se pudo obtener la información de tu cuenta.\n\nSi el problema persiste, toca \"salir\" e intente iniciar sesión nuevamente.';

  @override
  String get networkErrorTitle => 'Error de conexión';

  @override
  String get networkErrorMessage => 'No se pudo conectar con el servidor. Comprueba tu conexión de red e inténtalo de nuevo.';

  @override
  String get incompleteSignUpErrorTitle => 'Registro incompleto';

  @override
  String get incompleteSignUpErrorMessage => 'Parece que no ha completado el registro.\n\nPara acceder debe proporcionar algunos datos. Toca \"continua\" para terminar de acceder a los servicios web y completar el registro.';

  @override
  String get webAppDownloadBanner => 'Está utilizando la aplicación de la versión web. Si tiene un dispositivo Android o iOS, ¡descargue la versión nativa!';

  @override
  String get infoScreenTitle => 'Informaciones';

  @override
  String get infoScreenText => 'Shared Counter es la herramienta sencilla y eficaz para contar los accesos a eventos, negocios, celebraciones religiosas y mucho más, incluso la presencia de múltiples accesos.\n\nPara empezar, crea un nuevo contador, especificando opcionalmente la capacidad. Luego, puede compartir el cuento con otros dispositivos, por ejemplo, para monitorear múltiples entradas al mismo tiempo, a través de un link o un código QR. Siempre tendrás bajo control el cuento total de todos los dispositivos, sincronizados en tiempo real.\n\nEl servicio fue creado en particular para monitorear el acceso a la iglesia, pero ahora está disponible gratuitamente para todos. Si estás a cargo de una parroquia puedes acceder al\"Área reservada para parroquias\", para tener acceso a estadísticas de uso y otros servicios útiles en el portal web DinDonDan.\n\nShared Counter es un proyecto open source ofrecido de forma gratuita por la asociación DinDonDan App.';

  @override
  String get donateButton => 'Apóyenos con una donación';

  @override
  String get singleSubcounterLabel => 'Cuenta';

  @override
  String get counterTotalLabel => 'Cuenta total';

  @override
  String get reverseCounterTotalLabel => 'Plazas libres';

  @override
  String get chartTotalLabel => 'Total';

  @override
  String get notEnoughData => 'No hay suficientes datos';

  @override
  String get thisEntranceDefaultLabel => 'Esta entrada';

  @override
  String get otherEntranceDefaultLabel => 'Otra entrada';

  @override
  String get editEntranceLabelTitle => 'Cambia nombre de entrada';

  @override
  String get editCapacityTitle => 'Cambia la capacidad';

  @override
  String get editEntranceLabelHint => 'Nombre de la entrada';

  @override
  String get cancel => 'Cancela';

  @override
  String get confirm => 'Confirma';

  @override
  String get turnOnFlash => 'Enciende el flash';

  @override
  String get turnOffFlash => 'Apagar el flash';

  @override
  String get switchCamera => 'Cambia la cámara';

  @override
  String get quit => 'Sal';

  @override
  String get continueButton => 'Sigue';

  @override
  String get shareScreenTitle => 'Comparte el contador';

  @override
  String get shareQrCodeCaption => 'Escanea el código QR con todos los dispositivos con los que quieras contar';

  @override
  String get orShareScreenCaption => 'O comparte el link:';

  @override
  String get startOnThisDevice => 'Comenza en este dispositivo';

  @override
  String get shareLinkCreationErrorTitle => 'No se pudo obtener el link para compartir';

  @override
  String get shareLinkCreationErrorMessage => 'Comprueba tu conexión de red y vuelve a intentarlo.';

  @override
  String get shareDialogMessage => 'Inicia el contador compartido';

  @override
  String get shareDialogSubject => 'DinDonDan Shared Counter';

  @override
  String get linkCopied => '¡La dirección se ha copiado en el portapapeles!';

  @override
  String get signInScreenTitle => 'Inicia sesión como parroquia';

  @override
  String get signInEmailHint => 'E-mail';

  @override
  String get signInEmailValidator => 'Ingresa tu dirección e-mail';

  @override
  String get signInPasswordHint => 'Password';

  @override
  String get signInPasswordValidator => 'Ingresa tu password';

  @override
  String get signInSubmit => 'Inicia sesión';

  @override
  String get signUpButton => '¿No tiene una cuenta? ¡Regístrate ahora!';

  @override
  String get forgotPasswordButton => 'Olvidé la password';

  @override
  String get signInReservedWarning => '¡Advertencia! El inicio de sesión está reservado para las parroquias.';

  @override
  String get signInFormCaption => 'Para recopilar estadísticas de conteo para tu parroquia, inicia sesión con tu cuenta DinDonDan:';

  @override
  String get signInUnknownErrorMessage => 'Un error desconocido a ocurrido. Vuelve a intentarlo más tarde y, si el problema persiste, escribe a feedback@dindondan.app.';

  @override
  String get signInInvalidEmailError => 'La dirección de correo electrónico es inválida. Comprueba que esté escrito correctamente y vuelve a intentarlo.';

  @override
  String get signInWrongPasswordError => 'La password ingresada es incorrecta.';

  @override
  String get signInUserNotFoundError => 'Esta dirección no coincide con ningún usuario.';

  @override
  String get signInUserDisabledError => 'Este usuario ha sido inhabilitado. Para obtener más informaciones, escribe a feedback@dindondan.app.';

  @override
  String get signInTooManyAttemptsError => 'Has hecho demasiados intentos. Intenta más tarde.';

  @override
  String get signInNetworkError => 'No se pudo conectar al servidor. Comprueba tu conexión de red y vuelve a intentarlo.';

  @override
  String get statsScreenTitle => 'Estadísticas';

  @override
  String get lastUpdate => 'Última actualización';

  @override
  String get peakValue => 'Valor pico';

  @override
  String get entrances => 'Entradas';

  @override
  String get untitled => 'Sin nombre';

  @override
  String get enableVibration => 'Activar vibración';

  @override
  String get disableVibration => 'Desactivar vibración';

  @override
  String get shareCounter => 'Comparte el contador';

  @override
  String get resetCounter => 'Reinicia';

  @override
  String get resetConfirmTitle => 'Reinicia la cuenta';

  @override
  String get resetConfirmMessage => '¿Realmente quieres reiniciar el recuento? Eliminará irreversiblemente todos los datos relacionados con este recuento para todos los usuarios, incluidas las estadísticas. Los usuarios con los que haya compartido el recuento podrán seguir teniendo acceso.';

  @override
  String second(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num segundos atrás',
      one: 'un segundo atrás',
      zero: 'menos de un segundo atrás',
    );
    return '$_temp0';
  }

  @override
  String minute(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num minutos atrás',
      one: 'un minuto atrás',
      zero: 'menos de un minuto atrás',
    );
    return '$_temp0';
  }

  @override
  String hour(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num horas atrás',
      one: 'una hora atrás',
      zero: 'menos de una hora atrás',
    );
    return '$_temp0';
  }

  @override
  String day(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num dias atrás',
      one: 'un día atrás',
      zero: 'menos de un día atrás',
    );
    return '$_temp0';
  }

  @override
  String week(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num semanas atrás',
      one: 'una semana atrás',
      zero: 'menos de una semana atrás',
    );
    return '$_temp0';
  }

  @override
  String subcounters(num num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num entradas',
      one: 'Una entrada',
      zero: 'Ninguna entrada',
    );
    return '$_temp0';
  }
}
