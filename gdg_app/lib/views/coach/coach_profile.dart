import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class CoachProfile extends StatefulWidget {
  const CoachProfile({super.key});

  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  final _authService = AuthService();
  String _selectedDrawerItem = coachProfileRoute;

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
  try {
    final userData = await _authService.getCurrentUser();
    
    if (userData.isNotEmpty) {
      setState(() {
        _userName = userData['name'] ?? "Coach";
        _userEmail = userData['email'] ?? "";
        _userAvatar = userData['avatar'];
      });
    }
  } catch (e) {
    debugPrint('Error loading user info: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.people, title: 'View all players', route: coachHomeRoute),
      DrawerItem(icon: Icons.announcement, title: 'Make announcement', route: coachMakeAnAnnouncementRoute),
      DrawerItem(icon: Icons.schedule, title: 'Mark upcoming sessions', route: coachMarkSessionRoute),
      DrawerItem(icon: Icons.schedule, title: 'View Coaching Staffs Assigned', route: viewCoachingStaffsAssignedRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Medical records', route: coachViewPlayerMedicalReportRoute),
      DrawerItem(icon: Icons.person, title: 'View Profile', route: coachProfileRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Profile'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Edit profile action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile action'),
                  backgroundColor: Colors.deepPurple,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: _onSelectDrawerItem,
        drawerItems: drawerItems,
        onLogout: _handleLogout,
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header with Background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/coach_profile.jpg'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Coach John Smith',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Head Cricket Coach',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn('Experience', '10 years'),
                          _buildDivider(),
                          _buildStatColumn('Players', '42'),
                          _buildDivider(),
                          _buildStatColumn('Teams', '3'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _buildInfoItem(Icons.person, 'Full Name', 'John Michael Smith'),
                      _buildInfoItem(Icons.email, 'Email Address', 'john.smith@sportacademy.com'),
                      _buildInfoItem(Icons.cake, 'Date of Birth', 'January 15, 1985'),
                      _buildInfoItem(Icons.male, 'Gender', 'Male'),
                      _buildInfoItem(Icons.flag, 'Nationality', 'American'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _buildInfoItem(Icons.phone, 'Phone Number', '+1 234 567 890'),
                      _buildInfoItem(Icons.location_on, 'Country', 'United States'),
                      _buildInfoItem(Icons.location_city, 'State', 'California'),
                      _buildInfoItem(Icons.home, 'Address', '123 Main St, Los Angeles, CA'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Professional Information
              _buildSectionHeader('Professional Background'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _buildInfoItem(Icons.timeline, 'Years of Experience', '10 years'),
                      _buildInfoItem(Icons.sports_cricket, 'Specialization', 'Cricket Bowling, Fielding Strategy'),
                      _buildCertificationsItem([
                        'ICC Level 3 Cricket Coaching',
                        'Sports Nutrition Certified',
                        'First Aid & CPR'
                      ]),
                      _buildOrganizationsItem([
                        'XYZ Sports Club (2015-2020)',
                        'ABC Cricket Academy (2010-2015)',
                        'National Junior Team (2008-2010)'
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Achievements Section
              _buildSectionHeader('Achievements'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAchievementItem('🏆 Regional Championship Winner 2019'),
                      _buildAchievementItem('🏅 Coach of the Year 2018'),
                      _buildAchievementItem('🥇 National Training Excellence Award'),
                      _buildAchievementItem('📊 Developed 5 players to national team'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Additional Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildActionButton(
                      'Change Password',
                      Icons.lock,
                      () {
                        // Change password action
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      'Download Profile as PDF',
                      Icons.download,
                      () {
                        // Download profile action
                      },
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 4,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsItem(List<String> certifications) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.deepPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Certifications & Licenses',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                ...certifications.map((cert) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              cert,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationsItem(List<String> organizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business,
              color: Colors.deepPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous Coaching Organizations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                ...organizations.map((org) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              org,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        achievement,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, {Color color = Colors.deepPurple}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}