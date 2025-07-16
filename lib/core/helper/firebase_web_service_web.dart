import 'dart:html' as html;

void registerFirebaseServiceWorker() {
  if (html.window.navigator.serviceWorker != null) {
    html.window.navigator.serviceWorker!
        .register('firebase-messaging-sw.js')
        .then((registration) {
      print('✅ Service worker registered: $registration');
    }).catchError((error) {
      print('❌ Failed to register service worker: $error');
    });
  } else {
    print('❌ Service workers are not supported in this browser.');
  }
}
