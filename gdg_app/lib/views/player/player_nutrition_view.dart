// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class NutritionPlan extends StatefulWidget {
  const NutritionPlan({super.key});

  @override
  _NutritionPlanState createState() => _NutritionPlanState();
}

class _NutritionPlanState extends State<NutritionPlan> {
  final Map<String, bool> _expandedSections = {
    'Breakfast': false,
    'Lunch': false,
    'Snacks': false,
    'Dinner': false,
  };

  String _selectedDay = 'Monday';
  String _searchQuery = '';

  final Map<String, dynamic> nutritionData = {
    'Monday': {
      'breakfast': [
        {
          'name': 'Oatmeal with Berries',
          'protein': 10,
          'carbohydrates': 30,
          'fat': 5,
          'medicines': 'Vitamin D, Omega-3'
        },
        {
          'name': 'Scrambled Eggs',
          'protein': 12,
          'carbohydrates': 2,
          'fat': 10,
          'medicines': 'Multivitamin'
        },
      ],
      'lunch': [
        {
          'name': 'Grilled Chicken Salad',
          'protein': 25,
          'carbohydrates': 10,
          'fat': 15,
          'medicines': 'Vitamin C'
        },
      ],
      'snacks': [
        {
          'name': 'Greek Yogurt with Honey',
          'protein': 15,
          'carbohydrates': 20,
          'fat': 5,
          'medicines': 'Probiotic'
        },
      ],
      'dinner': [
        {
          'name': 'Salmon with Quinoa',
          'protein': 30,
          'carbohydrates': 25,
          'fat': 20,
          'medicines': 'Magnesium'
        },
      ],
    },
    // Add data for other days...
  };

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  void _onDayChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedDay = newValue;
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
        title: const Text('Nutrition Plan'),
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
        selectedDrawerItem: '/nutritional-plan',
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
                    value: _selectedDay,
                    onChanged: _onDayChanged,
                    items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCollapsibleCard(
                      title: 'Breakfast',
                      isExpanded: _expandedSections['Breakfast']!,
                      onToggle: () => _toggleSection('Breakfast'),
                      children: _buildMealItems(nutritionData[_selectedDay]['breakfast']),
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: 'Lunch',
                      isExpanded: _expandedSections['Lunch']!,
                      onToggle: () => _toggleSection('Lunch'),
                      children: _buildMealItems(nutritionData[_selectedDay]['lunch']),
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: 'Snacks',
                      isExpanded: _expandedSections['Snacks']!,
                      onToggle: () => _toggleSection('Snacks'),
                      children: _buildMealItems(nutritionData[_selectedDay]['snacks']),
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: 'Dinner',
                      isExpanded: _expandedSections['Dinner']!,
                      onToggle: () => _toggleSection('Dinner'),
                      children: _buildMealItems(nutritionData[_selectedDay]['dinner']),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.deepPurple,
            ),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMealItems(List<Map<String, dynamic>> meals) {
    return meals.map((meal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Protein: ${meal['protein']}g | Carbohydrates: ${meal['carbohydrates']}g | Fat: ${meal['fat']}g',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Medicines: ${meal['medicines']}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const Divider(),
        ],
      );
    }).toList();
  }
}