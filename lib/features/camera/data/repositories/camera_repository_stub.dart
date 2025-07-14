import 'dart:typed_data';

class CameraRepository {
  Future<Uint8List?> captureImage() async {
    throw UnsupportedError('Not supported on this platform');
  }

  Future<Uint8List?> pickImageFromGallery() async {
    throw UnsupportedError('Not supported on this platform');
  }
}
