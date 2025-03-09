import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualHomeView extends StatefulWidget {
  const IndividualHomeView({super.key});

  @override
  _IndividualHomeViewState createState() => _IndividualHomeViewState();
}

class _IndividualHomeViewState extends State<IndividualHomeView> with SingleTickerProviderStateMixin {
  String _selectedDrawerItem = individualHomeRoute;
  String _selectedGraph = 'RPE Line Graph';
  String _selectedWeek = 'Week 1';
  String _selectedMonth = 'January';
  String _selectedYear = '2025';
  late TabController _tabController;
  bool _showLegend = true;
  
  // Summary data
  final Map<String, double> _summaryData = {
    'Current RPE': 7.5,
    'Weekly Avg': 6.8,
    'Monthly Avg': 7.2,
    'Progress': 0.85,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedGraph = 'RPE Line Graph';
              break;
            case 1:
              _selectedGraph = 'Spider Graph';
              break;
            case 2:
              _selectedGraph = 'Comparative RPE and RP Graph';
              break;
          }
        });
      }
    });
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

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, landingPageRoute);
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
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }

    return shouldLogout;
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

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Dashboard'),
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          toolbarHeight: 65.0,
          elevation: 0,
          actions: [
          ],
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
        body: Column(
          children: [
            // Period selection
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selection row
                  Row(
                    children: [
                      Expanded(
                        child: _buildChipDropdown(
                          label: 'Week',
                          value: _selectedWeek,
                          items: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedWeek = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChipDropdown(
                          label: 'Month',
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChipDropdown(
                          label: 'Year',
                          value: _selectedYear,
                          items: ['2023', '2024', '2025', '2026'],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedYear = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Summary cards
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  _buildSummaryCard('Current RPE', '${_summaryData['Current RPE']}', Icons.speed),
                  _buildSummaryCard('Weekly Avg', '${_summaryData['Weekly Avg']}', Icons.trending_up),
                  _buildSummaryCard('Progress', '${(_summaryData['Progress']! * 100).toInt()}%', Icons.show_chart),
                ],
              ),
            ),
            
            // Graph type tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.deepPurple,
                indicatorWeight: 3,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey.shade600,
                tabs: const [
                  Tab(text: 'RPE Line Graph'),
                  Tab(text: 'Spider Graph'),
                  Tab(text: 'Comparative'),
                ],
              ),
            ),
            
            // Legend (conditionally shown)
            if (_showLegend)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildLegend(),
              ),
            
            // Graph area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildGraph(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 8,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data for $_selectedMonth $_selectedYear',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Handle export or share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report exported'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share Report'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add new data point
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Add New Data Point'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'RPE Value (1-10)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New data point added'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
          tooltip: 'Add Data Point',
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.15),
        margin: const EdgeInsets.only(right: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 24),
              isExpanded: true,
              dropdownColor: Colors.white,
              alignment: Alignment.centerRight,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    if (_selectedGraph == 'RPE Line Graph') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 4,
            color: Colors.deepPurple,
            margin: const EdgeInsets.only(right: 8),
          ),
          const Text('Rate of Perceived Exertion (RPE)', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          const Text('Scale: 1-10', style: TextStyle(fontSize: 12)),
        ],
      );
    } else if (_selectedGraph == 'Spider Graph') {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: Colors.deepPurple,
          ),
          SizedBox(width: 8),
          Text('Current Abilities', style: TextStyle(fontSize: 12)),
          SizedBox(width: 16),
          CircleAvatar(
            radius: 8,
            backgroundColor: Colors.orange,
          ),
          SizedBox(width: 8),
          Text('Target Abilities', style: TextStyle(fontSize: 12)),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 4,
            color: Colors.deepPurple,
            margin: const EdgeInsets.only(right: 8),
          ),
          const Text('RPE', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Container(
            width: 16,
            height: 4,
            color: Colors.red,
            margin: const EdgeInsets.only(right: 8),
          ),
          const Text('Recovery Points (RP)', style: TextStyle(fontSize: 12)),
        ],
      );
    }
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate of Perceived Exertion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              '$_selectedWeek, $_selectedMonth $_selectedYear',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'RPE',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 12),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Day',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 12),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  minX: 1,
                  maxX: 7,
                  minY: 1,
                  maxY: 10,
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
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.deepPurple,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.deepPurple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                    // Target line
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 7),
                        FlSpot(7, 7),
                      ],
                      isCurved: false,
                      color: Colors.grey.shade400,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor:(spot)=> Colors.white.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            'Day ${barSpot.x.toInt()}: ${barSpot.y}',
                            const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
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

  Widget _buildSpiderGraph() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Attributes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              '$_selectedMonth $_selectedYear',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  dataSets: [
                    // Current abilities
                    RadarDataSet(
                      dataEntries: const [
                        RadarEntry(value: 8),
                        RadarEntry(value: 7),
                        RadarEntry(value: 6),
                        RadarEntry(value: 5),
                        RadarEntry(value: 9),
                        RadarEntry(value: 8),
                      ],
                      borderColor: Colors.deepPurple,
                      fillColor: Colors.deepPurple.withOpacity(0.3),
                      entryRadius: 5,
                      borderWidth: 2.5,
                    ),
                    // Target abilities
                    RadarDataSet(
                      dataEntries: const [
                        RadarEntry(value: 10),
                        RadarEntry(value: 9),
                        RadarEntry(value: 8),
                        RadarEntry(value: 7),
                        RadarEntry(value: 10),
                        RadarEntry(value: 9),
                      ],
                      fillColor: Colors.transparent,
                      borderColor: Colors.orange,
                      entryRadius: 0,
                      borderWidth: 2,
                      // borderDash: [5, 5],
                    ),
                  ],
                  radarBorderData: const BorderSide(color: Colors.transparent),
                  radarBackgroundColor: Colors.transparent,
                  tickCount: 5,
                  ticksTextStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                  gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  titleTextStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                  ),
                  titlePositionPercentageOffset: 0.18,
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0:
                        return RadarChartTitle(text: 'Speed');
                      case 1:
                        return RadarChartTitle(text: 'Passing');
                      case 2:
                        return RadarChartTitle(text: 'Scoring');
                      case 3:
                        return RadarChartTitle(text: 'Defense');
                      case 4:
                        return RadarChartTitle(text: 'Stamina');
                      case 5:
                        return RadarChartTitle(text: 'Agility');
                      default:
                        return RadarChartTitle(text: '');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparativeGraph() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RPE vs Recovery Points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              '$_selectedWeek, $_selectedMonth $_selectedYear',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Value',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 12),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                                        bottomTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Day',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 12),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  minX: 1,
                  maxX: 7,
                  minY: 1,
                  maxY: 10,
                  lineBarsData: [
                    // RPE Line
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 6),
                        FlSpot(2, 5),
                        FlSpot(3, 8),
                        FlSpot(4, 7),
                        FlSpot(5, 9),
                        FlSpot(6, 8),
                        FlSpot(7, 6),
                      ],
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.deepPurple,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.deepPurple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                    // Recovery Points Line
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 4),
                        FlSpot(2, 7),
                        FlSpot(3, 5),
                        FlSpot(4, 6),
                        FlSpot(5, 4),
                        FlSpot(6, 7),
                        FlSpot(7, 8),
                      ],
                      isCurved: true,
                      color: Colors.red.shade400,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.red.shade400,
                          );
                        },
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor:(spot)=> Colors.white.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final String text = barSpot.barIndex == 0
                              ? 'RPE: ${barSpot.y}'
                              : 'RP: ${barSpot.y}';
                          final Color color = barSpot.barIndex == 0
                              ? Colors.deepPurple
                              : Colors.red.shade400;
                          return LineTooltipItem(
                            text,
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
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
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class CircularIndicator extends StatelessWidget {
  final double percent;
  final Color color;
  final double size;
  final String label;
  final String value;

  const CircularIndicator({
    Key? key,
    required this.percent,
    required this.color,
    required this.size,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}