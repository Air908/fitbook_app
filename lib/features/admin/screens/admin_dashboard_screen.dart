// features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bloc/admin_controller.dart';
import '../widgets/facility_approval_list.dart';
import '../widgets/recent_bookings.dart';
import '../widgets/stats_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  AdminDashboardScreen({Key? key}) : super(key: key);

  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  StatsCard(
                    title: 'Total Users',
                    value: controller.stats.value?.totalUsers.toString()??"0",
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  StatsCard(
                    title: 'Total Facilities',
                    value: controller.stats.value?.totalFacilities.toString()??"0",
                    icon: Icons.business,
                    color: Colors.green,
                  ),
                  StatsCard(
                    title: 'Total Bookings',
                    value: controller.stats.value?.totalBookings.toString()??"0",
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                  ),
                  StatsCard(
                    title: 'Revenue',
                    value: '₹${controller.stats.value?.totalRevenue.toStringAsFixed(0)??"0"}',
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pending Facility Approvals
              Text(
                'Pending Facility Approvals',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              FacilityApprovalList(
                facilities: controller.pendingFacilities,
                onApprove: (facility) {
                  controller.approveFacility(facility?.id ?? "");
                },
                onReject: (facility) {
                  controller.rejectFacility(facility?.id ?? "");
                },
              ),

              const SizedBox(height: 24),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              RecentBookings(bookings: controller.recentBookings),
            ],
          ),
        );
      }),
    );
  }
}
