import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:property_listing_app/core/common/utils/logger.dart';


class ApiService extends GetxService {
  final http.Client client = http.Client();

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(endpoint).replace(
        queryParameters: queryParams,
      );

      logger.i('API Request: $uri');

      final response = await client.get(
        uri,
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      logger.e('API Error: $e');
      rethrow;
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    logger.i('API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Request failed with status: ${response.statusCode}. ${response.body}',
      );
    }
  }

  @override
  void onClose() {
    client.close();
    super.onClose();
  }
}