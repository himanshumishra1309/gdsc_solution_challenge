import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewCoach extends StatefulWidget {
  const ViewCoach({super.key});

  @override
  _ViewCoachState createState() => _ViewCoachState();
}

class _ViewCoachState extends State<ViewCoach> {
  final _authService = AuthService();
// Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;
  String _selectedDrawerItem = viewCoachProfileRoute;
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  List<Map<String, String>> _coaches = [
    {
      'name': 'John Doe',
      'sport': 'Football',
      'image': 'assets/images/player1.png',
      'position': 'Head Coach',
      'email': 'john.doe@example.com',
      'dob': 'January 1, 1980',
      'gender': 'Male',
      'nationality': 'American',
      'phone': '+1 234 567 890',
      'country': 'USA',
      'state': 'California',
      'address': '123 Main St, Los Angeles, CA',
      'experience': '10',
      'certifications': 'Certified Professional Coach',
      'previousOrganizations': 'XYZ Sports Club, ABC Academy',
    },
    {
      'name': 'Jane Smith',
      'sport': 'Basketball',
      'image': 'assets/images/player2.jpg',
      'position': 'Assistant Coach',
      'email': 'jane.smith@example.com',
      'dob': 'February 2, 1985',
      'gender': 'Female',
      'nationality': 'Canadian',
      'phone': '+1 987 654 321',
      'country': 'Canada',
      'state': 'Ontario',
      'address': '456 Maple St, Toronto, ON',
      'experience': '8',
      'certifications': 'Certified Basketball Coach',
      'previousOrganizations': 'ABC Basketball Club, DEF Academy',
    },
    {
      'name': 'Alice Johnson',
      'sport': 'Tennis',
      'image': 'assets/images/player3.jpg',
      'position': 'Tennis Coach',
      'email': 'alice.johnson@example.com',
      'dob': 'March 3, 1990',
      'gender': 'Female',
      'nationality': 'British',
      'phone': '+44 123 456 789',
      'country': 'UK',
      'state': 'London',
      'address': '789 Elm St, London, UK',
      'experience': '6',
      'certifications': 'Certified Tennis Coach',
      'previousOrganizations': 'GHI Tennis Club, JKL Academy',
    },
    {
      'name': 'Bob Brown',
      'sport': 'Cricket',
      'image': 'assets/images/player4.png',
      'position': 'Cricket Coach',
      'email': 'bob.brown@example.com',
      'dob': 'April 4, 1975',
      'gender': 'Male',
      'nationality': 'Australian',
      'phone': '+61 987 654 321',
      'country': 'Australia',
      'state': 'New South Wales',
      'address': '101 Pine St, Sydney, NSW',
      'experience': '12',
      'certifications': 'Certified Cricket Coach',
      'previousOrganizations': 'MNO Cricket Club, PQR Academy',
    },
    // ... other coach data
  ];
  List<Map<String, String>> _filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _filteredCoaches = _coaches;
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Athlete";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  void _filterCoaches() {
    setState(() {
      _filteredCoaches = _coaches.where((coach) {
        return (coach['name']!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                coach['sport']!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())) &&
            (_selectedSport == 'All Sports' ||
                coach['sport'] == _selectedSport);
      }).toList();
    });
  }

  void _showCoachInfo(Map<String, String> coach) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Header background with coach sport as background color
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getSportColor(coach['sport']!),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Coach avatar
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(coach['image']!),
                        backgroundColor: Colors.grey.shade200,
                        radius: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Coach name and position
                    Text(
                      coach['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getSportColor(coach['sport']!).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getSportColor(coach['sport']!),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        coach['position']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getSportColor(coach['sport']!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Coach details in scrollable container
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Personal Information'),
                              _buildInfoRow(Icons.email, 'Email Address',
                                  coach['email']!),
                              _buildInfoRow(
                                  Icons.cake, 'Date of Birth', coach['dob']!),
                              _buildInfoRow(
                                  Icons.person, 'Gender', coach['gender']!),
                              _buildInfoRow(Icons.flag, 'Nationality',
                                  coach['nationality']!),
                              const SizedBox(height: 16),
                              _buildSectionHeader('Contact Information'),
                              _buildInfoRow(
                                  Icons.phone, 'Phone Number', coach['phone']!),
                              _buildInfoRow(Icons.location_on, 'Country',
                                  coach['country']!),
                              _buildInfoRow(Icons.location_city, 'State',
                                  coach['state']!),
                              _buildInfoRow(
                                  Icons.home, 'Address', coach['address']!),
                              const SizedBox(height: 16),
                              _buildSectionHeader('Professional Background'),
                              _buildInfoRow(Icons.timeline, 'Experience',
                                  '${coach['experience']!} years'),
                              _buildInfoRow(Icons.school, 'Certifications',
                                  coach['certifications']!),
                              _buildInfoRow(
                                  Icons.business,
                                  'Previous Organizations',
                                  coach['previousOrganizations']!),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Show message feature
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Message feature coming soon!'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.message),
                                  label: const Text('Contact Coach'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSportColor(String sport) {
    switch (sport) {
      case 'Football':
        return Colors.green.shade700;
      case 'Basketball':
        return Colors.orange.shade700;
      case 'Tennis':
        return Colors.yellow.shade700;
      case 'Cricket':
        return Colors.blue.shade700;
      default:
        return Colors.deepPurple;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 100,
          color: Colors.deepPurple.shade200,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          icon: Icons.show_chart, title: 'Graphs', route: playerHomeRoute),
      DrawerItem(
          icon: Icons.people,
          title: 'View Coaches',
          route: viewCoachProfileRoute),
      DrawerItem(
          icon: Icons.bar_chart,
          title: 'View Stats',
          route: viewPlayerStatisticsRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'View Medical Reports',
          route: medicalReportRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'View Nutritional Plan',
          route: nutritionalPlanRoute),
      DrawerItem(
          icon: Icons.announcement,
          title: 'View Announcements',
          route: playerviewAnnouncementRoute),
      DrawerItem(
          icon: Icons.calendar_today,
          title: 'View Calendar',
          route: viewCalendarRoute),
      DrawerItem(
          icon: Icons.fitness_center,
          title: 'View Gym Plan',
          route: viewGymPlanRoute),
      // DrawerItem(
      //     icon: Icons.edit,
      //     title: 'Fill Injury Form',
      //     route: fillInjuryFormRoute),
      DrawerItem(
          icon: Icons.attach_money,
          title: 'Finances',
          route: playerFinancialViewRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaches'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: drawerItems,
        onLogout: () => _handleLogout(),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search and filter container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Your Coach',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _filterCoaches();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search by name or sport',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.deepPurple),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSport,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.deepPurple),
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 14),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedSport = newValue!;
                                  _filterCoaches();
                                });
                              },
                              items: <String>[
                                'All Sports',
                                'Football',
                                'Basketball',
                                'Tennis',
                                'Cricket'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Results summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredCoaches.length} coaches found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedSport = 'All Sports';
                          _filterCoaches();
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Coach cards grid
              Expanded(
                child: _filteredCoaches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No coaches found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredCoaches.length,
                        itemBuilder: (context, index) {
                          final coach = _filteredCoaches[index];
                          return GestureDetector(
                            onTap: () => _showCoachInfo(coach),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Coach sport indicator
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getSportColor(coach['sport']!),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        // Coach image
                                        CircleAvatar(
                                          backgroundImage:
                                              AssetImage(coach['image']!),
                                          radius: 40,
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                        const SizedBox(height: 12),
                                        // Coach name
                                        Text(
                                          coach['name']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Coach position
                                        Text(
                                          coach['position']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Sport badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                _getSportColor(coach['sport']!)
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _getSportColor(
                                                      coach['sport']!)
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            coach['sport']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getSportColor(
                                                  coach['sport']!),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
