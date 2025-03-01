import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewAnnouncements extends StatefulWidget {
  const ViewAnnouncements({super.key});

  @override
  _ViewAnnouncementsState createState() => _ViewAnnouncementsState();
}

class _ViewAnnouncementsState extends State<ViewAnnouncements> {
  String _selectedSport = 'Football';
  String _searchQuery = '';
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _announcements = [
    {
      'sport': 'Football',
      'announcement': 'Practice session at 5 PM.',
      'time': '02/10/2025 10:00 AM',
      'coach': 'Coach John Doe'
    },
    {
      'sport': 'Basketball',
      'announcement': 'Team meeting at 3 PM.',
      'time': '02/10/2025 09:00 AM',
      'coach': 'Coach Jane Smith'
    },
    // Add more announcements here...
  ];

  List<Map<String, dynamic>> get _filteredAnnouncements {
    return _announcements.where((announcement) {
      final matchesSport = announcement['sport'] == _selectedSport;
      final matchesSearchQuery = announcement['announcement']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null ||
          DateFormat('MM/dd/yyyy').format(_selectedDate!) ==
              DateFormat('MM/dd/yyyy').format(DateTime.parse(announcement['time']));
      return matchesSport && matchesSearchQuery && matchesDate;
    }).toList();
  }

  void _onSportChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSport = newValue;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Announcements'),
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
        selectedDrawerItem: '/view-announcements',
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
        },
        drawerItems: [
          DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerProfileRoute),
          DrawerItem(icon: Icons.people, title: 'View Coaches', route: viewCoachProfileRoute),
          DrawerItem(icon: Icons.bar_chart, title: 'View Stats', route: viewPlayerStatisticsRoute),
          DrawerItem(icon: Icons.medical_services, title: 'View Medical Reports', route: medicalReportRoute),
          DrawerItem(icon: Icons.medical_services, title: 'View Nutritional Plan', route: nutritionalPlanRoute),
          DrawerItem(icon: Icons.announcement, title: 'View Announcements', route: playerviewAnnouncementRoute),
          DrawerItem(icon: Icons.calendar_today, title: 'View Calendar', route: viewCalendarRoute),
          DrawerItem(icon: Icons.fitness_center, title: 'View Gym Plan', route: viewGymPlanRoute),
          DrawerItem(icon: Icons.edit, title: 'Fill Injury Form', route: fillInjuryFormRoute),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    items: <String>['Football', 'Basketball', 'Tennis', 'Cricket']
                        .map<DropdownMenuItem<String>>((String value) {
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
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAnnouncements.length,
                itemBuilder: (context, index) {
                  final announcement = _filteredAnnouncements[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement['announcement'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${announcement['time']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coach: ${announcement['coach']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
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