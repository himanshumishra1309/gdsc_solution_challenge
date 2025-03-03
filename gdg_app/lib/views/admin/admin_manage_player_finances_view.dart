import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminFinancialView extends StatefulWidget {
  const AdminFinancialView({super.key});

  @override
  _AdminFinancialViewState createState() => _AdminFinancialViewState();
}

class _AdminFinancialViewState extends State<AdminFinancialView> {
  String _selectedDrawerItem = adminManagePlayerFinancesRoute; // Highlight the current page
  String _selectedSport = 'Cricket';
  String _searchQuery = ''; // For search functionality on the main page
  String _popupSearchQuery = ''; // For search functionality in the popup

  List<Map<String, String>> _players = [
    {'name': 'Player 1', 'image': 'assets/player1.png'},
    {'name': 'Player 2', 'image': 'assets/player2.png'},
    {'name': 'Player 3', 'image': 'assets/player3.png'},
    // Add more players as needed
  ];

  Map<String, double> _financeData = {
    'Salary/Stipend': 5000.0,
    'Prize Money Allocation': 2000.0,
    'Sponsorship Deals': 10000.0,
    'Training & Facility Sponsorship': 3000.0,
    'Travel & Accommodation Support': 4000.0,
    'Medical & Insurance Coverage': 2000.0,
    'Coaching Fees': 1500.0,
    'Team Equipment & Gear Costs': 2500.0,
    'Medical & Physiotherapy': 1800.0,
    'Nutrition & Supplements': 600.0,
    'Tax Deductions': 500.0,
    'Fines & Penalties': 200.0,
    'Team/Club Budget Allocation': 7000.0,
    'Funding Requests & Approvals': 3000.0,
    'Financial Aid & Loans': 5000.0,
    'Salary & Payment Statements': 15000.0,
    'Expense Breakdown': 12000.0,
    'Pending Approvals': 2000.0,
    'Annual Financial Summary': 25000.0,
  };

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  void _editFinance(String key, TextEditingController controller) {
    final newValue = double.tryParse(controller.text);
    if (newValue != null) {
      setState(() {
        _financeData[key] = newValue;
      });
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  void _showPlayerFinance(String playerName) {
    TextEditingController popupSearchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('$playerName\'s Finances'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Search Bar in Popup
                    TextField(
                      controller: popupSearchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _popupSearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Financial Data Table
                    DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                      ),
                      columns: const [
                        DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _financeData.entries.where((entry) {
                        return entry.key.toLowerCase().contains(_popupSearchQuery.toLowerCase());
                      }).map((entry) {
                        TextEditingController controller = TextEditingController(text: entry.value.toString());
                        return DataRow(
                          cells: [
                            DataCell(Text(entry.key)),
                            DataCell(
                              TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.save, color: Colors.deepPurple),
                                onPressed: () => _editFinance(entry.key, controller),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
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

    // Filter players based on search query
    final filteredPlayers = _players.where((player) {
      return player['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Financial View'),
        backgroundColor: Colors.deepPurple,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar on Main Page
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Players',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Sport Dropdown
            DropdownButton<String>(
              value: _selectedSport,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSport = newValue!;
                });
              },
              items: <String>['Cricket', 'Badminton', 'Football']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Player Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredPlayers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showPlayerFinance(filteredPlayers[index]['name']!),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(filteredPlayers[index]['image']!),
                            radius: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            filteredPlayers[index]['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
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
    );
  }
}