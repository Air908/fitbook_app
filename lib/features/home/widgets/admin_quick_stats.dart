import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../admin/bloc/admin_controller.dart';
import '../../home/screens/home_screen.dart';

class AdminQuickStats extends StatelessWidget {
  final Function(AdminStatType) onStatsCardTap;

  const AdminQuickStats({super.key, required this.onStatsCardTap});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find();

    return Obx(() {
      final stats = controller.stats.value;

      if (stats == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildStatCard(context, 'Users', stats.totalUsers.toString(), AdminStatType.users),
          _buildStatCard(context, 'Facilities', stats.totalFacilities.toString(), AdminStatType.facilities),
          _buildStatCard(context, 'Bookings', stats.totalBookings.toString(), AdminStatType.bookings),
          _buildStatCard(context, 'Revenue', '₹${stats.totalRevenue.toStringAsFixed(0)}', AdminStatType.revenue),
        ],
      );
    });
  }

  Widget _buildStatCard(BuildContext context, String title, String value, AdminStatType type) {
    return InkWell(
      onTap: () => onStatsCardTap(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
