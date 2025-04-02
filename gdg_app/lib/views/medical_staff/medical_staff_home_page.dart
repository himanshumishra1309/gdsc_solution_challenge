import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/serivces/auth_service.dart';

class MedicalStaffHomePage extends StatefulWidget {
  const MedicalStaffHomePage({super.key});

  @override
  _MedicalStaffHomePageState createState() => _MedicalStaffHomePageState();
}

class _MedicalStaffHomePageState extends State<MedicalStaffHomePage> {
  final _authService = AuthService();
  Map<String, List<dynamic>> _players = {};
  String _selectedSport = 'Cricket';
  List<dynamic> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedDrawerItem = medicalStaffHomeRoute;

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
    final String response =
        await rootBundle.loadString('assets/json_files/players.json');
    final data = await json.decode(response);
    setState(() {
      _players = Map<String, List<dynamic>>.from(data['players']);
      _filterPlayers();
    });
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players[_selectedSport]!.where((player) {
        return player['name']
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
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
      DrawerItem(
          icon: Icons.people,
          title: 'View all players',
          route: medicalStaffHomeRoute),
      DrawerItem(
          icon: Icons.announcement,
          title: 'Make announcement',
          route: medicalStaffMakeAnAnnouncementRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Mark upcoming sessions',
          route: medicalStaffMarkSessionRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Update Medical Report',
          route: medicalStaffUpdateMedicalReportRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'View Medical records',
          route: medicalStaffViewPlayerMedicalReportRoute),
      DrawerItem(
          icon: Icons.person,
          title: 'View Profile',
          route: medicalStaffProfileRoute),
    ];

    // Get screen width to make layout responsive
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Staff Dashboard'),
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
                      _buildStatCard(
                          'Total Patients',
                          '${_filteredPlayers.length}',
                          Icons.people,
                          Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Active Cases',
                          '${(_filteredPlayers.length * 0.6).round()}',
                          Icons.medical_services,
                          Colors.green),
                      const SizedBox(width: 16),
                      _buildStatCard(
                          'Rehab Cases',
                          '${(_filteredPlayers.length * 0.4).round()}',
                          Icons.healing,
                          Colors.orange),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'No $_selectedSport players found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign
                                    .center, // Center align for overflow
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
                                child: _buildPlayerCardContent(
                                    player, screenWidth),
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
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 1),
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
                borderSide:
                    const BorderSide(color: Colors.deepPurple, width: 1),
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
                  Icon(_getSportIcon(value),
                      size: 16, color: Colors.deepPurple),
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
              Text(player['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(player['role'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 8),
              // Medical-specific stats
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatBadge('BMI: 22.5', Icons.monitor_weight),
                  _buildStatBadge(
                      player['medicalStatus'] ?? 'Fit', Icons.favorite),
                  _buildStatBadge('Last Check: 3d ago', Icons.calendar_today),
                ],
              ),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

class PlayerProfileWrapper extends StatefulWidget {
  final Map<String, dynamic> player;

  const PlayerProfileWrapper({required this.player, super.key});

  @override
  _PlayerProfileWrapperState createState() => _PlayerProfileWrapperState();
}

class _PlayerProfileWrapperState extends State<PlayerProfileWrapper>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final String _selectedSport = 'Cricket';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.player['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.player['profileImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.deepPurple.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      // Add gradient overlay for better text readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Player info overlay
                      Positioned(
                        bottom: 60,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage(widget.player['profileImage']),
                              onBackgroundImageError:
                                  (exception, stackTrace) {},
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.player['role'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildPlayerStat(
                                          Icons.sports_cricket,
                                          widget.player['nationalRanking'] ??
                                              'N/A'),
                                      const SizedBox(width: 16),
                                      _buildPlayerStat(Icons.calendar_today,
                                          '${widget.player['age'] ?? 'N/A'} years'),
                                    ],
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit player feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showPlayerOptions(context);
                    },
                  ),
                ],
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.deepPurple,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.deepPurple,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Medical'),
                      Tab(text: 'Schedule'),
                      Tab(text: 'Finances'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPerformanceTab(),
              _buildMedicalTab(),
              _buildScheduleTab(),
              _buildFinancesTab(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMedicalQuickActions(context);
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showMedicalQuickActions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Medical Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildActionItem(
            icon: Icons.medical_services,
            title: 'New Medical Checkup',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to checkup form
            },
          ),
          _buildActionItem(
            icon: Icons.healing,
            title: 'Record Injury',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to injury form
            },
          ),
          _buildActionItem(
            icon: Icons.restaurant,
            title: 'Create Nutrition Plan',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to nutrition plan form
            },
          ),
          _buildActionItem(
            icon: Icons.fitness_center,
            title: 'Rehabilitation Program',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to rehab program form
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPlayerStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Tab content implementations
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Player Information'),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Performance Summary'),
          _buildPerformanceCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Activities'),
          _buildRecentActivities(),
          const SizedBox(height: 24),
          _buildSectionTitle('Notes'),
          _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Performance Metrics'),
          _buildPerformanceMetrics(),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Matches'),
          _buildRecentMatches(),
          const SizedBox(height: 24),
          _buildSectionTitle('Training Progress'),
          _buildTrainingProgress(),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Upcoming Sessions'),
          _buildUpcomingSessions(),
          const SizedBox(height: 24),
          _buildSectionTitle('Practice Schedule'),
          _buildScheduleCalendar(),
          const SizedBox(height: 24),
          _buildSectionTitle('Team Events'),
          _buildTeamEvents(),
        ],
      ),
    );
  }

  Widget _buildFinancesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Financial Summary'),
          _buildFinancialSummary(),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Transactions'),
          _buildRecentTransactions(),
          const SizedBox(height: 24),
          _buildSectionTitle('Pending Approvals'),
          _buildPendingApprovals(),
        ],
      ),
    );
  }

  // Helper widgets for building the UI components
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Age', '${widget.player['age'] ?? 'N/A'} years'),
            const Divider(),
            _buildInfoRow('Sport', widget.player['sport'] ?? _selectedSport),
            const Divider(),
            _buildInfoRow('Position', widget.player['role'] ?? 'N/A'),
            const Divider(),
            _buildInfoRow(
                'Experience', '${widget.player['experience'] ?? 'N/A'} years'),
            const Divider(),
            _buildInfoRow(
                'National Ranking', widget.player['nationalRanking'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPerformanceMeter('Overall', 0.85, Colors.deepPurple),
            const SizedBox(height: 16),
            _buildPerformanceMeter('Batting', 0.75, Colors.blue),
            const SizedBox(height: 16),
            _buildPerformanceMeter('Bowling', 0.65, Colors.green),
            const SizedBox(height: 16),
            _buildPerformanceMeter('Fielding', 0.90, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMeter(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'title': 'Training Session',
        'description': 'Completed batting practice',
        'time': '3 hours ago',
        'icon': Icons.sports_cricket,
        'color': Colors.blue,
      },
      {
        'title': 'Fitness Test',
        'description': 'Scored 85/100 in fitness assessment',
        'time': 'Yesterday',
        'icon': Icons.fitness_center,
        'color': Colors.green,
      },
      {
        'title': 'Match',
        'description': 'Played friendly match against Team B',
        'time': '2 days ago',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(activity['description'] as String),
            trailing: Text(
              activity['time'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Coach Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    // TODO: Implement note editing
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Player shows excellent potential in batting. '
              'Needs to work on their bowling technique. '
              'Recommended to focus on fielding drills in the coming week.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Add implementations for all the UI components
  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow('Batting Average', '42.5'),
            const Divider(),
            _buildMetricRow('Strike Rate', '135.7'),
            const Divider(),
            _buildMetricRow('Bowling Economy', '6.2'),
            const Divider(),
            _buildMetricRow('Wickets Taken', '32'),
            const Divider(),
            _buildMetricRow('Catches', '12'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatches() {
    final matches = [
      {
        'opponent': 'Team Thunder',
        'date': '10-Mar-2023',
        'result': 'Won',
        'performance': 'Scored 56 runs',
      },
      {
        'opponent': 'City Strikers',
        'date': '05-Mar-2023',
        'result': 'Lost',
        'performance': '2 wickets for 25 runs',
      },
      {
        'opponent': 'Royal XI',
        'date': '28-Feb-2023',
        'result': 'Won',
        'performance': 'Man of the Match',
      },
    ];

    return Column(
      children: matches.map((match) {
        final bool isWin = match['result'] == 'Won';
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isWin ? Colors.green.shade100 : Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isWin ? 'W' : 'L',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isWin ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs ${match['opponent']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match['date'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match['performance'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrainingProgress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Training Goals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrainingGoal('Batting Drills', 4, 5),
            const SizedBox(height: 12),
            _buildTrainingGoal('Bowling Practice', 3, 5),
            const SizedBox(height: 12),
            _buildTrainingGoal('Fitness Sessions', 5, 5),
            const SizedBox(height: 12),
            _buildTrainingGoal('Video Analysis', 2, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingGoal(String label, int completed, int total) {
    final double percentage = completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$completed/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Medical Status'),
          _buildMedicalStatusCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Vital Signs'),
          _buildVitalSignsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Performance Metrics'),
          _buildPerformanceMetricsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Injury History'),
          _buildInjuryHistoryList(),
          const SizedBox(height: 24),
          _buildSectionTitle('Medical Test Results'),
          _buildMedicalTestsCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Nutrition & Hydration'),
          _buildNutritionCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Mental Health & Sleep'),
          _buildMentalHealthCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Fitness Assessment'),
          _buildFitnessAssessmentCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('Medical Clearance'),
          _buildMedicalClearanceCard(),
        ],
      ),
    );
  }

  Widget _buildMedicalStatusCard() {
    // Mock data for medical status
    final bool isInjured = false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isInjured
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInjured ? Icons.healing : Icons.check_circle,
                color: isInjured ? Colors.red : Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isInjured ? 'Currently Injured' : 'Fit to Play',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInjured ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isInjured
                        ? 'Recovery in progress. Expected return: 2 weeks'
                        : 'No current injuries or medical concerns',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow('Resting Heart Rate', '72 bpm'),
            const Divider(),
            _buildMetricRow('Blood Pressure', '120/80 mmHg'),
            const Divider(),
            _buildMetricRow('Oxygen Saturation', '98%'),
            const Divider(),
            _buildMetricRow('Respiratory Rate', '14 breaths/min'),
            const Divider(),
            _buildMetricRow('Body Temperature', '36.6°C'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetricsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow('VO2 Max', '54.2 ml/kg/min'),
            const Divider(),
            _buildMetricRow('Sprint Speed (20m)', '3.2 seconds'),
            const Divider(),
            _buildMetricRow('Agility Score', '9.4/10'),
            const Divider(),
            _buildMetricRow('Strength Assessment', '82/100'),
            const Divider(),
            _buildMetricRow('Flexibility Test', 'Good'),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalTestsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildTestItem(
                    'Blood Test',
                    'Normal',
                    Colors.green,
                    'Last checked: 3 weeks ago',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTestItem(
                    'ECG',
                    'Normal',
                    Colors.green,
                    'Last checked: 2 months ago',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildTestItem(
                    'Bone Density',
                    'Good',
                    Colors.green,
                    'Last checked: 6 months ago',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTestItem(
                    'Lung Function',
                    'Above Average',
                    Colors.green,
                    'Last checked: 2 months ago',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // View detailed test results
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Full Test Results'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestItem(
      String title, String result, Color statusColor, String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                result,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildNutrientWidget(
                      'Calories', '2400 kcal', Colors.deepPurple),
                ),
                Expanded(
                  child: _buildNutrientWidget('Water', '3.2 L', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Supplementation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSupplementTag('Protein Powder'),
                _buildSupplementTag('Creatine'),
                _buildSupplementTag('Multivitamin'),
                _buildSupplementTag('Omega-3'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nutrient Deficiencies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'None Detected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientWidget(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == 'Calories'
                ? Icons.local_fire_department
                : Icons.water_drop,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplementTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMentalHealthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMentalHealthMeter('Stress Level', 0.35, Colors.amber),
            const SizedBox(height: 16),
            _buildMentalHealthMeter('Sleep Quality', 0.80, Colors.blue),
            const SizedBox(height: 16),
            _buildMentalHealthMeter('Focus/Concentration', 0.75, Colors.purple),
            const SizedBox(height: 16),
            _buildMentalHealthMeter('Motivation', 0.90, Colors.green),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.nightlight, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Average Sleep:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '7.5 hours/night',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentalHealthMeter(String label, double value, Color color) {
    String valueText;
    if (label == 'Stress Level') {
      // For stress, lower is better
      valueText = value < 0.3 ? 'Low' : (value < 0.7 ? 'Moderate' : 'High');
    } else {
      // For others, higher is better
      valueText = value < 0.3 ? 'Poor' : (value < 0.7 ? 'Good' : 'Excellent');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMedicalClearanceCard() {
    // Status can be "Full Clearance", "Partial Clearance" or "No Clearance"
    final String clearanceStatus = "Full Clearance";
    final Color statusColor = clearanceStatus == "Full Clearance"
        ? Colors.green
        : (clearanceStatus == "Partial Clearance" ? Colors.orange : Colors.red);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    clearanceStatus == "Full Clearance"
                        ? Icons.check_circle
                        : (clearanceStatus == "Partial Clearance"
                            ? Icons.warning
                            : Icons.cancel),
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clearanceStatus,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Cleared for all training and competition",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Doctor's Notes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Player is in excellent health and has no restrictions. Follow-up "
              "general assessment recommended in 6 months. Continue with current "
              "training program and maintain proper hydration and nutrition.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Next Assessment:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "October 15, 2025",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Medical Team:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Dr. Sarah Johnson",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryHistoryList() {
    final injuries = [
      {
        'type': 'Ankle Sprain',
        'date': '15-Jan-2023',
        'duration': '3 weeks',
        'treatment': 'Physiotherapy',
        'status': 'Recovered',
      },
      {
        'type': 'Shoulder Strain',
        'date': '05-Oct-2022',
        'duration': '2 weeks',
        'treatment': 'Rest and Medication',
        'status': 'Recovered',
      },
    ];

    return Column(
      children: injuries.map((injury) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      injury['type'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        injury['status'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInjuryInfoRow('Date', injury['date'] as String),
                _buildInjuryInfoRow('Duration', injury['duration'] as String),
                _buildInjuryInfoRow('Treatment', injury['treatment'] as String),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInjuryInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessAssessmentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Assessment (3 weeks ago)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFitnessMeter('Strength', 0.80, Colors.blue),
            const SizedBox(height: 12),
            _buildFitnessMeter('Endurance', 0.75, Colors.green),
            const SizedBox(height: 12),
            _buildFitnessMeter('Flexibility', 0.65, Colors.orange),
            const SizedBox(height: 12),
            _buildFitnessMeter('Speed', 0.90, Colors.purple),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: View detailed report
              },
              icon: const Icon(Icons.description, size: 16),
              label: const Text('View Full Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessMeter(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildUpcomingSessions() {
    final sessions = [
      {
        'title': 'Team Practice',
        'time': 'Today, 4:00 PM - 6:00 PM',
        'location': 'Main Ground',
        'type': 'team',
      },
      {
        'title': 'Batting Practice',
        'time': 'Tomorrow, 10:00 AM - 12:00 PM',
        'location': 'Nets Area',
        'type': 'individual',
      },
      {
        'title': 'Fitness Session',
        'time': 'Wednesday, 9:00 AM - 10:30 AM',
        'location': 'Gym',
        'type': 'individual',
      },
    ];

    return Column(
      children: sessions.map((session) {
        final bool isTeam = session['type'] == 'team';
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isTeam
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.deepPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTeam ? Icons.groups : Icons.person,
                color: isTeam ? Colors.blue : Colors.deepPurple,
              ),
            ),
            title: Text(
              session['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(session['time'] as String),
                Text(session['location'] as String),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.event_note, color: Colors.deepPurple),
              onPressed: () {
                // TODO: View session details
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCalendar() {
    // This is a placeholder. In a real app, you'd implement a proper calendar widget
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                const Text(
                  'April 2025',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Calendar implementation would go here'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: View full schedule
              },
              icon: const Icon(Icons.calendar_month, size: 16),
              label: const Text('View Full Schedule'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamEvents() {
    final events = [
      {
        'title': 'Team Meeting',
        'date': 'April 5, 2025',
        'location': 'Conference Room',
      },
      {
        'title': 'Friendly Match',
        'date': 'April 10, 2025',
        'location': 'City Stadium',
      },
      {
        'title': 'Tournament',
        'date': 'April 15-20, 2025',
        'location': 'National Stadium',
      },
    ];

    return Column(
      children: events.map((event) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event,
                color: Colors.amber,
              ),
            ),
            title: Text(
              event['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(event['date'] as String),
                Text(event['location'] as String),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFinanceSummaryItem(
                    'Income',
                    '₹42,500',
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                Expanded(
                  child: _buildFinanceSummaryItem(
                    'Expenses',
                    '₹12,800',
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildFinanceSummaryItem(
              'Current Balance',
              '₹29,700',
              Colors.blue,
              Icons.account_balance_wallet,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceSummaryItem(
      String label, String value, Color color, IconData icon,
      {bool isLarge = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: isLarge ? 28 : 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'title': 'Equipment Allowance',
        'amount': '+₹15,000',
        'date': 'Mar 25, 2025',
        'category': 'Income',
      },
      {
        'title': 'Training Camp Fee',
        'amount': '-₹8,500',
        'date': 'Mar 20, 2025',
        'category': 'Expense',
      },
      {
        'title': 'Tournament Prize',
        'amount': '+₹25,000',
        'date': 'Mar 15, 2025',
        'category': 'Income',
      },
    ];

    return Column(
      children: transactions.map((tx) {
        final bool isIncome = tx['category'] == 'Income';
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isIncome
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.attach_money : Icons.money_off,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              tx['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(tx['date'] as String),
            trailing: Text(
              tx['amount'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingApprovals() {
    final pending = [
      {
        'title': 'Travel Reimbursement',
        'amount': '₹5,200',
        'submitted': 'Mar 28, 2025',
        'status': 'Pending',
      },
      {
        'title': 'Nutrition Supplements',
        'amount': '₹3,800',
        'submitted': 'Mar 26, 2025',
        'status': 'Pending',
      },
    ];

    if (pending.isEmpty) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No pending approvals',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: pending.map((item) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions,
                color: Colors.amber,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Submitted: ${item['submitted']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['amount'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPlayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Player Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit profile page
              },
            ),
            _buildActionItem(
              icon: Icons.medical_services,
              title: 'Log Injury',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to injury form
              },
            ),
            _buildActionItem(
              icon: Icons.sports_score,
              title: 'Add Performance',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to performance form
              },
            ),
            _buildActionItem(
              icon: Icons.message,
              title: 'Send Message',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to messaging
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildActionItem(
              icon: Icons.fitness_center,
              title: 'Assign Training',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to training assignment
              },
            ),
            _buildActionItem(
              icon: Icons.schedule,
              title: 'Schedule Meeting',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to meeting scheduler
              },
            ),
            _buildActionItem(
              icon: Icons.sticky_note_2,
              title: 'Add Coach Note',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to note form
              },
            ),
            _buildActionItem(
              icon: Icons.assessment,
              title: 'Performance Assessment',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to assessment form
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}

// Helper class for persistent tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
