import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualGymPlanView extends StatefulWidget {
  const IndividualGymPlanView({super.key});

  @override
  _IndividualGymPlanViewState createState() => _IndividualGymPlanViewState();
}

class _IndividualGymPlanViewState extends State<IndividualGymPlanView> with SingleTickerProviderStateMixin {
  String _selectedDrawerItem = individualGymPlanRoute;
  String _selectedPlan = 'Own Plan';
  String _selectedWeek = 'Week 1';
  String _selectedMonth = 'January';
  late TabController _tabController;
  String _searchQuery = '';
  int _selectedDayIndex = 0;
  
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  // Workout data structure with more detailed information
  Map<String, List<Map<String, dynamic>>> _exercises = {};

  // Sample recommended plan data
  final Map<String, List<Map<String, dynamic>>> _recommendedExercises = {
    'Monday': [
      {'name': 'Bench Press', 'sets': 4, 'reps': '8-10', 'weight': '70kg', 'notes': 'Focus on chest contraction', 'category': 'Chest'},
      {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': '10-12', 'weight': '25kg', 'notes': 'Keep elbows at 45°', 'category': 'Chest'},
      {'name': 'Cable Flyes', 'sets': 3, 'reps': '12-15', 'weight': '15kg', 'notes': 'Full range of motion', 'category': 'Chest'},
      {'name': 'Tricep Pushdowns', 'sets': 4, 'reps': '12', 'weight': '30kg', 'notes': 'Focus on contraction', 'category': 'Arms'},
    ],
    'Wednesday': [
      {'name': 'Barbell Squats', 'sets': 4, 'reps': '8-10', 'weight': '100kg', 'notes': 'Focus on depth', 'category': 'Legs'},
      {'name': 'Romanian Deadlifts', 'sets': 3, 'reps': '10', 'weight': '80kg', 'notes': 'Keep back straight', 'category': 'Legs'},
      {'name': 'Leg Extensions', 'sets': 3, 'reps': '12-15', 'weight': '45kg', 'notes': 'Slow negatives', 'category': 'Legs'},
      {'name': 'Calf Raises', 'sets': 4, 'reps': '15-20', 'weight': '100kg', 'notes': 'Full extension', 'category': 'Legs'},
    ],
    'Friday': [
      {'name': 'Pull-ups', 'sets': 4, 'reps': '8-10', 'weight': 'BW', 'notes': 'Wide grip', 'category': 'Back'},
      {'name': 'Bent Over Rows', 'sets': 4, 'reps': '10', 'weight': '60kg', 'notes': 'Squeeze shoulder blades', 'category': 'Back'},
      {'name': 'Lat Pulldowns', 'sets': 3, 'reps': '12', 'weight': '65kg', 'notes': 'Wide grip', 'category': 'Back'},
      {'name': 'Bicep Curls', 'sets': 3, 'reps': '12', 'weight': '15kg', 'notes': 'Strict form', 'category': 'Arms'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedDayIndex = _tabController.index;
        });
      }
    });
    
    // Initialize empty exercise lists for all days
    for (var day in _days) {
      _exercises[day] = [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addExercise(String day) {
    setState(() {
      _exercises[day] = _exercises[day] ?? [];
      _exercises[day]!.add({
        'name': '',
        'sets': 3,
        'reps': '10',
        'weight': '',
        'notes': '',
        'category': 'Other',
        'saved': false,
      });
    });
  }

  void _removeExercise(String day, int index) {
    setState(() {
      _exercises[day]!.removeAt(index);
    });
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

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;
    
    switch (category.toLowerCase()) {
      case 'chest':
        icon = Icons.fitness_center;
        color = Colors.red.shade700;
        break;
      case 'back':
        icon = Icons.airline_seat_flat;
        color = Colors.blue.shade700;
        break;
      case 'legs':
        icon = Icons.directions_walk;
        color = Colors.green.shade700;
        break;
      case 'arms':
        icon = Icons.sports_handball;
        color = Colors.orange.shade700;
        break;
      case 'shoulders':
        icon = Icons.accessibility_new;
        color = Colors.purple.shade700;
        break;
      case 'core':
        icon = Icons.crop_square;
        color = Colors.teal.shade700;
        break;
      case 'cardio':
        icon = Icons.directions_run;
        color = Colors.pink.shade700;
        break;
      default:
        icon = Icons.fitness_center;
        color = Colors.grey.shade700;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
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
        title: const Text('Gym Plan'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Workout Analytics',
            onPressed: () {
              // Show analytics
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Workout Tips',
            onPressed: () {
              // Show tips dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Workout Tips'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proper Form',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Always prioritize proper form over lifting heavy weights'),
                        Text('• Focus on controlled movements and full range of motion'),
                        Text('• If unsure, consult a trainer or watch instructional videos'),
                        SizedBox(height: 16),
                        Text(
                          'Recovery',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Allow 48-72 hours of recovery for each muscle group'),
                        Text('• Ensure adequate sleep (7-9 hours) for optimal recovery'),
                        Text('• Consider deload weeks every 4-6 weeks'),
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
          // Header section with plan toggle
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
              ],
            ),
          ),
          
          // Search and filter section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.deepPurple),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Week and month selection
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedWeek,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedWeek = newValue!;
                              });
                            },
                            items: <String>['Week 1', 'Week 2', 'Week 3', 'Week 4']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMonth,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedMonth = newValue!;
                              });
                            },
                            items: <String>[
                              'January', 'February', 'March', 'April', 'May', 'June',
                              'July', 'August', 'September', 'October', 'November', 'December'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Days of week tabs
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.deepPurple,
              indicatorWeight: 3,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: _days.map((day) {
                // Show dot indicator for days with exercises
                bool hasExercises = false;
                if (_selectedPlan == 'Own Plan') {
                  hasExercises = (_exercises[day]?.isNotEmpty ?? false);
                } else {
                  hasExercises = (_recommendedExercises[day]?.isNotEmpty ?? false);
                }
                
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(day.substring(0, 3)),
                      if (hasExercises)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Workout content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                return _selectedPlan == 'Own Plan'
                    ? _buildOwnPlanDay(day)
                    : _buildRecommendedPlanDay(day);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedPlan == 'Own Plan'
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
              onPressed: () => _addExercise(_days[_selectedDayIndex]),
            )
          : null,
    );
  }

  Widget _buildOwnPlanDay(String day) {
    final exercises = _exercises[day] ?? [];
    
    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Exercises Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add exercises',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return _buildExerciseCard(day, index, exercises[index]);
      },
    );
  }

  Widget _buildExerciseCard(String day, int index, Map<String, dynamic> exercise) {
    final nameController = TextEditingController(text: exercise['name']?.toString() ?? '');
    final setsController = TextEditingController(text: exercise['sets']?.toString() ?? '3');
    final repsController = TextEditingController(text: exercise['reps']?.toString() ?? '');
    final weightController = TextEditingController(text: exercise['weight']?.toString() ?? '');
    final notesController = TextEditingController(text: exercise['notes']?.toString() ?? '');
    
    final categories = ['Chest', 'Back', 'Legs', 'Arms', 'Shoulders', 'Core', 'Cardio', 'Other'];
    final isNew = exercise['saved'] != true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCategoryIcon(exercise['category'] ?? 'Other'),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      exercise['name'] = value;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(day, index),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: exercise['category'] ?? 'Other',
                          isDense: true,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            setState(() {
                              exercise['category'] = newValue!;
                            });
                          },
                          items: categories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise['sets'] = int.tryParse(value) ?? 3;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: 'e.g., 8-10 or 12',
                    ),
                    onChanged: (value) {
                      exercise['reps'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: 'e.g., 60kg or BW',
                    ),
                    onChanged: (value) {
                      exercise['weight'] = value;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
                hintText: 'Add any tips or reminders',
              ),
              maxLines: 2,
              onChanged: (value) {
                exercise['notes'] = value;
              },
            ),
            
            if (isNew) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        // Apply any pending edits
                        if (nameController.text.isNotEmpty) {
                          exercise['name'] = nameController.text;
                        }
                        // Mark as saved
                        exercise['saved'] = true;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exercise added successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      
                      _addExercise(day);
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
  }

  Widget _buildRecommendedPlanDay(String day) {
    final exercises = _recommendedExercises[day] ?? [];
    
    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Rest Day',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take time to recover and prepare for your next session',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          color: Colors.deepPurple.shade50,
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDayWorkoutType(day),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercises.length} exercises · Approx. 60 minutes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  // Copy to own plan
                  setState(() {
                    _exercises[day] = List.from(exercises);
                    _selectedPlan = 'Own Plan';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to My Plan'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy to My Plan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _buildRecommendedExerciseCard(exercise, index + 1);
            },
          ),
        ),
      ],
    );
  }

  String _getDayWorkoutType(String day) {
    switch (day) {
      case 'Monday':
        return 'Chest & Triceps';
      case 'Tuesday':
        return 'Rest Day';
      case 'Wednesday':
        return 'Legs & Core';
      case 'Thursday':
        return 'Rest Day';
      case 'Friday':
        return 'Back & Biceps';
      case 'Saturday':
        return 'Rest Day';
      case 'Sunday':
        return 'Active Recovery';
      default:
        return 'Workout';
    }
  }

  Widget _buildRecommendedExerciseCard(Map<String, dynamic> exercise, int order) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                order.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(exercise['category']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise['category'],
                        style: TextStyle(
                          color: _getCategoryColor(exercise['category']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildExerciseDetail(
                      icon: Icons.repeat,
                      label: 'Sets',
                      value: exercise['sets'].toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildExerciseDetail(
                      icon: Icons.fitness_center,
                      label: 'Reps',
                      value: exercise['reps'],
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildExerciseDetail(
                      icon: Icons.scale,
                      label: 'Weight',
                      value: exercise['weight'],
                      color: Colors.orange,
                    ),
                  ],
                ),
                if (exercise['notes'] != null && exercise['notes'].isNotEmpty) ...[
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
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise['notes'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Open demo video/animation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(exercise['name']),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Proper form demonstration for ${exercise['name']}',
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
                      icon: const Icon(Icons.play_circle_outline, size: 16),
                      label: const Text('View Demo'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Track this exercise
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Start Tracking'),
                            content: const Text('Would you like to track this exercise in real-time?'),
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
                                      content: Text('Workout tracking started'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                child: const Text('Start'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer, size: 16),
                      label: const Text('Track'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildExerciseDetail({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'chest':
      return Colors.red.shade700;
    case 'back':
      return Colors.blue.shade700;
    case 'legs':
      return Colors.green.shade700;
    case 'arms':
      return Colors.orange.shade700;
    case 'shoulders':
      return Colors.purple.shade700;
    case 'core':
      return Colors.teal.shade700;
    case 'cardio':
      return Colors.pink.shade700;
    default:
      return Colors.grey.shade700;
  }
}
}