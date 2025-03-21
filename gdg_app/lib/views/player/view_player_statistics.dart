import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:fl_chart/fl_chart.dart';

class ViewPlayerStatistics extends StatefulWidget {
  const ViewPlayerStatistics({super.key});

  @override
  _ViewPlayerStatisticsState createState() => _ViewPlayerStatisticsState();
}

class _ViewPlayerStatisticsState extends State<ViewPlayerStatistics>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  String _selectedDrawerItem = viewPlayerStatisticsRoute;
  String _selectedSport = 'Football';
  Map<String, dynamic> _playerStats = {};
  String _searchQuery = '';
  bool _sortAscending = true;
  late TabController _tabController;
  bool _isLoading = true;
  String _selectedView = 'Table'; // 'Table' or 'Card'

  // Format stat values based on their type
  String _formatStatValue(String key, dynamic value) {
    // Format percentages
    if (key.toLowerCase().contains('percentage') ||
        key.toLowerCase().contains('accuracy') ||
        key.toLowerCase().contains('rate')) {
      return '$value%';
    }
    // Format speeds
    else if (key.toLowerCase().contains('speed')) {
      return '$value km/h';
    }
    // Else return as is
    return value.toString();
  }

  // Check if stat is a key metric for the selected sport
  bool _isKeyMetricForSport(String key) {
    if (_selectedSport == 'Football') {
      return key == 'Goals' || key == 'Assists';
    } else if (_selectedSport == 'Cricket') {
      return key == 'Total Runs' || key == 'Wickets';
    } else if (_selectedSport == 'Badminton') {
      return key == 'Hit Percentage' || key == 'Accuracy';
    }
    return false;
  }

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(
        length: 2, vsync: this); // Changed from 3 to 2 (removed Chart view)
    _loadPlayerData();
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

  Future<void> _loadPlayerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String response = await rootBundle
          .loadString('assets/json_files/player_statistics.json');
      final data = await json.decode(response);
      setState(() {
        _playerStats =
            _filterSportSpecificStats(data[_selectedSport.toLowerCase()] ?? {});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Default statistics based on sport selected
        _playerStats = _getDefaultStatsForSport(_selectedSport);
        _isLoading = false;
      });
    }
  }

  // New method to filter sport-specific statistics
  Map<String, dynamic> _filterSportSpecificStats(
      Map<String, dynamic> allStats) {
    // If source data is empty, return empty map
    if (allStats.isEmpty) return {};

    Map<String, dynamic> filteredStats = {};

    if (_selectedSport == 'Football') {
      // Keep only relevant football stats and ensure required ones exist
      if (allStats.containsKey('Goals'))
        filteredStats['Goals'] = allStats['Goals'];
      if (allStats.containsKey('Assists'))
        filteredStats['Assists'] = allStats['Assists'];
      if (allStats.containsKey('Minutes Played'))
        filteredStats['Minutes Played'] = allStats['Minutes Played'];
      if (allStats.containsKey('Pass Accuracy'))
        filteredStats['Pass Accuracy'] = allStats['Pass Accuracy'];
      if (allStats.containsKey('Yellow Cards'))
        filteredStats['Yellow Cards'] = allStats['Yellow Cards'];
      if (allStats.containsKey('Red Cards'))
        filteredStats['Red Cards'] = allStats['Red Cards'];
    } else if (_selectedSport == 'Cricket') {
      // Keep only relevant cricket stats
      if (allStats.containsKey('Total Runs'))
        filteredStats['Total Runs'] = allStats['Total Runs'];
      if (allStats.containsKey('Wickets'))
        filteredStats['Wickets'] = allStats['Wickets'];
      if (allStats.containsKey('Batting Average'))
        filteredStats['Batting Average'] = allStats['Batting Average'];
      if (allStats.containsKey('Economy Rate'))
        filteredStats['Economy Rate'] = allStats['Economy Rate'];
      if (allStats.containsKey('Centuries'))
        filteredStats['Centuries'] = allStats['Centuries'];
      if (allStats.containsKey('Half Centuries'))
        filteredStats['Half Centuries'] = allStats['Half Centuries'];
    } else if (_selectedSport == 'Badminton') {
      // Keep only relevant badminton stats
      if (allStats.containsKey('Hit Percentage'))
        filteredStats['Hit Percentage'] = allStats['Hit Percentage'];
      if (allStats.containsKey('Accuracy'))
        filteredStats['Accuracy'] = allStats['Accuracy'];
      if (allStats.containsKey('Win Rate'))
        filteredStats['Win Rate'] = allStats['Win Rate'];
      if (allStats.containsKey('Matches Played'))
        filteredStats['Matches Played'] = allStats['Matches Played'];
      if (allStats.containsKey('Smash Speed'))
        filteredStats['Smash Speed'] = allStats['Smash Speed'];
    }

    // If no specific stats were found, return all stats (fallback)
    return filteredStats.isEmpty ? allStats : filteredStats;
  }

  // Default stats based on sport
  Map<String, dynamic> _getDefaultStatsForSport(String sport) {
    if (sport == 'Football') {
      return {
        "Goals": 12,
        "Assists": 7,
        "Minutes Played": 1080,
        "Pass Accuracy": 87.5,
        "Yellow Cards": 3,
        "Red Cards": 0,
      };
    } else if (sport == 'Cricket') {
      return {
        "Total Runs": 452,
        "Wickets": 23,
        "Batting Average": 32.5,
        "Economy Rate": 4.8,
        "Centuries": 1,
        "Half Centuries": 3,
      };
    } else if (sport == 'Badminton') {
      return {
        "Hit Percentage": 78.2,
        "Accuracy": 82.4,
        "Win Rate": 65.0,
        "Matches Played": 24,
        "Smash Speed": 288,
      };
    }
    return {};
  }

  void _onSportChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedSport = newValue;
        // If view was Chart, reset to Table since Chart is now removed
        if (_selectedView == 'Chart') {
          _selectedView = 'Table';
        }
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
          // Try to parse as numbers first for proper numeric sorting
          try {
            final numA = double.parse(a.value.toString());
            final numB = double.parse(b.value.toString());
            return ascending ? numA.compareTo(numB) : numB.compareTo(numA);
          } catch (_) {
            // Fall back to string comparison if not numbers
            return ascending
                ? a.value.toString().compareTo(b.value.toString())
                : b.value.toString().compareTo(a.value.toString());
          }
        }
        return 0;
      });
      _playerStats = Map.fromEntries(entries);
      _sortAscending = ascending;
    });
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  Color _getStatColor(String category, dynamic value) {
    if (_selectedSport == 'Football') {
      if (category.toLowerCase() == 'goals') {
        return Colors.green.shade700;
      } else if (category.toLowerCase() == 'assists') {
        return Colors.deepPurple;
      } else if (category.toLowerCase().contains('card')) {
        return value is num && value > 0 ? Colors.red.shade700 : Colors.grey;
      }
    } else if (_selectedSport == 'Cricket') {
      if (category.toLowerCase() == 'total runs') {
        return Colors.blue.shade700;
      } else if (category.toLowerCase() == 'wickets') {
        return Colors.green.shade700;
      }
    } else if (_selectedSport == 'Badminton') {
      if (category.toLowerCase() == 'hit percentage') {
        return Colors.amber.shade700;
      } else if (category.toLowerCase() == 'accuracy') {
        return Colors.deepPurple;
      }
    }

    // Generic coloring for percentage values
    if (category.toLowerCase().contains('accuracy') ||
        category.toLowerCase().contains('percentage') ||
        category.toLowerCase().contains('rate')) {
      double numValue = double.tryParse(value.toString()) ?? 0;
      if (numValue >= 80) return Colors.green.shade700;
      if (numValue >= 60) return Colors.amber.shade700;
      return Colors.red.shade700;
    }

    return Colors.deepPurple;
  }

  IconData _getStatIcon(String category) {
    // Football icons
    if (category.toLowerCase() == 'goals') {
      return Icons.sports_soccer;
    } else if (category.toLowerCase() == 'assists') {
      return Icons.handshake;
    }
    // Cricket icons
    else if (category.toLowerCase() == 'total runs') {
      return Icons.score;
    } else if (category.toLowerCase() == 'wickets') {
      return Icons.sports_cricket;
    }
    // Badminton icons
    else if (category.toLowerCase() == 'hit percentage') {
      return Icons.gps_fixed;
    } else if (category.toLowerCase() == 'accuracy') {
      return Icons.precision_manufacturing;
    }
    // Generic icons
    else if (category.toLowerCase().contains('pass')) {
      return Icons.compare_arrows;
    } else if (category.toLowerCase().contains('tackle')) {
      return Icons.sports;
    } else if (category.toLowerCase().contains('intercept')) {
      return Icons.block;
    } else if (category.toLowerCase().contains('minute') ||
        category.toLowerCase().contains('time')) {
      return Icons.timer;
    } else if (category.toLowerCase().contains('yellow card')) {
      return Icons.warning_amber_rounded;
    } else if (category.toLowerCase().contains('red card')) {
      return Icons.error_outline;
    } else if (category.toLowerCase().contains('shot')) {
      return Icons.gps_fixed;
    } else if (category.toLowerCase().contains('matches')) {
      return Icons.event;
    } else if (category.toLowerCase().contains('speed')) {
      return Icons.speed;
    } else if (category.toLowerCase().contains('win')) {
      return Icons.emoji_events;
    } else if (category.toLowerCase().contains('centur')) {
      return Icons.sports_cricket;
    } else if (category.toLowerCase().contains('economy')) {
      return Icons.trending_down;
    } else if (category.toLowerCase().contains('average')) {
      return Icons.equalizer;
    } else {
      return Icons.analytics;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
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
      // DrawerItem(
      //     icon: Icons.edit,
      //     title: 'Fill Injury Form',
      //     route: fillInjuryFormRoute),
      DrawerItem(
          icon: Icons.attach_money,
          title: 'Finances',
          route: playerFinancialViewRoute),
    ];

    // Filter player stats based on search query
    final filteredStats = _playerStats.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.value
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Statistics'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
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
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: drawerItems,
        onLogout: _handleLogout,
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Column(
        children: [
          // Season summary card - Enhanced with sport-specific design
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _selectedSport == 'Football'
                    ? [Colors.green.shade700, Colors.green.shade900]
                    : _selectedSport == 'Cricket'
                        ? [Colors.blue.shade700, Colors.blue.shade900]
                        : [Colors.amber.shade700, Colors.amber.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_selectedSport == 'Football'
                          ? Colors.green.shade700
                          : _selectedSport == 'Cricket'
                              ? Colors.blue.shade700
                              : Colors.amber.shade700)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24,
                      child: Icon(
                        _selectedSport == 'Football'
                            ? Icons.sports_soccer
                            : _selectedSport == 'Cricket'
                                ? Icons.sports_cricket
                                : Icons.sports_tennis,
                        color: _selectedSport == 'Football'
                            ? Colors.green.shade700
                            : _selectedSport == 'Cricket'
                                ? Colors.blue.shade700
                                : Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Season 2024-25',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_selectedSport Statistics',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Toggle between different views (removed Chart option)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildViewToggle(Icons.table_chart, 'Table'),
                          _buildViewToggle(Icons.view_module, 'Card'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _selectedSport == 'Football'
                      ? [
                          // Football key stats
                          _buildHighlightStat(
                            _playerStats.containsKey('Goals')
                                ? _playerStats['Goals'].toString()
                                : '0',
                            'Goals',
                            Icons.sports_soccer,
                          ),
                          _buildHighlightStat(
                            _playerStats.containsKey('Assists')
                                ? _playerStats['Assists'].toString()
                                : '0',
                            'Assists',
                            Icons.handshake,
                          ),
                        ]
                      : _selectedSport == 'Cricket'
                          ? [
                              // Cricket key stats
                              _buildHighlightStat(
                                _playerStats.containsKey('Total Runs')
                                    ? _playerStats['Total Runs'].toString()
                                    : '0',
                                'Runs',
                                Icons.score,
                              ),
                              _buildHighlightStat(
                                _playerStats.containsKey('Wickets')
                                    ? _playerStats['Wickets'].toString()
                                    : '0',
                                'Wickets',
                                Icons.sports_cricket,
                              ),
                            ]
                          : [
                              // Badminton key stats
                              _buildHighlightStat(
                                _playerStats.containsKey('Hit Percentage')
                                    ? _playerStats['Hit Percentage']
                                            .toString() +
                                        '%'
                                    : '0%',
                                'Hit %',
                                Icons.gps_fixed,
                              ),
                              _buildHighlightStat(
                                _playerStats.containsKey('Accuracy')
                                    ? _playerStats['Accuracy'].toString() + '%'
                                    : '0%',
                                'Accuracy',
                                Icons.precision_manufacturing,
                              ),
                            ],
                ),
              ],
            ),
          ),

          // Search bar and sport selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search statistics...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.deepPurple.shade300, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSport,
                      onChanged: _onSportChanged,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.deepPurple.shade400),
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 14),
                      items: <String>['Football', 'Cricket', 'Badminton']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                value == 'Football'
                                    ? Icons.sports_soccer
                                    : value == 'Cricket'
                                        ? Icons.sports_cricket
                                        : Icons.sports_tennis,
                                color: value == 'Football'
                                    ? Colors.green.shade700
                                    : value == 'Cricket'
                                        ? Colors.blue.shade700
                                        : Colors.amber.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                value,
                                style: TextStyle(
                                  color: value == 'Football'
                                      ? Colors.green.shade700
                                      : value == 'Cricket'
                                          ? Colors.blue.shade700
                                          : Colors.amber.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Statistics content based on selected view (only Table or Card now)
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: _selectedSport == 'Football'
                          ? Colors.green.shade700
                          : _selectedSport == 'Cricket'
                              ? Colors.blue.shade700
                              : Colors.amber.shade700,
                      strokeWidth: 3,
                    ),
                  )
                : filteredStats.isEmpty
                    ? Center(
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
                              'No statistics found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or change sport',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _selectedView == 'Table'
                        ? _buildTableView(filteredStats)
                        : _buildCardView(filteredStats),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, String view) {
    final isSelected = _selectedView == view;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedView = view;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (_selectedSport == 'Football'
                  ? Colors.green.shade100
                  : _selectedSport == 'Cricket'
                      ? Colors.blue.shade100
                      : Colors.amber.shade100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? (_selectedSport == 'Football'
                  ? Colors.green.shade700
                  : _selectedSport == 'Cricket'
                      ? Colors.blue.shade700
                      : Colors.amber.shade700)
              : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildHighlightStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(List<MapEntry<String, dynamic>> filteredStats) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Row(
                    children: [
                      const Text(
                        'Statistic',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _sortTable('Category', !_sortAscending),
                        child: Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                DataColumn(
                  label: Row(
                    children: [
                      const Text(
                        'Value',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _sortTable('Statistic', !_sortAscending),
                        child: Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  numeric: true,
                ),
              ],
              rows: filteredStats.map((entry) {
                final isKeyMetric = _isKeyMetricForSport(entry.key);

                return DataRow(
                  color: MaterialStateColor.resolveWith((states) {
                    if (isKeyMetric) {
                      return (_selectedSport == 'Football'
                          ? Colors.green.shade50
                          : _selectedSport == 'Cricket'
                              ? Colors.blue.shade50
                              : Colors.amber.shade50);
                    }
                    if (states.contains(MaterialState.selected)) {
                      return Colors.deepPurple.shade50;
                    }
                    return Colors.transparent;
                  }),
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getStatColor(entry.key, entry.value)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatIcon(entry.key),
                              size: 16,
                              color: _getStatColor(entry.key, entry.value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: isKeyMetric
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showStatDetail(entry),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatColor(entry.key, entry.value)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatStatValue(entry.key, entry.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatColor(entry.key, entry.value),
                          ),
                        ),
                      ),
                      onTap: () => _showStatDetail(entry),
                    ),
                  ],
                );
              }).toList(),
              sortColumnIndex: 0,
              sortAscending: _sortAscending,
              dataRowHeight: 56,
              headingRowHeight: 56,
              columnSpacing: 24,
              headingTextStyle: TextStyle(
                color: _selectedSport == 'Football'
                    ? Colors.green.shade700
                    : _selectedSport == 'Cricket'
                        ? Colors.blue.shade700
                        : Colors.amber.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              headingRowColor: MaterialStateColor.resolveWith((states) {
                return Colors.grey.shade100;
              }),
              border: TableBorder(
                verticalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                horizontalInside: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView(List<MapEntry<String, dynamic>> filteredStats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredStats.length,
        itemBuilder: (context, index) {
          final entry = filteredStats[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stat Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _getStatColor(entry.key, entry.value).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatIcon(entry.key),
                    size: 28,
                    color: _getStatColor(entry.key, entry.value),
                  ),
                ),
                const SizedBox(height: 12),
                // Value
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getStatColor(entry.key, entry.value),
                  ),
                ),
                const SizedBox(height: 4),
                // Label
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartView(List<MapEntry<String, dynamic>> filteredStats) {
    // Filter only numeric values for the chart
    final numericStats = filteredStats.where((entry) {
      try {
        double.parse(entry.value.toString());
        return true;
      } catch (_) {
        return false;
      }
    }).toList();

    // Sort by value, descending
    numericStats.sort((a, b) {
      try {
        final double aVal = double.parse(a.value.toString());
        final double bVal = double.parse(b.value.toString());
        return bVal.compareTo(aVal);
      } catch (_) {
        return 0;
      }
    });

    // Limit to top 10 stats for better visibility
    final topStats = numericStats.take(10).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: topStats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No numeric statistics available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Numeric values only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            double.parse(topStats.first.value.toString()) * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (spot) =>
                                Colors.deepPurple.shade800,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${topStats[groupIndex].key}: ${topStats[groupIndex].value}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final int idx = value.toInt();
                                if (idx >= 0 && idx < topStats.length) {
                                  // Abbreviate long labels for better display
                                  String label = topStats[idx].key;
                                  if (label.length > 6) {
                                    label = '${label.substring(0, 5)}...';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval:
                              double.parse(topStats.first.value.toString()) / 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        barGroups: List.generate(
                          topStats.length,
                          (index) {
                            final double value =
                                double.parse(topStats[index].value.toString());
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatColor(topStats[index].key, value),
                                      _getStatColor(topStats[index].key, value)
                                          .withOpacity(0.6),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  width: 18,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: double.parse(
                                            topStats.first.value.toString()) *
                                        1.2,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Legend for chart colors
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(Colors.green.shade700, 'Offensive'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.deepPurple, 'General'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.amber.shade700, 'Medium'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.red.shade700, 'Warning'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // This new method adds animations to statistic cards
  Widget _buildAnimatedStatCard(MapEntry<String, dynamic> entry, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _getStatColor(entry.key, entry.value).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showStatDetail(entry),
          splashColor: _getStatColor(entry.key, entry.value).withOpacity(0.1),
          highlightColor:
              _getStatColor(entry.key, entry.value).withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stat Icon with animated container
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _getStatColor(entry.key, entry.value).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatIcon(entry.key),
                    size: 28,
                    color: _getStatColor(entry.key, entry.value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Value with counter animation
              TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 0,
                  end: bool.tryParse(entry.value.toString()) ??
                          entry.value is int
                      ? entry.value.toDouble()
                      : 0,
                ),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, _) {
                  return Text(
                    value % 1 == 0
                        ? value.toInt().toString()
                        : value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getStatColor(entry.key, entry.value),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show detailed stat information
  void _showStatDetail(MapEntry<String, dynamic> stat) {
    final bool isPercentage = stat.key.toLowerCase().contains('percentage') ||
        stat.key.toLowerCase().contains('accuracy');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatIcon(stat.key),
                    size: 28,
                    color: _getStatColor(stat.key, stat.value),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    stat.key,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatColor(stat.key, stat.value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isPercentage
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: double.parse(stat.value.toString()) / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatColor(stat.key, stat.value),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${stat.value}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatColor(stat.key, stat.value),
                              ),
                            ),
                            Text(
                              _getPerformanceLevel(
                                  double.parse(stat.value.toString())),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          stat.value.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getStatColor(stat.key, stat.value),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatDescription(stat.key),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              _buildComparisonSection(stat),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to get performance level based on percentage
  String _getPerformanceLevel(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 75) return 'Very Good';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Average';
    return 'Needs Improvement';
  }

  // Method to get stat descriptions
  String _getStatDescription(String statName) {
    if (statName.toLowerCase().contains('goals')) {
      return 'Total goals scored across all matches this season';
    } else if (statName.toLowerCase().contains('assist')) {
      return 'Total assists provided to teammates this season';
    } else if (statName.toLowerCase().contains('pass')) {
      return 'Total successful passes completed in all matches';
    } else if (statName.toLowerCase().contains('tackle')) {
      return 'Total successful tackles performed this season';
    } else if (statName.toLowerCase().contains('minute')) {
      return 'Total minutes played across all matches this season';
    } else if (statName.toLowerCase().contains('yellow card')) {
      return 'Total yellow cards received this season';
    } else if (statName.toLowerCase().contains('red card')) {
      return 'Total red cards received this season';
    } else {
      return 'Statistical measurement of player performance';
    }
  }

  // Method to build comparison section
  Widget _buildComparisonSection(MapEntry<String, dynamic> stat) {
    final teamAverage = (double.tryParse(stat.value.toString()) ?? 0) * 0.8;
    final leagueAverage = (double.tryParse(stat.value.toString()) ?? 0) * 0.7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparison',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
        const SizedBox(height: 12),
        _buildComparisonItem('Your value',
            double.tryParse(stat.value.toString()) ?? 0, Colors.deepPurple),
        const SizedBox(height: 8),
        _buildComparisonItem('Team average', teamAverage, Colors.blue.shade700),
        const SizedBox(height: 8),
        _buildComparisonItem(
            'League average', leagueAverage, Colors.green.shade700),
      ],
    );
  }

  // Method to build comparison item
  Widget _buildComparisonItem(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value % 1 == 0
                    ? value.toInt().toString()
                    : value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// New class for better stat organization
class PlayerStat {
  final String name;
  final dynamic value;
  final String category;
  final String trend;

  PlayerStat({
    required this.name,
    required this.value,
    required this.category,
    this.trend = 'stable',
  });
}
