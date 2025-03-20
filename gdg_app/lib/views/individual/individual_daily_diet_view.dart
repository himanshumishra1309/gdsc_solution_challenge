import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart'; // Add this package for date formatting

class IndividualDailyDietView extends StatefulWidget {
  const IndividualDailyDietView({super.key});

  @override
  _IndividualDailyDietViewState createState() => _IndividualDailyDietViewState();
}

class _IndividualDailyDietViewState extends State<IndividualDailyDietView> with SingleTickerProviderStateMixin {
  String _selectedDrawerItem = individualDailyDietRoute;
  String _selectedPlan = 'Own Plan';
  DateTime _selectedDate = DateTime.now();
  int _expandedDayIndex = 0;
  late TabController _tabController;
  String _searchQuery = '';
  
  // Predefined meal types
  final List<String> _mealTypes = ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  // Sample data for recommended plan
  final Map<String, List<Map<String, dynamic>>> _recommendedMeals = {
    'Monday': [
      {'type': 'Breakfast', 'time': '8:00 AM', 'food': 'Oatmeal with fruits', 'calories': 350},
      {'type': 'Morning Snack', 'time': '10:30 AM', 'food': 'Greek yogurt with honey', 'calories': 180},
      {'type': 'Lunch', 'time': '1:00 PM', 'food': 'Grilled chicken salad', 'calories': 450},
      {'type': 'Evening Snack', 'time': '4:00 PM', 'food': 'Mixed nuts', 'calories': 200},
      {'type': 'Dinner', 'time': '7:00 PM', 'food': 'Baked salmon with vegetables', 'calories': 520},
    ],
    'Tuesday': [
      {'type': 'Breakfast', 'time': '7:30 AM', 'food': 'Scrambled eggs with toast', 'calories': 380},
      {'type': 'Morning Snack', 'time': '10:00 AM', 'food': 'Apple with peanut butter', 'calories': 210},
      {'type': 'Lunch', 'time': '12:30 PM', 'food': 'Quinoa bowl with avocado', 'calories': 480},
      {'type': 'Evening Snack', 'time': '3:30 PM', 'food': 'Protein shake', 'calories': 220},
      {'type': 'Dinner', 'time': '7:30 PM', 'food': 'Lean beef stir fry', 'calories': 550},
    ],
  };

  // Sample supplements data
  final Map<String, List<Map<String, dynamic>>> _supplements = {
    'Monday': [
      {'name': 'Multivitamin', 'time': '8:00 AM', 'dosage': '1 tablet'},
      {'name': 'Protein Powder', 'time': '4:30 PM', 'dosage': '1 scoop'},
      {'name': 'Omega-3', 'time': '7:00 PM', 'dosage': '1 capsule'},
    ],
    'Tuesday': [
      {'name': 'Multivitamin', 'time': '7:30 AM', 'dosage': '1 tablet'},
      {'name': 'Creatine', 'time': '6:00 PM', 'dosage': '5g'},
      {'name': 'Magnesium', 'time': '9:00 PM', 'dosage': '1 tablet'},
    ],
  };

  // User's own plan data
  Map<String, List<Map<String, dynamic>>> _userMeals = {};
  Map<String, List<Map<String, dynamic>>> _userSupplements = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _expandedDayIndex = _tabController.index;
        });
      }
    });
    
    // Initialize with some sample user data
    for (var day in _days) {
      _userMeals[day] = [];
      _userSupplements[day] = [];
    }
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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tabController.animateTo(_selectedDate.weekday - 1);
      });
    }
  }

  void _addUserMeal(String day) {
  setState(() {
    // Ensure the day entry exists
    if (_userMeals[day] == null) {
      _userMeals[day] = [];
    }
    
    // Add a new meal with default values
    _userMeals[day]!.add({
      'type': _mealTypes[0], // Use first meal type as default
      'time': '12:00 PM',
      'food': '',
      'calories': 0,
    });
  });
}

 void _addUserSupplement(String day) {
  setState(() {
    // Ensure the day entry exists
    if (_userSupplements[day] == null) {
      _userSupplements[day] = [];
    }
    
    // Add a new supplement with default values
    _userSupplements[day]!.add({
      'name': '',
      'time': '8:00 AM',
      'dosage': '',
    });
  });
}

  void _removeMeal(String day, int index) {
    setState(() {
      _userMeals[day]!.removeAt(index);
    });
  }

  void _removeSupplement(String day, int index) {
    setState(() {
      _userSupplements[day]!.removeAt(index);
    });
  }

  final AuthService _authService = AuthService();
  
  // Update your _handleLogout method
  Future<void> _handleLogout() async {
    bool success = await _authService.logout();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }
  }

  // Update your _onWillPop method to use _handleLogout
  Future<bool> _onWillPop() async {
    final bool? shouldLogout = await showDialog<bool>(
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
    
    if (shouldLogout == true) {
      await _handleLogout();
    }
    
    return false; // Return false to prevent app from closing
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              // Show nutrition guide
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nutrition Guide'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Nutritional Goals:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Protein: 1.6-2g per kg of body weight'),
                        Text('• Carbs: 4-7g per kg of body weight'),
                        Text('• Fat: 0.5-1.5g per kg of body weight'),
                        Text('• Water: 35-45ml per kg of body weight'),
                        SizedBox(height: 16),
                        Text(
                          'Pre-Workout Nutrition:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• 1-2 hours before: Complex carbs + lean protein'),
                        Text('• Example: Oatmeal with banana and protein shake'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              // Show nutrition analytics
            },
          ),
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
        onLogout: () => _onWillPop(),
      ),
      body: Column(
        children: [
          // Header with date selector and plan toggle
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Plan Selection Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlan = 'Own Plan';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 'Own Plan'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'My Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedPlan == 'Own Plan'
                                    ? Colors.deepPurple
                                    : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlan = 'Recommended Plan';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 'Recommended Plan'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedPlan == 'Recommended Plan'
                                    ? Colors.deepPurple
                                    : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date selector
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Week of ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Days of week tabs
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.deepPurple,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: _days.map((day) => Tab(text: day)).toList(),
            ),
          ),
          
          // Plan Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                return _selectedPlan == 'Own Plan'
                    ? _buildUserPlanDay(day)
                    : _buildRecommendedPlanDay(day);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedPlan == 'Own Plan' ? FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.add),
      onPressed: () {
        final currentDay = _days[_tabController.index]; // Use current tab index
        
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add to your plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade50,
                      child: const Icon(Icons.fastfood, color: Colors.deepPurple),
                    ),
                    title: const Text('Add Meal'),
                    onTap: () {
                      Navigator.pop(context);
                      _addUserMeal(currentDay);
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade50,
                      child: const Icon(Icons.medication, color: Colors.deepPurple),
                    ),
                    title: const Text('Add Supplement'),
                    onTap: () {
                      Navigator.pop(context);
                      _addUserSupplement(currentDay);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ) : null,
    );
  }

  Widget _buildUserPlanDay(String day) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meals section
          _buildSectionHeader('Meals', Icons.restaurant),
          const SizedBox(height: 12),
          
          // User meals list
          ..._userMeals[day]!.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> meal = entry.value;
            return _buildUserMealCard(day, index, meal);
          }).toList(),
          
          if (_userMeals[day]!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No meals added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _addUserMeal(day),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Meal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Supplements section
          _buildSectionHeader('Supplements', Icons.medication),
          const SizedBox(height: 12),
          
          // User supplements list
          ..._userSupplements[day]!.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> supplement = entry.value;
            return _buildUserSupplementCard(day, index, supplement);
          }).toList(),
          
          if (_userSupplements[day]!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.medication,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No supplements added yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _addUserSupplement(day),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Supplement'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildRecommendedPlanDay(String day) {
    // Check if we have data for this day
    final hasMeals = _recommendedMeals.containsKey(day) && _recommendedMeals[day]!.isNotEmpty;
    final hasSupplements = _supplements.containsKey(day) && _supplements[day]!.isNotEmpty;
    
    if (!hasMeals && !hasSupplements) {
      // Show "create plan" view if no recommended plan exists for this day
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.deepPurple.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No plan available for this day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Answer a few questions to get a personalized diet plan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Show questionnaire for creating a plan
              },
              icon: const Icon(Icons.create),
              label: const Text('Create Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show the recommended plan
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutritional summary
          Card(
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
                    'Daily Nutritional Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNutrientProgress('Protein', 0.75, '120g', Colors.blue),
                      _buildNutrientProgress('Carbs', 0.6, '250g', Colors.orange),
                      _buildNutrientProgress('Fat', 0.85, '65g', Colors.green),
                      _buildNutrientProgress('Water', 0.5, '2.5L', Colors.cyan),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Meals section
          if (hasMeals) ...[
            _buildSectionHeader('Meals', Icons.restaurant),
            const SizedBox(height: 12),
            
            ..._recommendedMeals[day]!.map((meal) {
              return _buildRecommendedMealCard(meal);
            }).toList(),
            
            const SizedBox(height: 24),
          ],
          
          // Supplements section
          if (hasSupplements) ...[
            _buildSectionHeader('Supplements', Icons.medication),
            const SizedBox(height: 12),
            
            ..._supplements[day]!.map((supplement) {
              return _buildRecommendedSupplementCard(supplement);
            }).toList(),
          ],
          
          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.deepPurple,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

Widget _buildUserMealCard(String day, int index, Map<String, dynamic> meal) {
  // Create controllers to preserve values during editing
  final typeController = TextEditingController(text: meal['type']);
  final timeController = TextEditingController(text: meal['time']);
  final caloriesController = TextEditingController(text: meal['calories'].toString());
  final foodController = TextEditingController(text: meal['food']?.toString() ?? '');
  
  // Check if this is a newly added item (hasn't been saved yet)
  // We'll use a dedicated 'saved' flag rather than checking field values
  final bool isNew = meal['saved'] != true;
  
  return StatefulBuilder(
    builder: (context, setState) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        contentPadding: EdgeInsets.zero,
                      ),
                      value: meal['type'],
                      items: _mealTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          meal['type'] = newValue;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMeal(day, index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        contentPadding: EdgeInsets.zero,
                      ),
                      controller: timeController,
                      onChanged: (value) {
                        meal['time'] = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.number,
                      controller: caloriesController,
                      onChanged: (value) {
                        meal['calories'] = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Food/Description',
                  contentPadding: EdgeInsets.zero,
                ),
                controller: foodController,
                onChanged: (value) {
                  meal['food'] = value;
                },
              ),
              
              // Show Save button ONLY for new/unsaved items, regardless of content
              if (isNew) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Apply any pending edits from text controllers
                        if (timeController.text.isNotEmpty) {
                          meal['time'] = timeController.text;
                        }
                        if (caloriesController.text.isNotEmpty) {
                          meal['calories'] = int.tryParse(caloriesController.text) ?? 0;
                        }
                        if (foodController.text.isNotEmpty) {
                          meal['food'] = foodController.text;
                        }
                        
                        // Mark as saved
                        this.setState(() {
                          meal['saved'] = true;
                        });
                        
                        // Show confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Meal added successfully'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        
                        // Add another meal
                        _addUserMeal(day);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save & Add Another'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildUserSupplementCard(String day, int index, Map<String, dynamic> supplement) {
  // Create controllers to preserve values during editing
  final nameController = TextEditingController(text: supplement['name']);
  final timeController = TextEditingController(text: supplement['time']);
  final dosageController = TextEditingController(text: supplement['dosage']);
  
  // Check if this is a newly added item (hasn't been saved yet)
  final bool isNew = supplement['saved'] != true;
  
  return StatefulBuilder(
    builder: (context, setState) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Supplement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeSupplement(day, index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  contentPadding: EdgeInsets.zero,
                ),
                controller: nameController,
                onChanged: (value) {
                  supplement['name'] = value;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        contentPadding: EdgeInsets.zero,
                      ),
                      controller: timeController,
                      onChanged: (value) {
                        supplement['time'] = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Dosage',
                        contentPadding: EdgeInsets.zero,
                      ),
                      controller: dosageController,
                      onChanged: (value) {
                        supplement['dosage'] = value;
                      },
                    ),
                  ),
                ],
              ),
              
              // Show Save button ONLY for new items, regardless of content
              if (isNew) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Apply any pending edits from text controllers
                        if (nameController.text.isNotEmpty) {
                          supplement['name'] = nameController.text;
                        }
                        if (timeController.text.isNotEmpty) {
                          supplement['time'] = timeController.text;
                        }
                        if (dosageController.text.isNotEmpty) {
                          supplement['dosage'] = dosageController.text;
                        }
                        
                        // Mark as saved
                        this.setState(() {
                          supplement['saved'] = true;
                        });
                        
                        // Show confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Supplement added successfully'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        
                        // Add another supplement
                        _addUserSupplement(day);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save & Add Another'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildRecommendedMealCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMealTypeIcon(meal['type']),
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
                        meal['type'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meal['time'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${meal['calories']} cal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    size: 16,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal['food'],
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Show nutritional details
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Nutrition Facts'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // Add to shopping list
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Add to List'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide(color: Colors.deepPurple.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSupplementCard(Map<String, dynamic> supplement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Icon(
                Icons.medication,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplement['time'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplement['dosage'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              onPressed: () {
                // Show supplement details
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientProgress(String name, double progress, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'morning snack':
        return Icons.coffee;
      case 'lunch':
        return Icons.lunch_dining;
      case 'evening snack':
        return Icons.fastfood;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}