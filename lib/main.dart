import 'package:fitbook/core/config/environment.dart';
import 'package:fitbook/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/facilities/bloc/facility_bloc.dart';
import 'features/facilities/screens/facility_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Environment.supabaseUrl, // 🔁 Replace with your project URL
    anonKey: Environment.supabaseAnonKey, // 🔁 Replace with your anon key
  );

  runApp(const FitBookApp());
}

class FitBookApp extends StatelessWidget {
  const FitBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FacilityBloc()..add(LoadFacilities())),
        // Add more blocs here (e.g., AuthBloc, BookingBloc)
      ],
      child: MaterialApp(
        title: 'FitBook - Facility Booking App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const LoginScreen(), // Set your entry screen
      ),
    );
  }
}
