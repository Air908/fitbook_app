// features/home/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../booking/models/booking.dart';
import '../models/admin_alert.dart';
import '../../facilities/models/facility.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class UpdateUserRole extends HomeEvent {
  final String? role;
  const UpdateUserRole(this.role);
  @override
  List<Object?> get props => [role];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String? userRole;
  final User? currentUser;
  final List<Facility> featuredFacilities;
  final List<Booking> recentBookings;
  final AdminStats? adminStats;
  final List<AdminAlert>? adminAlerts;

  const HomeLoaded({
    required this.userRole,
    this.currentUser,
    required this.featuredFacilities,
    required this.recentBookings,
    this.adminStats,
    this.adminAlerts,
  });

  @override
  List<Object?> get props => [
    userRole,
    currentUser,
    featuredFacilities,
    recentBookings,
    adminStats,
    adminAlerts,
  ];

  HomeLoaded copyWith({
    String? userRole,
    User? currentUser,
    List<Facility>? featuredFacilities,
    List<Booking>? recentBookings,
    AdminStats? adminStats,
    List<AdminAlert>? adminAlerts,
  }) {
    return HomeLoaded(
      userRole: userRole ?? this.userRole,
      currentUser: currentUser ?? this.currentUser,
      featuredFacilities: featuredFacilities ?? this.featuredFacilities,
      recentBookings: recentBookings ?? this.recentBookings,
      adminStats: adminStats ?? this.adminStats,
      adminAlerts: adminAlerts ?? this.adminAlerts,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc Implementation
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;
  HomeBloc({required HomeService homeService})
      : _homeService = homeService,
        super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<UpdateUserRole>(_onUpdateUserRole);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event,
      Emitter<HomeState> emit,
      ) async {
    emit(HomeLoading());
    try {
      final homeData = await _homeService.getHomeData();
      emit(HomeLoaded(
        userRole: homeData.userRole,
        currentUser: homeData.currentUser,
        featuredFacilities: homeData.featuredFacilities,
        recentBookings: homeData.recentBookings,
        adminStats: homeData.adminStats,
        adminAlerts: homeData.adminAlerts,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
      RefreshHomeData event,
      Emitter<HomeState> emit,
      ) async {
    try {
      final homeData = await _homeService.getHomeData();
      if (state is HomeLoaded) {
        emit((state as HomeLoaded).copyWith(
          featuredFacilities: homeData.featuredFacilities,
          recentBookings: homeData.recentBookings,
          adminStats: homeData.adminStats,
          adminAlerts: homeData.adminAlerts,
        ));
      }
    } catch (_) {}
  }

  Future<void> _onUpdateUserRole(
      UpdateUserRole event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(userRole: event.role));
      add(LoadHomeData());
    }
  }
}

// Service
class HomeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<HomeData> getHomeData() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      return HomeData(
        userRole: 'guest',
        currentUser: null,
        featuredFacilities: [],
        recentBookings: [],
      );
    }

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', supabaseUser.id)
        .single();

    final user = User.fromJson(response)!;
    final role = user.role?.toLowerCase() ?? 'user';

    return role == 'admin'
        ? await _getAdminHomeData(user)
        : await _getUserHomeData(user);
  }

  Future<HomeData> _getAdminHomeData(User user) async {
    return HomeData(
      userRole: user.role,
      currentUser: user,
      featuredFacilities: await _fetchFeaturedFacilities(),
      recentBookings: await _fetchRecentBookings(user.id),
      adminStats: await _fetchAdminStats(),
      adminAlerts: await _fetchAdminAlerts(),
    );
  }

  Future<HomeData> _getUserHomeData(User user) async {
    return HomeData(
      userRole: user.role,
      currentUser: user,
      featuredFacilities: await _fetchFeaturedFacilities(),
      recentBookings: await _fetchRecentBookings(user.id),
    );
  }

  Future<List<Facility>> _fetchFeaturedFacilities() async {
    final response = await _supabase
        .from('facilities')
        .select()
        .eq('is_featured', true)
        .eq('is_active', true);

    return (response as List).map((f) => Facility.fromJson(f)).toList();
  }

  Future<List<Booking>> _fetchRecentBookings(String userId) async {
    final response = await _supabase
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('booking_date', ascending: false)
        .limit(5);

    return (response as List).map((b) => Booking.fromJson(b)).toList();
  }

  Future<AdminStats> _fetchAdminStats() async {
    final users = await _supabase.from('users').select('id');
    final facilities = await _supabase.from('facilities').select('id');
    final bookings = await _supabase.from('bookings').select('id');

    return AdminStats(
      totalUsers: users.length,
      totalFacilities: facilities.length,
      totalBookings: bookings.length,
      totalRevenue: 0.0,
      pendingApprovals: 0,
      activeUsers: users.length,
    );
  }

  Future<List<AdminAlert>> _fetchAdminAlerts() async {
    final response = await _supabase
        .from('admin_alerts')
        .select()
        .order('timestamp', ascending: false);

    return (response as List).map((a) => AdminAlert.fromJson(a)).toList();
  }
}

// Data Holder
class HomeData {
  final String? userRole;
  final User? currentUser;
  final List<Facility> featuredFacilities;
  final List<Booking> recentBookings;
  final AdminStats? adminStats;
  final List<AdminAlert>? adminAlerts;

  HomeData({
    required this.userRole,
    this.currentUser,
    required this.featuredFacilities,
    required this.recentBookings,
    this.adminStats,
    this.adminAlerts,
  });
}
