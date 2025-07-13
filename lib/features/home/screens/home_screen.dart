// You can replace your existing HomeScreen with this enhanced, polished version.
// Focused on modern UI design with spacing, shadows, and better section layouts.

import 'package:fitbook/core/routers/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/AppPreferences.dart';
import '../bloc/home_controller.dart';
import '../widgets/featured_facilities.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/quick_action.dart';
import '../../admin/widgets/recent_bookings.dart';

class HomeScreen extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeController.errorMessage.isNotEmpty) {
          return _buildErrorState(context, homeController.errorMessage.value);
        }

        final role = homeController.userRole.value;

        if (role == 'admin') {
          // Defer navigation until after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          });
          // Return a temporary widget
          return const Center(child: CircularProgressIndicator());
        } else if (role=='sub_admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.subAdminDashboard);
          });
          return const Center(child: CircularProgressIndicator());
        } else if (role == 'user'){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.userHome);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.login);
          });
        }
        return const Center(child: CircularProgressIndicator());
      }),
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
            Text('Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                await AppPreferences.clear();
                Get.offAllNamed('/login');
              },
              child: const Text('Retry Login'),
            ),
          ],
        ),
      ),
    );
  }

  List<QuickActionItem> _getUserActions() => [
    QuickActionItem(
      icon: Icons.search,
      title: 'Find Facilities',
      subtitle: 'Nearby options',
      actionType: UserActionType.searchFacilities,
    ),
    QuickActionItem(
      icon: Icons.calendar_today,
      title: 'My Bookings',
      subtitle: 'Check schedule',
      actionType: UserActionType.viewBookings,
    ),
    QuickActionItem(
      icon: Icons.favorite,
      title: 'Favorites',
      subtitle: 'Saved items',
      actionType: UserActionType.viewFavorites,
    ),
    QuickActionItem(
      icon: Icons.person,
      title: 'Profile',
      subtitle: 'Edit profile',
      actionType: UserActionType.manageProfile,
    ),
  ];
}

enum UserActionType { searchFacilities, viewBookings, viewFavorites, manageProfile }
enum AdminStatType { users, facilities, bookings, revenue }
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
