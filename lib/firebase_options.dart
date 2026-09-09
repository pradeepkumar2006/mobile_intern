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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBH-EkUdOJ1siqkx0CPecHoZFdFqfZrFh4',
    appId: '1:1028331024456:web:ctm0sk84vgh887k46lp90j',
    messagingSenderId: '1028331024456',
    projectId: 'creator-33409',
    authDomain: 'creator-33409.firebaseapp.com',
    storageBucket: 'creator-33409.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH-EkUdOJ1siqkx0CPecHoZFdFqfZrFh4',
    appId: '1:1028331024456:android:eb6e687dbf5d44ca41687d',
    messagingSenderId: '1028331024456',
    projectId: 'creator-33409',
    storageBucket: 'creator-33409.firebasestorage.app',
  );
}
