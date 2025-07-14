// lib/core/helper/firebase_notification_web_listener.dart
import 'dart:html' as html;
import 'package:get/get.dart';
import 'package:property_listing_app/features/property/presentation/controllers/property_controller.dart';

void setupWebNotificationRouteListener() {
  html.window.onMessage.listen((event) async {
    print('[WEB] Received message: ${event.data}');
    
    try {
      final data = event.data;
      if (data is Map && data['propertyId'] != null) {
        final propertyId = data['propertyId'].toString();
        print('[WEB] Processing propertyId: $propertyId');

        // Wait for app to be ready
         Get.until((route) => Get.currentRoute != '/');

        final controller = Get.find<PropertyController>();
        await controller.fetchProperties();

        final property = controller.properties.firstWhereOrNull(
          (p) => p.id.toString() == propertyId,
        );

        if (property != null) {
          Get.toNamed('/property-detail/$propertyId', arguments: property);
        } else {
          Get.snackbar('Not Found', 'Property not found or not loaded yet');
        }
      }
    } catch (e) {
      print('[WEB] Error handling notification: $e');
      Get.snackbar('Error', 'Failed to process notification');
    }
  });
}