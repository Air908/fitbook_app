// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:fitbook/features/auth/screens/login_screen.dart';
import 'package:fitbook/features/auth/screens/signup_screen.dart';
import 'package:fitbook/features/home/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/facilities/models/facility.dart';
import '../features/facilities/screens/FacilityDetailsScreen.dart';
import '../main.dart';

class AppRouter {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // case '/profile':
      //   return MaterialPageRoute(builder: (_) => const ProfileScreen());
      //
      // case '/bookings':
      //   return MaterialPageRoute(builder: (_) => const BookingScreen());

      case '/facility-details':
        return MaterialPageRoute(builder: (_) => FacilityDetailsScreen(facility: args as Facility));

      case '/admin-dashboard':
        return MaterialPageRoute(
          builder: (_) => FutureBuilder<bool>(
            future: isAdminUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.data == true) {
                return const AdminDashboardScreen();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Unauthorized Access')),
                );
              }
            },
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
Future<bool> isAdminUser() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  final response = await Supabase.instance.client
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

  return response['role'] == 'admin';
}
