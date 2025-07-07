enum AdminAlertType {
  facilityApproval,
  paymentIssue,
  systemUpdate,
}

class AdminAlert {
  final String id;
  final String title;
  final String message;
  final AdminAlertType type;
  final DateTime timestamp;

  AdminAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory AdminAlert.fromJson(Map<String, dynamic> json) {
    return AdminAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: AdminAlertType.values.firstWhere((type) => type.name == json['type']),
      timestamp: DateTime.parse(json['timestamp']));
  }

}

// models/admin_stats.dart
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
