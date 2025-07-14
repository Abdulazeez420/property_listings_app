
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_listing_app/core/app/routes/app_pages.dart';
import 'package:property_listing_app/core/common/widgets/responsive_layout.dart';
import 'package:property_listing_app/features/property/data/models/property_model.dart';
import 'package:property_listing_app/features/property/presentation/controllers/property_controller.dart';
import 'package:property_listing_app/features/property/presentation/views/widgets/property_card.dart';
import 'package:property_listing_app/features/property/presentation/views/widgets/property_filters.dart';

class PropertyListView extends GetView<PropertyController> {
  const PropertyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Listings'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          if (!ResponsiveLayout.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilters(context),
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileList(context),
        tablet: _buildTabletList(context),
        desktop: _buildDesktopList(context),
      ),
      floatingActionButton: ResponsiveLayout.isDesktop(context)
          ? null
          : FloatingActionButton(
              onPressed: () => controller.resetFilters(),
              tooltip: 'Reset Filters',
              child: const Icon(Icons.refresh),
            ),
    );
  }

  Widget _buildMobileList(context) {
    return Obx(() {
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          _buildResultsHeader(context),
          if (controller.isLoading.value && controller.properties.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.properties.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < controller.properties.length) {
                    return PropertyCard(
                      property: controller.properties[index],
                      onTap: () => _navigateToDetail(controller.properties[index]),
                    );
                  }
                  return _buildPaginationLoader(context);
                },
                childCount: controller.properties.length +
                    (controller.hasMore.value ? 1 : 0),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildTabletList(context) {
    return Obx(() {
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          _buildResultsHeader(context),
          if (controller.isLoading.value && controller.properties.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.properties.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < controller.properties.length) {
                      return PropertyCard(
                        property: controller.properties[index],
                        onTap: () => _navigateToDetail(controller.properties[index]),
                      );
                    }
                    return _buildPaginationLoader(context);
                  },
                  childCount: controller.properties.length +
                      (controller.hasMore.value ? 1 : 0),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDesktopList(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 320,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ), )
          ),
          child: const PropertyFilters(),
        ),

        // Main Content
        Expanded(
          child: Obx(() {
            return CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                _buildResultsHeader(context),
                if (controller.isLoading.value && controller.properties.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.properties.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        childAspectRatio: 0.9,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < controller.properties.length) {
                            return PropertyCard(
                              property: controller.properties[index],
                              onTap: () => _navigateToDetail(
                                  controller.properties[index]),
                            );
                          }
                          return _buildPaginationLoader(context);
                        },
                        childCount: controller.properties.length +
                            (controller.hasMore.value ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Text(
              '${controller.properties.length} results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search criteria',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => controller.resetFilters(),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader(context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _navigateToDetail(Property property) {
    Get.toNamed(
      '${Routes.propertyDetail}/${property.id}',
      arguments: property,
      preventDuplicates: false,
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PropertyFilters(),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: PropertySearchDelegate(controller),
    );
  }
}

class PropertySearchDelegate extends SearchDelegate {
  final PropertyController controller;

  PropertySearchDelegate(this.controller);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = controller.properties.where((property) {
      return property.title.toLowerCase().contains(query.toLowerCase()) ||
          property.location.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final property = results[index];
        return ListTile(
          title: Text(property.title),
          subtitle: Text(property.location),
          onTap: () {
            close(context, null);
            Get.toNamed(
              '${Routes.propertyDetail}/${property.id}',
              arguments: property,
            );
          },
        );
      },
    );
  }
}