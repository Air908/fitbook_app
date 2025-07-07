// models/facility.dart

class Facility {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl; // Deprecated in favor of images
  final List<String> images;
  final String city;
  final String state;
  final String facilityType;
  final double averageRating;
  final int totalReviews;
  final double pricingPerHour;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.city,
    required this.state,
    required this.facilityType,
    required this.averageRating,
    required this.totalReviews,
    required this.pricingPerHour,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      facilityType: json['facility_type'] ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      pricingPerHour: (json['pricing_per_hour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'images': images,
      'city': city,
      'state': state,
      'facility_type': facilityType,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'pricing_per_hour': pricingPerHour,
    };
  }
}