import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gdg_app/serivces/auth_service.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class AdminViewRequestSponsors extends StatefulWidget {
  const AdminViewRequestSponsors({super.key});

  @override
  _AdminViewRequestSponsorsState createState() => _AdminViewRequestSponsorsState();
}

class _AdminViewRequestSponsorsState extends State<AdminViewRequestSponsors> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  List<dynamic> _viewSponsors = [];
  List<dynamic> _requestSponsors = [];
  List<dynamic> _filteredSponsors = [];
  String _searchQuery = '';
  String _selectedMode = 'View';
  String _selectedSport = 'All';
  String _selectedTier = 'All';
  bool _isLoading = true;
  bool _isGridView = false;
  late TabController _tabController;
  
  final List<String> _sportFilters = ['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton', 'Swimming', 'Volleyball'];
  final List<String> _sponsorTiers = ['All', 'Platinum', 'Gold', 'Silver', 'Bronze'];

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Platinum':
        return Colors.blueGrey.shade700;
      case 'Gold':
        return Colors.amber.shade700;
      case 'Silver':
        return Colors.blueGrey.shade400;
      case 'Bronze':
        return Colors.brown.shade500;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadSponsors();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedMode = _tabController.index == 0 ? 'View' : 'Request';
        _filterSponsors();
      });
    }
  }

  Future<void> _loadSponsors() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final String viewResponse = await rootBundle.loadString('assets/json_files/sponsors_view.json');
      final String requestResponse = await rootBundle.loadString('assets/json_files/sponsors_request.json');
      final viewData = await json.decode(viewResponse);
      final requestData = await json.decode(requestResponse);
      
      setState(() {
        _viewSponsors = viewData;
        _requestSponsors = requestData;
        _filteredSponsors = _tabController.index == 0 ? viewData : requestData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _viewSponsors = [];
        _requestSponsors = [];
        _filteredSponsors = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading sponsors: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSponsors();
    });
  }

  void _onModeChanged(String? mode) {
    setState(() {
      _selectedMode = mode!;
      _filterSponsors();
      _tabController.animateTo(_selectedMode == 'View' ? 0 : 1);
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterSponsors();
    });
  }
  
  void _onTierChanged(String? tier) {
    setState(() {
      _selectedTier = tier!;
      _filterSponsors();
    });
  }
  
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _filterSponsors() {
    setState(() {
      if (_selectedMode == 'View') {
        _filteredSponsors = _viewSponsors.where((sponsor) {
          final matchesName = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesTier = _selectedTier == 'All' || sponsor['tier'] == _selectedTier;
          return matchesName && matchesTier;
        }).toList();
      } else {
        _filteredSponsors = _requestSponsors.where((sponsor) {
          final matchesName = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesSport = _selectedSport == 'All' || sponsor['sports'].contains(_selectedSport);
          return matchesName && matchesSport;
        }).toList();
      }
    });
  }

  void _showSponsorDetails(Map<String, dynamic> sponsor) {
    final isViewMode = _selectedMode == 'View';
    final sponsorColor = isViewMode ? _getTierColor(sponsor['tier'] ?? 'Bronze') : Colors.deepPurple;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(sponsor['profilePhoto'] ?? 'assets/images/player1.png'),
                      onBackgroundImageError: (_, __) => const Icon(Icons.business, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sponsor['name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 5),
                          if (isViewMode)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: sponsorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: sponsorColor.withOpacity(0.3))
                              ),
                              child: Text(
                                sponsor['tier'] ?? 'Unknown Tier',
                                style: TextStyle(
                                  color: sponsorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.sports, size: 14, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    (sponsor['sports'] as List<dynamic>).join(', '),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                _buildInfoRow(Icons.email, 'Email', sponsor['email'] ?? 'N/A'),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.phone, 'Phone', sponsor['phone'] ?? 'N/A'),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.location_on, 'Location', sponsor['location'] ?? 'N/A'),
                const SizedBox(height: 10),
                
                if (isViewMode) ...[
                  _buildInfoRow(Icons.calendar_today, 'Since', sponsor['since'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.attach_money, 'Contribution', sponsor['contribution'] ?? 'N/A'),
                  const SizedBox(height: 10),
                ] else ...[
                  _buildInfoRow(Icons.interests, 'Interest Level', sponsor['interestLevel'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.business, 'Company', sponsor['company'] ?? 'N/A'),
                  const SizedBox(height: 10),
                ],
                
                const Text(
                  'Details:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sponsor['details'] ?? 'No additional details available.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isViewMode)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactSponsorDialog();
                        },
                        child: const Text('Contact Sponsor'),
                      ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
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
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showContactSponsorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Sponsor'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent to sponsor!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddSponsorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Sponsor Request'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New sponsor request added!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Text(
                        'Filter Sponsors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (_selectedMode == 'View') ...[
                    const Text(
                      'Tier',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sponsorTiers.map((tier) {
                        Color tileColor = _getTierColor(tier);
                        return FilterChip(
                          label: Text(tier),
                          selected: _selectedTier == tier,
                          selectedColor: tileColor.withOpacity(0.2),
                          checkmarkColor: tileColor,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedTier = tier;
                            });
                            setState(() {
                              _selectedTier = tier;
                              _filterSponsors();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ] else ...[
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
                              _filterSponsors();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
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
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor Management'),
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
            tooltip: 'Filter',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white70),
          tabs: const [
            Tab(text: 'Current Sponsors'),
            Tab(text: 'Potential Sponsors'),
          ],
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: requestViewSponsorsRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
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
      body: Column(
        children: [
          // Search bar in purple container
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16,16, 16, 16),
            child: TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search sponsors...',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedMode == 'View' && _selectedTier != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_selectedTier),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedTier = 'All';
                                  _filterSponsors();
                                });
                              },
                              backgroundColor: _getTierColor(_selectedTier).withOpacity(0.1),
                              side: BorderSide(color: _getTierColor(_selectedTier).withOpacity(0.3)),
                            ),
                          ),
                          
                        if (_selectedMode == 'Request' && _selectedSport != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_selectedSport),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() {
                                  _selectedSport = 'All';
                                  _filterSponsors();
                                });
                              },
                              backgroundColor: Colors.deepPurple.withOpacity(0.1),
                              side: BorderSide(color: Colors.deepPurple.withOpacity(0.3)),
                            ),
                          ),
                        
                        // Total count pill
                        Chip(
                          label: Text('${_filteredSponsors.length} Sponsors'),
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
          
          // Sponsors list/grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _filteredSponsors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.business_center,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sponsors found',
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
                    : _isGridView
                        ? AnimationLimiter(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _filteredSponsors.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  columnCount: 2,
                                  duration: const Duration(milliseconds: 500),
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: _buildSponsorGridCard(_filteredSponsors[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              itemCount: _filteredSponsors.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildSponsorListCard(_filteredSponsors[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedMode == 'View' ? null : _showAddSponsorDialog,
        backgroundColor: _selectedMode == 'View' ? Colors.grey : Colors.deepPurple,
        label: Text(_selectedMode == 'View' ? 'Current Sponsors' : 'Add Sponsor Lead'),
        icon: Icon(_selectedMode == 'View' ? Icons.business : Icons.add),
        tooltip: _selectedMode == 'View' ? 'Current sponsors list' : 'Add new sponsor lead',
      ),
    );
  }
  
  Widget _buildSponsorGridCard(Map<String, dynamic> sponsor) {
    final isViewMode = _selectedMode == 'View';
    final sponsorColor = isViewMode ? _getTierColor(sponsor['tier'] ?? 'Bronze') : Colors.deepPurple;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSponsorDetails(sponsor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sponsor logo
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: sponsorColor, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(sponsor['profilePhoto'] ?? 'assets/default_profile.png'),
                    onError: (_, __) => const Icon(Icons.business, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Sponsor name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                sponsor['name'] ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tier or sports
            if (isViewMode)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: sponsorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sponsorColor.withOpacity(0.3)),
                ),
                child: Text(
                  sponsor['tier'] ?? 'Unknown Tier',
                  style: TextStyle(
                    color: sponsorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  (sponsor['sports'] as List<dynamic>).join(', '),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              
            const Spacer(),
            
            // View details button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sponsorColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  color: sponsorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSponsorListCard(Map<String, dynamic> sponsor) {
    final isViewMode = _selectedMode == 'View';
    final sponsorColor = isViewMode ? _getTierColor(sponsor['tier'] ?? 'Bronze') : Colors.deepPurple;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSponsorDetails(sponsor),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Sponsor logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: sponsorColor, width: 2),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(sponsor['profilePhoto'] ?? 'assets/default_profile.png'),
                    onError: (_, __) => const Icon(Icons.business, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Sponsor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 4),
                        // Sponsor info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      sponsor['email'] ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    sponsor['phone'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (isViewMode)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sponsorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: sponsorColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    sponsor['tier'] ?? 'Unknown Tier',
                                    style: TextStyle(
                                      color: sponsorColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Icon(Icons.sports, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        (sponsor['sports'] as List<dynamic>).join(', '),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: sponsorColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: sponsorColor,
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
      ),
    );
  }
}