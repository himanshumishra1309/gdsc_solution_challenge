import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class PlayerFinancialView extends StatefulWidget {
  const PlayerFinancialView({super.key});

  @override
  _PlayerFinancialViewState createState() => _PlayerFinancialViewState();
}

class _PlayerFinancialViewState extends State<PlayerFinancialView> {
  String _selectedDrawerItem = playerFinancialViewRoute; // Highlight the current page
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
      return MapEntry(key, 0);
    })..removeWhere((key, value) => value == null);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerProfileRoute),
      DrawerItem(icon: Icons.people, title: 'View Coaches', route: viewCoachProfileRoute),
      DrawerItem(icon: Icons.bar_chart, title: 'View Stats', route: viewPlayerStatisticsRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Medical Reports', route: medicalReportRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Nutritional Plan', route: nutritionalPlanRoute),
      DrawerItem(icon: Icons.announcement, title: 'View Announcements', route: playerviewAnnouncementRoute),
      DrawerItem(icon: Icons.calendar_today, title: 'View Calendar', route: viewCalendarRoute),
      DrawerItem(icon: Icons.fitness_center, title: 'View Gym Plan', route: viewGymPlanRoute),
      DrawerItem(icon: Icons.edit, title: 'Fill Injury Form', route: fillInjuryFormRoute),
      DrawerItem(icon: Icons.attach_money, title: 'Finances', route: playerFinancialViewRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Financial View'),
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