import 'package:flutter/material.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class GymTrainerUpdateGymPlanView extends StatefulWidget {
  const GymTrainerUpdateGymPlanView({super.key});

  @override
  _GymTrainerUpdateGymPlanViewState createState() =>
      _GymTrainerUpdateGymPlanViewState();
}

class _GymTrainerUpdateGymPlanViewState
    extends State<GymTrainerUpdateGymPlanView>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isLoading = true;
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  late TabController _tabController;

  // Map to store gym plans
  final Map<String, List<Map<String, dynamic>>> _gymPlans = {
    'active': [],
    'draft': [],
    'completed': [],
  };

  // List of players
  final List<Map<String, dynamic>> _players = [];

  // Selected players for assigning plans
  List<String> _selectedPlayerIds = [];

  // Currently selected plan for viewing/editing
  Map<String, dynamic>? _selectedPlan;

  // For new plan creation
  late DateTime _startDate;
  late DateTime _endDate;
  String _planName = '';
  String _planDescription = '';
  final List<Map<String, dynamic>> _weeklyExercises = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 7));
    _loadUserInfo();
    _loadSampleData();
    _initializeWeeklyExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeWeeklyExercises() {
    // Create empty exercise templates for each day of the week
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    _weeklyExercises.clear();

    for (var day in daysOfWeek) {
      _weeklyExercises.add({
        'day': day,
        'exercises': [],
        'isRestDay': false,
      });
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Gym Trainer";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSampleData() {
    // Sample default day plan template to use for plans missing daily plans
    final List<Map<String, dynamic>> defaultDailyPlans = [
      {
        'day': 'Monday',
        'isRestDay': false,
        'exercises': [
          {
            'name': 'Basic Warmup',
            'sets': 1,
            'reps': '5 minutes',
            'weight': 'N/A',
            'notes': 'Light cardio and dynamic stretching'
          }
        ]
      },
      {'day': 'Tuesday', 'isRestDay': false, 'exercises': []},
      {'day': 'Wednesday', 'isRestDay': true, 'exercises': []},
      {'day': 'Thursday', 'isRestDay': false, 'exercises': []},
      {'day': 'Friday', 'isRestDay': false, 'exercises': []},
      {'day': 'Saturday', 'isRestDay': false, 'exercises': []},
      {'day': 'Sunday', 'isRestDay': true, 'exercises': []}
    ];

    // Sample active plans - add daily plans to all of them
    _gymPlans['active'] = [
      {
        'id': '1',
        'name': 'Football Team Strength Plan',
        'description':
            'Focus on building core and leg strength for football players',
        'startDate': DateTime.now().subtract(const Duration(days: 3)),
        'endDate': DateTime.now().add(const Duration(days: 11)),
        'assignedPlayers': ['P001', 'P002', 'P003', 'P004'],
        'dailyPlans': [
          {
            'day': 'Monday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Squats',
                'sets': 4,
                'reps': '10-12',
                'weight': '60-70% 1RM',
                'notes': 'Focus on depth and form'
              },
              {
                'name': 'Leg Press',
                'sets': 3,
                'reps': '12-15',
                'weight': '70% 1RM',
                'notes': 'Control on the negative phase'
              },
              {
                'name': 'Romanian Deadlifts',
                'sets': 3,
                'reps': '10-12',
                'weight': '60% 1RM',
                'notes': 'Keep back straight'
              },
            ]
          },
          {
            'day': 'Tuesday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Bench Press',
                'sets': 4,
                'reps': '8-10',
                'weight': '70% 1RM',
                'notes': 'Full range of motion'
              },
              {
                'name': 'Incline Dumbbell Press',
                'sets': 3,
                'reps': '10-12',
                'weight': 'Moderate',
                'notes': ''
              },
            ]
          },
          {'day': 'Wednesday', 'isRestDay': true, 'exercises': []},
          {
            'day': 'Thursday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Pull-ups',
                'sets': 4,
                'reps': '8-10',
                'weight': 'Bodyweight',
                'notes': 'Full range of motion'
              }
            ]
          },
          {
            'day': 'Friday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Deadlifts',
                'sets': 4,
                'reps': '6-8',
                'weight': '70% 1RM',
                'notes': 'Maintain neutral spine'
              }
            ]
          },
          {
            'day': 'Saturday',
            'isRestDay': false,
            'exercises': [
              {
                'name': 'Shoulder Press',
                'sets': 3,
                'reps': '8-10',
                'weight': 'Moderate',
                'notes': 'Control the movement'
              }
            ]
          },
          {'day': 'Sunday', 'isRestDay': true, 'exercises': []}
        ]
      },
      {
        'id': '2',
        'name': 'Basketball Agility Program',
        'description': 'Explosive movement and vertical leap improvement',
        'startDate': DateTime.now().subtract(const Duration(days: 7)),
        'endDate': DateTime.now().add(const Duration(days: 7)),
        'assignedPlayers': ['P005', 'P006'],
        'dailyPlans': List.from(defaultDailyPlans)
      },
    ];

    // Sample draft plans - ensure they have daily plans
    _gymPlans['draft'] = [
      {
        'id': '3',
        'name': 'Cricket Team Core Strength',
        'description':
            'Draft plan for improving core strength and rotational power',
        'startDate': DateTime.now().add(const Duration(days: 3)),
        'endDate': DateTime.now().add(const Duration(days: 17)),
        'assignedPlayers': [],
        'dailyPlans': List.from(defaultDailyPlans)
      },
    ];

    // Sample completed plans - ensure they have daily plans
    _gymPlans['completed'] = [
      {
        'id': '4',
        'name': 'Pre-Season Conditioning',
        'description':
            'General conditioning program completed before season start',
        'startDate': DateTime.now().subtract(const Duration(days: 30)),
        'endDate': DateTime.now().subtract(const Duration(days: 2)),
        'assignedPlayers': ['P001', 'P002', 'P003', 'P004', 'P005', 'P006'],
        'dailyPlans': List.from(defaultDailyPlans)
      },
    ];

    // Sample players
    _players.addAll([
      {
        'id': 'P001',
        'name': 'John Smith',
        'sport': 'Football',
        'position': 'Forward',
        'avatar': 'assets/images/avatars/male_avatar_1.png',
      },
      {
        'id': 'P002',
        'name': 'Maria Garcia',
        'sport': 'Football',
        'position': 'Midfielder',
        'avatar': 'assets/images/avatars/female_avatar_1.png',
      },
      {
        'id': 'P003',
        'name': 'Robert Johnson',
        'sport': 'Football',
        'position': 'Defender',
        'avatar': 'assets/images/avatars/male_avatar_2.png',
      },
      {
        'id': 'P004',
        'name': 'David Lee',
        'sport': 'Football',
        'position': 'Goalkeeper',
        'avatar': 'assets/images/avatars/male_avatar_3.png',
      },
      {
        'id': 'P005',
        'name': 'Michael Chen',
        'sport': 'Basketball',
        'position': 'Point Guard',
        'avatar': 'assets/images/avatars/male_avatar_4.png',
      },
      {
        'id': 'P006',
        'name': 'Sarah Miller',
        'sport': 'Basketball',
        'position': 'Center',
        'avatar': 'assets/images/avatars/female_avatar_2.png',
      },
    ]);
  }

  void _handleLogout(BuildContext context) {
    _authService.logout().then((_) {
      Navigator.pushReplacementNamed(context, loginRoute);
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldNavigate = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return to Home'),
        content: const Text('Do you want to return to the home page?'),
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

    if (shouldNavigate) {
      Navigator.pushReplacementNamed(context, trainerHomeRoute);
    }

    return false; // Prevent default back button behavior
  }

  // Create or update a gym plan
  void _savePlan(bool isDraft) {
    if (_planName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a plan name')));
      return;
    }

    final newPlan = {
      'id': _selectedPlan != null
          ? _selectedPlan!['id']
          : DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _planName,
      'description': _planDescription,
      'startDate': _startDate,
      'endDate': _endDate,
      'assignedPlayers': _selectedPlayerIds,
      'dailyPlans': _weeklyExercises,
    };

    setState(() {
      if (_selectedPlan != null) {
        // Update existing plan
        final planType = isDraft ? 'draft' : 'active';

        // Find and replace in active plans
        int activeIndex = _gymPlans['active']!
            .indexWhere((plan) => plan['id'] == newPlan['id']);
        if (activeIndex != -1) {
          _gymPlans['active']!.removeAt(activeIndex);
        }

        // Find and replace in draft plans
        int draftIndex = _gymPlans['draft']!
            .indexWhere((plan) => plan['id'] == newPlan['id']);
        if (draftIndex != -1) {
          _gymPlans['draft']!.removeAt(draftIndex);
        }

        _gymPlans[planType]!.add(newPlan);
      } else {
        // Create new plan
        final planType = isDraft ? 'draft' : 'active';
        _gymPlans[planType]!.add(newPlan);
      }

      _selectedPlan = null;
      _resetPlanForm();

      // Switch to the appropriate tab
      _tabController.animateTo(isDraft ? 1 : 0);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isDraft
            ? 'Plan saved as draft'
            : 'Plan activated and assigned to ${_selectedPlayerIds.length} players')));
  }

  void _resetPlanForm() {
    setState(() {
      _planName = '';
      _planDescription = '';
      _startDate = DateTime.now();
      _endDate = _startDate.add(const Duration(days: 7));
      _selectedPlayerIds.clear();
      _initializeWeeklyExercises();
    });
  }

  // Display the edit plan form
  void _showCreatePlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
              ),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedPlan != null
                                  ? 'Edit Training Plan'
                                  : 'Create New Training Plan',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              _selectedPlan != null
                                  ? 'Modify your existing workout program'
                                  : 'Design a new workout program for your athletes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main content - scrollable
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Plan Details Section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Plan name input
                              TextField(
                                controller:
                                    TextEditingController(text: _planName),
                                onChanged: (value) => _planName = value,
                                decoration: InputDecoration(
                                  labelText: 'Plan Name',
                                  hintText: 'e.g., Strength Program Phase 1',
                                  prefixIcon: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.deepPurple,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.deepPurple, width: 2),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Plan description
                              TextField(
                                controller: TextEditingController(
                                    text: _planDescription),
                                onChanged: (value) => _planDescription = value,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText:
                                      'Describe the goals and focus of this plan',
                                  prefixIcon: const Icon(
                                    Icons.description,
                                    color: Colors.deepPurple,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.deepPurple, width: 2),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Date Range Section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Start date picker
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _startDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.deepPurple,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            _startDate = pickedDate;
                                            if (_endDate.isBefore(_startDate)) {
                                              _endDate = _startDate
                                                  .add(const Duration(days: 7));
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Start Date',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('MMM d, yyyy')
                                                        .format(_startDate),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // End date picker
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: _endDate,
                                          firstDate: _startDate,
                                          lastDate: _startDate
                                              .add(const Duration(days: 365)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary: Colors.deepPurple,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            _endDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: Colors.deepPurple,
                                            ),
                                            const SizedBox(width: 12),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'End Date',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('MMM d, yyyy')
                                                        .format(_endDate),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding:
                                    const EdgeInsets.all(10), // Smaller padding
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue[700],
                                      size: 16, // Smaller icon
                                    ),
                                    const SizedBox(width: 6), // Smaller spacing
                                    Flexible(
                                      // Use Flexible to allow text to adapt
                                      child: Text(
                                        'Duration: ${_endDate.difference(_startDate).inDays + 1} days',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 13, // Smaller text
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Player Selection Section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Assign Players',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedPlayerIds.length} selected',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _players.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_off,
                                              size: 32,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No players available',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _players.length,
                                        itemBuilder: (context, index) {
                                          final player = _players[index];
                                          final isSelected = _selectedPlayerIds
                                              .contains(player['id']);

                                          return Material(
                                            color: isSelected
                                                ? Colors.deepPurple
                                                    .withOpacity(0.05)
                                                : Colors.transparent,
                                            child: CheckboxListTile(
                                              title: Text(
                                                player['name'],
                                                style: TextStyle(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${player['sport']} - ${player['position']}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              secondary: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    player['avatar']),
                                                onBackgroundImageError: (e, s) {
                                                  // Fallback for image load errors
                                                },
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: const SizedBox(),
                                              ),
                                              activeColor: Colors.deepPurple,
                                              value: isSelected,
                                              onChanged: (bool? selected) {
                                                setState(() {
                                                  if (selected == true) {
                                                    _selectedPlayerIds
                                                        .add(player['id']);
                                                  } else {
                                                    _selectedPlayerIds
                                                        .remove(player['id']);
                                                  }
                                                });
                                              },
                                              dense: true,
                                              visualDensity:
                                                  const VisualDensity(
                                                      vertical: -1),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Weekly Schedule Section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weekly Training Schedule',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Day tabs with exercises
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 280,
                                child: DefaultTabController(
                                  length: 7,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: TabBar(
                                          isScrollable: true,
                                          tabs: [
                                            for (var dayPlan
                                                in _weeklyExercises)
                                              Tab(
                                                child: Text(
                                                  dayPlan['day'],
                                                  style: const TextStyle(
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          labelColor: Colors.deepPurple,
                                          unselectedLabelColor:
                                              Colors.grey[600],
                                          labelStyle: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          indicatorColor: Colors.deepPurple,
                                          dividerColor: Colors.transparent,
                                          indicatorSize:
                                              TabBarIndicatorSize.label,
                                        ),
                                      ),
                                      const Divider(height: 1, thickness: 1),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            for (int i = 0;
                                                i < _weeklyExercises.length;
                                                i++)
                                              _buildDayExercisesPanel(
                                                  i, setState),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Bottom fixed buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _savePlan(true); // Save as draft
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save as Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _savePlan(false); // Activate plan
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Activate Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build the exercise panel for a specific day of the week
  Widget _buildDayExercisesPanel(int dayIndex, StateSetter setState) {
    final dayPlan = _weeklyExercises[dayIndex];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header row
          Row(
            children: [
              Text(
                dayPlan['day'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Toggle rest day
              Row(
                children: [
                  const Text('Rest Day'),
                  Switch(
                    value: dayPlan['isRestDay'],
                    onChanged: (value) {
                      setState(() {
                        dayPlan['isRestDay'] = value;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Rest day or exercise list - using Expanded for both cases
          Expanded(
            child: dayPlan['isRestDay']
                ? Center(
                    child: Text(
                      'Rest Day - No exercises scheduled',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Exercise list
                      Expanded(
                        child: dayPlan['exercises'].isEmpty
                            ? const Center(
                                child: Text(
                                  'No exercises added yet.\nTap + to add exercises.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: dayPlan['exercises'].length,
                                itemBuilder: (context, index) {
                                  final exercise = dayPlan['exercises'][index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(exercise['name']),
                                      subtitle: Text(
                                        '${exercise['sets']} sets x ${exercise['reps']} reps${exercise['weight'].isNotEmpty ? ' @ ${exercise['weight']}' : ''}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _showAddExerciseDialog(dayIndex,
                                                    exercise, index, setState),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                dayPlan['exercises']
                                                    .removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Add exercise button
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton.small(
                          child: const Icon(Icons.add),
                          onPressed: () => _showAddExerciseDialog(
                              dayIndex, null, null, setState),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Dialog to add or edit an exercise
  void _showAddExerciseDialog(int dayIndex, Map<String, dynamic>? exercise,
      int? exerciseIndex, StateSetter setState) {
    final isEditing = exercise != null;

    // Controllers
    final nameController =
        TextEditingController(text: isEditing ? exercise['name'] : '');
    final setsController = TextEditingController(
        text: isEditing ? exercise['sets'].toString() : '');
    final repsController =
        TextEditingController(text: isEditing ? exercise['reps'] : '');
    final weightController =
        TextEditingController(text: isEditing ? exercise['weight'] : '');
    final notesController =
        TextEditingController(text: isEditing ? exercise['notes'] : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Exercise' : 'Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    hintText: 'e.g., Squats, Bench Press',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          hintText: '3-5',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          hintText: '8-12',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight/Intensity',
                    hintText: 'e.g., 70% 1RM, Bodyweight',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Special instructions or technique cues',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    setsController.text.isEmpty ||
                    repsController.text.isEmpty) {
                  // Show error or return
                  return;
                }

                setState(() {
                  final newExercise = {
                    'name': nameController.text,
                    'sets': int.tryParse(setsController.text) ?? 3,
                    'reps': repsController.text,
                    'weight': weightController.text,
                    'notes': notesController.text,
                  };

                  if (isEditing && exerciseIndex != null) {
                    // Update existing exercise
                    _weeklyExercises[dayIndex]['exercises'][exerciseIndex] =
                        newExercise;
                  } else {
                    // Add new exercise
                    _weeklyExercises[dayIndex]['exercises'].add(newExercise);
                  }
                });

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  // Helper method for card buttons (missing in original code)
  Widget _buildCardButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 26, // Fixed height
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: Size.zero, // Remove minimum size constraints
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          foregroundColor: color,
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  // Edit an existing plan
  void _editPlan(Map<String, dynamic> plan) {
    // Ensure we have dailyPlans
    if (plan['dailyPlans'] == null || (plan['dailyPlans'] as List).isEmpty) {
      plan['dailyPlans'] = List.from(_weeklyExercises);
    }

    setState(() {
      _selectedPlan = Map<String, dynamic>.from(plan);
      _planName = plan['name'] ?? '';
      _planDescription = plan['description'] ?? '';
      _startDate = plan['startDate'] ?? DateTime.now();
      _endDate = plan['endDate'] ?? _startDate.add(const Duration(days: 7));

      // Clear and add all players
      _selectedPlayerIds.clear();
      final playerList = plan['assignedPlayers'] ?? [];
      for (var playerId in playerList) {
        _selectedPlayerIds.add(playerId.toString());
      }

      // Copy daily plans with deep copy
      _weeklyExercises.clear();
      for (var dayPlan in plan['dailyPlans']) {
        final Map<String, dynamic> newDayPlan = {
          'day': dayPlan['day'],
          'isRestDay': dayPlan['isRestDay'] ?? false,
          'exercises': [],
        };

        // Copy exercises
        if (dayPlan['exercises'] != null) {
          for (var exercise in dayPlan['exercises']) {
            newDayPlan['exercises'].add({
              'name': exercise['name'] ?? '',
              'sets': exercise['sets'] ?? 3,
              'reps': exercise['reps'] ?? '',
              'weight': exercise['weight'] ?? '',
              'notes': exercise['notes'] ?? '',
            });
          }
        }

        _weeklyExercises.add(newDayPlan);
      }
    });

    // Show the bottom sheet after the state is updated
    Future.delayed(const Duration(milliseconds: 100), () {
      _showCreatePlanBottomSheet();
    });
  }

  // Delete a plan after confirmation
  void _confirmDeletePlan(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _gymPlans['active']!.removeWhere((p) => p['id'] == plan['id']);
                _gymPlans['draft']!.removeWhere((p) => p['id'] == plan['id']);
                _gymPlans['completed']!
                    .removeWhere((p) => p['id'] == plan['id']);
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Plan deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Activate a draft plan
  void _activateDraftPlan(Map<String, dynamic> plan) {
    if ((plan['assignedPlayers'] as List).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please assign players to the plan before activating')));
      _editPlan(plan);
      return;
    }

    setState(() {
      _gymPlans['draft']!.removeWhere((p) => p['id'] == plan['id']);
      _gymPlans['active']!.add(plan);
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan "${plan['name']}" activated')));
  }

  // Mark a plan as completed
  void _markPlanCompleted(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Plan'),
        content: Text('Mark "${plan['name']}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _gymPlans['active']!.removeWhere((p) => p['id'] == plan['id']);
                _gymPlans['completed']!.add(plan);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan marked as completed')));
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  // Helper widget for building player chips
  Widget _buildPlayerChip(String playerId) {
    final player = _players.firstWhere((p) => p['id'] == playerId,
        orElse: () => {'name': 'Unknown', 'sport': ''});

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        player['name'],
        style: const TextStyle(
          fontSize: 12,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  // Build the day plan view for the detail sheet
  Widget _buildDayPlanView(Map<String, dynamic> dayPlan) {
    if (dayPlan['isRestDay'] == true) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Use minimum size
                  children: const [
                    Icon(
                      Icons.hotel,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Rest Day',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No exercises scheduled for this day. Focus on recovery.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

    final exercises = dayPlan['exercises'] as List? ?? [];

    return exercises.isEmpty
        ? const Center(
            child: Text('No exercises for this day'),
          )
        : ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: const EdgeInsets.only(
                    bottom: 12, left: 8, right: 8, top: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fitness_center,
                              color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            exercise['name'] ?? 'Exercise',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _exerciseDetailItem(
                              'Sets', (exercise['sets'] ?? '').toString()),
                          _exerciseDetailItem('Reps', exercise['reps'] ?? ''),
                          if ((exercise['weight'] ?? '').isNotEmpty)
                            _exerciseDetailItem('Weight', exercise['weight']),
                        ],
                      ),
                      if ((exercise['notes'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${exercise['notes']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Helper widget for exercise details
  Widget _exerciseDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Show the detailed view of a plan
  void _viewPlanDetails(Map<String, dynamic> plan) {
    if (plan['dailyPlans'] == null || (plan['dailyPlans'] as List).isEmpty) {
      // If plan doesn't have daily plans, initialize with default ones
      plan['dailyPlans'] = List.from(_weeklyExercises);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with plan name and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          plan['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Plan details section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Date range
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d, yyyy').format(plan['startDate'])} - ${DateFormat('MMM d, yyyy').format(plan['endDate'])}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Assigned players
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[600], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Assigned to ${(plan['assignedPlayers'] as List).length} players',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    if ((plan['assignedPlayers'] as List).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final playerId in plan['assignedPlayers'])
                            _buildPlayerChip(playerId),
                        ],
                      ),
                    ]
                  ],
                ),
              ),

              const Divider(height: 32),

              // Weekly schedule tabs title
              const Text(
                'Weekly Training Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),

              // Weekly schedule tabs
              Expanded(
                child: DefaultTabController(
                  length: (plan['dailyPlans'] as List).length,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabs: [
                            for (var dayPlan in plan['dailyPlans'])
                              Tab(
                                child: Text(
                                  dayPlan['day'],
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                ),
                              ),
                          ],
                          labelColor: Colors.deepPurple,
                          unselectedLabelColor: Colors.grey[600],
                          indicator: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          dividerColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TabBarView(
                          children: [
                            for (var dayPlan in plan['dailyPlans'])
                              _buildDayPlanView(dayPlan),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons with Wrap to prevent overflow
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editPlan(
                          Map<String, dynamic>.from(plan)); // Create a copy
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Plan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (_gymPlans['active']!.any((p) => p['id'] == plan['id']))
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _markPlanCompleted(plan);
                      },
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text('Mark Completed'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (_gymPlans['draft']!.any((p) => p['id'] == plan['id']))
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _activateDraftPlan(plan);
                      },
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Activate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeletePlan(plan);
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Build the plan card for the list view
  // Update the _buildPlanCard method to prevent overflows
  Widget _buildPlanCard(
      Map<String, dynamic> plan, Color cardColor, String planType) {
    final startDate = plan['startDate'];
    final endDate = plan['endDate'];
    final isActive = planType == 'active';
    final isDraft = planType == 'draft';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cardColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewPlanDetails(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use min size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.play_circle_fill
                        : isDraft
                            ? Icons.edit_document
                            : Icons.check_circle,
                    color: cardColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      plan['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                plan['description'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16), // Fixed height instead of Spacer
              const Divider(height: 12),

              // Duration and Players info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${endDate.difference(startDate).inDays + 1} days',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Players',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        (plan['assignedPlayers'] as List).length.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Action buttons with fixed layout
              Wrap(
                spacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  if (isDraft)
                    _buildCardButton(
                      label: 'Activate',
                      color: Colors.deepPurple,
                      onPressed: () => _activateDraftPlan(plan),
                    ),
                  if (isActive)
                    _buildCardButton(
                      label: 'Complete',
                      color: Colors.green,
                      onPressed: () => _markPlanCompleted(plan),
                    ),
                  _buildCardButton(
                    label: 'Edit',
                    color: Colors.blue,
                    onPressed: () => _editPlan(Map<String, dynamic>.from(plan)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          icon: Icons.people,
          title: 'View All Players',
          route: trainerHomeRoute),
      DrawerItem(
          icon: Icons.announcement,
          title: 'Make Announcements',
          route: trainerMakeAnAnnouncementRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Session Management',
          route: trainerMarkSessionRoute),
      DrawerItem(
          icon: Icons.fitness_center,
          title: 'Training Plans',
          route: trainerUpdateGymPlanRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'Medical Records',
          route: trainerViewPlayerMedicalReportRoute),
      DrawerItem(
          icon: Icons.person, title: 'My Profile', route: trainerProfileRoute),
    ];

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Training Plans'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active Plans'),
              Tab(text: 'Draft Plans'),
              Tab(text: 'Completed'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        drawer: CustomDrawer(
          selectedDrawerItem: trainerUpdateGymPlanRoute,
          onSelectDrawerItem: (route) {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, route);
          },
          drawerItems: drawerItems,
          onLogout: () => _handleLogout(context),
          userName: _userName,
          userEmail: _userEmail,
          userAvatarUrl: _userAvatar,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Active Plans Tab
                  _buildPlansTab('active', Colors.green),

                  // Draft Plans Tab
                  _buildPlansTab('draft', Colors.amber),

                  // Completed Plans Tab
                  _buildPlansTab('completed', Colors.blue),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _resetPlanForm();
            _selectedPlan = null;
            _showCreatePlanBottomSheet();
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPlansTab(String planType, Color accentColor) {
    final plans = _gymPlans[planType]!;

    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              planType == 'active'
                  ? Icons.fitness_center
                  : planType == 'draft'
                      ? Icons.edit_document
                      : Icons.history,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              planType == 'active'
                  ? 'No active plans'
                  : planType == 'draft'
                      ? 'No draft plans'
                      : 'No completed plans',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              planType == 'active'
                  ? 'Start by creating or activating a plan'
                  : planType == 'draft'
                      ? 'Save plans as drafts while you work on them'
                      : 'Completed plans will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            if (planType == 'draft' || planType == 'active')
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _resetPlanForm();
                    _selectedPlan = null;
                    _showCreatePlanBottomSheet();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create New Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(
          plans[index],
          accentColor,
          planType,
        );
      },
    );
  }
}
