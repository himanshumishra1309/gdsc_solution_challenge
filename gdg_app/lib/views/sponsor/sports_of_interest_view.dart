import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class SportsOfInterestView extends StatefulWidget {
  const SportsOfInterestView({super.key});

  @override
  _SportsOfInterestViewState createState() => _SportsOfInterestViewState();
}

class _SportsOfInterestViewState extends State<SportsOfInterestView> with SingleTickerProviderStateMixin {
  List<SportItem> _allSports = [
    SportItem(name: 'Cricket', icon: Icons.sports_cricket),
    SportItem(name: 'Football', icon: Icons.sports_soccer),
    SportItem(name: 'Badminton', icon: Icons.sports_tennis),
    SportItem(name: 'Tennis', icon: Icons.sports_tennis),
    SportItem(name: 'Basketball', icon: Icons.sports_basketball),
    SportItem(name: 'Hockey', icon: Icons.sports_hockey),
    SportItem(name: 'Volleyball', icon: Icons.sports_volleyball),
    SportItem(name: 'Table Tennis', icon: Icons.table_chart),
    SportItem(name: 'Swimming', icon: Icons.pool),
    SportItem(name: 'Athletics', icon: Icons.directions_run),
    SportItem(name: 'Golf', icon: Icons.golf_course),
    SportItem(name: 'Chess', icon: Icons.grid_on),
  ];
  
  List<SportItem> _filteredSports = [];
  List<String> _selectedSports = [];
  String _searchQuery = '';
  String _selectedDrawerItem = sportsOfInterestRoute;
  bool _isEditing = false;
  late TabController _tabController;
  
  final List<String> _categories = [
    'All', 'Team Sports', 'Individual Sports', 'Selected'
  ];

  @override
  void initState() {
    super.initState();
    _filteredSports = _allSports;
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterByCategory(_categories[_tabController.index]);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterSports(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      if (category == 'All') {
        _filteredSports = _allSports;
      } else if (category == 'Team Sports') {
        _filteredSports = _allSports.where((sport) => 
          ['Cricket', 'Football', 'Basketball', 'Hockey', 'Volleyball'].contains(sport.name)
        ).toList();
      } else if (category == 'Individual Sports') {
        _filteredSports = _allSports.where((sport) => 
          ['Tennis', 'Badminton', 'Golf', 'Swimming', 'Athletics', 'Table Tennis', 'Chess'].contains(sport.name)
        ).toList();
      } else if (category == 'Selected') {
        _filteredSports = _allSports.where((sport) => 
          _selectedSports.contains(sport.name)
        ).toList();
      }
      
      // Apply search filter if there is a query
      if (_searchQuery.isNotEmpty) {
        _filteredSports = _filteredSports.where((sport) => 
          sport.name.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
    });
  }
  
  void _applyFilters() {
    _filterByCategory(_categories[_tabController.index]);
  }

  void _toggleSelection(String sport) {
    setState(() {
      if (_selectedSports.contains(sport)) {
        _selectedSports.remove(sport);
      } else {
        _selectedSports.add(sport);
      }
      
      // Refresh the list if in "Selected" tab
      if (_categories[_tabController.index] == 'Selected') {
        _applyFilters();
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveSelections() {
    // Here you would save the selected sports to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${_selectedSports.length} sport interests'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    _toggleEditMode();
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
        title: const Text('Sports of Interest'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        toolbarHeight: 65.0,
        actions: [
          // Toggle edit mode
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveSelections : _toggleEditMode,
            tooltip: _isEditing ? 'Save Changes' : 'Edit Interests',
          ),
        ],
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
          // Header section with purple background
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
                    onChanged: _filterSports,
                    decoration: InputDecoration(
                      hintText: 'Search sports',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.deepPurple),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilters();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                
                // Category tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: _categories.map((category) => Tab(
                    child: Row(
                      children: [
                        _getCategoryIcon(category),
                        const SizedBox(width: 8),
                        Text(category),
                        if (category == 'Selected')
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_selectedSports.length}',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // Selected sports count and clear button
          if (_isEditing && _selectedSports.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.deepPurple.shade50,
              child: Row(
                children: [
                  Text(
                    '${_selectedSports.length} sports selected',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    onPressed: () {
                      setState(() {
                        _selectedSports.clear();
                        _applyFilters();
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          
          // Sports grid
          Expanded(
            child: _filteredSports.isEmpty
                ? _buildEmptyView()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredSports.length,
                    itemBuilder: (context, index) {
                      final sport = _filteredSports[index];
                      final isSelected = _selectedSports.contains(sport.name);
                      return _buildSportCard(sport, isSelected);
                    },
                  ),
          ),
          
          // Action buttons
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSelections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSportCard(SportItem sport, bool isSelected) {
    return GestureDetector(
      onTap: _isEditing ? () => _toggleSelection(sport.name) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple.shade500, Colors.deepPurple.shade700],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sport icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    sport.icon,
                    size: 32,
                    color: isSelected ? Colors.white : Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                // Sport name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    sport.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                // Description/tags
                if (!isSelected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      _getSportCategory(sport.name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Selection indicator
            if (_isEditing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.deepPurple,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No sports found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
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
                _tabController.animateTo(0); // Switch to "All" tab
                _applyFilters();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getSportCategory(String sportName) {
    final teamSports = ['Cricket', 'Football', 'Basketball', 'Hockey', 'Volleyball'];
    return teamSports.contains(sportName) ? 'Team Sport' : 'Individual Sport';
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return const Icon(Icons.apps, size: 18);
      case 'Team Sports':
        return const Icon(Icons.group, size: 18);
      case 'Individual Sports':
        return const Icon(Icons.person, size: 18);
      case 'Selected':
        return const Icon(Icons.favorite, size: 18);
      default:
        return const Icon(Icons.sports, size: 18);
    }
  }
}

class SportItem {
  final String name;
  final IconData icon;
  
  SportItem({
    required this.name,
    required this.icon,
  });
}