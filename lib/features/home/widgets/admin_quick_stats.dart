import 'package:flutter/material.dart';
import '../../admin/bloc/admin_bloc.dart';
import '../../home/screens/home_screen.dart';
import '../models/admin_alert.dart';

class AdminQuickStats extends StatelessWidget {
  final AdminStats? stats;
  final Function(AdminStatType) onStatsCardTap;

  const AdminQuickStats({
    super.key,
    this.stats,
    required this.onStatsCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(context, 'Users', stats!.totalUsers.toString()??"0", AdminStatType.users),
        _buildStatCard(context, 'Facilities', stats!.totalFacilities.toString()??"0", AdminStatType.facilities),
        _buildStatCard(context, 'Bookings', stats!.totalBookings.toString()??"0", AdminStatType.bookings),
        _buildStatCard(context, 'Revenue', '₹${stats?.totalRevenue??"0"}', AdminStatType.revenue),
      ],
    );
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
