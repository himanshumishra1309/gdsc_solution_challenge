import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewGymPlan extends StatefulWidget {
  const ViewGymPlan({super.key});

  @override
  _ViewGymPlanState createState() => _ViewGymPlanState();
}

class _ViewGymPlanState extends State<ViewGymPlan> with SingleTickerProviderStateMixin {
  String _selectedMonth = 'January';
  String _selectedWeek = 'Week 1';
  String _selectedDay = 'Monday';
  late TabController _tabController;
  
  // Track expanded sections
  final Map<String, bool> _expandedSections = {
    'Monday': true,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  // Gym plan data structure - extended with more detailed workout information
  final Map<String, dynamic> _gymPlan = {
    'January': {
      'Week 1': {
        'Monday': {
          'title': 'Cardio and Abs',
          'focus': 'Endurance & Core',
          'exercises': [
            {
              'name': 'Running',
              'sets': '1',
              'reps': '20 mins',
              'notes': 'Moderate pace, maintain heart rate at 150 bpm'
            },
            {
              'name': 'Bicycle Crunches',
              'sets': '3',
              'reps': '20',
              'notes': 'Focus on controlled movement'
            },
            {
              'name': 'Plank',
              'sets': '3',
              'reps': '45 sec',
              'notes': 'Keep proper form, straight back'
            },
            {
              'name': 'Russian Twists',
              'sets': '3',
              'reps': '20',
              'notes': 'Use medicine ball if available'
            }
          ],
          'cooldown': 'Light stretching',
          'duration': '60 min',
          'intensity': 'Medium'
        },
        'Tuesday': {
          'title': 'Upper Body Strength',
          'focus': 'Chest, Back, Arms',
          'exercises': [
            {
              'name': 'Bench Press',
              'sets': '4',
              'reps': '8-10',
              'notes': 'Weight: 70-80% of 1RM'
            },
            {
              'name': 'Pull-ups',
              'sets': '3',
              'reps': '8-12',
              'notes': 'Assisted if necessary'
            },
            {
              'name': 'Shoulder Press',
              'sets': '3',
              'reps': '10',
              'notes': 'Maintain neutral spine'
            },
            {
              'name': 'Bicep Curls',
              'sets': '3',
              'reps': '12',
              'notes': 'Control the movement'
            }
          ],
          'cooldown': 'Upper body stretches',
          'duration': '75 min',
          'intensity': 'High'
        },
        'Wednesday': {
          'title': 'Lower Body Strength',
          'focus': 'Legs & Glutes',
          'exercises': [
            {
              'name': 'Squats',
              'sets': '4',
              'reps': '12',
              'notes': 'Focus on form and depth'
            },
            {
              'name': 'Lunges',
              'sets': '3',
              'reps': '10 each leg',
              'notes': 'Keep knees aligned'
            },
            {
              'name': 'Leg Press',
              'sets': '3',
              'reps': '15',
              'notes': 'Don\'t lock knees at extension'
            },
            {
              'name': 'Calf Raises',
              'sets': '3',
              'reps': '20',
              'notes': 'Full range of motion'
            }
          ],
          'cooldown': 'Lower body stretches',
          'duration': '70 min',
          'intensity': 'High'
        },
        'Thursday': {
          'title': 'Rest Day',
          'focus': 'Recovery',
          'exercises': [],
          'cooldown': 'Light walking if desired',
          'duration': '0 min',
          'intensity': 'Low',
          'notes': 'Focus on proper nutrition and hydration to aid recovery'
        },
        'Friday': {
          'title': 'Full Body Workout',
          'focus': 'Overall Strength',
          'exercises': [
            {
              'name': 'Deadlifts',
              'sets': '4',
              'reps': '8',
              'notes': 'Focus on proper back position'
            },
            {
              'name': 'Push-ups',
              'sets': '3',
              'reps': '15',
              'notes': 'Chest to floor'
            },
            {
              'name': 'Pull-ups',
              'sets': '3',
              'reps': '8-12',
              'notes': 'Full extension at bottom'
            },
            {
              'name': 'Kettlebell Swings',
              'sets': '3',
              'reps': '15',
              'notes': 'Explosive hip movement'
            }
          ],
          'cooldown': 'Full body stretching',
          'duration': '80 min',
          'intensity': 'High'
        },
        'Saturday': {
          'title': 'Yoga and Stretching',
          'focus': 'Mobility & Balance',
          'exercises': [
            {
              'name': 'Sun Salutations',
              'sets': '2',
              'reps': '5 mins',
              'notes': 'Flow through positions'
            },
            {
              'name': 'Warrior Poses',
              'sets': '1',
              'reps': '10 mins',
              'notes': 'Focus on stability'
            },
            {
              'name': 'Hip Openers',
              'sets': '1',
              'reps': '10 mins',
              'notes': 'Deep breathing'
            }
          ],
          'cooldown': 'Relaxation pose',
          'duration': '45 min',
          'intensity': 'Low'
        },
        'Sunday': {
          'title': 'Rest Day',
          'focus': 'Recovery',
          'exercises': [],
          'cooldown': 'Optional light stretching',
          'duration': '0 min',
          'intensity': 'Low',
          'notes': 'Prepare mentally for next week\'s training'
        },
      },
      'Week 2': {
        'Monday': {
          'title': 'HIIT Training',
          'focus': 'Cardiovascular & Fat Burn',
          'exercises': [
            {
              'name': 'Burpees',
              'sets': '5',
              'reps': '10',
              'notes': '30 sec rest between sets'
            },
            {
              'name': 'Mountain Climbers',
              'sets': '5',
              'reps': '30 sec',
              'notes': '30 sec rest between sets'
            },
            {
              'name': 'Jump Squats',
              'sets': '5',
              'reps': '15',
              'notes': '30 sec rest between sets'
            }
          ],
          'cooldown': 'Light stretching',
          'duration': '50 min',
          'intensity': 'Very High'
        },
        // Add other days for Week 2...
      },
    },
  };
  
  // Define icons for different workout types
  final Map<String, IconData> _workoutIcons = {
    'Cardio and Abs': Icons.directions_run,
    'Upper Body Strength': Icons.fitness_center,
    'Lower Body Strength': Icons.accessibility_new,
    'Rest Day': Icons.hotel,
    'Full Body Workout': Icons.sync_alt,
    'Yoga and Stretching': Icons.self_improvement,
    'HIIT Training': Icons.flash_on,
  };

  // Define colors for different workout intensities
  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return Colors.green.shade700;
      case 'medium':
        return Colors.amber.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'very high':
        return Colors.red.shade700;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    
    // Set the initial tab to today's day (Monday = 0, Sunday = 6)
    final today = DateTime.now().weekday;
    if (today >= 1 && today <= 7) {
      _tabController.index = today - 1;
      _selectedDay = _getDayName(today - 1);
      _expandedSections[_selectedDay] = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getDayName(int index) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }

  void _onMonthChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedMonth = newValue;
      });
    }
  }

  void _onWeekChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedWeek = newValue;
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedDay = _getDayName(index);
    });
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    final workoutPlan = _gymPlan[_selectedMonth]?[_selectedWeek]?[_selectedDay];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Plan'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: '/view-gym-plan',
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
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMonth,
                            onChanged: _onMonthChanged,
                            items: <String>[
                              'January',
                              'February',
                              'March',
                              'April',
                              'May',
                              'June',
                              'July',
                              'August',
                              'September',
                              'October',
                              'November',
                              'December'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 28),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedWeek,
                            onChanged: _onWeekChanged,
                            items: <String>[
                              'Week 1',
                              'Week 2',
                              'Week 3',
                              'Week 4',
                              'Week 5'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 28),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            elevation: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Day tabs
                TabBar(
                  controller: _tabController,
                  onTap: _onTabChanged,
                  isScrollable: true,
                  indicatorColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey.shade700,
                  tabs: [
                    _buildTabDay('Mon', 'Monday', 0),
                    _buildTabDay('Tue', 'Tuesday', 1),
                    _buildTabDay('Wed', 'Wednesday', 2),
                    _buildTabDay('Thu', 'Thursday', 3),
                    _buildTabDay('Fri', 'Friday', 4),
                    _buildTabDay('Sat', 'Saturday', 5),
                    _buildTabDay('Sun', 'Sunday', 6),
                  ],
                ),
              ],
            ),
          ),

          // Workout content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Monday
                _buildWorkoutDay('Monday'),
                // Tuesday
                _buildWorkoutDay('Tuesday'),
                // Wednesday
                _buildWorkoutDay('Wednesday'),
                // Thursday
                _buildWorkoutDay('Thursday'),
                // Friday
                _buildWorkoutDay('Friday'),
                // Saturday
                _buildWorkoutDay('Saturday'),
                // Sunday
                _buildWorkoutDay('Sunday'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mark workout as completed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${workoutPlan['title']} marked as completed!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.check),
        label: const Text('Mark Complete'),
      ),
    );
  }

  Widget _buildTabDay(String shortName, String fullName, int index) {
    final isSelected = _selectedDay == fullName;
    final hasWorkout = _gymPlan[_selectedMonth]?[_selectedWeek]?[fullName]['exercises'].length > 0;
    
    return Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shortName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasWorkout ? 
                Colors.deepPurple.withOpacity(isSelected ? 1.0 : 0.5) : 
                Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutDay(String day) {
    final workout = _gymPlan[_selectedMonth]?[_selectedWeek]?[day];
    
    if (workout == null) {
      return const Center(child: Text('No workout information available'));
    }

    final workoutTitle = workout['title'];
    final workoutFocus = workout['focus'];
    final exercises = workout['exercises'] as List<dynamic>;
    final cooldown = workout['cooldown'] ?? '';
    final duration = workout['duration'] ?? '';
    final intensity = workout['intensity'] ?? 'Medium';
    final notes = workout['notes'] ?? '';
    
    // Icon for workout type
    final IconData workoutIcon = _workoutIcons[workoutTitle] ?? Icons.fitness_center;
    
    // Color based on intensity
    final intensityColor = _getIntensityColor(intensity);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout header
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple,
                    Colors.deepPurple.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          workoutIcon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workoutTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workoutFocus,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
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
                      _buildWorkoutStat(Icons.timer, duration, 'Duration'),
                      _buildWorkoutStat(Icons.flash_on, intensity, 'Intensity'),
                      _buildWorkoutStat(Icons.fitness_center, '${exercises.length}', 'Exercises'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercises list
          if (exercises.isNotEmpty) ...[
            const Text(
              'Workout Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseCard(
                exercise['name'], 
                exercise['sets'], 
                exercise['reps'], 
                exercise['notes'],
                index,
              );
            }).toList(),
          ],
          
          const SizedBox(height: 16),
          
          // Cooldown section
          if (cooldown.isNotEmpty) ...[
            const Text(
              'Cooldown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.waves,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        cooldown,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Notes section
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        notes,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 80),  // Space for FAB
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  Widget _buildExerciseCard(String name, String sets, String reps, String notes, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            _buildExerciseMetric(Icons.repeat, '$sets sets'),
            const SizedBox(width: 16),
            _buildExerciseMetric(Icons.fitness_center, '$reps reps'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}