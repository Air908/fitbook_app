import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/AppPreferences.dart';
import '../../admin/widgets/recent_bookings.dart';
import '../models/admin_alert.dart';
import '../widgets/admin_alerts.dart';
import '../widgets/admin_quick_stats.dart';
import '../widgets/featured_facilities.dart';
import '../widgets/quick_action.dart';
import '../widgets/user_profile_header.dart';
import '../bloc/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.errorMessage.isNotEmpty) {
          return _buildErrorState(context, homeController.errorMessage.value);
        }

        switch (homeController.userRole.value) {
          case 'admin':
            return _buildAdminHome(context);
          case 'user':
            return _buildUserHome(context);
          default:
            return _buildUserHome(context);
        }
      }),
    );
  }

  Widget _buildAdminHome(BuildContext context) {
    return RefreshIndicator(
      onRefresh: homeController.refreshHomeData,
      child: CustomScrollView(
        slivers: [
          _buildAdminAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminQuickStats(
                    onStatsCardTap: _navigateToAdminSection,
                  ),
                  const SizedBox(height: 24),
                  AdminAlerts(
                    alerts: homeController.adminAlerts,
                    onAlertTap: _handleAdminAlert,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Quick Actions'),
                  QuickActions(
                    actions: _getAdminActions(),
                    onActionTap: _handleAdminAction,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Recent Activity'),
                  RecentBookings(bookings: homeController.recentBookings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHome(BuildContext context) {
    return RefreshIndicator(
      onRefresh: homeController.refreshHomeData,
      child: CustomScrollView(
        slivers: [
          _buildUserAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserProfileHeader(
                    user: homeController.currentUser.value!,
                    onProfileTap: () => Get.toNamed('/profile'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Quick Actions'),
                  QuickActions(
                    actions: _getUserActions(),
                    onActionTap: _handleUserAction,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Featured Facilities'),
                  FeaturedFacilities(
                    facilities: homeController.featuredFacilities,
                    onFacilityTap: (facility) => Get.toNamed(
                      '/facility-details',
                      arguments: facility,
                    ),
                  ),
                  if (homeController.recentBookings.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Your Recent Bookings'),
                    RecentBookings(bookings: homeController.recentBookings),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHome(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            Text(
              'Welcome to FitBook',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Book your favorite sports facilities with ease',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Get.toNamed('/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Get.toNamed('/admin-settings'),
        ),
      ],
    );
  }

  Widget _buildUserAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Hello, ${homeController.currentUser.value?.email ?? 'User'}!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Get.toNamed('/search'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Get.toNamed('/notifications'),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // 2. Sign out from Supabase (optional but good practice)
                await Supabase.instance.client.auth.signOut();

                // 1. Clear stored user session
                await AppPreferences.init();
                await AppPreferences.clear();

                // 3. Navigate to login screen
                Get.offAllNamed('/login');
              },
              child: const Text('Retry Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _navigateToAdminSection(AdminStatType statType) {
    switch (statType) {
      case AdminStatType.users:
        Get.toNamed('/admin/users');
        break;
      case AdminStatType.facilities:
        Get.toNamed('/admin/facilities');
        break;
      case AdminStatType.bookings:
        Get.toNamed('/admin/bookings');
        break;
      case AdminStatType.revenue:
        Get.toNamed('/admin/revenue');
        break;
    }
  }

  void _handleAdminAlert(AdminAlert alert) {
    Get.toNamed('/admin/alerts', arguments: alert);
  }

  void _handleAdminAction(QuickActionItem action) {
    switch (action.actionType) {
      case AdminActionType.approveFacilities:
        Get.toNamed('/admin/facility-approvals');
        break;
      case AdminActionType.manageUsers:
        Get.toNamed('/admin/users');
        break;
      case AdminActionType.viewReports:
        Get.toNamed('/admin/reports');
        break;
      case AdminActionType.systemSettings:
        Get.toNamed('/admin/settings');
        break;
    }
  }

  void _handleUserAction(QuickActionItem action) {
    switch (action.actionType) {
      case UserActionType.searchFacilities:
        Get.toNamed('/search');
        break;
      case UserActionType.viewBookings:
        Get.toNamed('/bookings');
        break;
      case UserActionType.viewFavorites:
        Get.toNamed('/favorites');
        break;
      case UserActionType.manageProfile:
        Get.toNamed('/profile');
        break;
    }
  }

  List<QuickActionItem> _getAdminActions() => [
    QuickActionItem(
      icon: Icons.approval,
      title: 'Approve Facilities',
      subtitle: 'Review pending facilities',
      actionType: AdminActionType.approveFacilities,
    ),
    QuickActionItem(
      icon: Icons.people_outline,
      title: 'Manage Users',
      subtitle: 'User management',
      actionType: AdminActionType.manageUsers,
    ),
    QuickActionItem(
      icon: Icons.analytics,
      title: 'View Reports',
      subtitle: 'Analytics & insights',
      actionType: AdminActionType.viewReports,
    ),
    QuickActionItem(
      icon: Icons.settings,
      title: 'System Settings',
      subtitle: 'App configuration',
      actionType: AdminActionType.systemSettings,
    ),
  ];

  List<QuickActionItem> _getUserActions() => [
    QuickActionItem(
      icon: Icons.search,
      title: 'Find Facilities',
      subtitle: 'Search nearby facilities',
      actionType: UserActionType.searchFacilities,
    ),
    QuickActionItem(
      icon: Icons.calendar_today,
      title: 'My Bookings',
      subtitle: 'View your bookings',
      actionType: UserActionType.viewBookings,
    ),
    QuickActionItem(
      icon: Icons.favorite,
      title: 'Favorites',
      subtitle: 'Your saved facilities',
      actionType: UserActionType.viewFavorites,
    ),
    QuickActionItem(
      icon: Icons.person,
      title: 'Profile',
      subtitle: 'Manage your profile',
      actionType: UserActionType.manageProfile,
    ),
  ];
}

// Models & Enums
class QuickActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic actionType;

  QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionType,
  });
}

enum AdminActionType { approveFacilities, manageUsers, viewReports, systemSettings }

enum UserActionType { searchFacilities, viewBookings, viewFavorites, manageProfile }

enum AdminStatType { users, facilities, bookings, revenue }
