// features/analytics/services/analytics_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final SupabaseClient _supabase;

  AnalyticsService(this._supabase);

  Future<Map<String, dynamic>> getBookingAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final bookings = await _supabase
        .from('bookings')
        .select('*, facilities(name, facility_type)')
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String());

    final totalBookings = bookings.length;
    final totalRevenue = bookings.fold<double>(
      0,
          (sum, booking) => sum + (booking['total_amount'] as num).toDouble(),
    );

    // Group by facility type
    final facilityTypeStats = <String, Map<String, dynamic>>{};
    for (final booking in bookings) {
      final facilityType = booking['facilities']['facility_type'] as String;
      if (!facilityTypeStats.containsKey(facilityType)) {
        facilityTypeStats[facilityType] = {
          'count': 0,
          'revenue': 0.0,
        };
      }
      facilityTypeStats[facilityType]!['count']++;
      facilityTypeStats[facilityType]!['revenue'] +=
          (booking['total_amount'] as num).toDouble();
    }

    // Group by date for trend analysis
    final dailyStats = <String, Map<String, dynamic>>{};
    for (final booking in bookings) {
      final date = DateTime.parse(booking['created_at']).toIso8601String().split('T')[0];
      if (!dailyStats.containsKey(date)) {
        dailyStats[date] = {
          'count': 0,
          'revenue': 0.0,
        };
      }
      dailyStats[date]!['count']++;
      dailyStats[date]!['revenue'] += (booking['total_amount'] as num).toDouble();
    }

    return {
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'facilityTypeStats': facilityTypeStats,
      'dailyStats': dailyStats,
    };
  }

  Future<Map<String, dynamic>> getUserAnalytics() async {
    final users = await _supabase
        .from('users')
        .select('role, created_at');

    final totalUsers = users.length;
    final roleDistribution = <String, int>{};

    for (final user in users) {
      final role = user['role'] as String;
      roleDistribution[role] = (roleDistribution[role] ?? 0) + 1;
    }

    return {
      'totalUsers': totalUsers,
      'roleDistribution': roleDistribution,
    };
  }

  Future<List<Map<String, dynamic>>> getTopFacilities({
    int limit = 10,
  }) async {
    final result = await _supabase
        .from('facilities')
        .select('*, bookings(total_amount)')
        .eq('is_approved', true)
        .order('average_rating', ascending: false)
        .limit(limit);

    return result.map((facility) {
      final bookings = facility['bookings'] as List;
      final totalRevenue = bookings.fold<double>(
        0,
            (sum, booking) => sum + (booking['total_amount'] as num).toDouble(),
      );

      return {
        ...facility,
        'total_revenue': totalRevenue,
        'total_bookings': bookings.length,
      };
    }).toList();
  }
}