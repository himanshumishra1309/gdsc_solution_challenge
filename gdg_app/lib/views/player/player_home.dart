import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class PlayerHome extends StatefulWidget {
  const PlayerHome({super.key});

  @override
  _PlayerHomeState createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> with TickerProviderStateMixin {
  String _selectedDrawerItem = playerHomeRoute;
  String _selectedGraph = 'RPE Line Graph';
  String _selectedWeek = 'Week 1';
  String _selectedMonth = 'January';
  String _selectedYear = '2025';
  
  // Add a tab controller for switching between different data views
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
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

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
    }

    return shouldLogout;
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
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
    ];

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Dashboard'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
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
        ),
        // Use a simple Container with color instead of a gradient with background image
        body: Container(
          color: Colors.deepPurple.shade50,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player Stats Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.deepPurple.shade100,
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alexander Thompson',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                Text(
                                  'Cricket - Right-arm Fast Bowler',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Fit to Play',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatWidget('Training Load', '7.6', 'High', Colors.orange),
                          _buildStatWidget('Fitness Level', '8.3', 'Good', Colors.green),
                          _buildStatWidget('Rest Score', '6.4', 'Average', Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Graph Selection and Filters
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Performance Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Info button action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View detailed analytics explanation'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.deepPurple.shade300,
                            ),
                            tooltip: 'Info',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Graph Type Selection Chip
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSelectionChip(
                              'RPE Line Graph',
                              _selectedGraph == 'RPE Line Graph',
                              () {
                                setState(() {
                                  _selectedGraph = 'RPE Line Graph';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildSelectionChip(
                              'Spider Graph',
                              _selectedGraph == 'Spider Graph',
                              () {
                                setState(() {
                                  _selectedGraph = 'Spider Graph';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildSelectionChip(
                              'Comparative Graph',
                              _selectedGraph == 'Comparative RPE and RP Graph',
                              () {
                                setState(() {
                                  _selectedGraph = 'Comparative RPE and RP Graph';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time Period Filters
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedWeek,
                              items: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedWeek = newValue!;
                                });
                              },
                              icon: Icons.date_range,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedMonth,
                              items: [
                                'January', 'February', 'March', 'April', 'May', 'June',
                                'July', 'August', 'September', 'October', 'November', 'December'
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMonth = newValue!;
                                });
                              },
                              icon: Icons.calendar_month,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedYear,
                              items: ['2023', '2024', '2025', '2026'],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedYear = newValue!;
                                });
                              },
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Graph Display - FIXED: removed Expanded which causes the layout issue
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Use min size
                  children: [
                    // Graph title with scrolling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _getGraphTitle(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download, size: 18),
                              onPressed: () {
                                // Download graph functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Graph downloaded'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              tooltip: 'Download Graph',
                              iconSize: 20,
                              color: Colors.deepPurple,
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, size: 18),
                              onPressed: () {
                                // Share graph functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share options'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              tooltip: 'Share Graph',
                              iconSize: 20,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Graph Legend - only show for comparative graph
                    if (_selectedGraph == 'Comparative RPE and RP Graph') ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'RPE (Rate of Perceived Exertion)',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Recovery Points',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Graph area with fixed height
                    SizedBox(
                      height: 350, // Fixed taller height for graphs
                      width: double.infinity,
                      child: _buildGraph(),
                    ),
                  ],
                ),
              ),
                
              // Add insights panel 
              // _buildInsightsPanel(),
                
              // Add upcoming events card
              // _buildUpcomingEventsCard(),
                
              // Add space at bottom for better scroll experience
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }

  String _getGraphTitle() {
    String title;
    switch (_selectedGraph) {
      case 'RPE Line Graph':
        title = 'RPE - $_selectedWeek, $_selectedMonth $_selectedYear';
        break;
      case 'Spider Graph':
        title = 'Performance - $_selectedMonth $_selectedYear';
        break;
      case 'Comparative RPE and RP Graph':
        title = 'RPE vs Recovery - $_selectedWeek, $_selectedMonth';
        break;
      default:
        title = '';
    }
    return title;
  }

  Widget _buildStatWidget(String label, String value, String status, Color statusColor) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple.shade300),
          iconSize: 20,
          isExpanded: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
          ),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.deepPurple.shade300, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

   Widget _buildGraph() {
    switch (_selectedGraph) {
      case 'RPE Line Graph':
        return _buildRPELineGraph();
      case 'Spider Graph':
        return _buildSpiderGraph();
      case 'Comparative RPE and RP Graph':
        return _buildComparativeGraph();
      default:
        return Container();
    }
  }

  Widget _buildRPELineGraph() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 350, // Increased height
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    if (value.toInt() == 1 || value.toInt() == 3 || value.toInt() == 5 || value.toInt() == 7) {
                      text = 'Day ${value.toInt()}';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400),
                left: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 10,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot)=> Colors.deepPurple, // Fixed tooltip background color
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    return LineTooltipItem(
                      'RPE: ${barSpot.y.toString()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(1, 5),
                  const FlSpot(2, 6),
                  const FlSpot(3, 7),
                  const FlSpot(4, 8),
                  const FlSpot(5, 9),
                  const FlSpot(6, 7),
                  const FlSpot(7, 6),
                ],
                isCurved: true,
                color: Colors.deepPurple,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.deepPurple,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.3),
                      Colors.deepPurple.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpiderGraph() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300, // Increased height
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.polygon,
            dataSets: [
              RadarDataSet(
                fillColor: Colors.deepPurple.withOpacity(0.3),
                borderColor: Colors.deepPurple,
                borderWidth: 2,
                entryRadius: 5,
                dataEntries: [
                  const RadarEntry(value: 8),  // Sprint Speed
                  const RadarEntry(value: 7),  // Pass Accuracy
                  const RadarEntry(value: 6),  // Goals/Wickets
                  const RadarEntry(value: 5),  // Tackles/Catches
                  const RadarEntry(value: 9),  // Stamina
                  const RadarEntry(value: 8),  // Agility
                ],
              ),
            ],
            radarBorderData: const BorderSide(
              color: Colors.transparent,
            ),
            tickBorderData: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
            gridBorderData: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
            ticksTextStyle: TextStyle(
              color: Colors.grey[700],
              fontSize: 10,
            ),
            tickCount: 5,
            radarBackgroundColor: Colors.transparent,
            getTitle: (index, angle) {
              final titles = [
                'Sprint\nSpeed',
                'Pass\nAccuracy',
                'Goals/\nWickets',
                'Tackles/\nCatches',
                'Stamina',
                'Agility',
              ];
              return RadarChartTitle(
                text: titles[index],
                angle: angle,
                positionPercentageOffset: 0.15,
              );
            },
            titleTextStyle: TextStyle(
              color: Colors.deepPurple.shade700,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparativeGraph() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300, // Increased height
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    if (value.toInt() == 1 || value.toInt() == 3 || value.toInt() == 5 || value.toInt() == 7) {
                      text = 'Day ${value.toInt()}';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400),
                left: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 10,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => spot.barIndex == 0 ? Colors.deepPurple : Colors.red,
                            tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final String label = barSpot.barIndex == 0 ? 'RPE' : 'Recovery';
                    final Color textColor = Colors.white;
                    return LineTooltipItem(
                      '$label: ${barSpot.y.toStringAsFixed(1)}',
                      TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              // RPE Data
              LineChartBarData(
                spots: [
                  const FlSpot(1, 5),
                  const FlSpot(2, 6),
                  const FlSpot(3, 7),
                  const FlSpot(4, 8),
                  const FlSpot(5, 9),
                  const FlSpot(6, 7),
                  const FlSpot(7, 6),
                ],
                isCurved: true,
                color: Colors.deepPurple,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.deepPurple,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.3),
                      Colors.deepPurple.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Recovery Points Data
              LineChartBarData(
                spots: [
                  const FlSpot(1, 8),
                  const FlSpot(2, 7),
                  const FlSpot(3, 6),
                  const FlSpot(4, 5),
                  const FlSpot(5, 4),
                  const FlSpot(6, 6),
                  const FlSpot(7, 7),
                ],
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.red,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.red.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show detailed info for a performance metric
  void _showMetricDetails(BuildContext context, String title, String value, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.deepPurple.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Value: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommendation: ${_getRecommendationForMetric(title)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.deepPurple,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to detailed history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing detailed history'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.history,
              size: 16,
            ),
            label: const Text('View History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get a recommendation based on the metric
  String _getRecommendationForMetric(String metric) {
    switch (metric) {
      case 'Training Load':
        return 'Consider reducing high-intensity sessions for the next 2 days.';
      case 'Fitness Level':
        return 'Maintain current training intensity to preserve good fitness.';
      case 'Rest Score':
        return 'Focus on improving sleep quality and consider active recovery.';
      default:
        return 'Continue monitoring this metric regularly.';
    }
  }

  // Function to add insights panel to the dashboard
  Widget _buildInsightsPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Insights & Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () {
                    // Refresh insights
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing insights...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  tooltip: 'Refresh Insights',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 16,
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          _buildInsightItem(
            Icons.trending_up,
            'Performance Trend',
            'Your overall performance shows a positive trend over the last 2 weeks.',
            Colors.green,
          ),
          _buildInsightItem(
            Icons.warning_amber_rounded,
            'Recovery Warning',
            'Your recovery score is declining. Consider adding more rest days.',
            Colors.orange,
          ),
          _buildInsightItem(
            Icons.fitness_center,
            'Training Suggestion',
            'Focus on improving your agility with specific drills this week.',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Upcoming events section
  Widget _buildUpcomingEventsCard() {
    final List<Map<String, dynamic>> events = [
      {
        'title': 'Training Session',
        'time': '09:00 AM',
        'location': 'Main Field',
        'coach': 'Coach Smith',
        'icon': Icons.sports_cricket,
      },
      {
        'title': 'Fitness Assessment',
        'time': '02:30 PM',
        'location': 'Training Center',
        'coach': 'Coach Johnson',
        'icon': Icons.fitness_center,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View full calendar action
                    Navigator.pushNamed(context, viewCalendarRoute);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Full Calendar',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ...events.map((event) => _buildEventItem(event)).toList(),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No events scheduled for today',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              event['icon'],
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['coach'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // View event details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing details for ${event['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }
}

// Helper classes for additional functionality
class PerformanceMetric {
  final String name;
  final double value;
  final String status;
  final Color statusColor;
  final String description;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.description,
  });
}

class SportEvent {
  final String title;
  final DateTime date;
  final String location;
  final String coachName;
  final IconData icon;
  final String eventType;

  SportEvent({
    required this.title,
    required this.date,
    required this.location,
    required this.coachName,
    required this.icon,
    required this.eventType,
  });
}