import 'package:fitbook/core/routers/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/AppPreferences.dart';
import '../../profile/screens/profile_screen.dart';

class SubAdminDashboardScreen extends StatelessWidget {
  const SubAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("Sub Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AppPreferences.clear();
              Get.offAllNamed(AppRoutes.login);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 16),
            _buildGridCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(radius: 30, backgroundColor: Colors.white),
                SizedBox(height: 12),
                Text('Sub Admin', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Get.to(() =>  ProfileScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Manage Listings'),
            onTap: () => Get.toNamed('/subadmin/listings'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('View Bookings'),
            onTap: () => Get.toNamed('/subadmin/bookings'),
          ),
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text('Analytics'),
            onTap: () => Get.toNamed('/subadmin/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Withdrawals'),
            onTap: () => Get.toNamed('/subadmin/withdrawals'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.indigoAccent],
        ),
      ),
      child: const Text(
        "Welcome Sub Admin! Manage your listings, bookings, and earnings here.",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildGridCards(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem("Manage Listings", Icons.store, '/subadmin/listings'),
      _DashboardItem("Bookings", Icons.calendar_month, '/subadmin/bookings'),
      _DashboardItem("Analytics", Icons.bar_chart, '/subadmin/analytics'),
      _DashboardItem("Withdrawals", Icons.money, '/subadmin/withdrawals'),
      _DashboardItem("User Queries", Icons.support_agent, '/subadmin/queries'),
      _DashboardItem("Add Services", Icons.add_business, '/subadmin/add-service'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: items.map((item) => _buildCardItem(context, item)).toList(),
    );
  }

  Widget _buildCardItem(BuildContext context, _DashboardItem item) {
    return InkWell(
      onTap: () => Get.toNamed(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: Colors.indigo, size: 36),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final String route;

  _DashboardItem(this.title, this.icon, this.route);
}
