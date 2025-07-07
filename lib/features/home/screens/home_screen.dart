// features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin/widgets/recent_bookings.dart';
import '../bloc/home_bloc.dart';
import '../models/admin_alert.dart';
import '../widgets/admin_alerts.dart';
import '../widgets/admin_quick_stats.dart';
import '../widgets/featured_facilities.dart';
import '../widgets/quick_action.dart';
import '../widgets/user_profile_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeLoaded) {
            return _buildRoleBasedHome(state);
          }

          if (state is HomeError) {
            return _buildErrorState(state.message);
          }

          return const Center(child: Text('Welcome to FitBook'));
        },
      ),
    );
  }

  Widget _buildRoleBasedHome(HomeLoaded state) {
    switch (state.currentUser?.role?.toLowerCase()) {
      case "admin":
        return _buildAdminHome(state);
      case "user":
        return _buildUserHome(state);
      default:
        return _buildGuestHome();
    }
  }

  Widget _buildAdminHome(HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: CustomScrollView(
        slivers: [
          _buildAdminAppBar(state),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Quick Stats
                  AdminQuickStats(
                    stats: state.adminStats,
                    onStatsCardTap: (statType) {
                      _navigateToAdminSection(statType);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Admin Alerts
                  AdminAlerts(
                    alerts: state.adminAlerts!,
                    onAlertTap: (alert) {
                      _handleAdminAlert(alert);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Quick Admin Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickActions(
                    actions: _getAdminActions(),
                    onActionTap: (action) {
                      _handleAdminAction(action);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RecentBookings(
                    bookings: state.recentBookings,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHome(HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      child: CustomScrollView(
        slivers: [
          _buildUserAppBar(state),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Header
                  UserProfileHeader(
                    user: state.currentUser!,
                    onProfileTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuickActions(
                    actions: _getUserActions(),
                    onActionTap: (action) {
                      _handleUserAction(action);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Featured Facilities
                  Text(
                    'Featured Facilities',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FeaturedFacilities(
                    facilities: state.featuredFacilities,
                    onFacilityTap: (facility) {
                      Navigator.pushNamed(
                        context,
                        '/facility-details',
                        arguments: facility,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Bookings
                  if (state.recentBookings.isNotEmpty) ...[
                    Text(
                      'Your Recent Bookings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentBookings(
                      bookings: state.recentBookings,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to FitBook',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Book your favorite sports facilities with ease',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAppBar(HomeLoaded state) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/admin-settings');
          },
        ),
      ],
    );
  }

  Widget _buildUserAppBar(HomeLoaded state) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Hello, ${state.currentUser?.email ?? 'User'}!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<HomeBloc>().add(LoadHomeData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<QuickActionItem> _getAdminActions() {
    return [
      QuickActionItem(
        icon: Icons.approval,
        title: 'Approve Facilities',
        subtitle: 'Review pending facilities',
        actionType: AdminActionType.approveFacilities,
      ),
      QuickActionItem(
        icon: Icons.people_outline,
        title: 'Manage Users',
        subtitle: 'User management',
        actionType: AdminActionType.manageUsers,
      ),
      QuickActionItem(
        icon: Icons.analytics,
        title: 'View Reports',
        subtitle: 'Analytics & insights',
        actionType: AdminActionType.viewReports,
      ),
      QuickActionItem(
        icon: Icons.settings,
        title: 'System Settings',
        subtitle: 'App configuration',
        actionType: AdminActionType.systemSettings,
      ),
    ];
  }

  List<QuickActionItem> _getUserActions() {
    return [
      QuickActionItem(
        icon: Icons.search,
        title: 'Find Facilities',
        subtitle: 'Search nearby facilities',
        actionType: UserActionType.searchFacilities,
      ),
      QuickActionItem(
        icon: Icons.calendar_today,
        title: 'My Bookings',
        subtitle: 'View your bookings',
        actionType: UserActionType.viewBookings,
      ),
      QuickActionItem(
        icon: Icons.favorite,
        title: 'Favorites',
        subtitle: 'Your saved facilities',
        actionType: UserActionType.viewFavorites,
      ),
      QuickActionItem(
        icon: Icons.person,
        title: 'Profile',
        subtitle: 'Manage your profile',
        actionType: UserActionType.manageProfile,
      ),
    ];
  }

  void _navigateToAdminSection(AdminStatType statType) {
    switch (statType) {
      case AdminStatType.users:
        Navigator.pushNamed(context, '/admin/users');
        break;
      case AdminStatType.facilities:
        Navigator.pushNamed(context, '/admin/facilities');
        break;
      case AdminStatType.bookings:
        Navigator.pushNamed(context, '/admin/bookings');
        break;
      case AdminStatType.revenue:
        Navigator.pushNamed(context, '/admin/revenue');
        break;
    }
  }

  void _handleAdminAlert(AdminAlert alert) {
    // Handle admin alert tap
    Navigator.pushNamed(context, '/admin/alerts', arguments: alert);
  }

  void _handleAdminAction(QuickActionItem action) {
    switch (action.actionType) {
      case AdminActionType.approveFacilities:
        Navigator.pushNamed(context, '/admin/facility-approvals');
        break;
      case AdminActionType.manageUsers:
        Navigator.pushNamed(context, '/admin/users');
        break;
      case AdminActionType.viewReports:
        Navigator.pushNamed(context, '/admin/reports');
        break;
      case AdminActionType.systemSettings:
        Navigator.pushNamed(context, '/admin/settings');
        break;
    }
  }

  void _handleUserAction(QuickActionItem action) {
    switch (action.actionType) {
      case UserActionType.searchFacilities:
        Navigator.pushNamed(context, '/search');
        break;
      case UserActionType.viewBookings:
        Navigator.pushNamed(context, '/bookings');
        break;
      case UserActionType.viewFavorites:
        Navigator.pushNamed(context, '/favorites');
        break;
      case UserActionType.manageProfile:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}

// Supporting Models and Enums
class QuickActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic actionType;

  QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionType,
  });
}

enum AdminActionType {
  approveFacilities,
  manageUsers,
  viewReports,
  systemSettings,
}

enum UserActionType {
  searchFacilities,
  viewBookings,
  viewFavorites,
  manageProfile,
}

enum AdminStatType {
  users,
  facilities,
  bookings,
  revenue,
}