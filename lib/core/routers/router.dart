import 'package:fitbook/core/routers/app_routes.dart';
import 'package:get/get.dart';
import 'package:fitbook/main.dart';
import 'package:fitbook/features/auth/screens/login_screen.dart';
import 'package:fitbook/features/auth/screens/signup_screen.dart';
import 'package:fitbook/features/home/screens/home_screen.dart';
import 'package:fitbook/features/admin/screens/admin_dashboard_screen.dart';
import 'package:fitbook/features/facilities/models/facility.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/facilities/screens/FacilityDetailsScreen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../middleware/admin_guard.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.home, page: () =>  HomeScreen()),

    // Facility details with arguments
    GetPage(
      name: AppRoutes.facilityDetails,
      page: () {
        final args = Get.arguments as Facility;
        return FacilityDetailsScreen(facility: args);
      },
    ),

    // Admin dashboard with route guard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () =>  AdminDashboardScreen(),
      middlewares: [AdminGuard()],
    ),
    GetPage(name: AppRoutes.profile, page: () =>  ProfileScreen()),
  ];
}
