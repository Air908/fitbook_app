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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.circleExclamation, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              'No featured facilities available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: facilities.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final facility = facilities[index];

          final imageUrl = facility.images?.isNotEmpty == true
              ? facility.images!.first
              : null;

          final name = facility.name ?? 'Unnamed Facility';
          final location = facility.location ?? 'Unknown Location';

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onFacilityTap(facility),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility Image
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImageError(),
                      )
                          : _buildImageError(),
                    ),

                    // Facility Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
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
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        FontAwesomeIcons.image,
        color: Colors.grey,
        size: 28,
      ),
    );
  }
}
