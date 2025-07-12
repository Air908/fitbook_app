import 'dart:ffi';

import 'package:fitbook/core/routers/app_routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/AppPreferences.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../booking/models/booking.dart';
import '../../facilities/models/facility.dart';
import '../models/admin_alert.dart';

class HomeController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Reactive states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var userRole = 'user'.obs;
  var currentUser = Rxn<User>();
  var featuredFacilities = <Facility>[].obs;
  var recentBookings = <Booking>[].obs;
  var adminStats = Rxn<AdminStats>();
  var adminAlerts = <AdminAlert>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      /// ✅ Load user info from Shared Preferences
      final isLoggedIn =
         await AppPreferences.getValue<bool>(AppPreferences.keyIsLoggedIn)?? false;

      if (!isLoggedIn) {
        userRole.value = 'user';
        currentUser.value = null;
        featuredFacilities.clear();
        recentBookings.clear();
        adminStats.value = null;
        adminAlerts.clear();
        return;
      }

      // Set shared preference values
      final userId = AppPreferences.getValue<String>(AppPreferences.keyUserId);
      final role = AppPreferences.getValue<String>(AppPreferences.keyUserRole);
      final email = AppPreferences.getValue<String>(AppPreferences.keyUserEmail);

      userRole.value = role.toString() ?? 'user';

      /// Note: Supabase `User` object is nullable. You can just store basic values from prefs.
      currentUser.value = Supabase.instance.client.auth.currentUser;

      if (userRole.value.toLowerCase() == 'admin') {
        Get.toNamed(AppRoutes.adminDashboard);
      } else {
        await _loadUserData(currentUser.value!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> refreshHomeData() async {
    if (currentUser.value == null) return;
    if (userRole.value == 'admin') {
      await _loadAdminData(currentUser.value!);
    } else {
      await _loadUserData(currentUser.value!);
    }
  }

  Future<void> updateUserRole(String role) async {
    userRole.value = role;
    await loadHomeData();
  }

  Future<void> _loadAdminData(User user) async {
    featuredFacilities.value = await fetchFeaturedFacilities();
    recentBookings.value = await _fetchRecentBookings(user.id);
    adminStats.value = await _fetchAdminStats();
    adminAlerts.value = await _fetchAdminAlerts();
  }

  Future<void> _loadUserData(User user) async {
    featuredFacilities.value = await fetchFeaturedFacilities();
    recentBookings.value = await _fetchRecentBookings(user.id);
  }

  Future<List<Facility>> fetchFeaturedFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true);

      if (response == null || (response as List).isEmpty) {
        return [];
      }

      return response.map((f) => Facility.fromJson(f)).toList();
    } catch (e) {
      // Optionally log the error
      return [];
    }
  }

  Future<List<Booking>> _fetchRecentBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('booking_date', ascending: false)
        .limit(5);

    return (response as List).map((b) => Booking.fromJson(b)).toList();
  }

  Future<AdminStats> _fetchAdminStats() async {
    final users = await _supabase.from('users').select('id');
    final facilities = await _supabase.from('facilities').select('id');
    final bookings = await _supabase.from('bookings').select('id');

    return AdminStats(
      totalUsers: users.length,
      totalFacilities: facilities.length,
      totalBookings: bookings.length,
      totalRevenue: 0.0,
      pendingApprovals: 0,
      activeUsers: users.length,
    );
  }

  Future<List<AdminAlert>> _fetchAdminAlerts() async {
    final response = await _supabase
        .from('admin_alerts')
        .select()
        .order('timestamp', ascending: false);

    return (response as List).map((a) => AdminAlert.fromJson(a)).toList();
  }
}
