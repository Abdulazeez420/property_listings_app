// web/firebase-messaging-sw.js

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
  console.log('Received background message: ', payload);
  
  // Forward to main thread
  self.clients.matchAll().then((clients) => {
    clients.forEach((client) => {
      client.postMessage({
        propertyId: payload.data.propertyId
      });
    });
  });
});





