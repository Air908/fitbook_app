import 'package:fitbook/core/config/environment.dart';
import 'package:fitbook/core/router.dart';
import 'package:fitbook/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart' as ab;
import 'features/facilities/bloc/facility_bloc.dart';
import 'features/facilities/screens/facility_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  runApp(const FitBookApp());
}

class FitBookApp extends StatelessWidget {
  const FitBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FacilityBloc()..add(LoadFacilities()),
        ),
        BlocProvider(
          create: (_) => AuthBloc(Supabase.instance.client)
            ..add(CheckAuthStatus()),
        ),
        // Add more blocs here (e.g., BookingBloc, UserBloc)
      ],
      child: MaterialApp(
        title: 'FitBook - Facility Booking App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // Use BlocBuilder to determine initial route based on auth state
        home: BlocBuilder<AuthBloc, ab.AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const SplashScreen();
            } else if (state is AuthAuthenticated) {
              return const FacilitySearchScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
          initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

// Simple splash screen widget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'FitBook',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}