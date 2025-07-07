// features/facilities/screens/facility_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/facility_bloc.dart';
import '../models/facility.dart';
import '../widgets/facility_card.dart';
import '../widgets/search_filters.dart';

class FacilitySearchScreen extends StatefulWidget {
  const FacilitySearchScreen({Key? key}) : super(key: key);

  @override
  State<FacilitySearchScreen> createState() => _FacilitySearchScreenState();
}

class _FacilitySearchScreenState extends State<FacilitySearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FacilityBloc>().add(LoadFacilities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Facilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search facilities...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                context.read<FacilityBloc>().add(
                  SearchFacilities(query),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<FacilityBloc, FacilityState>(
              builder: (context, state) {
                if (state is FacilityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FacilityError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FacilityBloc>().add(LoadFacilities());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is FacilityLoaded) {
                  return ListView.builder(
                    itemCount: state.facilities.length,
                    itemBuilder: (context, index) {
                      return FacilityCard(
                        facility: state.facilities[index],
                        onTap: () => _navigateToDetails(state.facilities[index]),
                      );
                    },
                  );
                }

                return const Center(child: Text('No facilities found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SearchFilters(),
    );
  }

  void _navigateToDetails(Facility facility) {
    // Navigate to facility details
  }
}