import 'package:flutter/material.dart';
import '../../booking/models/booking.dart';
import '../bloc/admin_controller.dart'; // Make sure Booking model is accessible

class RecentBookings extends StatelessWidget {
  final List<Booking> bookings;

  const RecentBookings({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Text('No recent bookings found.');
    }

    return Column(
      children: bookings.map((booking) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
            title: Text('${booking?.id??""} booked ${booking.facilityId??""}'),
            subtitle: Text('Booking ID: ${booking.id}'),
          ),
        );
      }).toList(),
    );
  }
}
