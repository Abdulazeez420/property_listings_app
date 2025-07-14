// lib/core/helper/firebase_web_service_web.dart
import 'dart:html' as html;

// Update your registration function
void registerFirebaseServiceWorker() {
  if (html.window.navigator.serviceWorker != null) {
    print('ℹ️ Service workers are supported, attempting registration...');
    html.window.navigator.serviceWorker!
        .register('firebase-messaging-sw.js')
        .then((registration) {
          print('✅ Service worker registered. Scope: ${registration.scope}');
          print('ℹ️ Active worker: ${registration.active}');
          print('ℹ️ Waiting worker: ${registration.waiting}');
          print('ℹ️ Installing worker: ${registration.installing}');
          
          // Add this to verify the worker can receive messages
          html.window.postMessage({'test': 'message'}, '*');
        })
        .catchError((error) {
          print('❌ Service worker registration failed: $error');
          print('ℹ️ Error stack: ${error.stackTrace}');
        });
  } else {
    print('❌ Service workers not supported in this browser.');
  }
}
