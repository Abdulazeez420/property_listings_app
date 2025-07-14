import 'package:get/get.dart';

import 'package:property_listing_app/core/network/api_service.dart';
import 'package:property_listing_app/features/property/data/repositories/property_repository.dart';
import 'package:property_listing_app/features/property/presentation/controllers/property_controller.dart';

class PropertyBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => PropertyRepository());
    Get.lazyPut(() => PropertyController());
  }
}