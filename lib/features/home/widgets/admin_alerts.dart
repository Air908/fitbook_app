import 'package:flutter/material.dart';
import '../models/admin_alert.dart';

class AdminAlerts extends StatelessWidget {
  final List<AdminAlert> alerts;
  final Function(AdminAlert) onAlertTap;

  const AdminAlerts({
    Key? key,
    required this.alerts,
    required this.onAlertTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No alerts available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((alert) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => onAlertTap(alert),
            title: Text(
              alert.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              alert.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      }).toList(),
    );
  }
}
