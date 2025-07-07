// features/home/widgets/featured_facilities.dart
import 'package:flutter/material.dart';
import '../../facilities/models/facility.dart';

class FeaturedFacilities extends StatelessWidget {
  final List<Facility> facilities;
  final Function(Facility) onFacilityTap;

  const FeaturedFacilities({
    Key? key,
    required this.facilities,
    required this.onFacilityTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) {
      return const Center(
        child: Text('No featured facilities available'),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final facility = facilities[index];
          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => onFacilityTap(facility),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility Image
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(
                              facility.images!.isNotEmpty
                                  ? facility.images!.first
                                  : 'https://via.placeholder.com/300x120',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Facility Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility?.name??"",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              facility.location ?? 'No location info',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
