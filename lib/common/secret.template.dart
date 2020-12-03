/// A set of secret variables that should not be made public
class Secret {
  /// URL of a webpage where the user can signup for Firebase Authentication
  static String get signUpURL => '';

  /// URL of a webpage where the user can complete the signup procedure,
  /// if needed
  static String get incompleteSignUpURL => '';

  /// URL of a webpage where the user can recover the password
  static String get recoverPasswordURL => '';

  /// Base URL of a custom REST API that provides the base user information,
  /// given the Firebase Authentication token
  static String get baseAPIURL => '';

  /// Secret API Key
  static String get secretAPIKey => '';

  /// Base URL used to share a counter. Should direct to the web version or to a
  /// fallback page in case the user doesn't have the app installed.
  static String get baseShareURL => '';
}
