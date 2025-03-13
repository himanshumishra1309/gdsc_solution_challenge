import 'package:flutter/material.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';

class CoachViewCoachingStaffsAssigned extends StatefulWidget {
  const CoachViewCoachingStaffsAssigned({super.key});

  @override
  _CoachViewCoachingStaffsAssignedState createState() => _CoachViewCoachingStaffsAssignedState();
}

class _CoachViewCoachingStaffsAssignedState extends State<CoachViewCoachingStaffsAssigned> {
  String _searchQuery = '';
  String _selectedSport = 'All Sports';
  final List<String> _sports = ['All Sports', 'Football', 'Basketball', 'Cricket', 'Badminton', 'Tennis'];
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _filteredPlayers = [];
  String _selectedDrawerItem = viewCoachingStaffsAssignedRoute; // Use route for selection

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    _players = [
      {
        'name': 'John Doe',
        'sport': 'Football',
        'profilePic': 'assets/images/player6.png',
        'coachingStaff': {
          'Head Coach': 'Coach A',
          'Assistant Coach': 'Coach B',
          'Medical Staff': 'Dr. C',
          'Gym Trainer': 'Trainer D',
        },
      },
      {
        'name': 'Jane Smith',
        'sport': 'Basketball',
        'profilePic': 'assets/images/player2.jpg',
        'coachingStaff': {
          'Head Coach': 'Coach E',
          'Assistant Coach': 'Coach F',
          'Medical Staff': 'Dr. G',
          'Gym Trainer': 'Trainer H',
        },
      },
      {
        'name': 'Alice Johnson',
        'sport': 'Cricket',
        'profilePic': 'assets/images/player3.jpg',
        'coachingStaff': {
          'Head Coach': 'Coach I',
          'Assistant Coach': 'Coach J',
          'Medical Staff': 'Dr. K',
          'Gym Trainer': 'Trainer L',
        },
      },
      {
        'name': 'Bob Brown',
        'sport': 'Badminton',
        'profilePic': 'assets/images/player4.jpg',
        'coachingStaff': {
          'Head Coach': 'Coach M',
          'Assistant Coach': 'Coach N',
          'Medical Staff': 'Dr. O',
          'Gym Trainer': 'Trainer P',
        },
      },
      {
        'name': 'Eva Garcia',
        'sport': 'Tennis',
        'profilePic': 'assets/images/player5.jpg',
        'coachingStaff': {
          'Head Coach': 'Coach Q',
          'Assistant Coach': 'Coach R',
          'Medical Staff': 'Dr. S',
          'Gym Trainer': 'Trainer T',
        },
      },
      {
        'name': 'Michael Wilson',
        'sport': 'Football',
        'profilePic': 'assets/images/player1.jpg',
        'coachingStaff': {
          'Head Coach': 'Coach U',
          'Assistant Coach': 'Coach V',
          'Medical Staff': 'Dr. W',
          'Gym Trainer': 'Trainer X',
        },
      },
    ];
    _filterPlayers();
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        final matchesName = player['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesSport = _selectedSport == 'All Sports' || player['sport'] == _selectedSport;
        return matchesName && matchesSport;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterPlayers();
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterPlayers();
    });
  }

  void _showCoachingStaffPopup(BuildContext context, Map<String, dynamic> player) {
    final coachingStaff = player['coachingStaff'];
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(player['profilePic']),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            player['sport'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Assigned Coaching Staff',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 10),
                _buildStaffInfoRow(Icons.person, 'Head Coach', coachingStaff['Head Coach']),
                _buildStaffInfoRow(Icons.person_outline, 'Assistant Coach', coachingStaff['Assistant Coach']),
                _buildStaffInfoRow(Icons.medical_services, 'Medical Staff', coachingStaff['Medical Staff']),
                _buildStaffInfoRow(Icons.fitness_center, 'Gym Trainer', coachingStaff['Gym Trainer']),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffInfoRow(IconData icon, String title, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 10),
          Column(
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
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
    }

    return shouldLogout;
  }

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
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

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('View Coaching Staffs'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 20, 
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          toolbarHeight: 65.0,
        ),
        drawer: CustomDrawer(
          selectedDrawerItem: _selectedDrawerItem,
          onSelectDrawerItem: _onSelectDrawerItem,
          drawerItems: drawerItems,
          onLogout: _handleLogout,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Players',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSport,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                              onChanged: _onSportChanged,
                              items: _sports.map((String sport) {
                                return DropdownMenuItem<String>(
                                  value: sport,
                                  child: Text(
                                    sport,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 15,
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredPlayers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No players found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = _filteredPlayers[index];
                          return GestureDetector(
                            onTap: () => _showCoachingStaffPopup(context, player),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        player['profilePic'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.person,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              _getSportIcon(player['sport']),
                                              size: 14,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              player['sport'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 14,
                                                color: Colors.deepPurple,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'View Staff',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
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

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Tennis':
        return Icons.sports_tennis;
      case 'Badminton':
        return Icons.sports_tennis; // No specific badminton icon
      default:
        return Icons.sports;
    }
  }
}