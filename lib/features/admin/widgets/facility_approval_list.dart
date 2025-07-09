import 'package:flutter/material.dart';
import '../../facilities/models/facility.dart';
import '../bloc/admin_controller.dart'; // Make sure the Facility model is accessible

class FacilityApprovalList extends StatelessWidget {
  final List<Facility> facilities;
  final void Function(Facility) onApprove;
  final void Function(Facility) onReject;

  const FacilityApprovalList({
    super.key,
    required this.facilities,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) {
      return const Text('No facilities pending approval.');
    }

    return Column(
      children: facilities.map((facility) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.business, color: Colors.blue),
            title: Text(facility?.name??""),
            subtitle: Text('ID: ${facility.id}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => onApprove(facility),
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => onReject(facility),
                  tooltip: 'Reject',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
