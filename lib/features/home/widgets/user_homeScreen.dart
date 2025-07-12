import 'package:fitbook/features/facilities/models/facility.dart';
import 'package:fitbook/features/home/bloc/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/services/AppPreferences.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<Facility> allHotels = [];
  List<Facility> bestHotels = [];
  List<Facility> nearbyHotels = [];
  bool isLoading = true;
  HomeController controller = Get.put(HomeController());

  final List<String> cities = ['Mumbai', 'Goa', 'Chennai', 'Jaipur', 'Pune'];

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  Future<void> _loadHotels() async {
    setState(() => isLoading = true);
    allHotels = controller.featuredFacilities;

    bestHotels = allHotels.where(_isBestRated).toList();
    final userCity = await _getCurrentCity();
    nearbyHotels = userCity == null
        ? []
        : allHotels.where((f) => f.city?.toLowerCase().trim() == userCity.toLowerCase().trim()).toList();

    setState(() => isLoading = false);
  }

  bool _isBestRated(Facility f) =>
      (f.averageRating ?? 0) >= 4.5 && (f.totalReviews ?? 0) > 20;

  Future<String?> _getCurrentCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      return placemarks.first.locality;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Explore Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AppPreferences.clear();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  SizedBox(height: 12),
                  Text('Welcome User', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => Get.toNamed('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () => Get.toNamed('/bookings'),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorites'),
              onTap: () => Get.toNamed('/favorites'),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () => Get.toNamed('/support'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadHotels,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchHeader(),
                const SizedBox(height: 16),
                _buildCityList(),
                const SizedBox(height: 24),
                _buildSection("Best Rated", bestHotels),
                const SizedBox(height: 24),
                _buildSection("Nearby Facilities", nearbyHotels, horizontal: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Live Green", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        height: 50,
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text("Search", style: TextStyle(color: Colors.white))),
            Icon(Icons.filter_list, color: Colors.white),
          ],
        ),
      ),
    ],
  );

  Widget _buildCityList() => SizedBox(
    height: 80,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: cities.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage('https://via.placeholder.com/100x100?text=${cities[i]}'),
          ),
          const SizedBox(height: 8),
          Text(cities[i]),
        ],
      ),
    ),
  );

  Widget _buildSection(String title, List<Facility> data, {bool horizontal = true}) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(child: Text("No data available for $title")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: () {}, child: const Text("See All")),
          ],
        ),
        const SizedBox(height: 8),
        horizontal
            ? SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _buildHotelCard(data[i], horizontal: true),
          ),
        )
            : ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _buildHotelCard(data[i], horizontal: false),
        ),
      ],
    );
  }

  Widget _buildHotelCard(Facility hotel, {bool horizontal = true}) => Container(
    width: horizontal ? 200 : double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            hotel.images?.first ?? '',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text("${hotel.averageRating ?? 0} (${hotel.totalReviews ?? 0} Reviews)"),
          ],
        ),
        const SizedBox(height: 6),
        Text(hotel.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(hotel.city ?? '', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Text("\u20B9${hotel.pricingPerHour ?? '--'}/hour", style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
