import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/views/coach/coach_home_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gdg_app/serivces/admin_services.dart';
import 'package:gdg_app/constants/api_constants.dart';

class AdminViewCoaches extends StatefulWidget {
  const AdminViewCoaches({super.key});

  @override
  _AdminViewCoachesState createState() => _AdminViewCoachesState();
}

class _AdminViewCoachesState extends State<AdminViewCoaches>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _adminService = AdminService();
  List<dynamic> _coaches = [];
  List<dynamic> _filteredCoaches = [];
  String _searchQuery = '';
  String _selectedSport = 'All';
  String _sortBy = 'Name (A-Z)';
  bool _isLoading = true;
  bool _isGridView = false;
  late AnimationController _animationController;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCoaches = 0;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

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
    'Experience (Most)',
    'Experience (Least)'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadCoaches();
    _loadUserInfo();
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

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Determine sort parameters based on current selection
      String sortField = 'name';
      String sortOrder = 'asc';

      switch (_sortBy) {
        case 'Name (A-Z)':
          sortField = 'name';
          sortOrder = 'asc';
          break;
        case 'Name (Z-A)':
          sortField = 'name';
          sortOrder = 'desc';
          break;
        case 'Sport':
          sortField = 'sport';
          sortOrder = 'asc';
          break;
        case 'Experience (Most)':
          sortField = 'experience';
          sortOrder = 'desc';
          break;
        case 'Experience (Least)':
          sortField = 'experience';
          sortOrder = 'asc';
          break;
      }

      // Call the API through AdminService
      final result = await _adminService.getAllCoaches(
        page: _currentPage,
        limit: 10, // You can adjust this as needed
        sort: sortField,
        order: sortOrder,
        search: _searchQuery,
        sport: _selectedSport,
      );

      if (result['success']) {
        setState(() {
          // Transform the API response to match your UI's expected structure
          _coaches = result['coaches'].map<Map<String, dynamic>>((coach) {
            return {
              'id': coach['_id'],
              'name': coach['name'] ?? 'No Name',
              'email': coach['email'] ?? 'No Email',
              'primarySport': coach['sport'] ?? 'Other',
              'specialization': coach['designation'] ?? 'Coach',
              'yearsOfExperience':
                  int.tryParse(coach['experience']?.toString() ?? '0') ?? 0,
              'profilePhoto': coach['avatar'] ??
                  'assets/default_profile.png', // Use a default image path
              'dateJoined': coach['createdAt'] != null
                  ? DateTime.parse(coach['createdAt']).toString()
                  : 'Unknown',
              'status': coach['status'] ?? 'Active',
              'contactNumber': coach['contactNumber'] ?? 'N/A',
              'organization': coach['organization']?['name'] ?? 'N/A',
              'assignedAthletes': coach['assignedAthletes'] ?? [],
              'coachId': coach['_id'] ?? 'COACH-XXXX',
              // Add any other fields your UI needs
            };
          }).toList();

          // Update pagination information
          final pagination = result['pagination'];
          _totalPages = pagination['totalPages'] ?? 1;
          _currentPage = pagination['currentPage'] ?? 1;
          _totalCoaches = pagination['totalCoaches'] ?? 0;
          _hasNextPage = pagination['hasNextPage'] ?? false;
          _hasPrevPage = pagination['hasPrevPage'] ?? false;

          // Filter coaches based on any client-side filters you want to keep
          _filteredCoaches = _coaches;
          _isLoading = false;
        });
      } else {
        setState(() {
          _coaches = [];
          _filteredCoaches = [];
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading coaches: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _loadCoaches: $e');
      setState(() {
        _coaches = [];
        _filteredCoaches = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortCoaches() {
    List<dynamic> sortedCoaches = List.from(_coaches);

    switch (_sortBy) {
      case 'Name (A-Z)':
        sortedCoaches.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'Name (Z-A)':
        sortedCoaches.sort(
            (a, b) => b['name'].toString().compareTo(a['name'].toString()));
        break;
      case 'Sport':
        sortedCoaches.sort((a, b) => a['primarySport']
            .toString()
            .compareTo(b['primarySport'].toString()));
        break;
      case 'Experience (Most)':
        sortedCoaches.sort((a, b) => (b['yearsOfExperience'] ?? 0)
            .compareTo(a['yearsOfExperience'] ?? 0));
        break;
      case 'Experience (Least)':
        sortedCoaches.sort((a, b) => (a['yearsOfExperience'] ?? 0)
            .compareTo(b['yearsOfExperience'] ?? 0));
        break;
    }

    _filteredCoaches = sortedCoaches.where((coach) {
      final matchesName =
          coach['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false;
      final matchesSport =
          _selectedSport == 'All' || coach['primarySport'] == _selectedSport;
      return matchesName && matchesSport;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // Reset to first page when searching
      _loadCoaches(); // Load directly from API instead of filtering locally
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _currentPage = 1; // Reset to first page when filtering
      _loadCoaches(); // Load directly from API instead of filtering locally
    });
  }

  void _onSortByChanged(String? sortOption) {
    setState(() {
      _sortBy = sortOption!;
      _loadCoaches(); // Reload with new sort option
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the bottom sheet to expand
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6, // Initial height (60% of screen)
              minChildSize:
                  0.3, // Minimum height when collapsed (30% of screen)
              maxChildSize: 0.9, // Maximum height when expanded (90% of screen)
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle for better UX
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Title
                        const Row(
                          children: [
                            Icon(Icons.filter_list, color: Colors.deepPurple),
                            SizedBox(width: 10),
                            Text(
                              'Filter Coaches',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sport',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sportFilters.map((sport) {
                            return FilterChip(
                              label: Text(sport),
                              selected: _selectedSport == sport,
                              selectedColor: Colors.deepPurple.withOpacity(0.2),
                              checkmarkColor: Colors.deepPurple,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedSport = sport;
                                });
                                setState(() {
                                  _selectedSport = sport;
                                  _sortCoaches();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sort By',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sortOptions.map((option) {
                            return ChoiceChip(
                              label: Text(option),
                              selected: _sortBy == option,
                              selectedColor: Colors.deepPurple.withOpacity(0.2),
                              onSelected: (selected) {
                                setModalState(() {
                                  _sortBy = option;
                                });
                                setState(() {
                                  _sortBy = option;
                                  _sortCoaches();
                                });
                              },
                            );
                          }).toList(),
                        ),

                        // Additional filters can be added here
                        const SizedBox(height: 20),
                        const Text(
                          'Experience Level',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.deepPurple,
                            inactiveTrackColor:
                                Colors.deepPurple.withOpacity(0.2),
                            thumbColor: Colors.deepPurple,
                            overlayColor: Colors.deepPurple.withOpacity(0.1),
                          ),
                          child: Slider(
                            value:
                                5, // Replace with your actual experience filter value
                            min: 0,
                            max: 20,
                            divisions: 20,
                            label: '5+ years',
                            onChanged: (value) {
                              // Update your experience filter
                              setModalState(() {
                                // _experienceFilter = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 30),
                        // Replace the Apply Filters button in the _showFilterBottomSheet method (around line 297)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // Load data with filters
                              setState(() {
                                _currentPage =
                                    1; // Reset to page 1 when applying filters
                                _loadCoaches();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Update the reset filters text button in _showFilterBottomSheet (around line 311)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedSport = 'All';
                                _sortBy = 'Name (A-Z)';
                              });
                              setState(() {
                                _selectedSport = 'All';
                                _sortBy = 'Name (A-Z)';
                                _currentPage = 1; // Reset to page 1
                                _loadCoaches(); // Re-fetch data from API
                              });
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
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
                        'Coach Directory Help',
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
                  title: 'Search Coaches',
                  description: 'Use the search bar to find coaches by name.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.filter_alt,
                  title: 'Filter by Sport',
                  description: 'Filter the coach list by their primary sport.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.sort,
                  title: 'Sort Coaches',
                  description:
                      'Sort coaches by name, sport, or years of experience.',
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  icon: Icons.grid_view,
                  title: 'Change View',
                  description: 'Toggle between list and grid view.',
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.deepPurple),
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
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToCoachProfile(Map<String, dynamic> coach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachProfileWrapper(coach: coach),
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _hasPrevPage
                ? () {
                    setState(() {
                      _currentPage--;
                      _loadCoaches();
                    });
                  }
                : null,
            color: _hasPrevPage ? Colors.deepPurple : Colors.grey,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _hasNextPage
                ? () {
                    setState(() {
                      _currentPage++;
                      _loadCoaches();
                    });
                  }
                : null,
            color: _hasNextPage ? Colors.deepPurple : Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Directory'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            color: Colors.white,
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: Colors.white,
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter & Sort',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            color: Colors.white,
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: viewAllCoachesRoute,
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
          // Search bar in purple container
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search coaches by name...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter pills
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Selected sport pill
                        if (_selectedSport != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_selectedSport),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedSport = 'All';
                                  _sortCoaches();
                                });
                              },
                              backgroundColor:
                                  Colors.deepPurple.withOpacity(0.1),
                              side: BorderSide(
                                  color: Colors.deepPurple.withOpacity(0.3)),
                            ),
                          ),

                        // Sort by pill
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Sort: $_sortBy'),
                            avatar: const Icon(Icons.sort, size: 18),
                            backgroundColor: Colors.grey.shade200,
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),

                        Chip(
                          label: Text('$_totalCoaches Coaches'),
                          backgroundColor: Colors.grey.shade200,
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Replace the Expanded widget in the build method (that contains the coach list) with:
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple))
                : _filteredCoaches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No coaches found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your search criteria',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _isGridView
                                ? AnimationLimiter(
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.75,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: _filteredCoaches.length,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredGrid(
                                          position: index,
                                          columnCount: 2,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: ScaleAnimation(
                                            child: FadeInAnimation(
                                              child: _buildCoachGridCard(
                                                  _filteredCoaches[index]),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : AnimationLimiter(
                                    child: ListView.builder(
                                      itemCount: _filteredCoaches.length,
                                      padding: const EdgeInsets.all(16),
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: SlideAnimation(
                                            horizontalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: _buildCoachListCard(
                                                  _filteredCoaches[index]),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          // Add pagination controls
                          _buildPaginationControls(),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, registerCoachRoute);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Coach',
      ),
    );
  }

  Widget _buildCoachGridCard(Map<String, dynamic> coach) {
    final sportColor = _getSportColor(coach['primarySport'] ?? '');

    return GestureDetector(
      onTap: () => _navigateToCoachProfile(coach),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top colored section with photo
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Colored gradient background
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [sportColor, sportColor.withOpacity(0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Profile photo
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'coach-avatar-${coach['id']}',
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(coach['profilePhoto'] ??
                              'assets/default_profile.png'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coach['name'] ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sportColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coach['primarySport'] ?? 'N/A',
                        style: TextStyle(
                          color: sportColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach['specialization'] ?? 'Coach',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachListCard(Map<String, dynamic> coach) {
    final sportColor = _getSportColor(coach['primarySport'] ?? '');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCoachProfile(coach),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile photo - FIXED WIDTH
              Hero(
                tag: 'coach-avatar-${coach['id']}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: sportColor, width: 2),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(coach['profilePhoto'] ??
                          'assets/default_profile.png'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Coach info - FIX: ADD EXPANDED HERE TO PREVENT OVERFLOW
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis, // Add this
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: sportColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            coach['primarySport'] ?? 'N/A',
                            style: TextStyle(
                              color: sportColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis, // Add this
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          // Add this wrapper
                          child: Text(
                            coach['specialization'] ?? 'Coach',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis, // Add this
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.stars,
                            size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Flexible(
                          // Add this wrapper
                          child: Text(
                            '${coach['yearsOfExperience'] ?? 0} years experience',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis, // Add this
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon - FIXED WIDTH
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
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
}

class CoachProfileWrapper extends StatelessWidget {
  final Map<String, dynamic> coach;

  const CoachProfileWrapper({required this.coach, super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure coach data has valid values to prevent null reference errors
    final safeCoachData = Map<String, dynamic>.from(coach);

    // Set default values for any potentially null properties
    if (safeCoachData['profilePhoto'] == null) {
      safeCoachData['profilePhoto'] = 'assets/images/player1.png';
    }

    if (safeCoachData['name'] == null) {
      safeCoachData['name'] = 'Coach Name';
    }

    if (safeCoachData['primarySport'] == null) {
      safeCoachData['primarySport'] = 'Default';
    }

    return Scaffold(
      body: CoachProfilePage(coachData: safeCoachData),
    );
  }
}

class CoachProfilePage extends StatefulWidget {
  final Map<String, dynamic> coachData;

  const CoachProfilePage({required this.coachData, super.key});

  @override
  _CoachProfilePageState createState() => _CoachProfilePageState();
}

class _CoachProfilePageState extends State<CoachProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final sportColor =
        _getSportColor(widget.coachData['primarySport'] ?? 'Default');

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              backgroundColor: sportColor,
              title: _isAppBarExpanded
                  ? Text(
                      widget.coachData['name'] ?? 'Coach Profile',
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
                          'coach-avatar-${widget.coachData['id'] ?? 'default'}',
                      child: Image.asset(
                        widget.coachData['profilePhoto'] ??
                            'assets/images/player1.png',
                        fit: BoxFit.cover,
                      ),
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
                    // Coach name and details - moved up to avoid overlap with tabs
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 60, // Increased to prevent tab overlap
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.coachData['name'] ?? 'Coach Name',
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
                                  color: sportColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.coachData['primarySport'] ?? 'Sport',
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
                                  '${widget.coachData['yearsOfExperience'] ?? '0'} yrs exp',
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
                                  widget.coachData['coachId'] ?? 'COACH-XXXX',
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
                      const SnackBar(content: Text('Edit coach profile')),
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
                            content: Text('Exporting coach profile...')),
                      );
                    } else if (value == 'archive') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archiving coach...')),
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
                          Text('Archive Coach'),
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
                      Tab(text: 'Teams'),
                      Tab(text: 'Schedule'),
                      Tab(text: 'Performance'),
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
            _buildTeamsTab(),
            _buildScheduleTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sending message to coach...')),
          );
        },
        backgroundColor: sportColor,
        icon: const Icon(Icons.message),
        label: const Text('Message'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final sportColor = _getSportColor(widget.coachData['primarySport'] ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach Bio Card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: sportColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Coach Biography',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    widget.coachData['bio'] ??
                        'Professional coach with expertise in ${widget.coachData['primarySport']}. Specializing in ${widget.coachData['specialization']}. Passionate about developing athletes to reach their full potential through personalized training and mentorship.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Coach Details
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: sportColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow('Full Name', widget.coachData['name']),
                  _buildInfoRow('Age', '${widget.coachData['age']} years'),
                  _buildInfoRow('Sport', widget.coachData['primarySport']),
                  _buildInfoRow(
                      'Specialization', widget.coachData['specialization']),
                  _buildInfoRow('Experience',
                      '${widget.coachData['yearsOfExperience']} years'),
                  _buildInfoRow(
                      'Certification',
                      widget.coachData['certification'] ??
                          'National Level Coach'),
                  _buildInfoRow('Email',
                      widget.coachData['email'] ?? 'coach@academysports.com'),
                  _buildInfoRow(
                      'Phone', widget.coachData['phone'] ?? '+91 98765 43210'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Achievements
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: sportColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Achievements & Certifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildAchievementItem(
                    title: 'National Championship Winner',
                    year: '2018',
                    description: 'Led team to national victory',
                  ),
                  const Divider(height: 24),
                  _buildAchievementItem(
                    title: 'Advanced Coaching Certification',
                    year: '2020',
                    description: 'International coaching association',
                  ),
                  const Divider(height: 24),
                  _buildAchievementItem(
                    title: 'Coach of the Year',
                    year: '2022',
                    description: 'Regional sports association award',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Training Philosophy
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: sportColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Training Philosophy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    widget.coachData['philosophy'] ??
                        "I believe in a holistic approach to training that focuses on technical skill development, physical conditioning, and mental preparation. My coaching methodology emphasizes personalized attention to each athlete's unique needs and talents, fostering an environment of continuous improvement and teamwork.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildPhilosophyItem(
                          'Technical Excellence', Icons.sports_soccer),
                      _buildPhilosophyItem(
                          'Mental Toughness', Icons.psychology),
                      _buildPhilosophyItem('Team Spirit', Icons.people),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String year,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSportColor(widget.coachData['primarySport'])
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            year,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getSportColor(widget.coachData['primarySport']),
            ),
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
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhilosophyItem(String label, IconData icon) {
    final sportColor = _getSportColor(widget.coachData['primarySport']);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sportColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: sportColor,
            ),
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
    );
  }

  Widget _buildTeamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Teams section
          Text(
            'Current Teams',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getSportColor(widget.coachData['primarySport']),
            ),
          ),
          const SizedBox(height: 12),
          _buildTeamCard(
            name: 'Junior Athletics Team',
            role: 'Head Coach',
            members: 14,
            ageGroup: 'U-16',
            imagePath: 'assets/team_images/team1.jpg',
          ),
          const SizedBox(height: 12),
          _buildTeamCard(
            name: 'Senior Competition Squad',
            role: 'Technical Director',
            members: 22,
            ageGroup: '18+',
            imagePath: 'assets/team_images/team2.jpg',
          ),

          const SizedBox(height: 24),

          // Past Teams section
          Text(
            'Past Teams',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getSportColor(widget.coachData['primarySport']),
            ),
          ),
          const SizedBox(height: 12),
          _buildPastTeamItem(
            name: 'City Sports Academy',
            duration: '2018-2022',
            achievement: 'Regional Champions 2020',
          ),
          const Divider(),
          _buildPastTeamItem(
            name: 'National Youth Team',
            duration: '2015-2018',
            achievement: 'National Quarter-Finalists',
          ),
          const Divider(),
          _buildPastTeamItem(
            name: 'University Team',
            duration: '2012-2015',
            achievement: 'University Champions',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard({
    required String name,
    required String role,
    required int members,
    required String ageGroup,
    required String imagePath,
  }) {
    final sportColor = _getSportColor(widget.coachData['primarySport']);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team image
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: AssetImage(
                    'assets/team_placeholder.jpg'), // Use a placeholder since the actual image might not exist
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sportColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        ageGroup,
                        style: TextStyle(
                          color: sportColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Coach Role: $role',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Team size: $members members',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.people),
                        label: const Text('View Team'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: sportColor,
                          side: BorderSide(color: sportColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.analytics),
                        label: const Text('Performance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sportColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildPastTeamItem({
    required String name,
    required String duration,
    required String achievement,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor:
            _getSportColor(widget.coachData['primarySport']).withOpacity(0.2),
        child: const Icon(Icons.history, color: Colors.grey),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Duration: $duration',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Text(
            achievement,
            style: TextStyle(
              color: _getSportColor(widget.coachData['primarySport']),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () {},
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
                colors: [
                  _getSportColor(widget.coachData['primarySport']),
                  _getSportColor(widget.coachData['primarySport'])
                      .withAlpha(200)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getSportColor(widget.coachData['primarySport'])
                      .withOpacity(0.3),
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
                    _buildScheduleStat('8', 'Sessions', Icons.event),
                    _buildScheduleStat('16h', 'Total Hours', Icons.timer),
                    _buildScheduleStat('3', 'Teams', Icons.people),
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
                  title: 'Morning Training',
                  timeRange: '6:00 AM - 8:00 AM',
                  location: 'Main Field',
                  team: 'Junior Athletics Team',
                  type: 'Regular',
                  typeColor: Colors.blue,
                ),
                const Divider(),
                _buildTrainingSession(
                  title: 'Advanced Skills Session',
                  timeRange: '4:00 PM - 6:00 PM',
                  location: 'Training Center',
                  team: 'Senior Competition Squad',
                  type: 'Technical',
                  typeColor: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Weekly schedule overview
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
                          'time': '06:00',
                          'title': 'Morning Training',
                          'color': Colors.blue,
                        },
                        {
                          'time': '16:00',
                          'title': 'Advanced Skills',
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
                          'time': '10:00',
                          'title': 'Team Strategy',
                          'color': Colors.green,
                        },
                        {
                          'time': '15:00',
                          'title': 'Junior Training',
                          'color': Colors.purple,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'WED',
                      date: 'Mar 10',
                      sessions: const [
                        {
                          'time': '08:30',
                          'title': 'Conditioning',
                          'color': Colors.red,
                        },
                        {
                          'time': '16:30',
                          'title': 'Match Prep',
                          'color': Colors.indigo,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'THU',
                      date: 'Mar 11',
                      sessions: const [
                        {
                          'time': '14:00',
                          'title': 'Team Meeting',
                          'color': Colors.teal,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'FRI',
                      date: 'Mar 12',
                      sessions: const [
                        {
                          'time': '07:00',
                          'title': 'Skill Training',
                          'color': Colors.amber,
                        },
                        {
                          'time': '16:00',
                          'title': 'Team Practice',
                          'color': Colors.deepPurple,
                        },
                      ],
                    ),
                    _buildDaySchedule(
                      day: 'SAT',
                      date: 'Mar 13',
                      sessions: const [
                        {
                          'time': '09:00',
                          'title': 'Competition',
                          'color': Colors.green,
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

          // Upcoming events
          _buildScheduleSection(
            title: 'Upcoming Events',
            icon: Icons.upcoming,
            child: Column(
              children: [
                _buildEventItem(
                  title: 'Regional Tournament',
                  date: 'March 20-22, 2025',
                  location: 'City Sports Complex',
                  role: 'Head Coach',
                  type: 'Competition',
                  typeColor: Colors.red,
                ),
                const Divider(),
                _buildEventItem(
                  title: 'Coaching Workshop',
                  date: 'April 5, 2025',
                  location: 'National Sports Institute',
                  role: 'Presenter',
                  type: 'Workshop',
                  typeColor: Colors.blue,
                ),
                const Divider(),
                _buildEventItem(
                  title: 'Selection Trials',
                  date: 'April 15, 2025',
                  location: 'Academy Training Center',
                  role: 'Selection Committee',
                  type: 'Trials',
                  typeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final sportColor = _getSportColor(widget.coachData['primarySport']);

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
                colors: [sportColor, sportColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: sportColor.withOpacity(0.3),
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
                      'Coaching Performance',
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
                        '92%', 'Success Rate', Icons.trending_up),
                    _buildPerformanceStat(
                        '87%', 'Team Satisfaction', Icons.emoji_emotions),
                    _buildPerformanceStat('95%', 'Attendance', Icons.people),
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
                      child: Row(
                        children: [
                          Text(
                            '4.8',
                            style: TextStyle(
                              color: sportColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Team Performance
          _buildSection(
            title: 'Team Performance',
            icon: Icons.groups,
            child: Column(
              children: [
                _buildTeamPerformanceItem(
                  teamName: 'Junior Athletics Team',
                  winLoss: '8-2',
                  progress: 0.8,
                  progressLabel: '80%',
                  trend: 'Improving',
                  trendIcon: Icons.trending_up,
                  trendColor: Colors.green,
                ),
                const Divider(),
                _buildTeamPerformanceItem(
                  teamName: 'Senior Competition Squad',
                  winLoss: '12-3',
                  progress: 0.85,
                  progressLabel: '85%',
                  trend: 'Stable',
                  trendIcon: Icons.trending_flat,
                  trendColor: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Athlete Development
          _buildSection(
            title: 'Athlete Development',
            icon: Icons.person_outline,
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildSkillProgressBar(
                  label: 'Technical Improvement',
                  progress: 0.87,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Physical Development',
                  progress: 0.92,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Strategic Understanding',
                  progress: 0.79,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildSkillProgressBar(
                  label: 'Team Coordination',
                  progress: 0.83,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reviews & Feedback
          _buildSection(
            title: 'Reviews & Feedback',
            icon: Icons.rate_review,
            child: Column(
              children: [
                _buildReviewItem(
                  reviewer: 'Athletics Director',
                  date: 'Feb 28, 2025',
                  comment:
                      'Coach demonstrates exceptional technical knowledge and leadership skills. Athletes show consistent improvement under guidance.',
                  rating: 5,
                ),
                const Divider(),
                _buildReviewItem(
                  reviewer: 'Parent Council',
                  date: 'Jan 15, 2025',
                  comment:
                      'Excellent communication with parents. Creates positive environment for young athletes while maintaining high standards.',
                  rating: 5,
                ),
                const Divider(),
                _buildReviewItem(
                  reviewer: 'Peer Review',
                  date: 'Dec 10, 2024',
                  comment:
                      'Strong technical coaching with innovative training methods. Could improve administrative documentation.',
                  rating: 4,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Professional Development
          _buildSection(
            title: 'Professional Development',
            icon: Icons.school,
            child: Column(
              children: [
                _buildDevelopmentItem(
                  title: 'Advanced Coaching Certification',
                  status: 'Completed',
                  date: 'Jan 2025',
                  statusColor: Colors.green,
                ),
                const Divider(),
                _buildDevelopmentItem(
                  title: 'Sports Psychology Workshop',
                  status: 'Completed',
                  date: 'Nov 2024',
                  statusColor: Colors.green,
                ),
                const Divider(),
                _buildDevelopmentItem(
                  title: 'International Coaching Conference',
                  status: 'Upcoming',
                  date: 'May 2025',
                  statusColor: Colors.blue,
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final sportColor = _getSportColor(widget.coachData['primarySport']);

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
                    color: sportColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: sportColor),
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

  Widget _buildScheduleSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final sportColor = _getSportColor(widget.coachData['primarySport']);

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
                    color: sportColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: sportColor),
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
    required String team,
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
                    Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      team,
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
        color: isToday
            ? _getSportColor(widget.coachData['primarySport']).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? _getSportColor(widget.coachData['primarySport'])
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isToday
                  ? _getSportColor(widget.coachData['primarySport'])
                  : Colors.grey.shade100,
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

  Widget _buildEventItem({
    required String title,
    required String date,
    required String location,
    required String role,
    required String type,
    required Color typeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'Competition'
                  ? Icons.emoji_events
                  : type == 'Workshop'
                      ? Icons.school
                      : Icons.event,
              color: typeColor,
              size: 24,
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
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
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

  Widget _buildTeamPerformanceItem({
    required String teamName,
    required String winLoss,
    required double progress,
    required String progressLabel,
    required String trend,
    required IconData trendIcon,
    required Color trendColor,
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
                  teamName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis, // Add this
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSportColor(widget.coachData['primarySport'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'W/L: $winLoss',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getSportColor(widget.coachData['primarySport']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Performance',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          progressLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getSportColor(
                                widget.coachData['primarySport']),
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
                          width: MediaQuery.of(context).size.width *
                              progress *
                              0.6,
                          decoration: BoxDecoration(
                            color: _getSportColor(
                                widget.coachData['primarySport']),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: trendColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendIcon,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
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
              style: const TextStyle(
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

  Widget _buildReviewItem({
    required String reviewer,
    required String date,
    required String comment,
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
                reviewer,
                style: const TextStyle(
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
            comment,
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

  Widget _buildDevelopmentItem({
    required String title,
    required String status,
    required String date,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSportColor(widget.coachData['primarySport'])
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              size: 16,
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
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
              ],
            ),
          ),
        ],
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
}
