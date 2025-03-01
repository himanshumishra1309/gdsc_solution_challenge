// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  String _selectedSport = 'Football';
  String _searchQuery = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Map<String, dynamic>>> _sessions = {
    DateTime.utc(2025, 2, 10): [
      {
        'time': '10:00 AM',
        'session': 'Practice Session',
        'coach': 'Coach John Doe'
      },
      {
        'time': '2:00 PM',
        'session': 'Strategy Meeting',
        'coach': 'Coach Jane Smith'
      },
    ],
    DateTime.utc(2025, 2, 11): [
      {
        'time': '9:00 AM',
        'session': 'Fitness Training',
        'coach': 'Coach John Doe'
      },
    ],
    DateTime.utc(2025, 2, 12): [
      {
        'time': '11:00 AM',
        'session': 'Team Meeting',
        'coach': 'Coach Jane Smith'
      },
    ],
    DateTime.utc(2025, 2, 13): [
      {
        'time': '3:00 PM',
        'session': 'Tactical Training',
        'coach': 'Coach John Doe'
      },
    ],
    DateTime.utc(2025, 2, 14): [
      {
        'time': '8:00 AM',
        'session': 'Warm-up Session',
        'coach': 'Coach Jane Smith'
      },
    ],
  };

  List<Map<String, dynamic>> _getSessionsForDay(DateTime day) {
    return _sessions[day] ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 80.0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: '/view-calendar',
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
                      filled: true,
                      fillColor: Colors.deepPurple.withOpacity(0.1),
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
              ],
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getSessionsForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.deepPurple[700]),
                defaultTextStyle: TextStyle(color: Colors.deepPurple[900]),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Colors.deepPurple[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.deepPurple),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _getSessionsForDay(_selectedDay ?? _focusedDay).length,
                itemBuilder: (context, index) {
                  final session = _getSessionsForDay(_selectedDay ?? _focusedDay)[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['session'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time: ${session['time']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coach: ${session['coach']}',
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