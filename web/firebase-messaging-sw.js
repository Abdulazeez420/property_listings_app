importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyACsBuxa7yJDPOyYVcZsSXw8C2egBhV9tA",
  authDomain: "propertylistingapp-da67c.firebaseapp.com",
  projectId: "propertylistingapp-da67c",
  storageBucket: "propertylistingapp-da67c.appspot.com",
  messagingSenderId: "10231355415",
  appId: "1:10231355415:web:81cb2a8e7156c50eb2e452",
  measurementId: "G-1XKJ67RZ83"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message', payload);

  // Optional: show a notification
  const title = payload.notification?.title || "Property Alert";
  const options = {
    body: payload.notification?.body || '',
    data: { propertyId: payload.data.propertyId }
  };
  self.registration.showNotification(title, options);

  // Post propertyId to all clients
  self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
    clients.forEach((client) => {
      client.postMessage({
        propertyId: payload.data.propertyId
      });
    });
  });
});

self.addEventListener('notificationclick', function (event) {
  const propertyId = event.notification.data?.propertyId;
  event.notification.close();

  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ('focus' in client) {
          client.focus().then(() => {
            client.postMessage({ propertyId });
          });
          return;
        }
      }
      if (self.clients.openWindow) {
        return self.clients.openWindow(`${self.location.origin}/?propertyId=${propertyId}`);
      }
    })
  );
});

