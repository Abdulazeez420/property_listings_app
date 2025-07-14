import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_listing_app/features/camera/presentation/controllers/camera_controller.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Property Image'),
        actions: [
          if (controller.imageData.value != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearImage,
            ),
        ],
      ),
      body: Center(
        child: Obx(() {
          if (controller.imageData.value != null) {
            return _buildImagePreview(context);
          }
          return  _buildWebUploadArea(context);
        }),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.memory(
              controller.imageData.value!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              onPressed: controller.clearImage,
              label: const Text('Retake'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              onPressed: () {
                 print("Sending back data: ${controller.imageData.value?.lengthInBytes}");
                Get.back(result: controller.imageData.value);
              },
              label: const Text('Use This Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebUploadArea(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 400,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Upload Property Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Drag & drop your image here or click to browse',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Drag and Drop Zone
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      DropzoneView(
                        operation: DragOperation.copy,
                        cursor: CursorType.grab,
                        onCreated: (ctrl) => controller.dropzoneCtrl = ctrl,
                        onLoaded: () => debugPrint('Zone loaded'),
                        onError: (ev) => debugPrint('Error: $ev'),
                        onHover: () => controller.isHovering.value = true,
                        onLeave: () => controller.isHovering.value = false,

                        /// ✅ This is the correct handler!
                        onDropFile: (file) async {
                          controller.isHovering.value = false;
                          try {
                            final bytes = await controller.dropzoneCtrl
                                .getFileData(file); // ✅ Correct
                            controller.handleDroppedFile(bytes);

                            final name = file.name;
                            final type = file.type;
                            final size = file.size;
                            debugPrint('Dropped: $name ($type, $size bytes)');
                          } catch (e, stackTrace) {
                            debugPrint('Error handling drop: $e');
                            debugPrintStack(stackTrace: stackTrace);
                            Get.snackbar(
                              'Error',
                              'Failed to process dropped file',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      ),

                      Obx(
                        () => Container(
                          color:
                              controller.isHovering.value
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  controller.isHovering.value
                                      ? 'Drop to upload'
                                      : 'Drag files here',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.pickImageFromGallery,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Browse Files'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
