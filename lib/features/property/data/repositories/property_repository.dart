import 'package:get/get.dart';
import 'package:property_listing_app/core/network/api_endpoints.dart';
import 'package:property_listing_app/core/network/api_service.dart';
import 'package:property_listing_app/features/property/data/models/property_model.dart';

class PropertyRepository {
  final ApiService _apiService = Get.find();

Future<List<Property>> fetchProperties({
  int page = 1,
  int pageSize = 20,
  double? minPrice,
  double? maxPrice,
  String? location,
  List<String>? tags,
  String? status,
  List<String>? amenities,
  String? type,
  String? bedrooms,
  String? bathrooms,
  double? minAreaSqFt,
  double? maxAreaSqFt,
}) async {
  try {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (minAreaSqFt != null) 'min_area_sqft': minAreaSqFt.toString(),
      if (maxAreaSqFt != null) 'max_area_sqft': maxAreaSqFt.toString(),
      if (location != null && location.isNotEmpty) 'location': location,
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
      if (bedrooms != null && bedrooms.isNotEmpty) 'bedrooms': bedrooms,
      if (bathrooms != null && bathrooms.isNotEmpty) 'bathrooms': bathrooms,
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
      if (amenities != null && amenities.isNotEmpty) 'amenities': amenities.join(','),
    };

    final response = await _apiService.get(
      ApiEndpoints.properties,
      queryParams: queryParams,
    );

    if (response.containsKey('properties')) {
      return (response['properties'] as List)
          .map((item) => Property.fromJson(item))
          .toList();
    } else {
      throw Exception('Invalid response format: missing "properties" key');
    }
  } catch (e) {
    rethrow;
  }
}

}