import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';

class CameraRepository {
  Future<Uint8List?> captureImage() async {
    return await ImagePickerWeb.getImageAsBytes();
  }

  Future<Uint8List?> pickImageFromGallery() async {
    return await ImagePickerWeb.getImageAsBytes();
  }
}
