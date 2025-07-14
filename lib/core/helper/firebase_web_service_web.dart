// lib/core/helper/firebase_web_service_web.dart
import 'dart:html' as html;

void registerFirebaseServiceWorker() {
  if (html.window.navigator.serviceWorker != null) {
    html.window.navigator.serviceWorker!
        .register('firebase-messaging-sw.js')
        .then((registration) {
          print('✅ Service worker registered: $registration');
        })
        .catchError((error) {
          print('❌ Service worker registration failed: $error');
        });
  } else {
    print('❌ Service workers not supported.');
  }
}
