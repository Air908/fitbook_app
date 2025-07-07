// features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/facility_approval_list.dart';
import '../widgets/recent_bookings.dart';
import '../widgets/stats_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      StatsCard(
                        title: 'Total Users',
                        value: state.stats.totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      StatsCard(
                        title: 'Total Facilities',
                        value: state.stats.totalFacilities.toString(),
                        icon: Icons.business,
                        color: Colors.green,
                      ),
                      StatsCard(
                        title: 'Total Bookings',
                        value: state.stats.totalBookings.toString(),
                        icon: Icons.calendar_today,
                        color: Colors.orange,
                      ),
                      StatsCard(
                        title: 'Revenue',
                        value: '₹${state.stats.totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pending Facility Approvals
                  Text(
                    'Pending Facility Approvals',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  FacilityApprovalList(
                    facilities: state.pendingFacilities,
                    onApprove: (facility) {
                      context.read<AdminBloc>().add(
                        ApproveFacility(facility?.id??""),
                      );
                    },
                    onReject: (facility) {
                      context.read<AdminBloc>().add(
                        RejectFacility(facility?.id??""),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Bookings
                  Text(
                    'Recent Bookings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  RecentBookings(bookings: state.recentBookings),
                ],
              ),
            );
          }

          return const Center(child: Text('Error loading dashboard'));
        },
      ),
    );
  }
}