import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:property_listing_app/core/app/routes/app_pages.dart'
    show Routes;
import 'package:property_listing_app/core/common/utils/logger.dart';
import 'package:property_listing_app/core/network/api_endpoints.dart';
import 'package:property_listing_app/features/analytics/data/services/analytics_service.dart';
import 'package:property_listing_app/features/camera/data/repositories/camera_repository_mobile.dart';
import 'package:property_listing_app/features/property/data/models/property_model.dart';
import 'package:property_listing_app/features/property/data/repositories/property_repository.dart';
import 'dart:io' show Platform;

class PropertyController extends GetxController {
  final PropertyRepository _repository = Get.find();
  final AnalyticsService _analytics = Get.find();
  final CameraRepository _cameraRepo = CameraRepository();

  final RxList<Property> properties = <Property>[].obs;

  final RxBool isLoading = false.obs;
 
  final RxBool hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final int pageSize = 20;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000000.0.obs;
  final ScrollController scrollController = ScrollController();
  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
  RxDouble minArea = 0.0.obs;
  RxDouble maxArea = 10000.0.obs;

  @override
  void onInit() {
    fetchProperties();
    
    _setupScrollListener();

    super.onInit();
  }

  currentProperty(propertyId) async {
    Property? property = properties.firstWhereOrNull((p) => p.id == propertyId);

  return property;
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (_shouldLoadMore()) {
        fetchProperties();
      }
    });
  }

  bool _shouldLoadMore() {
    return scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        hasMore.value &&
        !isLoading.value;
  }

  Future<void> fetchProperties() async {
    // if (isLoading.value) return;

    isLoading.value = true;
    

    _analytics.trackEvent(
      'property_fetch_attempt',
      parameters: {'page': currentPage.value, 'filters': filters},
    );

    try {
      final newProperties = await _repository.fetchProperties(
        page: currentPage.value,
        pageSize: pageSize,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        location: filters['location'],
        tags: filters['tags'],
        status: filters['status'],
      );
print("newProperties :$newProperties");
      if (newProperties.isEmpty) {
        hasMore.value = false;
      } else {
        properties.addAll(newProperties);
        currentPage.value++;
      }

      _analytics.trackEvent(
        'property_fetch_success',
        parameters: {'count': newProperties.length, 'total': properties.length},
      );
        isLoading.value = false;
    } catch (e) {
      _analytics.trackEvent(
        'property_fetch_error',
        parameters: {'error': e.toString()},
      );
      Get.snackbar(
        'Error',
        'Failed to load properties',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
     
    }
  }

  void resetFilters() {
    minPrice.value = 0.0;
    maxPrice.value = 1000000.0;
    minArea.value = 0.0;
    maxArea.value = 10000.0;
    filters.clear();
    currentPage.value = 1;
    properties.clear();
    hasMore.value = true;

    _analytics.trackEvent('filters_reset');
    fetchProperties();
  }

  Future<void> fetchFilteredProperties() async {
    if (isLoading.value) return;

    isLoading.value = true;
    _analytics.trackEvent('property_filter_fetch', parameters: filters);

    try {
      final newProperties = await _repository.fetchProperties(
        page: currentPage.value,
        pageSize: pageSize,
        minPrice: filters['minPrice'] ?? minPrice.value,
        maxPrice: filters['maxPrice'] ?? maxPrice.value,
        location: filters['location'],
        type: filters['type'],
        bedrooms: filters['bedrooms'],
        bathrooms: filters['bathrooms'],
        status: filters['status'],
        minAreaSqFt: filters['minArea'],
        maxAreaSqFt: filters['maxArea'],
        amenities:
            filters['amenities'] is List
                ? filters['amenities'].join(',')
                : null,
      );

      if (newProperties.isEmpty) {
        hasMore.value = false;
        if (currentPage.value == 1) {
          properties.clear();
        }
      } else {
        if (currentPage.value == 1) {
          properties.assignAll(newProperties);
        } else {
          properties.addAll(newProperties);
        }
        currentPage.value++;
      }

      _analytics.trackEvent(
        'property_fetch_success',
        parameters: {'count': newProperties.length, 'total': properties.length},
      );
    } catch (e) {
      _analytics.trackEvent(
        'filter_fetch_error',
        parameters: {'error': e.toString()},
      );
      Get.snackbar(
        'Error',
        'Failed to load filtered properties',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    try {
  
      final cleanedFilters = Map<String, dynamic>.from(newFilters)..removeWhere(
        (key, value) =>
            value == null ||
            value == '' ||
            (value is List && value.isEmpty) ||
            (value is bool && !value),
      );


      currentPage.value = 1;
      properties.clear();
      hasMore.value = true;

      filters.value = {
        ...cleanedFilters,
        'minPrice': minPrice.value,
        'maxPrice': maxPrice.value,
        'min_area_sqft': minArea.value,
        'max_area_sqft': maxArea.value,
      };

      _analytics.trackEvent('filters_applied', parameters: filters);
      fetchFilteredProperties();
    } catch (e) {
      _analytics.trackEvent(
        'filter_error',
        parameters: {'error': e.toString()},
      );
      Get.snackbar(
        'Error',
        'Invalid filter parameters',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadPropertyImage(
    String propertyId, [
    Uint8List? imageData,
  ]) async {
    try {
      if (imageData == null && !kIsWeb) {
        final source = await _showImageSourceModal();
        if (source != null) {
          imageData =
              source == ImageSource.camera
                  ? await _cameraRepo.captureImage()
                  : await _cameraRepo.pickImageFromGallery();
        }
      }

      if (imageData == null && kIsWeb) {
        final result = await Get.toNamed(Routes.cameraView) as Uint8List?;
        print("Received result from CameraView: ${result?.lengthInBytes}");
        if (result != null) imageData = result;
      }

      if (imageData == null || imageData.isEmpty) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final imageUrl = await _uploadToCloudStorage(propertyId, imageData);
      print("imageUrl :${imageUrl}");
      final index = properties.indexWhere((p) => p.id == propertyId);

      if (index != -1) {
        properties[index] = properties[index].copyWith(
          images: [...properties[index].images, imageUrl],
        );
        update();
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Image uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _analytics.trackEvent(
        'property_image_uploaded',
        parameters: {'property_id': propertyId, 'image_url': imageUrl},
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to upload image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> shareProperty(String propertyId) async {
    try {
      final property = properties.firstWhere(
        (p) => p.id == propertyId,
        orElse: () => Property.empty(),
      );

      if (property.id.isEmpty) {
        _analytics.trackEvent(
          'property_share_error',
          parameters: {
            'property_id': propertyId,
            'error': 'Property not found',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        return;
      }

      _analytics.trackEvent(
        'property_share_attempt',
        parameters: {
          'property_id': propertyId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final shareText = '''
🏡 ${property.title} 🏡

📍 ${property.location}
💰 \$${property.price.toStringAsFixed(2)}
${property.status != 'available' ? '🔴 ${property.status.toUpperCase()}' : '🟢 AVAILABLE'}

${property.description}
${Routes.propertyDetail}
''';

      // Platform check before sharing
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _analytics.trackEvent(
          'property_shared',
          parameters: {
            'property_id': propertyId,
            'platform': Platform.operatingSystem,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Fallback for web or unsupported platforms
        await _copyToClipboard(shareText);
        _analytics.trackEvent(
          'property_share_fallback',
          parameters: {
            'property_id': propertyId,
            'platform': kIsWeb ? 'web' : 'unsupported',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        Get.snackbar('Copied!', 'Property details copied to clipboard');
      }
    } catch (e) {
      _analytics.trackEvent(
        'property_share_error',
        parameters: {
          'property_id': propertyId,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Fallback to clipboard if sharing fails
      await _copyToClipboard(e.toString());
      Get.snackbar('Copied!', 'Property name copied to clipboard');
    }
  }

  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      logger.e('Failed to copy to clipboard: $e');
    }
  }

  Future<ImageSource?> _showImageSourceModal() async {
    return await Get.bottomSheet<ImageSource?>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<String> _uploadToCloudStorage(
    String propertyId,
    Uint8List imageData,
  ) async {
    
    await Future.delayed(const Duration(seconds: 1)); 
    return '${ApiEndpoints.baseUrl}/property_images/${propertyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
