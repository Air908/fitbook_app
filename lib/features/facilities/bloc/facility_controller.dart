import 'package:get/get.dart';
import '../models/facility.dart';

class FacilityController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var facilities = <Facility>[].obs;
  var allFacilities = <Facility>[];
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFacilities();
  }

  // Load all facilities (simulate API call or Supabase fetch)
  Future<void> loadFacilities() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      allFacilities = List.generate(
        10,
            (index) => Facility(
          id: '$index',
          name: 'Facility $index',
          location: 'Location $index',
          description: 'Description for Facility $index',
          imageUrl: 'https://via.placeholder.com/150',
          images: ['https://via.placeholder.com/300x200?text=Facility+$index'],
          city: 'City $index',
          state: 'State $index',
          facilityType: index % 2 == 0 ? 'gym' : 'yoga_studio',
          averageRating: 4.0 + (index % 5) * 0.1,
          totalReviews: 20 + index,
          pricingPerHour: 100 + index * 10,
        ),
      );

      facilities.assignAll(allFacilities);
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Failed to load facilities';
      facilities.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Search facilities
  void searchFacilities(String query) {
    final lowerQuery = query.toLowerCase();
    final results = allFacilities.where(
          (f) => f.name!.toLowerCase().contains(lowerQuery),
    ).toList();

    facilities.assignAll(results);
  }
}
