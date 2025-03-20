import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/serivces/auth_service.dart'; 
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gdg_app/serivces/admin_services.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _organizationStats = {
    'adminCount': 0,
    'coachCount': 0,
    'athleteCount': 0,
    'sponsorCount': 0,
  };

  @override
void initState() {
  super.initState();
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  _animationController.forward();
  
  // Fetch organization stats when the page loads
  _fetchOrganizationStats();
}

// Add a method to fetch the stats:
Future<void> _fetchOrganizationStats() async {
  setState(() => _isLoading = true);
  
  try {
    final result = await _adminService.getOrganizationStats();
    
    if (result['success']) {
      setState(() {
        _organizationStats = result['stats'];
      });
    } else {
      // Show error if stats fetch failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load organization statistics')),
        );
      }
    }
  } catch (e) {
    // Handle unexpected errors
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Simple demo data
  final Map<String, dynamic> _dashboardData = {
    'playerCount': 126,
    'coachCount': 24,
    'sponsorCount': 14,
    'upcomingEvents': 5,
    'recentActivity': [
      {'action': 'Player Registration', 'name': 'Michael Johnson', 'time': '2 hours ago', 'icon': Icons.person_add, 'color': Colors.blue},
      {'action': 'Coach Added', 'name': 'Sarah Williams', 'time': '1 day ago', 'icon': Icons.sports, 'color': Colors.green},
      {'action': 'Video Uploaded', 'name': 'Coach David', 'time': '3 days ago', 'icon': Icons.video_library, 'color': Colors.orange},
    ],
  };

  void _handleLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              setState(() => _isLoading = true);
              
              // Call the auth service logout method
              final success = await _authService.logout();
              
              setState(() => _isLoading = false);
              
              if (success && mounted) {
                // Navigate to landing page after successful logout
                Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
              } else {
                // Show error if logout failed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout failed. Please try again.')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
  // Show logout confirmation dialog when back button is pressed
  final shouldPop = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
  
  if (shouldPop == true) {
    // Show loading indicator
    setState(() => _isLoading = true);
    
    // Call the auth service logout method
    final success = await _authService.logout();
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      // Navigate to landing page after successful logout
      Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
    }
  }
  
  // Prevent default back button behavior
  return false;
},
    child: Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: adminHomeRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(icon: Icons.home, title: 'Admin Home', route: adminHomeRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Admin', route: registerAdminRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Coach', route: registerCoachRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Player', route: registerPlayerRoute),
          DrawerItem(icon: Icons.people, title: 'View All Players', route: viewAllPlayersRoute),
          DrawerItem(icon: Icons.people, title: 'View All Coaches', route: viewAllCoachesRoute),
          DrawerItem(icon: Icons.request_page, title: 'Request/View Sponsors', route: requestViewSponsorsRoute),
          DrawerItem(icon: Icons.video_library, title: 'Video Analysis', route: videoAnalysisRoute),
          DrawerItem(icon: Icons.edit, title: 'Edit Forms', route: editFormsRoute),
          DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
        ],
        onLogout: () => _handleLogout(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchOrganizationStats();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildQuickActions(),
                    _buildStatCards(),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
    )
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          AnimationLimiter(
            child: Row(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildActionButton(
                    icon: Icons.person_add,
                    label: 'Register Player',
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, registerPlayerRoute),
                  ),
                  _buildActionButton(
                    icon: Icons.sports,
                    label: 'Register Coach',
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, registerCoachRoute),
                  ),
                  _buildActionButton(
                    icon: Icons.video_call,
                    label: 'Upload Video',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, videoAnalysisRoute),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStatCard(
              title: 'Players',
              value: _organizationStats['athleteCount'].toString(),
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Coaches',
              value: _organizationStats['coachCount'].toString(),
              icon: Icons.sports_outlined,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildStatCard(
              title: 'Admins',
              value: _organizationStats['adminCount'].toString(),
              icon: Icons.admin_panel_settings_outlined,
              color: Colors.red,
            ),
            _buildStatCard(
              title: 'Sponsors',
              value: _organizationStats['sponsorCount'].toString(),
              icon: Icons.handshake_outlined,
              color: Colors.amber,
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dashboardData['recentActivity'].length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 70,
              ),
              itemBuilder: (context, index) {
                final activity = _dashboardData['recentActivity'][index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: activity['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity['icon'],
                      color: activity['color'],
                      size: 22,
                    ),
                  ),
                  title: Text(
                    activity['action'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '${activity['name']} • ${activity['time']}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}