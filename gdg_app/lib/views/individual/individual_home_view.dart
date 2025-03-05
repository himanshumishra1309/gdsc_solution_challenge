import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualHomeView extends StatefulWidget {
  const IndividualHomeView({super.key});

  @override
  _IndividualHomeViewState createState() => _IndividualHomeViewState();
}

class _IndividualHomeViewState extends State<IndividualHomeView> {
  String _selectedDrawerItem = individualHomeRoute; // Highlight the current page
  String _selectedGraph = 'RPE Line Graph';
  String _selectedWeek = 'Week 1';
  String _selectedMonth = 'January';
  String _selectedYear = '2025';

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, landingPageRoute); // Replace with your home route
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
          title: const Text('Individual Home'),
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
              // First Row: Graph and Week Dropdowns
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedGraph,
                      items: ['RPE Line Graph', 'Spider Graph', 'Comparative RPE and RP Graph'],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGraph = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedWeek,
                      items: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedWeek = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Second Row: Month and Year Dropdowns
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
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
              const SizedBox(height: 24),
              Expanded(
                child: _buildGraph(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 1.5),
      ),
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        underline: Container(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 28),
        dropdownColor: Colors.white,
        elevation: 2,
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
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Day ${value.toInt()}',
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.deepPurple)),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 5),
              FlSpot(2, 6),
              FlSpot(3, 7),
              FlSpot(4, 8),
              FlSpot(5, 9),
              FlSpot(6, 7),
              FlSpot(7, 6),
            ],
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiderGraph() {
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: 8),
              RadarEntry(value: 7),
              RadarEntry(value: 6),
              RadarEntry(value: 5),
              RadarEntry(value: 9),
              RadarEntry(value: 8),
            ],
            borderColor: Colors.deepPurple,
            fillColor: Colors.deepPurple.withOpacity(0.3),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: const TextStyle(color: Colors.deepPurple, fontSize: 14),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: 'Sprint Speed');
            case 1:
              return RadarChartTitle(text: 'Pass Accuracy');
            case 2:
              return RadarChartTitle(text: 'Goals Scored');
            case 3:
              return RadarChartTitle(text: 'Tackles Won');
            case 4:
              return RadarChartTitle(text: 'Stamina');
            case 5:
              return RadarChartTitle(text: 'Agility');
            default:
              return RadarChartTitle(text: '');
          }
        },
      ),
    );
  }

  Widget _buildComparativeGraph() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Day ${value.toInt()}',
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.deepPurple)),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 5),
              FlSpot(2, 6),
              FlSpot(3, 7),
              FlSpot(4, 8),
              FlSpot(5, 9),
              FlSpot(6, 7),
              FlSpot(7, 6),
            ],
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: [
              FlSpot(1, 4),
              FlSpot(2, 5),
              FlSpot(3, 6),
              FlSpot(4, 7),
              FlSpot(5, 8),
              FlSpot(6, 6),
              FlSpot(7, 5),
            ],
            isCurved: true,
            color: Colors.red,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}