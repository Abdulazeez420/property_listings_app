// camera_binding.dart
import 'package:get/get.dart';
import 'package:property_listing_app/features/camera/presentation/controllers/camera_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {

    Get.put(CameraController());
  }
}

