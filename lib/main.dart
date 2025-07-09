import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/environment.dart';
import 'core/theme/app_theme.dart';
import 'core/routers/router.dart';

import 'features/auth/bloc/AuthController.dart';
import 'features/facilities/bloc/facility_controller.dart';
import 'features/home/bloc/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  // Initialize GetX Controllers
  Get.put(AuthController());
  Get.put(FacilityController());
  Get.put(HomeController());

  runApp(const FitBookApp());
}

class FitBookApp extends StatelessWidget {
  const FitBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitBook - Facility Booking App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: AppPages.pages, // Must use GetX style route definitions
    );
  }
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    await Future.delayed(const Duration(seconds: 2));

    if (session != null && session.user != null) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAuth();

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
