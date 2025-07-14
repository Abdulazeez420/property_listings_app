import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CameraRepository {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (image != null) {
        return await image.readAsBytes();
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
      return null;
    }
  }

  Future<Uint8List?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        return await image.readAsBytes();
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
      return null;
    }
  }
}
