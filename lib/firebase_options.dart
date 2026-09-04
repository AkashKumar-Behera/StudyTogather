// File generated for Firebase configuration.
// Replace with your actual Firebase options or run `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Configurations placeholder. You can update these with your Firebase Console Project credentials
  // or use `flutterfire configure` to overwrite this file automatically.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyWebXXXXXXXX',
    appId: '1:100000000000:web:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'studytogether-demo',
    authDomain: 'studytogether-demo.firebaseapp.com',
    storageBucket: 'studytogether-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyAndroidXXXXX',
    appId: '1:100000000000:android:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'studytogether-demo',
    storageBucket: 'studytogether-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyIosXXXXXXXXX',
    appId: '1:100000000000:ios:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'studytogether-demo',
    storageBucket: 'studytogether-demo.appspot.com',
    iosBundleId: 'com.example.studytogether',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyWindowsXXXXX',
    appId: '1:100000000000:web:abcdef1234567890',
    messagingSenderId: '100000000000',
    projectId: 'studytogether-demo',
    authDomain: 'studytogether-demo.firebaseapp.com',
    storageBucket: 'studytogether-demo.appspot.com',
  );
}
