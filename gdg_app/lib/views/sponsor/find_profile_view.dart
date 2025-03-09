// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class FindProfilesView extends StatefulWidget {
  const FindProfilesView({super.key});

  @override
  _FindProfilesViewState createState() => _FindProfilesViewState();
}

class _FindProfilesViewState extends State<FindProfilesView> with SingleTickerProviderStateMixin {
  List<Map<String, String>> _profiles = [];
  List<Map<String, String>> _filteredProfiles = [];
  String _searchQuery = '';
  String _selectedCategory = 'individuals';
  String _selectedDrawerItem = findOrganizationOrPlayersRoute;
  List<String> _selectedFilters = [];
  late TabController _tabController;
  bool _isLoading = true;

  final List<String> _sportsFilters = ['Cricket', 'Football', 'Tennis', 'Basketball', 'Golf', 'Swimming'];
  final List<String> _locationFilters = ['Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Kolkata'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadProfiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _tabController.index == 0 ? 'individuals' : 'organizations';
        _loadProfiles();
      });
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });

    // Add a small delay to simulate network loading
    await Future.delayed(const Duration(milliseconds: 800));

    const String jsonData = '''
    {
      "individuals": [
        {
          "name": "John Doe",
          "username": "johndoe",
          "image": "assets/images/player1.png",
          "location": "Mumbai",
          "sport": "Cricket",
          "rating": "4.8"
        },
        {
          "name": "Jane Smith",
          "username": "janesmith",
          "image": "assets/images/player2.jpg",
          "location": "Delhi",
          "sport": "Tennis",
          "rating": "4.6"
        },
        {
          "name": "Alice Johnson",
          "username": "alicejohnson",
          "image": "assets/images/player3.jpg",
          "location": "Bangalore",
          "sport": "Football",
          "rating": "4.9"
        },
        {
          "name": "Bob Brown",
          "username": "bobbrown",
          "image": "assets/images/player4.png",
          "location": "Chennai",
          "sport": "Basketball",
          "rating": "4.5"
        },
        {
          "name": "Charlie Davis",
          "username": "charliedavis",
          "image": "assets/images/player5.jpg",
          "location": "Kolkata",
          "sport": "Golf",
          "rating": "4.2"
        },
        {
          "name": "Diana Evans",
          "username": "dianaevans",
          "image": "assets/images/player6.png",
          "location": "Mumbai",
          "sport": "Swimming",
          "rating": "4.7"
        }
      ],
      "organizations": [
        {
          "name": "Mumbai Cricket Club",
          "username": "mumbai_cricket",
          "image": "assets/images/player1.png",
          "location": "Mumbai",
          "sport": "Cricket",
          "rating": "4.8"
        },
        {
          "name": "Delhi Tennis Academy",
          "username": "delhi_tennis",
          "image": "assets/images/player2.jpg",
          "location": "Delhi",
          "sport": "Tennis",
          "rating": "4.3"
        },
        {
          "name": "Bangalore FC",
          "username": "bangalore_fc",
          "image": "assets/images/player3.jpg",
          "location": "Bangalore",
          "sport": "Football",
          "rating": "4.9"
        },
        {
          "name": "Chennai Basketball League",
          "username": "chennai_bball",
          "image": "assets/images/player4.png",
          "location": "Chennai",
          "sport": "Basketball",
          "rating": "4.6"
        },
        {
          "name": "Kolkata Golf Club",
          "username": "kolkata_golf",
          "image": "assets/images/player5.jpg",
          "location": "Kolkata",
          "sport": "Golf",
          "rating": "4.5"
        },
        {
          "name": "Mumbai Swimming Association",
          "username": "mumbai_swim",
          "image": "assets/images/player6.png",
          "location": "Mumbai",
          "sport": "Swimming",
          "rating": "4.4"
        }
      ]
    }
    ''';
    
    final data = json.decode(jsonData);
    setState(() {
      _profiles = List<Map<String, String>>.from(
        (data[_selectedCategory] as List).map((item) => Map<String, String>.from(item))
      );
      _filteredProfiles = _profiles;
      _isLoading = false;
    });
  }

  void _filterProfiles() {
    setState(() {
      _filteredProfiles = _profiles.where((profile) {
        // Apply search query filter
        bool matchesQuery = profile['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               profile['username']!.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Apply sport and location filters
        bool matchesFilters = true;
        for (String filter in _selectedFilters) {
          if (!((profile['sport'] ?? '').contains(filter) || (profile['location'] ?? '').contains(filter))) {
            matchesFilters = false;
            break;
          }
        }
        
        return matchesQuery && matchesFilters;
      }).toList();
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
      _filterProfiles();
    });
  }

  void _onSelectDrawerItem(String route) {
    if (route != _selectedDrawerItem) {
      setState(() {
        _selectedDrawerItem = route;
      });
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, landingPageRoute);
  }

  void _viewProfile(Map<String, String> profile) {
  // Show a bottom sheet with more profile details
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        // Use CustomScrollView to handle both fixed and scrollable content
        child: CustomScrollView(
          controller: controller, // Connect to DraggableScrollableSheet
          slivers: [
            // Profile header - fixed at top
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(profile['image']!),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['name']!,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${profile['username']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  profile['location'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  profile['rating'] ?? '4.0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
                  
                  // Sport and other details
                  Text(
                    'Sport',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getSportIcon(profile['sport'] ?? ''),
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          profile['sport'] ?? 'Not specified',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bio section (simulated)
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam vel justo nec nisi efficitur scelerisque. Nullam facilisis metus eget massa posuere, in condimentum nisl facilisis.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  
                  // Achievements (simulated)
                  const SizedBox(height: 24),
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            // Achievements list - can grow/scroll as needed
            SliverToBoxAdapter(
              child: _buildAchievementsList(),
            ),
            
            // Spacer that pushes the button to the bottom when there's room
            const SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: SizedBox(height: 20),
            ),
            
            // Contact button - appears at the bottom
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Contact request sent to ${profile['name']}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Contact for Sponsorship',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildAchievementsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.amber.shade100,
            child: Icon(
              Icons.emoji_events, 
              color: Colors.amber.shade700,
              size: 20,
            ),
          ),
          title: Text(
            'Achievement ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Description of achievement ${index + 1}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'golf':
        return Icons.golf_course;
      case 'swimming':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.article, title: 'News and Updates', route: sponsorHomeViewRoute),
      DrawerItem(icon: Icons.sports, title: 'Sports of Interest', route: sportsOfInterestRoute),
      DrawerItem(icon: Icons.mail, title: 'Invitations', route: invitationToSponsorRoute),
      DrawerItem(icon: Icons.request_page, title: 'Requests', route: requestToSponsorPageRoute),
      DrawerItem(icon: Icons.search, title: 'Find Organization or Players', route: findOrganizationOrPlayersRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Partners',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        toolbarHeight: 65.0,
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
        onLogout: _handleLogout,
      ),
      body: Column(
        children: [
          // Header with background color
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                )
              ],
            ),
            child: Column(
              children: [
                // Search bar
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                        _filterProfiles();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search names or usernames',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.deepPurple),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _filterProfiles();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                
                // Tab bar for category selection
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Text('Individuals'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business),
                          SizedBox(width: 8),
                          Text('Organizations'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedFilters.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilters.clear();
                            _filterProfiles();
                          });
                        },
                        child: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Sport filters
                      ..._sportsFilters.map((sport) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(sport),
                          selected: _selectedFilters.contains(sport),
                          onSelected: (_) => _toggleFilter(sport),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: Colors.deepPurple.shade100,
                          checkmarkColor: Colors.deepPurple,
                          labelStyle: TextStyle(
                            color: _selectedFilters.contains(sport)
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _selectedFilters.contains(sport)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      )),
                      // Location filters
                      ..._locationFilters.map((location) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(location),
                          selected: _selectedFilters.contains(location),
                          onSelected: (_) => _toggleFilter(location),
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: Colors.deepPurple.shade100,
                          checkmarkColor: Colors.deepPurple,
                          labelStyle: TextStyle(
                            color: _selectedFilters.contains(location)
                                ? Colors.deepPurple
                                : Colors.black87,
                            fontWeight: _selectedFilters.contains(location)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          avatar: Icon(
                            Icons.location_on,
                            size: 14,
                            color: _selectedFilters.contains(location)
                                ? Colors.deepPurple
                                : Colors.grey.shade600,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Profile grid
          Expanded(
            child: _isLoading 
                ? _buildLoadingView()
                : _filteredProfiles.isEmpty
                    ? _buildEmptyView()
                    : RefreshIndicator(
                        onRefresh: _loadProfiles,
                        color: Colors.deepPurple,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = _filteredProfiles[index];
                            return _buildProfileCard(profile);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, String> profile) {
  return GestureDetector(
    onTap: () => _viewProfile(profile),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image (with fixed height to prevent overflow)
          SizedBox(
            height: 120, // Reduced from 140
            child: Stack(
              children: [
                Image.asset(
                  profile['image']!,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile['rating'] ?? '4.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Sport badge
                if (profile['sport'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        profile['sport']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Profile details - use a tight height constraint
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use minimum size
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name']!,
                    style: const TextStyle(
                      fontSize: 14, // Smaller font
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // Smaller gap
                  Text(
                    '@${profile['username']}',
                    style: TextStyle(
                      fontSize: 12, // Smaller font
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Location
                  if (profile['location'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12, // Smaller icon
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2), // Smaller gap
                        Expanded(
                          child: Text(
                            profile['location']!,
                            style: TextStyle(
                              fontSize: 11, // Smaller font
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profiles...',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No profiles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty
                ? 'Try adjusting your filters'
                : 'Try selecting a different category',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedFilters.clear();
                _loadProfiles();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}