import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../../../core/helper/firebase_notification_listener.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> initialize() async {
    await _setupFirebase();
    await _setupLocalNotifications();
    await _handleInitialMessage();
    _setupInteractions(); //

    if (kIsWeb) {
      setupWebNotificationRouteListener();
    }
    return this;
  }

  Future<void> _setupFirebase() async {
    await Firebase.initializeApp();

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kIsWeb) {
        await _firebaseMessaging.getToken(
          vapidKey:
              'BFLrB8TUyYNvbBgBEO9eoyxfZqrDL6NX2d0cxOoi1ar-B8wPVrg9HRb8ZCQY7w1eg1NjKfpHGGWuRFHrsIHYvKk',
        );
      }

      final token = await _firebaseMessaging.getToken();
      debugPrint(' FCM Token: $token');

      FirebaseMessaging.onMessage.listen(_showNotification);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationInteraction(details.payload);
      },
    );

    //  Create Android notification channel here
    const androidChannel = AndroidNotificationChannel(
      'property_channel',
      'Property Updates',
      description: 'Notifications for property updates',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _handleInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null && message.data['propertyId'] != null) {
      _handleNotificationInteraction(message.data['propertyId']);
    }
  }

  void _setupInteractions() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationInteraction(message.data['propertyId']);
    });
  }

  void _showNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'property_channel',
            'Property Updates',
            channelDescription: 'Notifications for property updates',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['propertyId'],
      );
    }
  }

  void _handleNotificationInteraction(String? propertyId) async {
    if (propertyId == null) return;

    try {
      if (propertyId != '') {
        debugPrint(' Found property: $propertyId');

        Get.offAndToNamed(
          '/property-detail/$propertyId',
          arguments: propertyId,
        );
      } else {
        debugPrint(' Property not found: $propertyId');
      }
    } catch (e) {
      debugPrint(' Error in notification handling: $e');
    }
  }
}
