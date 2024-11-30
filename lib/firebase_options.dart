// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; // Konfigurasi untuk platform Web
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjMDNMKQFz5Clw8BK343WWe4QwsrTqSs4',
    appId: '1:353816920464:web:a3f3a2924a77c09537b315',
    messagingSenderId: '353816920464',
    projectId: 'fp-tekber-c-kel4',
    storageBucket: 'fp-tekber-c-kel4.firebasestorage.app',
    measurementId: 'G-0WBKLX7PJV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKyCbGnqE_1G1sJ0g1u_8kn5ggo3Fkmmk',
    appId: '1:353816920464:android:1778ff9177a8cd8437b315',
    messagingSenderId: '353816920464',
    projectId: 'fp-tekber-c-kel4',
    storageBucket: 'fp-tekber-c-kel4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1MLjzxUlqBVaOcoNR-Y4FpxBzmWdTuu0',
    appId: '1:353816920464:ios:e992cbffe66248b237b315',
    messagingSenderId: '353816920464',
    projectId: 'fp-tekber-c-kel4',
    storageBucket: 'fp-tekber-c-kel4.firebasestorage.app',
    iosBundleId: 'com.example.uiSederhana',
  );
}