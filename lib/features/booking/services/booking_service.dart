import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BookingService {
  final SupabaseClient _supabase;

  BookingService(this._supabase);

  /// Stream of bookings for a given facility and date
  Stream<List<Booking>> watchBookings(String facilityId, DateTime date) {
    final dateString = date.toIso8601String().split('T')[0];

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('facility_id', facilityId)
        .map((event) => event
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList());
  }

  /// Checks if a time slot is available (no overlapping confirmed bookings)
  Future<bool> checkAvailability({
    required String facilityId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);

    final response = await _supabase
        .from('bookings')
        .select()
        .eq('facility_id', facilityId)
        .eq('booking_date', dateString)
        .eq('status', 'confirmed')
        .or('start_time.lte.$end,end_time.gte.$start');

    return (response as List).isEmpty;
  }

  /// Creates a new booking entry
  Future<Booking> createBooking({
    required String facilityId,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String bookingType,
    required double amount,
  }) async {
    final bookingData = {
      'facility_id': facilityId,
      'booking_date': date.toIso8601String().split('T')[0],
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      'booking_type': bookingType,
      'total_amount': amount,
      'status': 'pending',
    };

    final response = await _supabase
        .from('bookings')
        .insert(bookingData)
        .select()
        .single();

    return Booking.fromJson(response as Map<String, dynamic>);
  }

  /// Utility to format TimeOfDay to HH:mm
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
