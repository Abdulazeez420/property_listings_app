// views/property_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:property_listing_app/core/common/utils/logger.dart' show logger;
import 'package:property_listing_app/features/analytics/data/services/analytics_service.dart';
import 'package:property_listing_app/features/property/data/models/property_model.dart';
import 'package:property_listing_app/features/property/presentation/controllers/property_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class PropertyDetailView extends StatefulWidget {
  final Property property;

  const PropertyDetailView({super.key, required this.property});

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  AnalyticsService analytics = Get.find();
  PropertyController controller = Get.find();
  final DateTime _startTime = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    _trackInitialAnalytics();

    _trackPropertyImpression();

    _setupScrollTracking();
  }

  void _setupScrollTracking() {
    _scrollController.addListener(() {
      final newPosition = _scrollController.position.pixels;
      if ((newPosition - _scrollPosition).abs() > 100) {
        analytics.trackEvent(
          'property_scroll',
          parameters: {
            'property_id': widget.property.id,
            'scroll_position': newPosition,
          },
        );
        _scrollPosition = newPosition;
      }
    });
  }

  void _trackInitialAnalytics() {
    try {
      analytics.trackPropertyView(widget.property.id);
      analytics.trackView(
        'property_detail',
        parameters: {
          'property_id': widget.property.id,
          'price': widget.property.price,
          'status': widget.property.status,
        },
      );
    } catch (e) {
      logger.e('Failed to track analytics: $e');
    }
  }

  void _trackPropertyImpression() {
    analytics.trackEvent(
      'property_impression',
      parameters: {
        'property_id': widget.property.id,
        'price': widget.property.price,
        'status': widget.property.status,
        'bedrooms': widget.property.bedrooms,
        'bathrooms': widget.property.bathrooms,
      },
    );
  }

  void _trackInteraction(String element) {
    analytics.trackEvent(
      'property_interaction',
      parameters: {
        'property_id': widget.property.id,
        'element': element,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void dispose() {
    try {
      final duration = DateTime.now().difference(_startTime);
      analytics.trackPropertyTimeSpent(widget.property.id, duration);
      analytics.trackEvent(
        'property_view_session',
        parameters: {
          'property_id': widget.property.id,
          'duration_seconds': duration.inSeconds,
          'max_scroll_position': _scrollController.position.maxScrollExtent,
        },
      );
      _scrollController.dispose();
    } catch (e) {
      logger.e('Failed to track time spent: $e');
    }
    super.dispose();
  }

  Future<void> _shareProperty() async {
    try {
      analytics.trackEvent(
        'property_share_attempt',
        parameters: {
          'property_id': widget.property.id,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final shareText =
          '🏡 ${widget.property.title} 🏡\n\n'
          '📍 ${widget.property.location}\n'
          '💰 ${widget.property.currency} ${NumberFormat('#,##0').format(widget.property.price)}\n'
          '🛏️ ${widget.property.bedrooms} Bedrooms | 🛁 ${widget.property.bathrooms} Bathrooms\n'
          '📏 ${widget.property.areaSqFt} sqft\n\n'
          '${widget.property.description}\n\n'
          'Contact agent: ${widget.property.agentName} - ${widget.property.agentContact}';

      final result = await Share.share(
        shareText,
        subject: 'Property Listing: ${widget.property.title}',
      );

      if (result.status == ShareResultStatus.success) {
        analytics.trackEvent(
          'property_shared',
          parameters: {
            'property_id': widget.property.id,
            'share_method': result.raw,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        Get.snackbar(
          'Shared Successfully',
          'Property details have been shared',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      analytics.trackEvent(
        'property_share_error',
        parameters: {
          'property_id': widget.property.id,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      Get.snackbar(
        'Sharing Failed',
        'Could not share property details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openMap() async {
    _trackInteraction('map_button');

    if (widget.property.location.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Location is not available.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final encoded = Uri.encodeComponent(widget.property.location);
    final Uri mapUri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$encoded",
    );
    final Uri geoUri = Uri.parse("geo:0,0?q=$encoded");

    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open maps application';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _contactAgent() async {
    _trackInteraction('contact_agent');
    final phone = widget.property.agentContact.replaceAll(RegExp(r'\s+'), '');

    try {
      final Uri telUri = Uri(scheme: 'tel', path: phone);

      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw 'Could not launch phone dialer';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final dateFormat = DateFormat('MMM d, y');
    if (widget.property.id.isNotEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.title),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareProperty),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with Indicators
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height:
                        isDesktop
                            ? 500
                            : isTablet
                            ? 350
                            : 250,
                    viewportFraction: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items:
                      widget.property.images.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 50),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
                if (widget.property.images.length > 1)
                  Positioned(
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.property.images.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentImageIndex == entry.key
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.withOpacity(0.4),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),

            // Property Details
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    isDesktop
                        ? 48
                        : isTablet
                        ? 32
                        : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          widget.property.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: _statusColor(widget.property.status),
                      ),
                      Text(
                        '${widget.property.currency} ${NumberFormat('#,##0').format(widget.property.price)}',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Property Title and Location
                  Text(
                    widget.property.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.property.location,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Listed: ${dateFormat.format(widget.property.postedDate)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Key Features Grid
                  Text(
                    'Property Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount:
                        isDesktop
                            ? 4
                            : isTablet
                            ? 3
                            : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isDesktop ? 1.5 : 1.8,
                    children: [
                      _buildFeatureItem(
                        Icons.king_bed,
                        '${widget.property.bedrooms} Beds',
                      ),
                      _buildFeatureItem(
                        Icons.bathtub,
                        '${widget.property.bathrooms} Baths',
                      ),
                      _buildFeatureItem(
                        Icons.square_foot,
                        '${widget.property.areaSqFt} sqft',
                      ),
                      _buildFeatureItem(
                        Icons.calendar_today,
                        'Listed ${dateFormat.format(widget.property.postedDate)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Tags Section
                  if (widget.property.tags.isNotEmpty) ...[
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.property.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Agent Information
                  Text(
                    'Agent Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.property.agentName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.property.agentContact,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.property.agentEmail,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: _contactAgent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _openMap,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Add Photo'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: () {
                                _trackInteraction('add_photo_button');
                                controller.uploadPropertyImage(
                                  widget.property.id,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _openMap,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Add Photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _trackInteraction('add_photo_button');
                              controller.uploadPropertyImage(
                                widget.property.id,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
