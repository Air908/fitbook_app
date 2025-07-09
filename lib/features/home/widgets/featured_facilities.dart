import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

          final imageUrl = (facility.images?.isNotEmpty ?? false)
              ? facility.images!.first
              : null;

          final facilityName = facility.name ?? 'Unnamed Facility';
          final location = facility.location ?? 'Unknown Location';

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
                    // Facility Image or Placeholder
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: imageUrl != null
                            ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageError(),
                        )
                            : _buildImageError(),
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
                              facilityName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        FontAwesomeIcons.triangleExclamation,
        color: Colors.redAccent,
        size: 32,
      ),
    );
  }
}
