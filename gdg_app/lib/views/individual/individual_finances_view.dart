import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualFinances extends StatefulWidget {
  const IndividualFinances({super.key});

  @override
  _IndividualFinancesState createState() => _IndividualFinancesState();
}

class _IndividualFinancesState extends State<IndividualFinances> {
  String _selectedDrawerItem = individualFinancesRoute; // Highlight the current page
  Map<String, double> _financeData = {
    'Prize Money': 5000.0,
    'Sponsorship Deals': 10000.0,
    'Grants & Scholarships': 2000.0,
    'Freelance Training Income': 1500.0,
    'Crowdfunding/Donations': 800.0,
    'Training & Coaching Fees': 3000.0,
    'Gym & Sports Facility Costs': 1200.0,
    'Equipment & Gear': 2500.0,
    'Travel & Accommodation': 4000.0,
    'Medical & Physiotherapy': 1800.0,
    'Nutrition & Supplements': 600.0,
    'Insurance Costs': 1000.0,
    'Taxes & Compliance': 500.0,
    'Personal Savings': 7000.0,
    'Sports Equipment Investment': 3000.0,
    'Retirement Planning': 5000.0,
    'Expense Tracking': 15000.0,
    'Budget Planning': 12000.0,
    'Pending Payments/Dues': 2000.0,
  };

  String _searchQuery = ''; // For search functionality

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  void _editFinance(String key) {
    TextEditingController controller = TextEditingController(text: _financeData[key].toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $key'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
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
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Filter finance data based on search query
  Map<String, double> get _filteredFinanceData {
    if (_searchQuery.isEmpty) {
      return _financeData;
    }
    return _financeData.map((key, value) {
      if (key.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return MapEntry(key, value);
      }
      return MapEntry(key, 10);
    })..removeWhere((key, value) => value == null);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.home, title: 'Home', route: individualHomeRoute),
      DrawerItem(icon: Icons.upload_file, title: 'Upload Achievement', route: uploadAchievementRoute),
      DrawerItem(icon: Icons.video_library, title: 'Game Videos', route: gameVideosRoute),
      DrawerItem(icon: Icons.contact_mail, title: 'View and Contact Sponsor', route: viewContactSponsorRoute),
      DrawerItem(icon: Icons.fastfood, title: 'Daily Diet Plan', route: individualDailyDietRoute),
      DrawerItem(icon: Icons.fitness_center, title: 'Gym Plan', route: individualGymPlanRoute),
      DrawerItem(icon: Icons.attach_money, title: 'Finances', route: individualFinancesRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Finances'),
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
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: drawerItems,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
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
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Data Table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  columns: const [
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _filteredFinanceData.entries.map((entry) {
                    return DataRow(
                      cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text('\$${entry.value.toStringAsFixed(2)}')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () => _editFinance(entry.key),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}