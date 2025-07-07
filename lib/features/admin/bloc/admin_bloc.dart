import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../booking/models/booking.dart';
import '../../facilities/models/facility.dart';
import '../../home/models/admin_alert.dart';

// EVENTS
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends AdminEvent {}

class ApproveFacility extends AdminEvent {
  final String facilityId;

  const ApproveFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class RejectFacility extends AdminEvent {
  final String facilityId;

  const RejectFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

// STATES
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final AdminStats stats;
  final List<Facility> pendingFacilities;
  final List<Booking> recentBookings;

  const AdminLoaded({
    required this.stats,
    required this.pendingFacilities,
    required this.recentBookings,
  });

  @override
  List<Object?> get props => [stats, pendingFacilities, recentBookings];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLOC
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminBloc() : super(AdminInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<ApproveFacility>(_onApproveFacility);
    on<RejectFacility>(_onRejectFacility);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event, Emitter<AdminState> emit) async {
    emit(AdminLoading());

    try {
      final users = await _supabase.from('users').select();
      final facilities = await _supabase.from('facilities').select();
      final bookings = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      final pendingFacilities = await _supabase
          .from('facilities')
          .select()
          .eq('is_approved', false);

      emit(AdminLoaded(
        stats: AdminStats(
          totalUsers: users.length,
          totalFacilities: facilities.length,
          totalBookings: bookings.length,
          totalRevenue: 0, pendingApprovals: 0, activeUsers: 0, // TODO: fetch revenue if stored
        ),
        pendingFacilities:
        (pendingFacilities as List).map((f) => Facility.fromJson(f)).toList(),
        recentBookings:
        (bookings as List).map((b) => Booking.fromJson(b)).toList(),
      ));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveFacility(
      ApproveFacility event, Emitter<AdminState> emit) async {
    try {
      await _supabase
          .from('facilities')
          .update({'is_approved': true})
          .eq('id', event.facilityId);
      add(LoadDashboardData());
    } catch (e) {
      emit(AdminError("Failed to approve facility: ${e.toString()}"));
    }
  }

  Future<void> _onRejectFacility(
      RejectFacility event, Emitter<AdminState> emit) async {
    try {
      await _supabase
          .from('facilities')
          .delete()
          .eq('id', event.facilityId);
      add(LoadDashboardData());
    } catch (e) {
      emit(AdminError("Failed to reject facility: ${e.toString()}"));
    }
  }
}
