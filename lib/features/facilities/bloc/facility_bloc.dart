import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/facility.dart';

// Events
abstract class FacilityEvent {}

class LoadFacilities extends FacilityEvent {}
class SearchFacilities extends FacilityEvent {
  final String query;
  SearchFacilities(this.query);
}

// States
abstract class FacilityState {}
class FacilityInitial extends FacilityState {}
class FacilityLoading extends FacilityState {}
class FacilityLoaded extends FacilityState {
  final List<Facility> facilities;
  FacilityLoaded(this.facilities);
}
class FacilityError extends FacilityState {
  final String message;
  FacilityError(this.message);
}

// Bloc
class FacilityBloc extends Bloc<FacilityEvent, FacilityState> {
  List<Facility> _allFacilities = [];

  FacilityBloc() : super(FacilityInitial()) {
    on<LoadFacilities>((event, emit) async {
      emit(FacilityLoading());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Dummy data updated to match model
        _allFacilities = List.generate(
          10,
              (index) => Facility(
            id: '$index',
            name: 'Facility $index',
            location: 'Location $index',
            description: 'Description for Facility $index',
            imageUrl: 'https://via.placeholder.com/150',
            images: [
              'https://via.placeholder.com/300x200?text=Facility+$index'
            ],
            city: 'City $index',
            state: 'State $index',
            facilityType: index % 2 == 0 ? 'gym' : 'yoga_studio',
            averageRating: 4.0 + (index % 5) * 0.1,
            totalReviews: 20 + index,
            pricingPerHour: 100 + index * 10,
          ),
        );
        emit(FacilityLoaded(_allFacilities));
      } catch (e) {
        emit(FacilityError('Failed to load facilities'));
      }
    });

    on<SearchFacilities>((event, emit) async {
      final query = event.query.toLowerCase();
      final results = _allFacilities
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
      emit(FacilityLoaded(results));
    });
  }
}
