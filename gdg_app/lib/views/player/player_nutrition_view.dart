// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class NutritionPlan extends StatefulWidget {
  const NutritionPlan({super.key});

  @override
  _NutritionPlanState createState() => _NutritionPlanState();
}

class _NutritionPlanState extends State<NutritionPlan> {
  final _authService = AuthService();
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
          'calories': 220,
          'medicines': 'Vitamin D, Omega-3',
          'image': 'assets/images/oatmeal.jpg',
        },
        {
          'name': 'Scrambled Eggs',
          'protein': 12,
          'carbohydrates': 2,
          'fat': 10,
          'calories': 175,
          'medicines': 'Multivitamin',
          'image': 'assets/images/eggs.jpg',
        },
      ],
      'lunch': [
        {
          'name': 'Grilled Chicken Salad',
          'protein': 25,
          'carbohydrates': 10,
          'fat': 15,
          'calories': 320,
          'medicines': 'Vitamin C',
          'image': 'assets/images/salad.jpg',
        },
      ],
      'snacks': [
        {
          'name': 'Greek Yogurt with Honey',
          'protein': 15,
          'carbohydrates': 20,
          'fat': 5,
          'calories': 180,
          'medicines': 'Probiotic',
          'image': 'assets/images/yogurt.jpg',
        },
      ],
      'dinner': [
        {
          'name': 'Salmon with Quinoa',
          'protein': 30,
          'carbohydrates': 25,
          'fat': 20,
          'calories': 420,
          'medicines': 'Magnesium',
          'image': 'assets/images/salmon.jpg',
        },
      ],
    },
    // Add data for other days...
  };

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  // Get appropriate icon for meal type
  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'snacks':
        return Icons.restaurant_menu;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.food_bank;
    }
  }

  // Get appropriate color for meal type
  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.amber.shade700;
      case 'lunch':
        return Colors.green.shade600;
      case 'snacks':
        return Colors.purple.shade400;
      case 'dinner':
        return Colors.indigo.shade400;
      default:
        return Colors.deepPurple;
    }
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Nutrition Info',
            onPressed: () {
              _showNutritionInfo(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: '/nutritional-plan',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Nutrition Summary Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Nutrition Plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            _selectedDay,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildDaySelector(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search meals...',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutrientWidget(
                          'Protein', '80g', Colors.red.shade400),
                      _buildNutrientWidget(
                          'Carbs', '87g', Colors.green.shade400),
                      _buildNutrientWidget('Fat', '50g', Colors.amber.shade400),
                      _buildNutrientWidget(
                          'Calories', '1095', Colors.blue.shade400),
                    ],
                  ),
                ],
              ),
            ),
            // Meal Cards
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    _buildMealCard(
                      'Breakfast',
                      nutritionData[_selectedDay]['breakfast'],
                    ),
                    _buildMealCard(
                      'Lunch',
                      nutritionData[_selectedDay]['lunch'],
                    ),
                    _buildMealCard(
                      'Snacks',
                      nutritionData[_selectedDay]['snacks'],
                    ),
                    _buildMealCard(
                      'Dinner',
                      nutritionData[_selectedDay]['dinner'],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tracking feature coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add_task, color: Colors.white),
        tooltip: 'Track your meals',
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDay,
          onChanged: _onDayChanged,
          items: <String>[
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ].map<DropdownMenuItem<String>>((String value) {
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
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          dropdownColor: Colors.white,
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildNutrientWidget(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            label == 'Protein'
                ? Icons.fitness_center
                : label == 'Carbs'
                    ? Icons.grain
                    : label == 'Fat'
                        ? Icons.opacity
                        : Icons.local_fire_department,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String mealType, List<Map<String, dynamic>> meals) {
    if (meals.isEmpty) return Container();

    final bool isExpanded = _expandedSections[mealType]!;
    final Color mealColor = _getMealColor(mealType);

    return Container(
      margin: const EdgeInsets.only(top: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Header
          InkWell(
            onTap: () => _toggleSection(mealType),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: mealColor.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: mealColor.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getMealIcon(mealType),
                      color: mealColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mealType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mealColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: mealColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mealColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${meals.length} item${meals.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mealColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: mealColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: mealColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Meal Content
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              children:
                  meals.map((meal) => _buildMealItem(meal, mealType)).toList(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal, String mealType) {
    final Color mealColor = _getMealColor(mealType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal image or placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 80,
              height: 80,
              color: mealColor.withOpacity(0.1),
              child: meal.containsKey('image') && meal['image'] != null
                  ? Image.asset(
                      meal['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.restaurant,
                          color: mealColor.withOpacity(0.5),
                          size: 32,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.restaurant,
                        color: mealColor.withOpacity(0.5),
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name
                Text(
                  meal['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mealColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Macronutrients
                Wrap(
  spacing: 8, // horizontal spacing
  runSpacing: 8, // vertical spacing
  children: [
    _buildMacroIndicator('P', meal['protein'], 'g', Colors.red.shade400),
    _buildMacroIndicator('C', meal['carbohydrates'], 'g', Colors.green.shade400),
    _buildMacroIndicator('F', meal['fat'], 'g', Colors.amber.shade400),
    if (meal.containsKey('calories'))
      _buildMacroIndicator('Cal', meal['calories'], '', Colors.blue.shade400),
  ],
),
                const SizedBox(height: 8),
                // Medicines
                if (meal.containsKey('medicines') && meal['medicines'] != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.medication,
                        size: 14,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meal['medicines'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline,
                size: 20, color: Colors.deepPurple),
            onPressed: () => _showMealDetails(context, meal),
            splashRadius: 20,
            tooltip: 'View details',
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(
      String label, dynamic value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetails(BuildContext context, Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Center(
              child: Text(
                meal['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailCard(
                    'Protein', '${meal['protein']}g', Colors.red.shade400),
                _buildDetailCard('Carbs', '${meal['carbohydrates']}g',
                    Colors.green.shade400),
                _buildDetailCard(
                    'Fat', '${meal['fat']}g', Colors.amber.shade400),
                if (meal.containsKey('calories'))
                  _buildDetailCard('Calories', meal['calories'].toString(),
                      Colors.blue.shade400),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Nutritional Benefits:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _generateNutritionBenefits(meal),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            if (meal.containsKey('medicines') && meal['medicines'] != null) ...[
              const Text(
                'Supplements:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meal['medicines'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal marked as consumed!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mark as Consumed'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, Color color) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _generateNutritionBenefits(Map<String, dynamic> meal) {
    String mealName = meal['name'].toString().toLowerCase();

    if (mealName.contains('oatmeal')) {
      return 'Rich in fiber that helps maintain healthy blood sugar levels. Berries provide antioxidants that support recovery and immune function.';
    } else if (mealName.contains('egg')) {
      return 'High-quality protein source that supports muscle repair and growth. Contains choline for brain health and development.';
    } else if (mealName.contains('chicken')) {
      return 'Lean protein source that aids in muscle recovery. The salad provides essential vitamins and minerals for overall health.';
    } else if (mealName.contains('yogurt')) {
      return 'Contains probiotics that support gut health and immune function. Good source of protein and calcium for muscle and bone health.';
    } else if (mealName.contains('salmon')) {
      return 'Rich in omega-3 fatty acids that reduce inflammation and support heart health. Quinoa provides complex carbohydrates and complete protein.';
    }

    return 'This meal provides a balanced mix of nutrients to support your training goals and overall health.';
  }

  void _showNutritionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nutrition Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your personalized nutrition plan is designed to optimize your athletic performance and recovery.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Plans are tailored to your specific training needs',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Macronutrients are balanced for optimal performance',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Supplements are recommended by our sports nutritionists',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 2,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
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
}

// Custom clip path for diagonal section dividers
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Enhanced version of nutrition plan with improved styling
class EnhancedNutritionPlan extends StatefulWidget {
  const EnhancedNutritionPlan({super.key});

  @override
  _EnhancedNutritionPlanState createState() => _EnhancedNutritionPlanState();
}

class _EnhancedNutritionPlanState extends State<EnhancedNutritionPlan>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 7, vsync: this); // One tab for each day
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Nutrition'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Monday'),
            Tab(text: 'Tuesday'),
            Tab(text: 'Wednesday'),
            Tab(text: 'Thursday'),
            Tab(text: 'Friday'),
            Tab(text: 'Saturday'),
            Tab(text: 'Sunday'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // One tab view for each day
          for (int i = 0; i < 7; i++) _buildDayView(i),
        ],
      ),
    );
  }

  Widget _buildDayView(int dayIndex) {
    // Here you would implement the enhanced day view
    return Center(
      child: Text('Enhanced nutrition view for day ${dayIndex + 1}'),
    );
  }
}
