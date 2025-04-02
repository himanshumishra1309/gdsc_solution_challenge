import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/views/player/player_home.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Add this package
import 'package:gdg_app/serivces/auth_service.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:gdg_app/serivces/admin_services.dart';

class AdminViewPlayers extends StatefulWidget {
  const AdminViewPlayers({super.key});

  @override
  _AdminViewPlayersState createState() => _AdminViewPlayersState();
}

class _AdminViewPlayersState extends State<AdminViewPlayers>
    with SingleTickerProviderStateMixin {
  final _adminService = AdminService();
  final _authService = AuthService();
  List<dynamic> _players = [];
  List<dynamic> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedSport = 'All';
  String _sortBy = 'Name (A-Z)';
  bool _isLoading = true;
  bool _isGridView = false;
  late AnimationController _animationController;

  int _currentPage = 1;
  int _totalPages = 1;
  int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  final List<String> _sportFilters = [
    'All',
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Badminton',
    'Swimming',
    'Volleyball'
  ];
  final List<String> _sortOptions = [
    'Name (A-Z)',
    'Name (Z-A)',
    'Sport',
    'Age (Youngest)',
    'Age (Oldest)'
  ];

  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadUserInfo();
    _loadPlayers();
  }

  Future<void> _loadUserInfo() async {
  try {
    final userData = await _authService.getCurrentUser();
    
    if (userData.isNotEmpty) {
      setState(() {
        _userName = userData['name'] ?? "Admin";
        _userEmail = userData['email'] ?? "";
        _userAvatar = userData['avatar'];
      });
    }
  } catch (e) {
    debugPrint('Error loading user info: $e');
  }
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Replace the existing _loadPlayers method with this:

  Future<void> _loadPlayers({bool resetPage = true}) async {
    if (resetPage) {
      setState(() {
        _currentPage = 1;
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // Call the API service
      final result = await _adminService.getAllAthletes(
        page: _currentPage,
        limit: _itemsPerPage,
        sort: _getSortField(),
        order: _getSortOrder(),
        search: _searchQuery,
        sport: _selectedSport == 'All' ? '' : _selectedSport,
        skillLevel:
            _currentPage == 1 ? '' : '', // Add skill level logic if needed
        gender: '', // Add gender filter if needed
      );

      if (result['success']) {
        final List<dynamic> fetchedPlayers = result['athletes'];
        final Map<String, dynamic> pagination = result['pagination'];

        setState(() {
          // Always replace the entire list with new data, not append
          _players = fetchedPlayers;
          _filteredPlayers = fetchedPlayers;

          _totalPages = pagination['totalPages'] ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load players'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading player data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Add helper methods to map UI sort options to API parameters
  String _getSortField() {
    switch (_sortBy) {
      case 'Name (A-Z)':
      case 'Name (Z-A)':
        return 'name';
      case 'Sport':
        return 'sports';
      case 'Age (Youngest)':
      case 'Age (Oldest)':
        return 'dob';
      default:
        return 'name';
    }
  }

  String _getSortOrder() {
    switch (_sortBy) {
      case 'Name (Z-A)':
      case 'Age (Oldest)':
        return 'desc';
      default:
        return 'asc';
    }
  }

  // Update these methods to load players from API instead of filtering locally:

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      // Load from API instead of filtering locally
      _loadPlayers();
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      // Load from API instead of filtering locally
      _loadPlayers();
    });
  }

  void _onSortChanged(String? sortOption) {
    setState(() {
      _sortBy = sortOption!;
      // Load from API instead of filtering locally
      _loadPlayers();
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        final matchesName = player['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesSport = _selectedSport == 'All' ||
                player['sports'] != null && player['sports'].isNotEmpty
            ? player['sports'][0]
            : 'Unknown' == _selectedSport;
        return matchesName && matchesSport;
      }).toList();

      _sortPlayers();
    });
  }

  void _sortPlayers() {
    switch (_sortBy) {
      case 'Name (A-Z)':
        _filteredPlayers.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'Name (Z-A)':
        _filteredPlayers.sort(
            (a, b) => b['name'].toString().compareTo(a['name'].toString()));
        break;
      case 'Sport':
        _filteredPlayers.sort((a, b) => a['primarySport']
            .toString()
            .compareTo(b['primarySport'].toString()));
        break;
      case 'Age (Youngest)':
        _filteredPlayers
            .sort((a, b) => a['age'].toString().compareTo(b['age'].toString()));
        break;
      case 'Age (Oldest)':
        _filteredPlayers
            .sort((a, b) => b['age'].toString().compareTo(a['age'].toString()));
        break;
    }
  }

  // Update the _navigateToPlayerProfile method:

  void _navigateToPlayerProfile(Map<String, dynamic> player) {
    // Debug the data to see what fields are available
    debugPrint('Player data: ${player.keys.join(', ')}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerProfileWrapper(player: player),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          );
        },
      );

      try {
        // First clear local data directly
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Then try server-side logout, but don't block on it
        _authService.logout().catchError((e) {
          print('Server logout error: $e');
        });

        // Navigate to login page
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushNamedAndRemoveUntil(
            context,
            coachAdminPlayerRoute, // Make sure this constant is defined in your routes file
            (route) => false, // This clears the navigation stack
          );
        }
      } catch (e) {
        // Handle errors
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildListView() {
    if (_filteredPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No players found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = _filteredPlayers[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 350),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _navigateToPlayerProfile(player),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'player-avatar-${player['id']}',
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundImage: player['avatar'] != null
                                    ? NetworkImage(player['avatar'])
                                    : const AssetImage(
                                            'assets/images/default_avatar.png')
                                        as ImageProvider,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        player['name'],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getSportColor(
                                                player['sports'] != null &&
                                                        player['sports']
                                                            .isNotEmpty
                                                    ? player['sports'][0]
                                                    : 'Unknown')
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        player['sports'] != null &&
                                                player['sports'].isNotEmpty
                                            ? player['sports'][0]
                                            : 'Unknown',
                                        style: TextStyle(
                                          color: _getSportColor(
                                              player['sports'] != null &&
                                                      player['sports']
                                                          .isNotEmpty
                                                  ? player['sports'][0]
                                                  : 'Unknown'),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      player['athleteId'] ??
                                          'ATH-${index + 1000}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.school,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              player['school'] ??
                                                  'Not specified',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${player['age']} yrs',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    if (_filteredPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No players found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _filteredPlayers.length,
        itemBuilder: (context, index) {
          final player = _filteredPlayers[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 350),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _navigateToPlayerProfile(player),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Hero(
                              tag: 'player-avatar-${player['id']}',
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: player['avatar'] != null
                                        ? NetworkImage(player['avatar'])
                                        : const AssetImage(
                                                'assets/images/player1.png')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  player['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSportColor(
                                            player['sports'] != null &&
                                                    player['sports'].isNotEmpty
                                                ? player['sports'][0]
                                                : 'Unknown')
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    player['sports'] != null &&
                                            player['sports'].isNotEmpty
                                        ? player['sports'][0]
                                        : 'Unknown',
                                    style: TextStyle(
                                      color: _getSportColor(
                                          player['sports'] != null &&
                                                  player['sports'].isNotEmpty
                                              ? player['sports'][0]
                                              : 'Unknown'),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${player['age']} years • ${player['currentLevel'] ?? 'Beginner'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        // Makes control scrollable on small screens
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage <= 1
                  ? null
                  : () {
                      setState(() {
                        _currentPage = 1;
                      });
                      _loadPlayers(
                          resetPage: false); // Don't reset when navigating
                    },
              color:
                  _currentPage <= 1 ? Colors.grey.shade400 : Colors.deepPurple,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage <= 1
                  ? null
                  : () {
                      setState(() {
                        _currentPage--;
                      });
                      _loadPlayers(
                          resetPage: false); // Don't reset when navigating
                    },
              color:
                  _currentPage <= 1 ? Colors.grey.shade400 : Colors.deepPurple,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page $_currentPage of $_totalPages',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage >= _totalPages
                  ? null
                  : () {
                      setState(() {
                        _currentPage++;
                      });
                      _loadPlayers(
                          resetPage: false); // Don't reset when navigating
                    },
              color: _currentPage >= _totalPages
                  ? Colors.grey.shade400
                  : Colors.deepPurple,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage >= _totalPages
                  ? null
                  : () {
                      setState(() {
                        _currentPage = _totalPages;
                      });
                      _loadPlayers(
                          resetPage: false); // Don't reset when navigating
                    },
              color: _currentPage >= _totalPages
                  ? Colors.grey.shade400
                  : Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSportColor(String sport) {
    switch (sport) {
      case 'Football':
        return Colors.green;
      case 'Cricket':
        return Colors.blue;
      case 'Basketball':
        return Colors.orange;
      case 'Tennis':
        return Colors.red;
      case 'Badminton':
        return Colors.purple;
      case 'Swimming':
        return Colors.cyan;
      case 'Volleyball':
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Directory'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: _toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadPlayers,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting player data...')),
                );
              } else if (value == 'help') {
                _showHelpDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: viewAllPlayersRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(
              icon: Icons.home, title: 'Admin Home', route: adminHomeRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Admin',
              route: registerAdminRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Coach',
              route: registerCoachRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Player',
              route: registerPlayerRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View All Players',
              route: viewAllPlayersRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View All Coaches',
              route: viewAllCoachesRoute),
          DrawerItem(
              icon: Icons.request_page,
              title: 'Request/View Sponsors',
              route: requestViewSponsorsRoute),
          DrawerItem(
              icon: Icons.video_library,
              title: 'Video Analysis',
              route: videoAnalysisRoute),
          DrawerItem(
              icon: Icons.attach_money,
              title: 'Manage Player Finances',
              route: adminManagePlayerFinancesRoute),
        ],
        onLogout: () => _handleLogout(context),
        userName: _userName,
        userEmail: _userEmail, 
        userAvatarUrl: _userAvatar,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stats summary
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.people,
                        title: 'Total',
                        value: _players.length.toString(),
                      ),
                      _buildStatItem(
                        icon: Icons.sports_soccer,
                        title: 'Sports',
                        value: _sportFilters.length > 0
                            ? (_sportFilters.length - 1).toString()
                            : '0',
                      ),
                      _buildStatItem(
                        icon: Icons.filter_alt,
                        title: 'Filtered',
                        value: _filteredPlayers.length.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Search field
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search players...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Sport: $_selectedSport',
                          icon: Icons.sports,
                          onPressed: () => _showSportFilterBottomSheet(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChip(
                          label: 'Sort: $_sortBy',
                          icon: Icons.sort,
                          onPressed: () => _showSortOptionsBottomSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, registerPlayerRoute);
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Player'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredPlayers.length} Players Found',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedSport != 'All')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedSport = 'All';
                        _sortBy = 'Name (A-Z)';
                        _filterPlayers();
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading player data...',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isGridView
                                ? _buildGridView()
                                : _buildListView(),
                          ),
                        ),
                        _buildPaginationControls(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      {required IconData icon, required String title, required String value}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSportFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Filter by Sport',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sportFilters.length,
                    itemBuilder: (context, index) {
                      final sport = _sportFilters[index];
                      return ListTile(
                        title: Text(sport),
                        leading: Icon(
                          _getSportIcon(sport),
                          color: sport == 'All'
                              ? Colors.deepPurple
                              : _getSportColor(sport),
                        ),
                        trailing: sport == _selectedSport
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.deepPurple,
                              )
                            : null,
                        onTap: () {
                          _onSportChanged(sport);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.sort,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Sort Players By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sortOptions.length,
                    itemBuilder: (context, index) {
                      final option = _sortOptions[index];
                      return ListTile(
                        title: Text(option),
                        leading: Icon(
                          _getSortIcon(option),
                          color: Colors.deepPurple,
                        ),
                        trailing: option == _sortBy
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.deepPurple,
                              )
                            : null,
                        onTap: () {
                          _onSortChanged(option);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline,
                          color: Colors.deepPurple),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Player Directory Help',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildHelpItem(
                  icon: Icons.search,
                  title: 'Search Players',
                  description: 'Use the search bar to find players by name.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.filter_alt,
                  title: 'Filter by Sport',
                  description: 'Filter the player list by their primary sport.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.sort,
                  title: 'Sort Players',
                  description: 'Sort the player list by different criteria.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.grid_view,
                  title: 'View Modes',
                  description: 'Toggle between list and grid view layouts.',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Got It'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer;
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Tennis':
        return Icons.sports_tennis;
      case 'Badminton':
        return Icons.sports_handball;
      case 'Swimming':
        return Icons.pool;
      case 'Volleyball':
        return Icons.sports_volleyball;
      case 'All':
        return Icons.sports;
      default:
        return Icons.sports;
    }
  }

  IconData _getSortIcon(String sortOption) {
    switch (sortOption) {
      case 'Name (A-Z)':
        return Icons.sort_by_alpha;
      case 'Name (Z-A)':
        return Icons.sort_by_alpha;
      case 'Sport':
        return Icons.sports;
      case 'Age (Youngest)':
        return Icons.arrow_upward;
      case 'Age (Oldest)':
        return Icons.arrow_downward;
      default:
        return Icons.sort;
    }
  }
}

// Wrapper for Player Profile Page
class PlayerProfileWrapper extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerProfileWrapper({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayerProfilePage(playerData: player),
    );
  }
}

class PlayerProfilePage extends StatefulWidget {
  final Map<String, dynamic> playerData;

  const PlayerProfilePage({super.key, required this.playerData});

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Adjusted threshold to avoid overlap with tabs
    bool isExpanded = _scrollController.hasClients &&
        _scrollController.offset > (150 - kToolbarHeight);
    if (isExpanded != _isAppBarExpanded) {
      setState(() {
        _isAppBarExpanded = isExpanded;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              backgroundColor: Colors.deepPurple,
              title: _isAppBarExpanded
                  ? Text(
                      widget.playerData['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                // Remove the title from here to avoid double titles and collisions
                titlePadding: EdgeInsets.zero,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dark gradient at top for better visibility of icons
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                    // Profile image
                    Hero(
                      tag:
                          'player-avatar-${widget.playerData['_id'] ?? 'unknown'}',
                      child: widget.playerData['avatar'] != null
                          ? Image.network(
                              widget.playerData['avatar'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarPlaceholder(),
                            )
                          : _buildAvatarPlaceholder(),
                    ),
                    // Stronger gradient overlay at bottom for text clarity
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Player name and details - moved up to avoid overlap with tabs
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 60, // Increased to prevent tab overlap
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.playerData['name'] ?? 'Unknown Player',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getSportColor(
                                          widget.playerData['sports'] != null &&
                                                  widget.playerData['sports']
                                                      .isNotEmpty
                                              ? widget.playerData['sports'][0]
                                              : 'Unknown')
                                      .withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.playerData['sports'] != null &&
                                          widget.playerData['sports'].isNotEmpty
                                      ? widget.playerData['sports'][0]
                                      : 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.playerData['age'] ?? '??'} years',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.playerData['athleteId'] ?? 'ATH-XXXX',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Icons have adaptive colors based on background
              iconTheme: IconThemeData(
                color: _isAppBarExpanded ? Colors.white : Colors.white,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  // Icon color will inherit from iconTheme
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit player profile')),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  // Icon color will inherit from iconTheme
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'export') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Exporting player profile...')),
                      );
                    } else if (value == 'archive') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archiving player...')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text('Export Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text('Archive Player'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              // High-contrast tab bar that maintains visibility over all backgrounds
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color:
                      Colors.black.withOpacity(0.3), // Dark background for tabs
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    isScrollable: true,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Performance'),
                      Tab(text: 'Medical'),
                      Tab(text: 'Schedule'),
                      Tab(text: 'Finances'),
                    ],
                  ),
                ),
              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sending message to player...')),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.message),
        label: const Text('Message'),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.deepPurple.shade100,
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.deepPurple.shade300,
        ),
      ),
    );
  }

  Color _getSportColor(String sport) {
    switch (sport) {
      case 'Football':
        return Colors.green;
      case 'Cricket':
        return Colors.blue;
      case 'Basketball':
        return Colors.orange;
      case 'Tennis':
        return Colors.red;
      case 'Badminton':
        return Colors.purple;
      case 'Swimming':
        return Colors.cyan;
      case 'Volleyball':
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            title: 'Personal Information',
            icon: Icons.person,
            content: Column(
              children: [
                _buildInfoRow(
                  label: 'Date of Birth',
                  value: widget.playerData['dob']?.toString()?.split('T')?[0] ??
                      'Not available',
                  icon: Icons.cake,
                ),
                _buildInfoRow(
                  label: 'Gender',
                  value: widget.playerData['gender'] ?? 'Not available',
                  icon: Icons.person,
                ),
                _buildInfoRow(
                  label: 'Nationality',
                  value: widget.playerData['nationality'] ?? 'Not available',
                  icon: Icons.public,
                ),
                _buildInfoRow(
                  label: 'Address',
                  value: widget.playerData['address'] ?? 'Not available',
                  icon: Icons.location_on,
                ),
                _buildInfoRow(
                  label: 'Contact',
                  value: widget.playerData['phoneNumber'] ?? 'Not available',
                  icon: Icons.phone,
                ),
                _buildInfoRow(
                  label: 'Email',
                  value: widget.playerData['email'] ?? 'Not available',
                  icon: Icons.email,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Academic Details',
            icon: Icons.school,
            content: Column(
              children: [
                _buildInfoRow(
                  label: 'School/College',
                  value: widget.playerData['school'] ?? 'Not available',
                  icon: Icons.school,
                ),
                _buildInfoRow(
                  label: 'Grade/Year',
                  value: widget.playerData['grade'] ?? 'Not available',
                  icon: Icons.grade,
                ),
                _buildInfoRow(
                  label: 'Student ID',
                  value: widget.playerData['studentId'] ?? 'Not available',
                  icon: Icons.badge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Sports Information',
            icon: Icons.sports,
            content: Column(
              children: [
                _buildInfoRow(
                  label: 'Primary Sport',
                  value: widget.playerData['primarySport'] ?? 'Not available',
                  icon: Icons.sports,
                ),
                _buildInfoRow(
                  label: 'Secondary Sport',
                  value: widget.playerData['secondarySport'] ?? 'None',
                  icon: Icons.sports_handball,
                ),
                _buildInfoRow(
                  label: 'Position/Role',
                  value:
                      widget.playerData['playingPosition'] ?? 'Not specified',
                  icon: Icons.person_pin_circle,
                ),
                _buildInfoRow(
                  label: 'Current Level',
                  value: widget.playerData['currentLevel'] ?? 'Beginner',
                  icon: Icons.trending_up,
                ),
                _buildInfoRow(
                  label: 'Training Since',
                  value:
                      widget.playerData['trainingStartDate'] ?? 'Not available',
                  icon: Icons.calendar_today,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Assigned Staff',
            icon: Icons.people,
            content: Column(
              children: [
                _buildAssignedStaffRow(
                  name: widget.playerData['coachAssigned'] ?? 'Not assigned',
                  role: 'Coach',
                  imagePath: 'assets/images/coach_avatar.png',
                ),
                const Divider(),
                _buildAssignedStaffRow(
                  name:
                      widget.playerData['gymTrainerAssigned'] ?? 'Not assigned',
                  role: 'Gym Trainer',
                  imagePath: 'assets/images/trainer_avatar.png',
                ),
                const Divider(),
                _buildAssignedStaffRow(
                  name: widget.playerData['medicalStaffAssigned'] ??
                      'Not assigned',
                  role: 'Medical Staff',
                  imagePath: 'assets/images/doctor_avatar.png',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Emergency Contact',
            icon: Icons.emergency,
            content: Column(
              children: [
                _buildInfoRow(
                  label: 'Name',
                  value: 'Parent/Guardian',
                  icon: Icons.person,
                ),
                _buildInfoRow(
                  label: 'Phone',
                  value:
                      widget.playerData['emergencyContact'] ?? 'Not available',
                  icon: Icons.phone,
                ),
                _buildInfoRow(
                  label: 'Relationship',
                  value: 'Parent',
                  icon: Icons.family_restroom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      {required String title,
      required IconData icon,
      required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      {required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.deepPurple),
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
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
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

  Widget _buildAssignedStaffRow(
      {required String name, required String role, required String imagePath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(imagePath),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback for missing images
              const Icon(Icons.person, color: Colors.white);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Contacting $role...')),
              );
            },
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder widgets for other tabs
  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Stats Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Performance Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPerformanceStat(
                        '85', 'Consistency', Icons.auto_graph),
                    _buildPerformanceStat('92', 'Technique', Icons.sports),
                    _buildPerformanceStat('78', 'Stamina', Icons.timer),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white30, thickness: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overall Rating',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '8.5 / 10',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Training Sessions
          _buildSection(
            title: 'Recent Training Sessions',
            icon: Icons.calendar_today,
            child: Column(
              children: [
                _buildTrainingSessionItem(
                  date: 'Mar 6, 2025',
                  duration: '2h 15m',
                  performance: 'Excellent',
                  performanceColor: Colors.green,
                ),
                const Divider(),
                _buildTrainingSessionItem(
                  date: 'Mar 3, 2025',
                  duration: '1h 45m',
                  performance: 'Good',
                  performanceColor: Colors.blue,
                ),
                const Divider(),
                _buildTrainingSessionItem(
                  date: 'Feb 28, 2025',
                  duration: '2h 30m',
                  performance: 'Average',
                  performanceColor: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Skills Assessment
          _buildSection(
            title: 'Skills Assessment',
            icon: Icons.psychology_alt,
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildSkillProgressBar(
                  label: 'Ball Control',
                  progress: 0.85,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Passing Accuracy',
                  progress: 0.75,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Shooting Power',
                  progress: 0.92,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Game Awareness',
                  progress: 0.68,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Team Coordination',
                  progress: 0.81,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Coach Feedback
          _buildSection(
            title: 'Coach Feedback',
            icon: Icons.comment,
            child: Column(
              children: [
                _buildCoachFeedback(
                  coachName: 'Coach Johnson',
                  date: 'Mar 5, 2025',
                  feedback:
                      'Showing excellent progress in ball control and passing accuracy. Needs to work on defensive positioning and communication on field.',
                  rating: 4,
                ),
                const Divider(),
                _buildCoachFeedback(
                  coachName: 'Coach Williams',
                  date: 'Feb 20, 2025',
                  feedback:
                      'Good technical skills displayed during practice matches. Recommend focusing on endurance training to maintain performance throughout full match duration.',
                  rating: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Upcoming Goals
          _buildSection(
            title: 'Performance Goals',
            icon: Icons.track_changes,
            child: Column(
              children: [
                _buildGoalItem(
                  title: 'Improve Sprint Speed',
                  description: 'Target: 100m in under 12 seconds',
                  deadline: 'April 15, 2025',
                  progress: 0.65,
                ),
                const Divider(),
                _buildGoalItem(
                  title: 'Master Free Kicks',
                  description: '80% accuracy from 25 yards',
                  deadline: 'May 30, 2025',
                  progress: 0.4,
                ),
                const Divider(),
                _buildGoalItem(
                  title: 'Build Stamina',
                  description: 'Complete full match without substitution',
                  deadline: 'June 10, 2025',
                  progress: 0.25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingSessionItem({
    required String date,
    required String duration,
    required String performance,
    required Color performanceColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports, color: Colors.deepPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  performance,
                  style: TextStyle(
                    color: performanceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillProgressBar({
    required String label,
    required double progress,
    required Color color,
  }) {
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
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * progress * 0.8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoachFeedback({
    required String coachName,
    required String date,
    required String feedback,
    required int rating,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                coachName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: index < rating ? Colors.amber : Colors.grey.shade300,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required String description,
    required String deadline,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due by: $deadline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * progress * 0.7,
                      decoration: BoxDecoration(
                        color: progress < 0.3
                            ? Colors.red
                            : progress < 0.7
                                ? Colors.orange
                                : Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medical verification banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Information Access',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are viewing restricted medical information. All data accessed is logged for compliance purposes.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Physical measurements card
          _buildMedicalSection(
            title: 'Physical Measurements',
            icon: Icons.straighten,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildMeasurement(
                      label: 'Height',
                      value: '5\'10"',
                      icon: Icons.height,
                    ),
                    _buildMeasurement(
                      label: 'Weight',
                      value: '72 kg',
                      icon: Icons.monitor_weight,
                    ),
                    _buildMeasurement(
                      label: 'BMI',
                      value: '22.4',
                      icon: Icons.speed,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMeasurement(
                      label: 'Blood Type',
                      value: 'O+',
                      icon: Icons.bloodtype,
                    ),
                    _buildMeasurement(
                      label: 'Heart Rate',
                      value: '68 bpm',
                      icon: Icons.favorite,
                    ),
                    _buildMeasurement(
                      label: 'BP',
                      value: '118/78',
                      icon: Icons.monitor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Allergies and medical conditions
          _buildMedicalSection(
            title: 'Medical Alerts',
            icon: Icons.warning_amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMedicalAlertItem(
                  title: 'Pollen Allergy',
                  description: 'Mild seasonal allergic rhinitis',
                  severity: 'Mild',
                  severityColor: Colors.yellow.shade700,
                ),
                const Divider(),
                _buildMedicalAlertItem(
                  title: 'Ibuprofen',
                  description: 'Avoid due to mild gastric discomfort',
                  severity: 'Low',
                  severityColor: Colors.orange,
                ),
                const Divider(),
                _buildMedicalAlertItem(
                  title: 'Asthma',
                  description: 'Exercise-induced asthma, well controlled',
                  severity: 'Moderate',
                  severityColor: Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vaccination history
          _buildMedicalSection(
            title: 'Vaccination History',
            icon: Icons.vaccines,
            child: Column(
              children: [
                _buildVaccinationItem(
                  name: 'Tetanus Booster',
                  date: 'Jan 15, 2023',
                  dueDate: 'Jan 15, 2033',
                  status: 'Current',
                ),
                const Divider(),
                _buildVaccinationItem(
                  name: 'Influenza',
                  date: 'Oct 8, 2024',
                  dueDate: 'Oct 2025',
                  status: 'Current',
                ),
                const Divider(),
                _buildVaccinationItem(
                  name: 'COVID-19',
                  date: 'May 22, 2023',
                  dueDate: 'May 2025',
                  status: 'Current',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent injuries
          _buildMedicalSection(
            title: 'Injury History',
            icon: Icons.personal_injury,
            child: Column(
              children: [
                _buildInjuryItem(
                  title: 'Ankle Sprain',
                  date: 'Feb 12, 2025',
                  status: 'Recovering',
                  statusColor: Colors.orange,
                  details:
                      'Grade 1 lateral ankle sprain sustained during training. Currently undergoing physiotherapy 3x per week.',
                  recoveryProgress: 0.7,
                ),
                const Divider(),
                _buildInjuryItem(
                  title: 'Hamstring Strain',
                  date: 'Nov 5, 2024',
                  status: 'Recovered',
                  statusColor: Colors.green,
                  details:
                      'Minor hamstring strain. Completed rehabilitation program and returned to full training.',
                  recoveryProgress: 1.0,
                ),
                const Divider(),
                _buildInjuryItem(
                  title: 'Shoulder Contusion',
                  date: 'Aug 23, 2024',
                  status: 'Resolved',
                  statusColor: Colors.green,
                  details:
                      'Impact injury during match. Required ice treatment and short rest period.',
                  recoveryProgress: 1.0,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Medical appointments
          _buildMedicalSection(
            title: 'Upcoming Medical Appointments',
            icon: Icons.event_available,
            child: Column(
              children: [
                _buildAppointmentItem(
                  appointmentType: 'Physiotherapy Session',
                  provider: 'Dr. Sarah Johnson',
                  date: 'Mar 12, 2025',
                  time: '10:30 AM',
                  location: 'Sports Medicine Center',
                ),
                const Divider(),
                _buildAppointmentItem(
                  appointmentType: 'Annual Sports Physical',
                  provider: 'Dr. Michael Chen',
                  date: 'Mar 20, 2025',
                  time: '2:00 PM',
                  location: 'Athletic Health Clinic',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Medical documents
          _buildMedicalSection(
            title: 'Medical Documents',
            icon: Icons.folder_open,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: const Text('Medical Clearance Form'),
                  subtitle: Text('Uploaded: Jan 5, 2025'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Viewing document...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Downloading document...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image, color: Colors.blue),
                  ),
                  title: const Text('X-Ray Results'),
                  subtitle: Text('Uploaded: Feb 14, 2025'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Viewing document...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Downloading document...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.description, color: Colors.green),
                  ),
                  title: const Text('Physiotherapy Progress Report'),
                  subtitle: Text('Uploaded: Mar 1, 2025'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Viewing document...')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.download, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Downloading document...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confidentiality notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Confidentiality Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This medical information is confidential and protected by privacy laws. Unauthorized access, use, or disclosure is prohibited and may result in penalties.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurement({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalAlertItem({
    required String title,
    required String description,
    required String severity,
    required Color severityColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.priority_high,
              color: severityColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: severityColor.withOpacity(0.3)),
            ),
            child: Text(
              severity,
              style: TextStyle(
                color: severityColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationItem({
    required String name,
    required String date,
    required String dueDate,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Given: $date',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.update,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: $dueDate',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Text(
              'Current',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryItem({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required String details,
    required double recoveryProgress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.healing,
                  color: statusColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: $date',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                if (recoveryProgress < 1.0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recovery Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(recoveryProgress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: double.infinity * recoveryProgress,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem({
    required String appointmentType,
    required String provider,
    required String date,
    required String time,
    required String location,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today,
                color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointmentType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Appointment rescheduled')),
                        );
                      },
                      icon: const Icon(Icons.edit_calendar, size: 16),
                      label: const Text('Reschedule'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment canceled')),
                        );
                      },
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          // Weekly schedule overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Week Schedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Mar 8 - Mar 14',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScheduleStat('5', 'Sessions', Icons.sports),
                    _buildScheduleStat('10h', 'Total Hours', Icons.timer),
                    _buildScheduleStat('2', 'Rest Days', Icons.hotel),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Today's sessions
          _buildScheduleSection(
            title: 'Today\'s Sessions',
            icon: Icons.today,
            child: Column(
              children: [
                _buildTrainingSession(
                  title: 'Morning Drill Practice',
                  timeRange: '6:00 AM - 7:30 AM',
                  location: 'Main Field',
                  coach: 'Coach Johnson',
                  type: 'Technical',
                  typeColor: Colors.blue,
                ),
                const Divider(),
                _buildTrainingSession(
                  title: 'Strength & Conditioning',
                  timeRange: '4:00 PM - 5:30 PM',
                  location: 'Gym',
                  coach: 'Coach Williams',
                  type: 'Physical',
                  typeColor: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Upcoming sessions
          _buildScheduleSection(
            title: 'Upcoming Sessions',
            icon: Icons.upcoming,
            child: Column(
              children: [
                _buildTrainingSession(
                  title: 'Team Strategy Session',
                  timeRange: 'Tomorrow, 9:00 AM - 11:00 AM',
                  location: 'Training Room',
                  coach: 'Coach Martinez',
                  type: 'Tactical',
                  typeColor: Colors.green,
                ),
                const Divider(),
                _buildTrainingSession(
                  title: 'Practice Match',
                  timeRange: 'Mar 10, 3:30 PM - 5:30 PM',
                  location: 'Main Field',
                  coach: 'Coach Johnson',
                  type: 'Competitive',
                  typeColor: Colors.purple,
                ),
                const Divider(),
                _buildTrainingSession(
                  title: 'Recovery Session',
                  timeRange: 'Mar 11, 10:00 AM - 11:00 AM',
                  location: 'Therapy Center',
                  coach: 'Coach Williams',
                  type: 'Recovery',
                  typeColor: Colors.teal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Weekly schedule
          _buildScheduleSection(
            title: 'Weekly Schedule',
            icon: Icons.calendar_view_week,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    _buildDaySchedule(
                      day: 'MON',
                      date: 'Mar 8',
                      sessions: const [
                        {
                          'time': '6:00 AM',
                          'title': 'Morning Drill',
                          'color': Colors.blue,
                        },
                        {
                          'time': '4:00 PM',
                          'title': 'Conditioning',
                          'color': Colors.orange,
                        },
                      ],
                      isToday: true,
                    ),
                    _buildDaySchedule(
                      day: 'TUE',
                      date: 'Mar 9',
                      sessions: const [
                        {
                          'time': '9:00 AM',
                          'title': 'Strategy',
                          'color': Colors.green,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'WED',
                      date: 'Mar 10',
                      sessions: const [
                        {
                          'time': '3:30 PM',
                          'title': 'Match',
                          'color': Colors.purple,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'THU',
                      date: 'Mar 11',
                      sessions: const [
                        {
                          'time': '10:00 AM',
                          'title': 'Recovery',
                          'color': Colors.teal,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'FRI',
                      date: 'Mar 12',
                      sessions: const [
                        {
                          'time': '4:00 PM',
                          'title': 'Team Training',
                          'color': Colors.indigo,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'SAT',
                      date: 'Mar 13',
                      sessions: const [
                        {
                          'time': '9:30 AM',
                          'title': 'Competition',
                          'color': Colors.red,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'SUN',
                      date: 'Mar 14',
                      sessions: const [],
                      isRestDay: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Upcoming tournaments/events
          _buildScheduleSection(
            title: 'Upcoming Competitions',
            icon: Icons.emoji_events,
            child: Column(
              children: [
                _buildCompetitionItem(
                  name: 'Regional Championships',
                  date: 'March 20-22, 2025',
                  location: 'City Sports Complex',
                  status: 'Registered',
                  statusColor: Colors.green,
                ),
                const Divider(),
                _buildCompetitionItem(
                  name: 'Spring Invitational Tournament',
                  date: 'April 5, 2025',
                  location: 'University Stadium',
                  status: 'Registration Pending',
                  statusColor: Colors.orange,
                ),
                const Divider(),
                _buildCompetitionItem(
                  name: 'State Finals',
                  date: 'May 15-18, 2025',
                  location: 'State Sports Arena',
                  status: 'Qualification Required',
                  statusColor: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Canceled or rescheduled sessions
          _buildScheduleSection(
            title: 'Changes & Notifications',
            icon: Icons.notifications_active,
            child: Column(
              children: [
                _buildNotificationItem(
                  title: 'Session Canceled',
                  message:
                      'The evening session on Friday has been canceled due to venue maintenance.',
                  date: 'Mar 7, 2025',
                  isRead: true,
                  type: 'cancellation',
                ),
                const Divider(),
                _buildNotificationItem(
                  title: 'Time Change',
                  message:
                      'Saturday\'s competition has been moved from 8:30 AM to 9:30 AM.',
                  date: 'Mar 6, 2025',
                  isRead: false,
                  type: 'change',
                ),
                const Divider(),
                _buildNotificationItem(
                  title: 'New Session Added',
                  message:
                      'A special technical drill session has been added next Monday at 3:00 PM.',
                  date: 'Mar 5, 2025',
                  isRead: false,
                  type: 'addition',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingSession({
    required String title,
    required String timeRange,
    required String location,
    required String coach,
    required String type,
    required Color typeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 100,
            decoration: BoxDecoration(
              color: typeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      timeRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      coach,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule({
    required String day,
    required String date,
    required List<Map<String, dynamic>> sessions,
    bool isToday = false,
    bool isRestDay = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      decoration: BoxDecoration(
        color: isToday ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? Colors.deepPurple : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? Colors.deepPurple : Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            child: isRestDay
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hotel,
                          size: 28,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Rest Day',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                : sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No Sessions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sessions.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: session['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: session['color'].withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session['time'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: session['color'],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session['title'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionItem({
    required String name,
    required String date,
    required String location,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // View competition details
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        foregroundColor: Colors.deepPurple,
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String date,
    required bool isRead,
    required String type,
  }) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'cancellation':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'change':
        icon = Icons.update;
        iconColor = Colors.orange;
        break;
      case 'addition':
        icon = Icons.add_circle;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
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
          // Financial Information Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Information Access',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You are viewing restricted financial information. All data accessed is logged for compliance purposes.',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account Summary
          _buildFinanceSection(
            title: 'Account Summary',
            icon: Icons.account_balance_wallet,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildFinanceStat(
                      label: 'Balance Due',
                      value: '₹12,500',
                      icon: Icons.payments,
                      isNegative: true,
                    ),
                    _buildFinanceStat(
                      label: 'Credits',
                      value: '₹3,000',
                      icon: Icons.add_card,
                      isNegative: false,
                    ),
                    _buildFinanceStat(
                      label: 'Net Due',
                      value: '₹9,500',
                      icon: Icons.calculate,
                      isNegative: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Current Term Fees Due Date: March 31, 2025',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.payment),
                        label: const Text('Make Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history),
                        label: const Text('Payment History'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fee Breakdown
          _buildFinanceSection(
            title: 'Fee Breakdown (Academic Year 2024-25)',
            icon: Icons.receipt_long,
            child: Column(
              children: [
                _buildFeeItem(
                  title: 'Training Fee',
                  amount: '₹40,000',
                  isPaid: false,
                  description: 'Annual training program fee',
                  dueDate: 'Mar 31, 2025 (Installment 1/4)',
                ),
                const Divider(),
                _buildFeeItem(
                  title: 'Equipment',
                  amount: '₹8,500',
                  isPaid: true,
                  description: 'Training kit and equipment',
                  dueDate: 'Oct 15, 2024',
                ),
                const Divider(),
                _buildFeeItem(
                  title: 'Competition Registration',
                  amount: '₹6,000',
                  isPaid: false,
                  description: 'Regional championship registration',
                  dueDate: 'Apr 10, 2025',
                ),
                const Divider(),
                _buildFeeItem(
                  title: 'Medical Insurance',
                  amount: '₹2,500',
                  isPaid: true,
                  description: 'Annual sports medical coverage',
                  dueDate: 'Sep 30, 2024',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Transactions
          _buildFinanceSection(
            title: 'Recent Transactions',
            icon: Icons.history,
            child: Column(
              children: [
                _buildTransactionItem(
                  title: 'Training Fee Payment',
                  amount: '₹10,000',
                  date: 'Feb 15, 2025',
                  type: 'Credit',
                  method: 'Online Banking',
                  reference: 'TRX23456789',
                ),
                const Divider(),
                _buildTransactionItem(
                  title: 'Late Fee',
                  amount: '₹500',
                  date: 'Feb 2, 2025',
                  type: 'Debit',
                  method: 'Auto-charged',
                  reference: 'LATE-FEB2025',
                ),
                const Divider(),
                _buildTransactionItem(
                  title: 'Equipment Purchase',
                  amount: '₹3,500',
                  date: 'Jan 20, 2025',
                  type: 'Debit',
                  method: 'Cash',
                  reference: 'EQP-2501-234',
                ),
                const Divider(),
                _buildTransactionItem(
                  title: 'Scholarship Credit',
                  amount: '₹5,000',
                  date: 'Dec 10, 2024',
                  type: 'Credit',
                  method: 'Institution Transfer',
                  reference: 'SCH-2024-056',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Payment Options
          _buildFinanceSection(
            title: 'Payment Options',
            icon: Icons.payment,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance, color: Colors.blue),
                  ),
                  title: const Text('Online Banking'),
                  subtitle:
                      const Text('Transfer funds directly to our account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.credit_card, color: Colors.green),
                  ),
                  title: const Text('Credit/Debit Card'),
                  subtitle: const Text('Pay securely with your card'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone_android, color: Colors.purple),
                  ),
                  title: const Text('Mobile Payment'),
                  subtitle: const Text('UPI, Paytm, Google Pay and more'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.money, color: Colors.amber),
                  ),
                  title: const Text('Cash Payment'),
                  subtitle: const Text('Pay in person at our office'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Financial Assistance
          _buildFinanceSection(
            title: 'Financial Assistance & Scholarships',
            icon: Icons.volunteer_activism,
            child: Column(
              children: [
                _buildAssistanceItem(
                  title: 'Merit Scholarship',
                  status: 'Awarded',
                  statusColor: Colors.green,
                  amount: '₹15,000',
                  description:
                      'Based on outstanding performance in regional championships',
                  date: 'Dec 5, 2024',
                ),
                const Divider(),
                _buildAssistanceItem(
                  title: 'Financial Need Grant',
                  status: 'In Review',
                  statusColor: Colors.orange,
                  amount: '₹20,000',
                  description:
                      'Application under review by scholarship committee',
                  date: 'Feb 20, 2025',
                ),
                const Divider(),
                _buildAssistanceItem(
                  title: 'Sports Excellence Fund',
                  status: 'Not Applied',
                  statusColor: Colors.grey,
                  amount: 'Up to ₹50,000',
                  description:
                      'Available for state-level players with 3+ years of training',
                  date: 'Applications open July 2025',
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.article),
                  label: const Text('Apply for Financial Assistance'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Support and Contact
          _buildFinanceSection(
            title: 'Finance Department Contact',
            icon: Icons.support_agent,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.email, color: Colors.orange),
                  ),
                  title: const Text('Email Support'),
                  subtitle: const Text('finance@academysports.com'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, color: Colors.teal),
                  ),
                  title: const Text('Phone Support'),
                  subtitle: const Text('+91 98765 43210'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.schedule, color: Colors.indigo),
                  ),
                  title: const Text('Office Hours'),
                  subtitle: const Text('Monday-Friday: 9:00 AM - 5:00 PM'),
                  trailing: const Icon(Icons.info_outline, size: 18),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legal notice
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Financial Record Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This financial information is private and confidential. For any discrepancies in the financial records, please contact the finance department within 7 days of noticing the issue.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceStat({
    required String label,
    required String value,
    required IconData icon,
    required bool isNegative,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNegative
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isNegative ? Colors.red : Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isNegative ? Colors.red : Colors.green.shade700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem({
    required String title,
    required String amount,
    required bool isPaid,
    required String description,
    required String dueDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              color: isPaid ? Colors.green : Colors.orange,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isPaid
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        isPaid ? 'Paid' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String amount,
    required String date,
    required String type,
    required String method,
    required String reference,
  }) {
    final bool isCredit = type == 'Credit';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      isCredit ? '+$amount' : '-$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            method,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reference,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistanceItem({
    required String title,
    required String status,
    required Color statusColor,
    required String amount,
    required String description,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
