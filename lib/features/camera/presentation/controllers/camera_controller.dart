import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';

class CameraController extends GetxController {
  final Rx<Uint8List?> imageData = Rx<Uint8List?>(null);
  late DropzoneViewController dropzoneCtrl;
  final isHovering = false.obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        imageData.value = bytes;
        Get.back(result: imageData.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    await pickImage(ImageSource.gallery);
  }

  Future<void> handleDroppedFile(Uint8List bytes) async {
    try {
      if (bytes.isNotEmpty) {
        imageData.value = bytes;
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to process dropped file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearImage() {
    imageData.value = null;
  }
}