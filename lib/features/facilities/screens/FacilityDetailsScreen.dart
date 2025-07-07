// lib/features/facilities/screens/facility_details_screen.dart
import 'package:flutter/material.dart';
import '../models/facility.dart';

class FacilityDetailsScreen extends StatelessWidget {
  final Facility facility;

  const FacilityDetailsScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(facility.name??"")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(facility.description??"", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text("Price/hr: ₹${facility.pricingPerHour}"),
            // Add more details...
          ],
        ),
      ),
    );
  }
}
