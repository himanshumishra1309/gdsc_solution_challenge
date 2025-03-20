import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class AdminFinancialView extends StatefulWidget {
  const AdminFinancialView({super.key});

  @override
  _AdminFinancialViewState createState() => _AdminFinancialViewState();
}

class _AdminFinancialViewState extends State<AdminFinancialView> {
  final _authService = AuthService();
  String _selectedDrawerItem = adminManagePlayerFinancesRoute;
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  String _popupSearchQuery = '';

  // Enhanced player data with more financial information
  final List<Map<String, dynamic>> _players = [
    {
      'name': 'Virat Kohli',
      'image': 'assets/images/player1.png',
      'sport': 'Cricket',
      'total_funds': 500000.0,
      'remaining': 325000.0,
      'status': 'Active',
      'lastTransaction': '2023-03-15',
    },
    {
      'name': 'Saina Nehwal',
      'image': 'assets/images/player2.jpg',
      'sport': 'Badminton',
      'total_funds': 350000.0,
      'remaining': 120000.0,
      'status': 'Active',
      'lastTransaction': '2023-03-10',
    },
    {
      'name': 'Sunil Chhetri',
      'image': 'assets/images/player3.jpg',
      'sport': 'Football',
      'total_funds': 425000.0,
      'remaining': 380000.0,
      'status': 'Active',
      'lastTransaction': '2023-03-05',
    },
    {
      'name': 'PV Sindhu',
      'image': 'assets/images/player4.png',
      'sport': 'Badminton',
      'total_funds': 450000.0,
      'remaining': 290000.0,
      'status': 'Active',
      'lastTransaction': '2023-03-12',
    },
  ];

  // Finance categories with descriptions
  final Map<String, Map<String, dynamic>> _financeCategories = {
    'Salary/Stipend': {
      'amount': 5000.0,
      'description': 'Monthly stipend paid to player',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    'Prize Money': {
      'amount': 2000.0,
      'description': 'Tournament winnings allocation',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
    },
    'Sponsorship': {
      'amount': 10000.0,
      'description': 'Revenue from brand sponsorships',
      'icon': Icons.handshake,
      'color': Colors.blue,
    },
    'Training': {
      'amount': 3000.0,
      'description': 'Training facilities and coaching',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
    },
    'Travel': {
      'amount': 4000.0,
      'description': 'Transportation and accommodation',
      'icon': Icons.flight,
      'color': Colors.purple,
    },
    'Medical': {
      'amount': 2000.0,
      'description': 'Healthcare and insurance',
      'icon': Icons.medical_services,
      'color': Colors.red,
    },
    'Equipment': {
      'amount': 2500.0,
      'description': 'Sports gear and equipment',
      'icon': Icons.sports_cricket,
      'color': Colors.teal,
    },
  };

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != item) {
      Navigator.pushReplacementNamed(context, item);
    }
  }

  void _handleLogout(BuildContext context) async {
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
        Navigator.pop(context);
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

  void _showPlayerFinance(Map<String, dynamic> player) {
    final controller = ScrollController();
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter categories based on search
            final filteredCategories = _financeCategories.entries
                .where((entry) => entry.key
                    .toLowerCase()
                    .contains(_popupSearchQuery.toLowerCase()))
                .toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Player info header with gradient
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(player['image']),
                                radius: 30,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player['name'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      player['sport'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  player['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildFinanceSummaryCard(
                                'Total Allocated',
                                player['total_funds'],
                                Icons.account_balance,
                                Colors.white,
                              ),
                              const SizedBox(width: 16),
                              _buildFinanceSummaryCard(
                                'Remaining',
                                player['remaining'],
                                Icons.savings,
                                Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Categories',
                          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                          suffixIcon: _popupSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      _popupSearchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _popupSearchQuery = value;
                          });
                        },
                      ),
                    ),

                    // Categories list
                    Expanded(
                      child: filteredCategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No categories found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Scrollbar(
                              controller: controller,
                              thickness: 8,
                              radius: const Radius.circular(12),
                              child: // Categories list in the _showPlayerFinance method
ListView.builder(
  controller: controller,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  itemCount: filteredCategories.length,
  itemBuilder: (context, index) {
    final entry = filteredCategories[index];
    final category = entry.key;
    final data = entry.value;
    final amountController = TextEditingController(
      text: data['amount'].toString(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Icon and title in one line
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: data['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    data['icon'],
                    color: data['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Category title
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Second row: Description in small font
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: Text(
                data['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Third row: Amount field and save button
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.deepPurple),
                  onPressed: () {
                    final newValue = double.tryParse(amountController.text);
                    if (newValue != null) {
                      setState(() {
                        _financeCategories[category]?['amount'] = newValue;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Updated $category to ₹${newValue.toStringAsFixed(2)}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
),
                            ),
                    ),

                    // Action buttons at bottom
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('CANCEL'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Save all changes
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Financial changes saved successfully'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            icon: const Icon(Icons.save),
                            label: const Text('SAVE ALL'),
                          ),
                        ],
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
  }

  Widget _buildFinanceSummaryCard(String label, double amount, IconData icon, Color textColor) {
    final formatter = NumberFormat.currency(symbol: '₹');
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatter.format(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
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
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
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
    ];

    // Filter players based on search and sport selection
    List<Map<String, dynamic>> filteredPlayers = _players.where((player) {
      final matchesSearch = player['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSport = _selectedSport == 'All Sports' || player['sport'] == _selectedSport;
      return matchesSearch && matchesSport;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Finance Manager'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: _onSelectDrawerItem,
        drawerItems: drawerItems,
        onLogout:() => _handleLogout(context),
      ),
      body: Column(
        children: [
          // Stats summary at top
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Total Budget', '₹16.25L', Icons.account_balance, Colors.amber),
                    const SizedBox(width: 12),
                    _buildStatCard('Allocated', '₹11.15L', Icons.people, Colors.green),
                    const SizedBox(width: 12),
                    _buildStatCard('Available', '₹5.10L', Icons.savings, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          
          // Search and filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search players...',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 12),
                
                // Sport filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSportFilterChip('All Sports', Icons.sports),
                      _buildSportFilterChip('Cricket', Icons.sports_cricket),
                      _buildSportFilterChip('Badminton', Icons.sports_tennis),
                      _buildSportFilterChip('Football', Icons.sports_soccer),
                      _buildSportFilterChip('Basketball', Icons.sports_basketball),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Players (${filteredPlayers.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: 'Alphabetical',
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Alphabetical',
                      child: Text('Alphabetical'),
                    ),
                    DropdownMenuItem(
                      value: 'Budget: High to Low',
                      child: Text('Budget: High to Low'),
                    ),
                    DropdownMenuItem(
                      value: 'Budget: Low to High',
                      child: Text('Budget: Low to High'),
                    ),
                  ],
                  onChanged: (value) {
                    // Handle sorting
                  },
                ),
              ],
            ),
          ),

          // Player grid
          Expanded(
            child: filteredPlayers.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredPlayers.length,
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      final progress = player['remaining'] / player['total_funds'];
                      return _buildPlayerFinanceCard(player, progress);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show dialog to add new player
        },
        backgroundColor: Colors.deepPurple,
        label: const Text('ADD PLAYER'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
  }

  Widget _buildSportFilterChip(String sport, IconData icon) {
    final isSelected = _selectedSport == sport;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.deepPurple,
            ),
            const SizedBox(width: 6),
            Text(sport),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSport = sport;
          });
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.deepPurple,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.deepPurple,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

 Widget _buildPlayerFinanceCard(Map<String, dynamic> player, double progress) {
  final formatter = NumberFormat.currency(symbol: '₹');
  Color statusColor = progress > 0.7 
      ? Colors.green 
      : progress > 0.4 
          ? Colors.orange 
          : Colors.red;
  
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: () => _showPlayerFinance(player),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player header with image and overlay info - REDUCED HEIGHT
          AspectRatio(
            aspectRatio: 16/10, // Changed from 16/9 to reduce height
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    player['image'],
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay for text visibility
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // Sport icon badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSportIcon(player['sport']),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player['sport'],
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
                // Player name at bottom
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 10,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Last updated: ${player['lastTransaction']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
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
              ],
            ),
          ),
          
          // Financial details section - REDUCED PADDING
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Important to prevent expansion
              children: [
                // Funds info in cards
                Row(
                  children: [
                    // Total funds card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 12, // Reduced size
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 3), // Reduced spacing
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatter.format(player['total_funds']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6), // Reduced spacing
                    // Remaining funds card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Reduced padding
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.savings,
                                  size: 12, // Reduced size
                                  color: statusColor,
                                ),
                                const SizedBox(width: 3), // Reduced spacing
                                const Text(
                                  'Rem.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatter.format(player['remaining']),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced spacing
                
                // Progress bar with budget utilization
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important to prevent expansion
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Budget Used',
                          style: TextStyle(
                            fontSize: 10, // Reduced font size
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${((1 - progress) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3), // Reduced spacing
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4), // Reduced radius
                      child: LinearProgressIndicator(
                        value: 1 - progress,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 5, // Reduced height
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action buttons - MOVED TO THE BOTTOM TO FILL REMAINING SPACE
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30, // Fixed height
                        child: ElevatedButton.icon(
                          onPressed: () => _showPlayerFinance(player),
                          icon: const Icon(Icons.visibility, size: 14),
                          label: const Text('Details', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero, // Remove padding
                            minimumSize: Size.zero, // No minimum size
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6), // Reduced spacing
                    Expanded(
                      child: SizedBox(
                        height: 30, // Fixed height
                        child: OutlinedButton.icon(
                          onPressed: () => _showTransferDialog(player),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Fund', style: TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: EdgeInsets.zero, // Remove padding
                            minimumSize: Size.zero, // No minimum size
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyState() {
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
          'No players found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _searchQuery.isEmpty
                ? 'Try selecting a different sport category'
                : 'Try adjusting your search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _selectedSport = 'All Sports';
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

void _showTransferDialog(Map<String, dynamic> player) {
  final amountController = TextEditingController();
  final formatter = NumberFormat.currency(symbol: '₹');
  String selectedPurpose = 'Training';
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Transfer Funds to ${player['name']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 20, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatter.format(player['remaining']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount input
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Transfer Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            
            // Transfer purpose
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purpose',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPurposeChip('Training', Icons.fitness_center, selectedPurpose, (value) {
                          setState(() => selectedPurpose = value);
                        }),
                        _buildPurposeChip('Travel', Icons.flight, selectedPurpose, (value) {
                          setState(() => selectedPurpose = value);
                        }),
                        _buildPurposeChip('Medical', Icons.medical_services, selectedPurpose, (value) {
                          setState(() => selectedPurpose = value);
                        }),
                        _buildPurposeChip('Stipend', Icons.attach_money, selectedPurpose, (value) {
                          setState(() => selectedPurpose = value);
                        }),
                        _buildPurposeChip('Equipment', Icons.sports_cricket, selectedPurpose, (value) {
                          setState(() => selectedPurpose = value);
                        }),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              setState(() {
                player['remaining'] += amount;
                if (player['remaining'] > player['total_funds']) {
                  player['total_funds'] = player['remaining'];
                }
                player['lastTransaction'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
              });
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully transferred ${formatter.format(amount)} to ${player['name']}'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('TRANSFER'),
        ),
      ],
    ),
  );
}

Widget _buildPurposeChip(String label, IconData icon, String selectedValue, Function(String) onSelected) {
  final isSelected = selectedValue == label;
  
  return ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    ),
    selected: isSelected,
    onSelected: (selected) {
      if (selected) {
        onSelected(label);
      }
    },
    backgroundColor: Colors.white,
    selectedColor: Colors.deepPurple,
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : Colors.black,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey.shade300,
      ),
    ),
  );
}

IconData _getSportIcon(String sport) {
  switch (sport) {
    case 'Cricket':
      return Icons.sports_cricket;
    case 'Football':
      return Icons.sports_soccer;
    case 'Badminton':
      return Icons.sports_tennis;
    case 'Basketball':
      return Icons.sports_basketball;
    case 'All Sports':
      return Icons.sports;
    default:
      return Icons.sports;
  }
}
}