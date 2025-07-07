class Booking {
  final String id;
  final String facilityId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String bookingType;
  final double totalAmount;
  final String status;

  Booking({
    required this.id,
    required this.facilityId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.bookingType,
    required this.totalAmount,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      facilityId: json['facility_id'].toString(),
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      bookingType: json['booking_type'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': facilityId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'booking_type': bookingType,
      'total_amount': totalAmount,
      'status': status,
    };
  }
}
