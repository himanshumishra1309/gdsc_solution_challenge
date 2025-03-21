import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class CoachViewPlayerReport extends StatefulWidget {
  const CoachViewPlayerReport({super.key});

  @override
  _CoachViewPlayerReportState createState() => _CoachViewPlayerReportState();
}

class _CoachViewPlayerReportState extends State<CoachViewPlayerReport> {
  final _authService = AuthService();
  String _searchQuery = '';
  String _selectedSport = 'All Sports';
  final List<String> _sports = [
    'All Sports',
    'Football',
    'Basketball',
    'Cricket',
    'Badminton',
    'Tennis'
  ];
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
          _userName = userData['name'] ?? "Coach";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  final List<Map<String, dynamic>> _players = [
    {
      'name': 'John Doe',
      'sport': 'Football',
      'profilePic': 'assets/images/player3.jpg',
      'report': {
        'date': '02/10/2025',
        'sport': 'Football',
        'athleteName': 'John Doe',
        'age': 25,
        'athleteId': '12345',
        'organization': 'FC Awesome',
        'height': 180,
        'weight': 75,
        'bmi': 23.1,
        'restingHeartRate': 60,
        'bloodPressure': '120/80',
        'oxygenSaturation': 98,
        'respiratoryRate': 16,
        'bodyTemperature': 36.5,
        'vo2Max': 55,
        'sprintSpeed': 9.8,
        'agilityScore': 85,
        'strength': 100,
        'flexibilityTest': 30,
        'pastInjuries': 'ACL Tear (2023), Ankle Sprain (2022)',
        'ongoingTreatment': 'Rehab Plan, Physiotherapy Sessions',
        'returnToPlayStatus': 'Cleared',
        'bloodTest': 'Normal',
        'ecg': 'Normal',
        'boneDensity': 'Healthy',
        'lungFunction': 'Normal',
        'caloricIntake': 2500,
        'waterIntake': 3,
        'nutrientDeficiencies': 'None',
        'supplements': 'Protein, Creatine, B12',
        'stressLevel': 5,
        'sleepQuality': 8,
        'cognitiveScore': 90,
        'medicalClearance': '✅ Fit to Play',
        'nextCheckupDate': '03/10/2025',
        'doctorsNotes': 'Keep up the good work!',
        'status': 'Excellent',
        'statusColor': Colors.green,
      },
    },
    {
      'name': 'Jane Smith',
      'sport': 'Basketball',
      'profilePic': 'assets/images/player2.jpg',
      'report': {
        'date': '02/10/2025',
        'sport': 'Basketball',
        'athleteName': 'Jane Smith',
        'age': 22,
        'athleteId': '67890',
        'organization': 'Basketball Club',
        'height': 175,
        'weight': 65,
        'bmi': 21.2,
        'restingHeartRate': 58,
        'bloodPressure': '118/78',
        'oxygenSaturation': 99,
        'respiratoryRate': 15,
        'bodyTemperature': 36.6,
        'vo2Max': 60,
        'sprintSpeed': 10.2,
        'agilityScore': 90,
        'strength': 95,
        'flexibilityTest': 32,
        'pastInjuries': 'None',
        'ongoingTreatment': 'None',
        'returnToPlayStatus': 'Cleared',
        'bloodTest': 'Normal',
        'ecg': 'Normal',
        'boneDensity': 'Healthy',
        'lungFunction': 'Normal',
        'caloricIntake': 2400,
        'waterIntake': 2.5,
        'nutrientDeficiencies': 'None',
        'supplements': 'Vitamin D, Calcium',
        'stressLevel': 4,
        'sleepQuality': 7,
        'cognitiveScore': 88,
        'medicalClearance': '✅ Fit to Play',
        'nextCheckupDate': '03/10/2025',
        'doctorsNotes': 'Maintain current regimen.',
        'status': 'Good',
        'statusColor': Colors.blue,
      },
    },
    {
      'name': 'Mike Johnson',
      'sport': 'Cricket',
      'profilePic': 'assets/images/player1.jpg',
      'report': {
        'date': '01/15/2025',
        'sport': 'Cricket',
        'athleteName': 'Mike Johnson',
        'age': 28,
        'athleteId': '54321',
        'organization': 'Cricket Club',
        'height': 185,
        'weight': 78,
        'bmi': 22.8,
        'restingHeartRate': 62,
        'bloodPressure': '122/82',
        'oxygenSaturation': 97,
        'respiratoryRate': 16,
        'bodyTemperature': 36.7,
        'vo2Max': 52,
        'sprintSpeed': 9.5,
        'agilityScore': 82,
        'strength': 95,
        'flexibilityTest': 28,
        'pastInjuries': 'Shoulder strain (2024)',
        'ongoingTreatment': 'Strengthening exercises',
        'returnToPlayStatus': 'Limited Practice',
        'bloodTest': 'Normal',
        'ecg': 'Minor abnormality - monitoring',
        'boneDensity': 'Healthy',
        'lungFunction': 'Normal',
        'caloricIntake': 2600,
        'waterIntake': 3.2,
        'nutrientDeficiencies': 'Slight iron deficiency',
        'supplements': 'Iron, Protein, Multivitamin',
        'stressLevel': 6,
        'sleepQuality': 6.5,
        'cognitiveScore': 85,
        'medicalClearance': '⚠️ Limited Activity',
        'nextCheckupDate': '02/15/2025',
        'doctorsNotes': 'Continue shoulder exercises. Limit throwing practice.',
        'status': 'Limited',
        'statusColor': Colors.orange,
      },
    },
    {
      'name': 'Sarah Williams',
      'sport': 'Tennis',
      'profilePic': 'assets/images/player4.jpg',
      'report': {
        'date': '01/22/2025',
        'sport': 'Tennis',
        'athleteName': 'Sarah Williams',
        'age': 26,
        'athleteId': '98765',
        'organization': 'Tennis Academy',
        'height': 172,
        'weight': 62,
        'bmi': 21.0,
        'restingHeartRate': 55,
        'bloodPressure': '115/75',
        'oxygenSaturation': 99,
        'respiratoryRate': 14,
        'bodyTemperature': 36.4,
        'vo2Max': 58,
        'sprintSpeed': 9.9,
        'agilityScore': 88,
        'strength': 90,
        'flexibilityTest': 35,
        'pastInjuries': 'Wrist sprain (2023), Tennis elbow (2022)',
        'ongoingTreatment': 'Recovery Program',
        'returnToPlayStatus': 'Cleared',
        'bloodTest': 'Normal',
        'ecg': 'Normal',
        'boneDensity': 'Healthy',
        'lungFunction': 'Superior',
        'caloricIntake': 2200,
        'waterIntake': 3.5,
        'nutrientDeficiencies': 'None',
        'supplements': 'BCAA, Magnesium, CoQ10',
        'stressLevel': 3,
        'sleepQuality': 8.5,
        'cognitiveScore': 92,
        'medicalClearance': '✅ Fit to Play',
        'nextCheckupDate': '03/22/2025',
        'doctorsNotes': 'Excellent progress. Continue current program.',
        'status': 'Excellent',
        'statusColor': Colors.green,
      },
    },
  ];

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

  Color _getStatusColor(Map<String, dynamic> report) {
    if (report.containsKey('statusColor') && report['statusColor'] is Color) {
      return report['statusColor'];
    }
    if (report['medicalClearance'].contains('✅')) {
      return Colors.green;
    } else if (report['medicalClearance'].contains('⚠️')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
        return Icons.sports_tennis; // No specific badminton icon
      default:
        return Icons.sports;
    }
  }

  void _showPlayerReport(BuildContext context, Map<String, dynamic> player) {
    final report = player['report'];
    final statusColor = _getStatusColor(report);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
              maxWidth:
                  math.min(MediaQuery.of(dialogContext).size.width * 0.9, 500),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section with player info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(player['profilePic']),
                            onBackgroundImageError: (exception, stackTrace) {
                              // Handle image loading errors
                            },
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _getSportIcon(player['sport']),
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      player['sport'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        report.containsKey('status')
                                            ? report['status']
                                            : 'Unknown',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderItem(Icons.calendar_today, 'Report Date',
                              report['date']),
                          _buildHeaderItem(Icons.medical_services, 'Status',
                              report['returnToPlayStatus']),
                          _buildHeaderItem(Icons.access_time, 'Next Checkup',
                              report['nextCheckupDate']),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body section with medical report
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMedicalReportSection(
                            'General Information',
                            Icons.person,
                            [
                              _buildInfoRow('ID', '#${report['athleteId']}'),
                              _buildInfoRow('Age', '${report['age']} years'),
                              _buildInfoRow(
                                  'Organization', report['organization']),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Body Measurements',
                            Icons.height,
                            [
                              _buildInfoRow('Height', '${report['height']} cm'),
                              _buildInfoRow('Weight', '${report['weight']} kg'),
                              _buildInfoRow('BMI', '${report['bmi']}'),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Vitals',
                            Icons.favorite,
                            [
                              _buildInfoRow('Heart Rate',
                                  '${report['restingHeartRate']} bpm'),
                              _buildInfoRow(
                                  'Blood Pressure', report['bloodPressure']),
                              _buildInfoRow(
                                  'SpO2', '${report['oxygenSaturation']}%'),
                              _buildInfoRow('Temperature',
                                  '${report['bodyTemperature']}°C'),
                              _buildInfoRow('Respiratory Rate',
                                  '${report['respiratoryRate']} bpm'),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Performance Metrics',
                            Icons.speed,
                            [
                              _buildInfoRow(
                                  'VO₂ Max', '${report['vo2Max']} ml/kg/min'),
                              _buildInfoRow('Sprint Speed',
                                  '${report['sprintSpeed']} m/s'),
                              _buildInfoRow('Agility Score',
                                  '${report['agilityScore']}/100'),
                              _buildInfoRow(
                                  'Strength', '${report['strength']} kg'),
                              _buildInfoRow('Flexibility',
                                  '${report['flexibilityTest']} cm'),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Medical History',
                            Icons.healing,
                            [
                              _buildInfoRow(
                                  'Past Injuries', report['pastInjuries']),
                              _buildInfoRow(
                                  'Treatment', report['ongoingTreatment']),
                              _buildInfoRow('Return Status',
                                  report['returnToPlayStatus']),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Test Results',
                            Icons.science,
                            [
                              _buildInfoRow('Blood Test', report['bloodTest']),
                              _buildInfoRow('ECG', report['ecg']),
                              _buildInfoRow(
                                  'Bone Density', report['boneDensity']),
                              _buildInfoRow(
                                  'Lung Function', report['lungFunction']),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Nutrition',
                            Icons.restaurant,
                            [
                              _buildInfoRow('Calories',
                                  '${report['caloricIntake']} kcal'),
                              _buildInfoRow(
                                  'Water', '${report['waterIntake']} L'),
                              _buildInfoRow('Deficiencies',
                                  report['nutrientDeficiencies']),
                              _buildInfoRow(
                                  'Supplements', report['supplements']),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Mental & Cognitive Health',
                            Icons.psychology,
                            [
                              _buildInfoRow('Stress Level',
                                  '${report['stressLevel']}/10'),
                              _buildInfoRow('Sleep Quality',
                                  '${report['sleepQuality']} hrs'),
                              _buildInfoRow('Cognitive Score',
                                  '${report['cognitiveScore']}/100'),
                            ],
                          ),
                          const Divider(),
                          _buildMedicalReportSection(
                            'Doctor\'s Notes',
                            Icons.note_alt,
                            [
                              Text(
                                report['doctorsNotes'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer with action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Add print functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printing report...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Print'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderItem(IconData icon, String title, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalReportSection(
      String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
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
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Medical Reports'),
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
        selectedDrawerItem: coachViewPlayerMedicalReportRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(
              icon: Icons.people,
              title: 'View all players',
              route: coachHomeRoute),
          DrawerItem(
              icon: Icons.announcement,
              title: 'Make announcement',
              route: coachMakeAnAnnouncementRoute),
          DrawerItem(
              icon: Icons.schedule,
              title: 'Mark upcoming sessions',
              route: coachMarkSessionRoute),
          DrawerItem(
              icon: Icons.schedule,
              title: 'View Coaching Staffs Assigned',
              route: viewCoachingStaffsAssignedRoute),
          DrawerItem(
              icon: Icons.medical_services,
              title: 'View Medical records',
              route: coachViewPlayerMedicalReportRoute),
          DrawerItem(
              icon: Icons.person,
              title: 'View Profile',
              route: coachProfileRoute),
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
            // Search and filter section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Adapt layout based on screen width
                  screenWidth > 500
                      ? _buildWideSearchRow()
                      : _buildNarrowSearchLayout(),
                ],
              ),
            ),

            // Player card section
            Expanded(
              child: _filteredPlayers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medical reports found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing your filters',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            0.58, // Adjusted to fix 36px overflow (previously 0.65)
                      ),
                      itemCount: _filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final player = _filteredPlayers[index];
                        final report = player['report'];
                        final statusColor = _getStatusColor(report);

                        return Material(
                          color: Colors.transparent,
                          child: _buildPlayerCard(player, report, statusColor),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Split search layout into separate methods for different screen sizes
  Widget _buildWideSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Players',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 1),
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildSportDropdown(),
      ],
    );
  }

  Widget _buildNarrowSearchLayout() {
    return Column(
      children: [
        Container(
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
          ),
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search Players',
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.deepPurple, width: 1),
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildSportDropdown(),
      ],
    );
  }

  Widget _buildSportDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSport,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          onChanged: _onSportChanged,
          items: _sports.map((String sport) {
            return DropdownMenuItem<String>(
              value: sport,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getSportIcon(sport),
                      size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    sport,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 15,
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
      ),
    );
  }

  // Fixed player card with proper constraints to avoid overflow
  Widget _buildPlayerCard(Map<String, dynamic> player,
      Map<String, dynamic> report, Color statusColor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, // Remove default margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPlayerReport(context, player),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player image with reduced height
              SizedBox(
                height: 120, // Further reduced height
                width: double.infinity,
                child: Image.asset(
                  player['profilePic'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        size: 48, // Smaller icon
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),

              // Player info section with more compact layout
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use minimum size
                    children: [
                      // Name and status icon in more compact form
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Center-align
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4), // Smaller padding
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              _getMedicalStatusIcon(report),
                              color: statusColor,
                              size: 12, // Smaller icon
                            ),
                          ),
                          const SizedBox(width: 4), // Smaller spacing
                          Expanded(
                            child: Text(
                              player['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20, // Smaller font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // Smaller spacing

                      // Sport info with icon - more compact
                      Row(
                        children: [
                          Icon(
                            _getSportIcon(player['sport']),
                            size: 15, // Smaller icon
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              player['sport'],
                              style: TextStyle(
                                fontSize: 15, // Smaller font
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), // Smaller spacing

                      // Medical clearance badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 4), // Smaller padding
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(4), // Smaller radius
                        ),
                        child: Text(
                          report['medicalClearance'],
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12, // Smaller font
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 17), // Smaller spacing

                      // Combine dates to save space
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(
                              text: 'Last: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: report['date']),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(
                              text: 'Next: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: report['nextCheckupDate']),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6), // Smaller spacing

                      // View report button with reduced height
                      SizedBox(
                        width: double.infinity,
                        height: 28, // Reduced height
                        child: ElevatedButton.icon(
                          onPressed: () => _showPlayerReport(context, player),
                          icon: const Icon(Icons.visibility,
                              size: 10), // Smaller icon
                          label: const Text('View Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(6), // Smaller radius
                            ),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity:
                                VisualDensity.compact, // Make it more compact
                            textStyle: const TextStyle(
                              fontSize: 10, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMedicalStatusIcon(Map<String, dynamic> report) {
    if (report['medicalClearance'].contains('✅')) {
      return Icons.check_circle;
    } else if (report['medicalClearance'].contains('⚠️')) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }
}
