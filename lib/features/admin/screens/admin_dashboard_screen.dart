import 'package:fitbook/core/routers/app_routes.dart';
import 'package:fitbook/core/theme/appString.dart';
import 'package:fitbook/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/AppPreferences.dart';
import '../../profile/screens/profile_screen.dart';
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
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AppPreferences.clear();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 30, backgroundColor: AppColors.white),
                  SizedBox(height: 12),
                  Text('Super Admin', style: TextStyle(color: AppColors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Get.to(() => ProfileScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Customer Support'),
              onTap: () => Get.toNamed('/admin/support'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Withdrawal Requests'),
              onTap: () => Get.toNamed('/admin/withdrawals'),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatsCard(
                      title: AppStrings.totalUsers,
                      value: '${controller.stats.value?.totalUsers ?? 0}',
                      icon: Icons.people,
                      color: AppColors.primaryBlue,
                    ),
                    StatsCard(
                      title: AppStrings.totalFacilities,
                      value: '${controller.stats.value?.totalFacilities ?? 0}',
                      icon: Icons.business,
                      color: AppColors.secondaryGreen,
                    ),
                    StatsCard(
                      title: AppStrings.totalBookings,
                      value: '${controller.stats.value?.totalBookings ?? 0}',
                      icon: Icons.calendar_today,
                      color: AppColors.warning,
                    ),
                    StatsCard(
                      title: AppStrings.revenue,
                      value: '₹${controller.stats.value?.totalRevenue.toStringAsFixed(0) ?? '0'}',
                      icon: Icons.monetization_on,
                      color: AppColors.secondaryPurple,
                    ),
                    StatsCard(
                      title: AppStrings.totalVendors,
                      value: '${controller.stats.value?.totalUsers ?? 0}',
                      icon: Icons.store,
                      color: AppColors.secondaryTeal,
                    ),
                    StatsCard(
                      title: AppStrings.totalCustomers,
                      value: '${controller.stats.value?.totalUsers ?? 0}',
                      icon: Icons.person_outline,
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(AppStrings.pendingApprovals, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                FacilityApprovalList(
                  facilities: controller.pendingFacilities,
                  onApprove: (f) => controller.approveFacility(f?.id ?? ''),
                  onReject: (f) => controller.rejectFacility(f?.id ?? ''),
                ),
                const SizedBox(height: 24),
                Text(AppStrings.recentBookings, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                RecentBookings(bookings: controller.recentBookings),
              ],
            ),
          ),
        );
      }),
    );
  }
}
