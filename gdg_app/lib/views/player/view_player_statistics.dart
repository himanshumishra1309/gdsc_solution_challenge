import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewPlayerStatistics extends StatefulWidget {
  const ViewPlayerStatistics({super.key});

  @override
  _ViewPlayerStatisticsState createState() => _ViewPlayerStatisticsState();
}

class _ViewPlayerStatisticsState extends State<ViewPlayerStatistics> {
  String _selectedDrawerItem = viewPlayerStatisticsRoute;
  String _selectedSport = 'Football';
  Map<String, dynamic> _playerStats = {};
  String _searchQuery = '';
  bool _sortAscending = true; // For sorting

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    final String response = await rootBundle.loadString('assets/json_files/player_statistics.json');
    final data = await json.decode(response);
    setState(() {
      _playerStats = data[_selectedSport.toLowerCase()];
    });
  }

  void _onSportChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSport = newValue;
        _loadPlayerData();
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
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

  void _sortTable(String column, bool ascending) {
    setState(() {
      final entries = _playerStats.entries.toList();
      entries.sort((a, b) {
        if (column == 'Category') {
          return ascending ? a.key.compareTo(b.key) : b.key.compareTo(a.key);
        } else if (column == 'Statistic') {
          return ascending
              ? a.value.toString().compareTo(b.value.toString())
              : b.value.toString().compareTo(a.value.toString());
        }
        return 0;
      });
      _playerStats = Map.fromEntries(entries);
      _sortAscending = ascending;
    });
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

    // Filter player stats based on search query
    final filteredStats = _playerStats.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             entry.value.toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Player Statistics'),
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
            // Search Bar and Dropdown
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
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
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 1.5),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSport,
                    onChanged: _onSportChanged,
                    items: <String>['Football', 'Cricket', 'Badminton'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 28),
                    dropdownColor: Colors.white,
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Data Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: const Text('Category'),
                        onSort: (columnIndex, ascending) {
                          _sortTable('Category', ascending);
                        },
                      ),
                      DataColumn(
                        label: const Text('Statistic'),
                        onSort: (columnIndex, ascending) {
                          _sortTable('Statistic', ascending);
                        },
                      ),
                    ],
                    rows: filteredStats.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toString())),
                      ]);
                    }).toList(),
                    sortAscending: _sortAscending,
                    sortColumnIndex: 0, // Default sort by Category
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    dataRowHeight: 48,
                    headingRowHeight: 56,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    dataTextStyle: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}