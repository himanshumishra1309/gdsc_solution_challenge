import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with SingleTickerProviderStateMixin {
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late TabController _tabController;
  
  // Event categories with colors
  final Map<String, Color> _eventCategories = {
    'Practice': Colors.blue.shade700,
    'Meeting': Colors.amber.shade700,
    'Training': Colors.green.shade700,
    'Match': Colors.red.shade700,
  };

  final Map<DateTime, List<Map<String, dynamic>>> _sessions = {
    DateTime.utc(2025, 2, 10): [
      {
        'time': '10:00 AM',
        'session': 'Practice Session',
        'coach': 'Coach John Doe',
        'type': 'Practice',
        'location': 'Field 2',
        'duration': '2 hours',
        'notes': 'Focus on defensive drills and set pieces',
      },
      {
        'time': '2:00 PM',
        'session': 'Strategy Meeting',
        'coach': 'Coach Jane Smith',
        'type': 'Meeting',
        'location': 'Room A',
        'duration': '1 hour',
        'notes': 'Pre-tournament planning and video analysis',
      },
    ],
    DateTime.utc(2025, 2, 11): [
      {
        'time': '9:00 AM',
        'session': 'Fitness Training',
        'coach': 'Coach John Doe',
        'type': 'Training',
        'location': 'Gym',
        'duration': '1.5 hours',
        'notes': 'Strength and conditioning program',
      },
    ],
    DateTime.utc(2025, 2, 12): [
      {
        'time': '11:00 AM',
        'session': 'Team Meeting',
        'coach': 'Coach Jane Smith',
        'type': 'Meeting',
        'location': 'Room B',
        'duration': '45 minutes',
        'notes': 'Review of recent performance and feedback',
      },
    ],
    DateTime.utc(2025, 2, 13): [
      {
        'time': '3:00 PM',
        'session': 'Tactical Training',
        'coach': 'Coach John Doe',
        'type': 'Training',
        'location': 'Field 1',
        'duration': '2 hours',
        'notes': 'Formation practice and tactical adjustments',
      },
    ],
    DateTime.utc(2025, 2, 14): [
      {
        'time': '8:00 AM',
        'session': 'Warm-up Session',
        'coach': 'Coach Jane Smith',
        'type': 'Practice',
        'location': 'Indoor Court',
        'duration': '1 hour',
        'notes': 'Light warm-up and stretching',
      },
      {
        'time': '5:00 PM',
        'session': 'Friendly Match vs. City FC',
        'coach': 'Coach John Doe',
        'type': 'Match',
        'location': 'Main Stadium',
        'duration': '2.5 hours',
        'notes': 'Friendly match to test new tactics',
      },
    ],
    DateTime.utc(2025, 2, 15): [
      {
        'time': '10:00 AM',
        'session': 'Recovery Session',
        'coach': 'Coach Jane Smith',
        'type': 'Training',
        'location': 'Swimming Pool',
        'duration': '1 hour',
        'notes': 'Light recovery exercises and pool therapy',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSessionsForDay(DateTime day) {
    // Filter sessions based on search query and selected sport
    final daySessions = _sessions[DateTime.utc(day.year, day.month, day.day)] ?? [];
    
    if (_searchQuery.isEmpty && _selectedSport == 'All Sports') {
      return daySessions;
    }
    
    return daySessions.where((session) {
      final matchesSearch = _searchQuery.isEmpty || 
          session['session'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session['coach'].toLowerCase().contains(_searchQuery.toLowerCase());
          
      final matchesSport = _selectedSport == 'All Sports' || 
          (_selectedSport == 'Football'); // In a real app, you'd have sport field in sessions
          
      return matchesSearch && matchesSport;
    }).toList();
  }

  int _getEventsForDay(DateTime day) {
    return _getSessionsForDay(day).length;
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

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }
  
  // Get appropriate icon based on session type
  IconData _getSessionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'practice':
        return Icons.sports_soccer;
      case 'meeting':
        return Icons.people;
      case 'training':
        return Icons.fitness_center;
      case 'match':
        return Icons.emoji_events;
      default:
        return Icons.calendar_today;
    }
  }
  
  void _showSessionDetails(Map<String, dynamic> session) {
    final sessionType = session['type'] as String;
    final typeColor = _eventCategories[sessionType] ?? Colors.deepPurple;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Session type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSessionIcon(sessionType),
                          size: 16,
                          color: typeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sessionType,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Session title
              Text(
                session['session'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Session details
              _buildSessionDetailRow(
                Icons.access_time,
                'Time',
                session['time'],
                Colors.blue.shade700,
              ),
              const SizedBox(height: 12),
              _buildSessionDetailRow(
                Icons.timelapse,
                'Duration',
                session['duration'],
                Colors.purple.shade700,
              ),
              const SizedBox(height: 12),
              _buildSessionDetailRow(
                Icons.location_on,
                'Location',
                session['location'],
                Colors.red.shade700,
              ),
              const SizedBox(height: 12),
              _buildSessionDetailRow(
                Icons.person,
                'Coach',
                session['coach'],
                Colors.green.shade700,
              ),
              const SizedBox(height: 24),
              
              // Notes section
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  session['notes'],
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder set for this session')),
                        );
                      },
                      icon: const Icon(Icons.notifications_active, size: 18),
                      label: const Text('Set Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message sent to coach')),
                        );
                      },
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Contact Coach'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSessionDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sessionCount = _getEventsForDay(_selectedDay ?? now);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Calendar'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Go to today',
          ),
          IconButton(
            icon: const Icon(Icons.view_agenda),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
            tooltip: 'Change calendar view',
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: '/view-calendar',
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerHomeRoute),
          DrawerItem(icon: Icons.people, title: 'View Coaches', route: viewCoachProfileRoute),
          DrawerItem(icon: Icons.bar_chart, title: 'View Stats', route: viewPlayerStatisticsRoute),
          DrawerItem(icon: Icons.medical_services, title: 'View Medical Reports', route: medicalReportRoute),
          DrawerItem(icon: Icons.medical_services, title: 'View Nutritional Plan', route: nutritionalPlanRoute),
          DrawerItem(icon: Icons.announcement, title: 'View Announcements', route: playerviewAnnouncementRoute),
          DrawerItem(icon: Icons.calendar_today, title: 'View Calendar', route: viewCalendarRoute),
          DrawerItem(icon: Icons.fitness_center, title: 'View Gym Plan', route: viewGymPlanRoute),
          DrawerItem(icon: Icons.edit, title: 'Fill Injury Form', route: fillInjuryFormRoute),
          DrawerItem(icon: Icons.attach_money, title: 'Finances', route: playerFinancialViewRoute),
        ],
        onLogout: () => _handleLogout(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search sessions',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSport,
                            onChanged: _onSportChanged,
                            items: <String>['All Sports', 'Football', 'Basketball', 'Tennis', 'Cricket']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      value == 'All Sports'
                                          ? Icons.sports
                                          : value == 'Football'
                                              ? Icons.sports_soccer
                                              : value == 'Basketball'
                                                  ? Icons.sports_basketball
                                                  : value == 'Tennis'
                                                      ? Icons.sports_tennis
                                                      : Icons.sports_cricket,
                                      color: Colors.deepPurple,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value,
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.deepPurple),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Event type legend
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _eventCategories.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Calendar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) => _getSessionsForDay(day),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markersMaxCount: 3,
                  markersAnchor: 0.7,
                  markerDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    color: Colors.deepPurple.shade900,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left, 
                    color: Colors.deepPurple.shade800,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right, 
                    color: Colors.deepPurple.shade800,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            events.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Selected day header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('MMM d, yyyy').format(_selectedDay ?? now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sessionCount > 0 
                        ? '$sessionCount session${sessionCount > 1 ? 's' : ''}' 
                        : 'No sessions',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  sessionCount == 0
                      ? TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Feature coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Request'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            
            // Sessions list
                        // Sessions list
            Expanded(
              child: sessionCount == 0
                  ? SingleChildScrollView(  // Added SingleChildScrollView here
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sessions scheduled',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enjoy your free time!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _getSessionsForDay(_selectedDay ?? now).length,
                      itemBuilder: (context, index) {
                        // ListView builder content remains the same
                        final session = _getSessionsForDay(_selectedDay ?? now)[index];
                        final sessionType = session['type'] as String;
                        final typeColor = _eventCategories[sessionType] ?? Colors.deepPurple;
                        
                        // Existing code continues...
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showSessionDetails(session),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Time indicator
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getSessionIcon(sessionType),
                                          color: typeColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        session['time'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Session details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8, 
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: typeColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                sessionType,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: typeColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          session['session'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              session['coach'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                                                                    children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              session['location'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              session['duration'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Action button
                                  IconButton(
                                    onPressed: () => _showSessionDetails(session),
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: typeColor,
                                    ),
                                    splashRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the following month's sessions
          setState(() {
            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
            _selectedDay = _focusedDay;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jumped to ${DateFormat('MMMM yyyy').format(_focusedDay)}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.calendar_month, color: Colors.white),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Custom calendar dot marker builder
class EventDot extends StatelessWidget {
  final Color color;
  
  const EventDot({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.5),
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// Custom Calendar Header Builder
class CustomCalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  
  const CustomCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMMM().format(focusedDay);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Month and year
          Text(
            headerText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
          ),
          const Spacer(),
          // Today button
          InkWell(
            onTap: onTodayButtonTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigation arrows
          IconButton(
            onPressed: onLeftArrowTap,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(Icons.chevron_left, color: Colors.deepPurple.shade700, size: 20),
            ),
            splashRadius: 20,
          ),
          IconButton(
            onPressed: onRightArrowTap,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(Icons.chevron_right, color: Colors.deepPurple.shade700, size: 20),
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

// Enhanced AnimatedCalendarDay widget for more attractive day cells
class AnimatedCalendarDay extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final bool isUnavailable;
  final bool hasEvents;
  final int eventCount;
  final List<Color> eventColors;
  final VoidCallback onTap;
  
  const AnimatedCalendarDay({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.isUnavailable,
    required this.hasEvents,
    required this.eventCount,
    required this.eventColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.deepPurple
            : isToday
                ? Colors.deepPurple.withOpacity(0.2)
                : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: Colors.deepPurple, width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isOutside
                          ? Colors.grey.shade400
                          : isUnavailable
                              ? Colors.grey.shade400
                              : Colors.black87,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (hasEvents)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  height: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: eventColors.take(3).map((color) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : color,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}