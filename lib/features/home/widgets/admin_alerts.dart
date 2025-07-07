import 'package:flutter/material.dart';

import '../models/admin_alert.dart';

class AdminAlerts extends StatelessWidget {
  final List<AdminAlert> alerts;
  final Function(AdminAlert) onAlertTap;

  const AdminAlerts({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Text('No alerts available');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((alert) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => onAlertTap(alert),
            title: Text(alert!.title),
            subtitle: Text(alert!.message),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      }).toList(),
    );
  }
}
