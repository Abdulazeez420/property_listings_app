import 'dart:html' as html;

// import 'package:get/get.dart';

void setupWebNotificationRouteListener() {
  html.window.onMessage.listen((event) {
    final data = event.data;

    print("📬 Message received: $data");

    if (data is Map && data.containsKey('propertyId')) {
      final propertyId = data['propertyId'];
      print("🧭 Navigating to property: $propertyId");
      html.window.postMessage({'propertyId': propertyId}, '*');
      // Get.toNamed('/property-detail', parameters: {'id': propertyId});
    }
  });
}
