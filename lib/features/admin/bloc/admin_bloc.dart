// admin_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends AdminEvent {}

class ApproveFacility extends AdminEvent {
  final int facilityId;

  ApproveFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class RejectFacility extends AdminEvent {
  final int facilityId;

  RejectFacility(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

// States
abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final AdminStats stats;
  final List<Facility> pendingFacilities;
  final List<Booking> recentBookings;

  AdminLoaded({
    required this.stats,
    required this.pendingFacilities,
    required this.recentBookings,
  });

  @override
  List<Object?> get props => [stats, pendingFacilities, recentBookings];
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(AdminLoading());

      // Fake delay and dummy data
      await Future.delayed(Duration(seconds: 1));

      emit(AdminLoaded(
        stats: AdminStats(
          totalUsers: 1200,
          totalFacilities: 150,
          totalBookings: 430,
          totalRevenue: 755000,
        ),
        pendingFacilities: List.generate(3, (index) => Facility(id: index, name: 'Facility $index')),
        recentBookings: List.generate(5, (index) => Booking(id: index, user: 'User $index', facility: 'Facility $index')),
      ));
    });

    on<ApproveFacility>((event, emit) {
      // Handle approval logic
    });

    on<RejectFacility>((event, emit) {
      // Handle rejection logic
    });
  }
}


// Models
class AdminStats extends Equatable {
  final int totalUsers;
  final int totalFacilities;
  final int totalBookings;
  final double totalRevenue;

  AdminStats({
    required this.totalUsers,
    required this.totalFacilities,
    required this.totalBookings,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [totalUsers, totalFacilities, totalBookings, totalRevenue];
}

class Facility extends Equatable {
  final int id;
  final String name;

  Facility({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Booking extends Equatable {
  final int id;
  final String user;
  final String facility;

  Booking({required this.id, required this.user, required this.facility});

  @override
  List<Object?> get props => [id, user, facility];
}
