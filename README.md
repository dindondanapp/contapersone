# Contapersone by DinDonDan

A multi-platform app to count people and share the real-time total count with multiple devices, through a simple URL or QR code. The app is made with Flutter and powered by Firebase Cloud Firestore and Cloud Functions.

## How to build

To build Contapersone you will need to install Flutter, set up a Firebase account and include the needed configuration files as described in the official [documentation](https://firebase.google.com/docs/flutter/setup). Enable Firebase Authentication, also with anonymous login, and Firebase Cloud Firestore.

You also need to create a common/secret.dart file with URLs and secret keys to handle user authentication. See [secret.template.dart](lib/common/secret.template.dart) for instructions. Note that if you don't want to set up the authentication API you can leave all the fields empty, and you will still be able to use the app core features.
