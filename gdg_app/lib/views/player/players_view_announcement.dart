import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewAnnouncements extends StatefulWidget {
  const ViewAnnouncements({super.key});

  @override
  _ViewAnnouncementsState createState() => _ViewAnnouncementsState();
}

class _ViewAnnouncementsState extends State<ViewAnnouncements>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  String _selectedSport =
      'All Sports'; // Changed to include "All Sports" option
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _showFilters = false; // Toggle for responsive design
  late TabController _tabController;

  final List<String> _sportCategories = [
    'All Sports',
    'Football',
    'Basketball',
    'Tennis',
    'Cricket'
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': '1',
      'sport': 'Football',
      'announcement':
          'Practice session at 5 PM. All players are required to attend on time. Equipment check will be done before the session starts.',
      'time': '02/10/2025 10:00 AM',
      'coach': 'Coach John Doe',
      'priority': 'High',
      'isNew': true,
    },
    {
      'id': '2',
      'sport': 'Basketball',
      'announcement':
          'Team meeting at 3 PM to discuss the upcoming tournament strategy. Attendance is mandatory for all team members.',
      'time': '02/10/2025 09:00 AM',
      'coach': 'Coach Jane Smith',
      'priority': 'Medium',
      'isNew': true,
    },
    {
      'id': '3',
      'sport': 'Football',
      'announcement':
          'Friendly match scheduled against West Side FC on Saturday. All players to report at 9 AM.',
      'time': '02/09/2025 08:30 AM',
      'coach': 'Coach John Doe',
      'priority': 'High',
      'isNew': false,
    },
    {
      'id': '4',
      'sport': 'Cricket',
      'announcement':
          'Net practice session changed to 7 AM tomorrow due to expected rain in the afternoon.',
      'time': '02/08/2025 05:00 PM',
      'coach': 'Coach Mike Johnson',
      'priority': 'Medium',
      'isNew': false,
    },
    {
      'id': '5',
      'sport': 'Tennis',
      'announcement':
          'Court maintenance scheduled for this weekend. No practice on Saturday and Sunday.',
      'time': '02/07/2025 11:00 AM',
      'coach': 'Coach Sarah Williams',
      'priority': 'Low',
      'isNew': false,
    },
  ];

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Athlete";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAnnouncements {
    return _announcements.where((announcement) {
      final matchesSport = _selectedSport == 'All Sports' ||
          announcement['sport'] == _selectedSport;
      final matchesSearchQuery = announcement['announcement']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null ||
          _selectedDate!.day == DateTime.now().day; // Simplified for demo
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

  void _clearFilters() {
    setState(() {
      _selectedSport = 'All Sports';
      _searchQuery = '';
      _selectedDate = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  void _markAsRead(String id) {
    setState(() {
      final index =
          _announcements.indexWhere((announcement) => announcement['id'] == id);
      if (index != -1) {
        _announcements[index]['isNew'] = false;
      }
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _selectedSport != 'All Sports' ||
        _searchQuery.isNotEmpty ||
        _selectedDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Hide filters' : 'Show filters',
          ),
          // Clear filters
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Announcements'),
            Tab(text: 'New'),
          ],
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: '/view-announcements',
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(
              icon: Icons.show_chart, title: 'Graphs', route: playerHomeRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View Coaches',
              route: viewCoachProfileRoute),
          DrawerItem(
              icon: Icons.bar_chart,
              title: 'View Stats',
              route: viewPlayerStatisticsRoute),
          DrawerItem(
              icon: Icons.medical_services,
              title: 'View Medical Reports',
              route: medicalReportRoute),
          DrawerItem(
              icon: Icons.medical_services,
              title: 'View Nutritional Plan',
              route: nutritionalPlanRoute),
          DrawerItem(
              icon: Icons.announcement,
              title: 'View Announcements',
              route: playerviewAnnouncementRoute),
          DrawerItem(
              icon: Icons.calendar_today,
              title: 'View Calendar',
              route: viewCalendarRoute),
          DrawerItem(
              icon: Icons.fitness_center,
              title: 'View Gym Plan',
              route: viewGymPlanRoute),
          
          DrawerItem(
              icon: Icons.attach_money,
              title: 'Finances',
              route: playerFinancialViewRoute),
        ],
        onLogout: () => _handleLogout(context),
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Column(
        children: [
          // Filters section - Collapsible
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? 150 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Announcements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search announcements',
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.deepPurple, width: 2),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Date selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: _selectedDate != null
                                ? Colors.deepPurple
                                : Colors.grey.shade600,
                          ),
                          onPressed: () => _selectDate(context),
                          tooltip: 'Select Date',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Sport categories
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _sportCategories.map((sport) {
                        final isSelected = sport == _selectedSport;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(sport),
                            selected: isSelected,
                            selectedColor: Colors.deepPurple.shade100,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) _onSportChanged(sport);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          if (hasActiveFilters && !_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedSport != 'All Sports')
                      _buildFilterChip(
                        label: _selectedSport,
                        onDeleted: () =>
                            setState(() => _selectedSport = 'All Sports'),
                      ),
                    if (_searchQuery.isNotEmpty)
                      _buildFilterChip(
                        label: '"$_searchQuery"',
                        onDeleted: () => setState(() => _searchQuery = ''),
                      ),
                    if (_selectedDate != null)
                      _buildFilterChip(
                        label:
                            DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        onDeleted: () => setState(() => _selectedDate = null),
                      ),
                  ],
                ),
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All announcements tab
                _buildAnnouncementsList(_filteredAnnouncements),

                // New announcements tab
                _buildAnnouncementsList(_filteredAnnouncements
                    .where((a) => a['isNew'] == true)
                    .toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      {required String label, required VoidCallback onDeleted}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.deepPurple.shade800,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade50,
        deleteIcon: const Icon(
          Icons.close,
          size: 16,
          color: Colors.deepPurple,
        ),
        onDeleted: onDeleted,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildAnnouncementsList(List<Map<String, dynamic>> announcements) {
    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No announcements found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        final DateTime announcementTime = DateTime.now(); // Simplified for demo
        final bool isToday = announcementTime.day == DateTime.now().day;
        final bool isNew = announcement['isNew'] == true;
        final String priority = announcement['priority'] as String;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isNew ? Colors.deepPurple.shade200 : Colors.transparent,
              width: isNew ? 1 : 0,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showAnnouncementDetails(announcement),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with sport category and priority
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          announcement['sport'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _getPriorityColor(priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getPriorityColor(priority)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${priority} Priority',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(priority),
                              ),
                            ),
                          ),
                          if (isNew)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Announcement content
                  Text(
                    announcement['announcement'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Footer info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time and coach info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isToday
                                    ? 'Today, ${DateFormat('h:mm a').format(announcementTime)}'
                                    : DateFormat('MMM d, h:mm a')
                                        .format(announcementTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                announcement['coach'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Mark as read button
                      if (isNew)
                        TextButton(
                          onPressed: () => _markAsRead(announcement['id']),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Mark as read'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    final String priority = announcement['priority'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          if (announcement['isNew'] == true) {
            _markAsRead(announcement['id']);
          }

          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title bar with priority
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Announcement Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getPriorityColor(priority).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${priority} Priority',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(priority),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sport and timestamp
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement['sport'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              announcement['time'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            announcement['sport'] == 'Football'
                                ? Icons.sports_soccer
                                : announcement['sport'] == 'Basketball'
                                    ? Icons.sports_basketball
                                    : announcement['sport'] == 'Cricket'
                                        ? Icons.sports_cricket
                                        : Icons.sports_tennis,
                            color: Colors.deepPurple,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Announcement content
                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      announcement['announcement'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Coach information
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement['coach'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Team Coach',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Contact coach functionality
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Contacting coach...')),
                          );
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Contact'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Added to your calendar')),
                            );
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Add to Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
