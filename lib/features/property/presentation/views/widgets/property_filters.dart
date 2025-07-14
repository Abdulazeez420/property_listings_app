import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_listing_app/core/common/utils/constants.dart';
import 'package:property_listing_app/features/property/presentation/controllers/property_controller.dart';
import 'package:property_listing_app/core/common/widgets/responsive_layout.dart';

class PropertyFilters extends GetView<PropertyController> {
  const PropertyFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildFilterContent(context, false),
      tablet: _buildFilterContent(context, false),
      desktop: _buildFilterContent(context, true),
    );
  }

  Widget _buildFilterContent(BuildContext context, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 800;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isLargeTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: isDesktop
            ? BorderRadius.circular(AppConstants.cardRadius)
            : const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.cardRadius),
                topRight: Radius.circular(AppConstants.cardRadius),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          _buildHeader(isDesktop),
          const SizedBox(height: 16),
          
          // Filter content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Filter
                  _buildPriceRangeFilter(),
                  const SizedBox(height: 24),

                  // Property Type Filter
                  _buildPropertyTypeFilter(isLargeTablet),
                  const SizedBox(height: 24),

                  // Bedrooms Filter
                  _buildBedroomsFilter(isLargeTablet),
                  const SizedBox(height: 24),

                  // Bathrooms Filter
                  _buildBathroomsFilter(isLargeTablet),
                  const SizedBox(height: 24),

                  // Status Filter
                  _buildStatusFilter(isLargeTablet),
                  const SizedBox(height: 24),

                  // Location Filter
                  _buildLocationFilter(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filters',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!isDesktop)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
        Obx(() {
          return Column(
            children: [
              RangeSlider(
                values: RangeValues(
                  controller.minPrice.value,
                  controller.maxPrice.value,
                ),
                min: 0,
                max: 1000000,
                divisions: 20,
                labels: RangeLabels(
                  '\$${controller.minPrice.value.toStringAsFixed(0)}',
                  '\$${controller.maxPrice.value.toStringAsFixed(0)}',
                ),
                onChanged: (values) {
                  controller.minPrice.value = values.start;
                  controller.maxPrice.value = values.end;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${controller.minPrice.value.toStringAsFixed(0)}'),
                    Text('\$${controller.maxPrice.value.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPropertyTypeFilter(bool isLargeTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Property Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['House', 'Apartment', 'Condo', 'Townhouse']
              .map((type) => ChoiceChip(
                    label: Text(type),
                    selected: controller.filters['type'] == type,
                    onSelected: (selected) {
                      controller.filters['type'] = selected ? type : null;
                      controller.filters.refresh();
                    },
                  ))
              .toList(),
        )),
      ],
    );
  }

  Widget _buildBedroomsFilter(bool isLargeTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bedrooms', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1', '2', '3', '4', '5+']
              .map((value) => ChoiceChip(
                    label: Text(value),
                    selected: controller.filters['bedrooms'] == value,
                    onSelected: (selected) {
                      controller.filters['bedrooms'] = selected ? value : null;
                      controller.filters.refresh();
                    },
                  ))
              .toList(),
        )),
      ],
    );
  }

  Widget _buildBathroomsFilter(bool isLargeTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bathrooms', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1', '2', '3', '4+']
              .map((value) => ChoiceChip(
                    label: Text(value),
                    selected: controller.filters['bathrooms'] == value,
                    onSelected: (selected) {
                      controller.filters['bathrooms'] = selected ? value : null;
                      controller.filters.refresh();
                    },
                  ))
              .toList(),
        )),
      ],
    );
  }

  Widget _buildStatusFilter(bool isLargeTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Available', 'Sold', 'Upcoming']
              .map((status) => ChoiceChip(
                    label: Text(status),
                    selected: controller.filters['status'] == status,
                    onSelected: (selected) {
                      controller.filters['status'] = selected ? status : null;
                      controller.filters.refresh();
                    },
                  ))
              .toList(),
        )),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.filters['location'],
          isExpanded: true,
          items: [
            'All Locations',
            'Hillview',
            'Metrocity',
            'Beachside',
            'Townsburg',
            'Cityville'
          ].map((location) => DropdownMenuItem(
                value: location == 'All Locations' ? null : location,
                child: Text(location),
              )).toList(),
          onChanged: (value) {
            controller.filters['location'] = value;
            controller.filters.refresh();
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            
          ),
        )),),
      ],
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    return isDesktop
        ? Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.resetFilters,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Reset All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters({
                      ...controller.filters,
                      'minPrice': controller.minPrice.value,
                      'maxPrice': controller.maxPrice.value,
                    });
                    if (!isDesktop) Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters({
                      ...controller.filters,
                      'minPrice': controller.minPrice.value,
                      'maxPrice': controller.maxPrice.value,
                    });
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    controller.resetFilters();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Reset All'),
                ),
              ),
            ],
          );
  }
}