import 'dart:convert';
import 'package:get/get.dart';
import 'package:property_listing_app/core/common/utils/logger.dart';

class AnalyticsService extends GetxService {
  final Map<String, DateTime> _viewStartTimes = {};
  final Map<String, Map<String, dynamic>> _analyticsData = {};

  @override
  void onInit() {
    super.onInit();
    logger.i('AnalyticsService initialized (console-only)');
  }

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    final event = {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };

    _simulateBackendSend(event);
  }

  void trackView(String screenName, {Map<String, dynamic>? parameters}) {
    trackEvent('screen_view', parameters: {
      'screen_name': screenName,
      ...?parameters,
    });
  }

  void trackPropertyView(String propertyId) {
    _viewStartTimes[propertyId] = DateTime.now();

    final data = _analyticsData[propertyId] ?? {
      'view_count': 0,
      'total_time': 0,
      'interactions': {},
    };

    data['view_count'] = (data['view_count'] ?? 0) + 1;
    data['last_viewed'] = DateTime.now().toIso8601String();
    _analyticsData[propertyId] = data;

    trackEvent('property_view', parameters: {'property_id': propertyId});
  }

  void trackPropertyTimeSpent(String propertyId, Duration duration) {
    final data = _analyticsData[propertyId] ?? {
      'view_count': 0,
      'total_time': 0,
      'interactions': {},
    };

    data['total_time'] = (data['total_time'] ?? 0) + duration.inSeconds;
    _analyticsData[propertyId] = data;

    trackEvent('property_time_spent', parameters: {
      'property_id': propertyId,
      'duration_seconds': duration.inSeconds,
    });
  }

  void trackInteraction(String propertyId, String elementType) {
    final data = _analyticsData[propertyId] ?? {
      'view_count': 0,
      'total_time': 0,
      'interactions': {},
    };

    final interactions = Map<String, int>.from(data['interactions'] ?? {});
    interactions[elementType] = (interactions[elementType] ?? 0) + 1;
    data['interactions'] = interactions;

    _analyticsData[propertyId] = data;

    trackEvent('interaction', parameters: {
      'property_id': propertyId,
      'element_type': elementType,
    });
  }

  void endPropertyView(String propertyId) {
    if (_viewStartTimes.containsKey(propertyId)) {
      final duration = DateTime.now().difference(_viewStartTimes[propertyId]!);
      trackPropertyTimeSpent(propertyId, duration);
      _viewStartTimes.remove(propertyId);
    }
  }

  Map<String, dynamic> getPropertyAnalytics(String propertyId) {
    return _analyticsData[propertyId] ?? {};
  }

  List<Map<String, dynamic>> getMostViewedProperties([int limit = 5]) {
    final entries = _analyticsData.entries.toList();
    entries.sort((a, b) =>
        (b.value['view_count'] ?? 0).compareTo(a.value['view_count'] ?? 0));

    return entries.take(limit).map((e) {
      return {
        'property_id': e.key,
        ...e.value,
      };
    }).toList();
  }

  void _simulateBackendSend(Map<String, dynamic> event) {
    logger.i('📊 Analytics Event: ${jsonEncode(event)}');
  }

  @override
  void onClose() {
    logger.i('AnalyticsService closed');
    super.onClose();
  }
}
