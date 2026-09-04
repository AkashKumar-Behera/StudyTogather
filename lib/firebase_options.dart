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
    apiKey: 'AIzaSyBGnFw13ko0b4KAs7plpFmHlg0GohowElA',
    appId: '1:373326963708:web:a53bef73c7f3b6bffe4879',
    messagingSenderId: '373326963708',
    projectId: 'webrtc-cd5af',
    authDomain: 'webrtc-cd5af.firebaseapp.com',
    databaseURL: 'https://webrtc-cd5af-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'webrtc-cd5af.firebasestorage.app',
    measurementId: 'G-HSNTF46M1B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAawUTO44Dr7h2uJ_XU3hfBmtjfm93rsCY',
    appId: '1:373326963708:android:4637135da94a0a3efe4879',
    messagingSenderId: '373326963708',
    projectId: 'webrtc-cd5af',
    databaseURL: 'https://webrtc-cd5af-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'webrtc-cd5af.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhJAzD7-8pSlKSYLNFuPG0FJ95VnT6sCk',
    appId: '1:373326963708:ios:90326e00d2a1eca2fe4879',
    messagingSenderId: '373326963708',
    projectId: 'webrtc-cd5af',
    databaseURL: 'https://webrtc-cd5af-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'webrtc-cd5af.firebasestorage.app',
    androidClientId: '373326963708-4ca7rccl7s0k7ioo4mqg9tadv3edvjab.apps.googleusercontent.com',
    iosClientId: '373326963708-ga15ak9so4m8ls3su0b2ehme7rlpc82f.apps.googleusercontent.com',
    iosBundleId: 'com.example.studytogether',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGnFw13ko0b4KAs7plpFmHlg0GohowElA',
    appId: '1:373326963708:web:45a90fd3054b51a8fe4879',
    messagingSenderId: '373326963708',
    projectId: 'webrtc-cd5af',
    authDomain: 'webrtc-cd5af.firebaseapp.com',
    databaseURL: 'https://webrtc-cd5af-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'webrtc-cd5af.firebasestorage.app',
    measurementId: 'G-CFLRDJB1FF',
  );
}
