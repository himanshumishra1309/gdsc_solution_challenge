import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class MedicalStaffPutRecords extends StatefulWidget {
  const MedicalStaffPutRecords({super.key});

  @override
  _MedicalStaffPutRecordsState createState() => _MedicalStaffPutRecordsState();
}

class _MedicalStaffPutRecordsState extends State<MedicalStaffPutRecords> {
  final _authService = AuthService();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSport = 'All Sports';
  final List<Map<String, dynamic>> _players = [];

  // User info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  // Sports list
  final List<String> _sports = [
    'All Sports',
    'Cricket',
    'Football',
    'Basketball',
    'Badminton',
    'Tennis'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSamplePlayers();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Medical Staff";
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

  void _loadSamplePlayers() {
    // Sample data for players
    final samplePlayers = [
      {
        'id': 'P1001',
        'name': 'John Smith',
        'age': 22,
        'sport': 'Football',
        'position': 'Forward',
        'profilePic': 'assets/images/player1.jpg',
        'status': 'Fit to Play',
        'statusColor': Colors.green,
        'lastCheckup': '2023-12-15',
      },
      {
        'id': 'P1002',
        'name': 'Michael Johnson',
        'age': 24,
        'sport': 'Basketball',
        'position': 'Point Guard',
        'profilePic': 'assets/images/player2.jpg',
        'status': 'Minor Injury',
        'statusColor': Colors.orange,
        'lastCheckup': '2024-01-10',
      },
      {
        'id': 'P1003',
        'name': 'Sarah Williams',
        'age': 21,
        'sport': 'Tennis',
        'position': 'Singles',
        'profilePic': 'assets/images/player3.jpg',
        'status': 'Fit to Play',
        'statusColor': Colors.green,
        'lastCheckup': '2023-11-28',
      },
      {
        'id': 'P1004',
        'name': 'David Brown',
        'age': 23,
        'sport': 'Cricket',
        'position': 'Batsman',
        'profilePic': 'assets/images/player4.jpg',
        'status': 'Injured',
        'statusColor': Colors.red,
        'lastCheckup': '2024-02-05',
      },
      {
        'id': 'P1005',
        'name': 'Emily Davis',
        'age': 20,
        'sport': 'Badminton',
        'position': 'Singles',
        'profilePic': 'assets/images/player5.jpg',
        'status': 'Fit to Play',
        'statusColor': Colors.green,
        'lastCheckup': '2024-01-20',
      },
    ];

    setState(() {
      _players.addAll(samplePlayers);
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
    });
  }

  List<Map<String, dynamic>> get _filteredPlayers {
    return _players.where((player) {
      final matchesName =
          player['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSport =
          _selectedSport == 'All Sports' || player['sport'] == _selectedSport;
      return matchesName && matchesSport;
    }).toList();
  }

  void _navigateToPlayerMedicalForm(Map<String, dynamic> player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerMedicalForm(player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          icon: Icons.people,
          title: 'View all players',
          route: medicalStaffHomeRoute),
      DrawerItem(
          icon: Icons.announcement,
          title: 'Make announcement',
          route: medicalStaffMakeAnAnnouncementRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Mark upcoming sessions',
          route: medicalStaffMarkSessionRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Update Medical Report',
          route: medicalStaffUpdateMedicalReportRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'View Medical records',
          route: medicalStaffViewPlayerMedicalReportRoute),
      DrawerItem(
          icon: Icons.person,
          title: 'View Profile',
          route: medicalStaffProfileRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
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
        drawerItems: drawerItems,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        onLogout: () => Navigator.pushReplacementNamed(context, loginRoute),
        selectedDrawerItem: medicalStaffUpdateMedicalReportRoute,
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      const Text(
                        'Players Medical Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search player',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSport,
                                items: _sports.map((sport) {
                                  return DropdownMenuItem<String>(
                                    value: sport,
                                    child: Text(sport),
                                  );
                                }).toList(),
                                onChanged: _onSportChanged,
                                icon: const Icon(Icons.sports),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Players grid
                Expanded(
                  child: _filteredPlayers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No players found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : // In the _MedicalStaffPutRecordsState class, replace the GridView.builder section with this:
                      GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // Change the childAspectRatio to give more height for content
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredPlayers.length,
                          itemBuilder: (context, index) {
                            final player = _filteredPlayers[index];
                            Color statusColor =
                                player['statusColor'] ?? Colors.grey;

                            return GestureDetector(
                              onTap: () => _navigateToPlayerMedicalForm(player),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Player image with status indicator - FIXED HEIGHT
                                    SizedBox(
                                      height:
                                          130, // Fixed height for the image section
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            child: Image.asset(
                                              player['profilePic'],
                                              height: 130,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 130,
                                                  width: double.infinity,
                                                  color: Colors.grey.shade300,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color: statusColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    player['status'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Player info - FLEXIBLE CONTENT
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              player['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  _getSportIcon(
                                                      player['sport']),
                                                  size: 14,
                                                  color: Colors.deepPurple,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    player['sport'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  'Last check: ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _formatDate(
                                                        player['lastCheckup']),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(), // Pushes button to bottom
                                            // Action button
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Update Medical Record',
                                                style: TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Tennis':
        return Icons.sports_tennis;
      case 'Badminton':
        return Icons.sports_handball;
      default:
        return Icons.sports;
    }
  }

  String _formatDate(String date) {
    final DateTime parsed = DateTime.parse(date);
    return DateFormat('MMM d, y').format(parsed);
  }
}

class PlayerMedicalForm extends StatefulWidget {
  final Map<String, dynamic> player;

  const PlayerMedicalForm({required this.player, super.key});

  @override
  _PlayerMedicalFormState createState() => _PlayerMedicalFormState();
}

class _PlayerMedicalFormState extends State<PlayerMedicalForm> {
  late Map<String, dynamic> _medicalData;
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final Map<String, bool> _expandedSections = {
    'General Health & Vitals': true,
    'Fitness & Performance Metrics': false,
    'Injury History & Recovery': false,
    'Medical Test Results': false,
    'Nutrition & Hydration': false,
    'Mental Health & Sleep Patterns': false,
    'Medical Clearance': false,
  };

  @override
  void initState() {
    super.initState();
    _loadMedicalData();
  }

  void _loadMedicalData() {
    // In a real app, you would fetch this from a database
    // For demo purposes, we'll use mock data
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _medicalData = {
          // General
          'date': DateTime.now().toString().split(' ')[0],
          'sport': widget.player['sport'],
          'athleteName': widget.player['name'],
          'age': widget.player['age'],
          'athleteId': widget.player['id'],
          'organization': 'Sports Academy',

          // Physical metrics
          'height': '182',
          'weight': '78',
          'bmi': '23.5',

          // Vital signs
          'restingHeartRate': '68',
          'bloodPressure': '120/80',
          'oxygenSaturation': '98',
          'respiratoryRate': '14',
          'bodyTemperature': '36.6',

          // Performance metrics
          'vo2Max': '52.4',
          'sprintSpeed': '8.2',
          'agilityScore': '86',
          'strength': '72',
          'flexibilityTest': 'Good',

          // Medical history
          'pastInjuries': 'Minor ankle sprain (2023)',
          'ongoingTreatment': 'None',
          'returnToPlayStatus': 'Full participation',

          // Test results
          'bloodTest': 'Normal',
          'ecg': 'Normal',
          'boneDensity': 'Good',
          'lungFunction': 'Above Average',

          // Nutrition
          'caloricIntake': '2400',
          'waterIntake': '3.2',
          'nutrientDeficiencies': 'None',
          'supplements': 'Multivitamin, Protein',

          // Mental health
          'stressLevel': '3',
          'sleepQuality': '7.5',
          'cognitiveScore': '92',

          // Clinical notes
          'medicalClearance': 'Full Clearance',
          'nextCheckupDate': '2024-05-15',
          'doctorsNotes':
              'Player is in excellent health with no concerns. Maintain current training regimen.',
        };
        _isLoading = false;
      });
    });
  }

  Future<void> _saveMedicalData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form')),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Update any calculated fields
    _medicalData['date'] = DateTime.now().toString().split(' ')[0];

    // Calculate BMI
    final height = double.tryParse(_medicalData['height'] ?? '0') ?? 0;
    final weight = double.tryParse(_medicalData['weight'] ?? '0') ?? 0;
    if (height > 0 && weight > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      _medicalData['bmi'] = bmi.toStringAsFixed(1);
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medical record saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Record: ${widget.player['name']}',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Patient header
                  Container(
                    color: Colors.deepPurple.shade50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepPurple.shade100,
                          backgroundImage: _getPlayerImage(),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Fallback to default avatar
                          },
                          child: _getPlayerImage() == null
                              ? Text(
                                  widget.player['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.player['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.player['age']} yrs • ${widget.player['sport']} • ID: ${widget.player['id']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor().withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            widget.player['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form sections
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSection(
                          'General Health & Vitals',
                          Icons.favorite,
                          [
                            _buildDoubleFieldRow(
                              'Height (cm)',
                              'height',
                              'Weight (kg)',
                              'weight',
                            ),
                            _buildTextField(
                              'Resting Heart Rate (bpm)',
                              'restingHeartRate',
                            ),
                            _buildTextField(
                              'Blood Pressure (mmHg)',
                              'bloodPressure',
                            ),
                            _buildDoubleFieldRow(
                              'Oxygen Saturation (%)',
                              'oxygenSaturation',
                              'Respiratory Rate',
                              'respiratoryRate',
                            ),
                            _buildTextField(
                              'Body Temperature (°C)',
                              'bodyTemperature',
                            ),
                          ],
                        ),
                        _buildSection(
                          'Fitness & Performance Metrics',
                          Icons.fitness_center,
                          [
                            _buildTextField(
                              'VO2 Max (ml/kg/min)',
                              'vo2Max',
                            ),
                            _buildDoubleFieldRow(
                              'Sprint Speed (m/s)',
                              'sprintSpeed',
                              'Agility Score',
                              'agilityScore',
                            ),
                            _buildDoubleFieldRow(
                              'Strength',
                              'strength',
                              'Flexibility Test',
                              'flexibilityTest',
                            ),
                          ],
                        ),
                        _buildSection(
                          'Injury History & Recovery',
                          Icons.healing,
                          [
                            _buildMultilineTextField(
                              'Past Injuries',
                              'pastInjuries',
                            ),
                            _buildMultilineTextField(
                              'Ongoing Treatment',
                              'ongoingTreatment',
                            ),
                            _buildDropdownField(
                              'Return to Play Status',
                              'returnToPlayStatus',
                              [
                                'Full participation',
                                'Limited participation',
                                'No contact',
                                'No participation'
                              ],
                            ),
                          ],
                        ),
                        _buildSection(
                          'Medical Test Results',
                          Icons.science,
                          [
                            _buildDropdownField(
                              'Blood Test',
                              'bloodTest',
                              ['Normal', 'Abnormal', 'Not Tested'],
                            ),
                            _buildDropdownField(
                              'ECG',
                              'ecg',
                              ['Normal', 'Abnormal', 'Not Tested'],
                            ),
                            _buildDropdownField(
                              'Bone Density',
                              'boneDensity',
                              ['Excellent', 'Good', 'Average', 'Poor'],
                            ),
                            _buildDropdownField(
                              'Lung Function',
                              'lungFunction',
                              [
                                'Excellent',
                                'Above Average',
                                'Average',
                                'Below Average',
                                'Poor'
                              ],
                            ),
                          ],
                        ),
                        _buildSection(
                          'Nutrition & Hydration',
                          Icons.restaurant,
                          [
                            _buildTextField(
                              'Caloric Intake (kcal)',
                              'caloricIntake',
                            ),
                            _buildTextField(
                              'Water Intake (L)',
                              'waterIntake',
                            ),
                            _buildTextField(
                              'Nutrient Deficiencies',
                              'nutrientDeficiencies',
                            ),
                            _buildTextField(
                              'Supplements',
                              'supplements',
                            ),
                          ],
                        ),
                        _buildSection(
                          'Mental Health & Sleep Patterns',
                          Icons.psychology,
                          [
                            _buildSliderField(
                              'Stress Level',
                              'stressLevel',
                              0,
                              10,
                              'Low',
                              'High',
                            ),
                            _buildTextField(
                              'Sleep Quality (hours)',
                              'sleepQuality',
                            ),
                            _buildTextField(
                              'Cognitive Score',
                              'cognitiveScore',
                            ),
                          ],
                        ),
                        _buildSection(
                          'Medical Clearance',
                          Icons.medical_services,
                          [
                            _buildDropdownField(
                              'Medical Clearance',
                              'medicalClearance',
                              [
                                'Full Clearance',
                                'Partial Clearance',
                                'No Clearance'
                              ],
                            ),
                            _buildDateField(
                              'Next Checkup Date',
                              'nextCheckupDate',
                            ),
                            _buildMultilineTextField(
                              'Doctor\'s Notes',
                              'doctorsNotes',
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Save button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMedicalData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.deepPurple.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Medical Record',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => _toggleSection(title),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _expandedSections[title]!
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_expandedSections[title]!)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildTextField(String label, String field, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _medicalData[field]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
        onSaved: (value) {
          _medicalData[field] = value;
        },
      ),
    );
  }

  Widget _buildMultilineTextField(String label, String field,
      {int maxLines = 3}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _medicalData[field]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        maxLines: maxLines,
        onSaved: (value) {
          _medicalData[field] = value;
        },
      ),
    );
  }

  Widget _buildDoubleFieldRow(
      String label1, String field1, String label2, String field2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _medicalData[field1]?.toString() ?? '',
              decoration: InputDecoration(
                labelText: label1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              onSaved: (value) {
                _medicalData[field1] = value;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: _medicalData[field2]?.toString() ?? '',
              decoration: InputDecoration(
                labelText: label2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              onSaved: (value) {
                _medicalData[field2] = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String field, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _medicalData[field]?.toString() ?? options.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _medicalData[field] = value;
          });
        },
        onSaved: (value) {
          _medicalData[field] = value;
        },
      ),
    );
  }

  Widget _buildDateField(String label, String field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _medicalData[field]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );

          if (pickedDate != null) {
            setState(() {
              _medicalData[field] = pickedDate.toString().split(' ')[0];
            });
          }
        },
        onSaved: (value) {
          _medicalData[field] = value;
        },
      ),
    );
  }

  Widget _buildSliderField(
    String label,
    String field,
    double min,
    double max,
    String minLabel,
    String maxLabel,
  ) {
    final value = double.tryParse(_medicalData[field]?.toString() ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${value.toInt()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                minLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Expanded(
                child: Slider(
                  value: value < min ? min : (value > max ? max : value),
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  label: value.toInt().toString(),
                  onChanged: (newValue) {
                    setState(() {
                      _medicalData[field] = newValue.toInt().toString();
                    });
                  },
                ),
              ),
              Text(
                maxLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Guidelines'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Filling Medical Records',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Complete all required fields marked with (*)\n'
                  '• Ensure measurements are in the correct units\n'
                  '• For numerical values, use decimal points when needed\n'
                  '• Add detailed notes for any abnormal findings\n'
                  '• Document all injuries with dates and severity\n'
                  '• Update medical clearance status based on overall assessment',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'Reference Ranges',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Heart Rate: 60-100 bpm (athletes: 40-60 bpm)\n'
                  '• Blood Pressure: 90/60 - 120/80 mmHg\n'
                  '• Oxygen Saturation: 95-100%\n'
                  '• Respiratory Rate: 12-20 breaths/minute\n'
                  '• BMI: 18.5-24.9 (athletes may vary)\n'
                  '• Body Temperature: 36.1-37.2°C',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  ImageProvider? _getPlayerImage() {
    try {
      return AssetImage(widget.player['profilePic']);
    } catch (e) {
      return null;
    }
  }

  Color _getStatusColor() {
    if (widget.player.containsKey('statusColor')) {
      return widget.player['statusColor'];
    }

    final status = widget.player['status']?.toLowerCase() ?? '';

    if (status.contains('fit') || status.contains('clear')) {
      return Colors.green;
    } else if (status.contains('minor') || status.contains('limited')) {
      return Colors.orange;
    } else if (status.contains('injur') || status.contains('no')) {
      return Colors.red;
    } else if (status.contains('need') || status.contains('assessment')) {
      return Colors.blue;
    }

    return Colors.grey;
  }
}
