import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../booking/models/booking.dart';
import '../../facilities/models/facility.dart';
import '../../home/models/admin_alert.dart';

class AdminStats {
  final int totalUsers;
  final int totalFacilities;
  final int totalBookings;
  final double totalRevenue;
  final int pendingApprovals;
  final int activeUsers;

  AdminStats({
    required this.totalUsers,
    required this.totalFacilities,
    required this.totalBookings,
    required this.totalRevenue,
    required this.pendingApprovals,
    required this.activeUsers,
  });
}

class AdminController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var stats = Rxn<AdminStats>();
  var pendingFacilities = <Facility>[].obs;
  var recentBookings = <Booking>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final users = await _supabase.from('users').select();
      final facilities = await _supabase.from('facilities').select();
      final bookings = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      final pending = await _supabase
          .from('facilities')
          .select()
          .eq('is_approved', false);

      stats.value = AdminStats(
        totalUsers: users.length,
        totalFacilities: facilities.length,
        totalBookings: bookings.length,
        totalRevenue: 0,
        pendingApprovals: pending.length,
        activeUsers: users.length, // Update logic if needed
      );

      pendingFacilities.value =
          (pending as List).map((e) => Facility.fromJson(e)).toList();

      recentBookings.value =
          (bookings as List).map((e) => Booking.fromJson(e)).toList();
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveFacility(String facilityId) async {
    try {
      await _supabase
          .from('facilities')
          .update({'is_approved': true})
          .eq('id', facilityId);
      loadDashboardData();
    } catch (e) {
      errorMessage.value = 'Approval failed: ${e.toString()}';
    }
  }

  Future<void> rejectFacility(String facilityId) async {
    try {
      await _supabase
          .from('facilities')
          .delete()
          .eq('id', facilityId);
      loadDashboardData();
    } catch (e) {
      errorMessage.value = 'Rejection failed: ${e.toString()}';
    }
  }
}
