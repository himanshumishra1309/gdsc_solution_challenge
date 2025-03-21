import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/views/player/player_home.dart';
import 'package:gdg_app/serivces/auth_service.dart';

class CoachHomePage extends StatefulWidget {
  const CoachHomePage({super.key});

  @override
  _CoachHomePageState createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  final _authService = AuthService();
  Map<String, List<dynamic>> _players = {};
  String _selectedSport = 'Cricket';
  List<dynamic> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedDrawerItem = coachHomeRoute;

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
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadPlayers();
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

  Future<void> _loadPlayers() async {
    final String response = await rootBundle.loadString('assets/json_files/players.json');
    final data = await json.decode(response);
    setState(() {
      _players = Map<String, List<dynamic>>.from(data['players']);
      _filterPlayers();
    });
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players[_selectedSport]!.where((player) {
        return player['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  void _navigateToPlayerProfile(Map<String, dynamic> player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerProfileWrapper(player: player),
      ),
    );
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
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

    // Get screen width to make layout responsive
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coach Dashboard'),
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
          child: Column(
            children: [
              // Top Search and Filter Section
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
                      'Player Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Make search row layout more responsive
                    screenWidth > 360
                        ? _buildWideSearchRow()
                        : _buildNarrowSearchColumn(),
                  ],
                ),
              ),

              // Stats Summary Section - Wrap in SingleChildScrollView for narrow screens
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _buildStatCard('Total Players', '${_filteredPlayers.length}', Icons.people, Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatCard('Active', '${(_filteredPlayers.length * 0.8).round()}', Icons.check_circle, Colors.green),
                      const SizedBox(width: 16),
                      _buildStatCard('Injured', '${(_filteredPlayers.length * 0.2).round()}', Icons.healing, Colors.orange),
                    ],
                  ),
                ),
              ),

              // Players List Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Use Flexible to prevent overflow in text
                    Flexible(
                      child: Text(
                        '$_selectedSport Players',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min, // Use minimum width
                        children: [
                          Icon(Icons.sort, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            'Sort',
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

              // Player List
              Expanded(
                child: _filteredPlayers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_kabaddi,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'No $_selectedSport players found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center, // Center align for overflow
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = _filteredPlayers[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _navigateToPlayerProfile(player),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: _buildPlayerCardContent(player, screenWidth),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // Removed the floatingActionButton property
      ),
    );
  }

  // Split search row into separate widget to handle responsively
  Widget _buildWideSearchRow() {
    return Row(
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterPlayers();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Players',
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
        _buildSportDropdown(),
      ],
    );
  }

  // For smaller screens, stack the search and dropdown vertically
  Widget _buildNarrowSearchColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterPlayers();
              });
            },
            decoration: InputDecoration(
              labelText: 'Search Players',
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
        const SizedBox(height: 12),
        _buildSportDropdown(),
      ],
    );
  }

  // Extracted dropdown to avoid duplication
  Widget _buildSportDropdown() {
    return Container(
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
          onChanged: (String? newValue) {
            setState(() {
              _selectedSport = newValue!;
              _filterPlayers();
            });
          },
          items: <String>['Cricket', 'Football', 'Badminton']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getSportIcon(value), size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(value),
                ],
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
    );
  }

  // Responsive player card content
  Widget _buildPlayerCardContent(dynamic player, double screenWidth) {
    // Simplify for small screens
    if (screenWidth < 340) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(player['profileImage']),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
          const SizedBox(height: 8),
          Text(
            player['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            player['role'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildPlayerStatsWrap(player),
        ],
      );
    }
    
    // Standard layout for larger screens
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.deepPurple.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(player['profileImage']),
            onBackgroundImageError: (exception, stackTrace) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                player['role'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildPlayerStatsWrap(player),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  // Changed Row to Wrap for stats to handle overflow
  Widget _buildPlayerStatsWrap(Map<String, dynamic> player) {
    List<Widget> stats = [];
    
    if (player['role'] == 'Batsman' || player['role'] == 'All-rounder') {
      stats.add(_buildStatBadge('Avg: 42.5', Icons.area_chart));
    }
    
    if (player['role'] == 'Bowler' || player['role'] == 'All-rounder') {
      stats.add(_buildStatBadge('Wickets: 32', Icons.sports_cricket));
    }
    
    stats.add(_buildStatBadge('Matches: 24', Icons.calendar_today));
    
    return Wrap(
      spacing: 8, // gap between adjacent stats
      runSpacing: 8, // gap between lines
      children: stats,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 110, // Fixed width to prevent differences in size
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.deepPurple),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerProfileWrapper extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerProfileWrapper({required this.player, super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(player['name']),
          backgroundColor: Colors.deepPurple,
        ),
        body: PlayerHome(), // Use the player's home page
      ),
    );
  }
}