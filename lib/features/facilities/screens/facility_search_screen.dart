import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bloc/facility_controller.dart';
import '../models/facility.dart';
import '../widgets/facility_card.dart';
import '../widgets/search_filters.dart';

class FacilitySearchScreen extends StatefulWidget {
  const FacilitySearchScreen({Key? key}) : super(key: key);

  @override
  State<FacilitySearchScreen> createState() => _FacilitySearchScreenState();
}

class _FacilitySearchScreenState extends State<FacilitySearchScreen> {
  final _searchController = TextEditingController();
  final FacilityController controller = Get.put(FacilityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search facilities...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.searchFacilities,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${controller.errorMessage.value}'),
                      ElevatedButton(
                        onPressed: controller.loadFacilities,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.facilities.isEmpty) {
                return const Center(child: Text('No facilities found'));
              }

              return ListView.builder(
                itemCount: controller.facilities.length,
                itemBuilder: (context, index) {
                  final facility = controller.facilities[index];
                  return FacilityCard(
                    facility: facility,
                    onTap: () => _navigateToDetails(facility),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SearchFilters(),
    );
  }

  void _navigateToDetails(Facility facility) {
    Get.toNamed('/facility-details', arguments: facility);
  }
}
