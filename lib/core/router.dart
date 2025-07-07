// lib/core/router.dart
import 'package:fitbook/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fitbook/features/auth/screens/login_screen.dart';
import 'package:fitbook/features/auth/screens/signup_screen.dart';

import '../features/facilities/screens/facility_search_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const FacilitySearchScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
