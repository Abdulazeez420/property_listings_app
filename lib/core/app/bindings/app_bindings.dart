import 'package:get/get.dart';
import 'package:property_listing_app/core/network/api_service.dart';
import 'package:property_listing_app/features/analytics/data/services/analytics_service.dart';
import 'package:property_listing_app/features/camera/data/repositories/camera_repository_mobile.dart';
import 'package:property_listing_app/features/notifications/data/services/notification_service.dart';
import 'package:property_listing_app/features/property/data/repositories/property_repository.dart';

class AppBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(ApiService(), permanent: true);
    Get.put(PropertyRepository(), permanent: true);
    Get.put(AnalyticsService(), permanent: true);
    Get.put(CameraRepository(), permanent: true);
    await Get.putAsync(() => NotificationService().initialize());
  }

  Future<void> init() async {
    await dependencies();
  }
}
