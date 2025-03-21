import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this package to pubspec.yaml

class MedicalReport extends StatefulWidget {
  const MedicalReport({super.key});

  @override
  _MedicalReportState createState() => _MedicalReportState();
}

class _MedicalReportState extends State<MedicalReport> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final Map<String, bool> _expandedSections = {
    'General Health & Vitals': false,
    'Fitness & Performance Metrics': false,
    'Performance Graph': false,
    'Injury History & Recovery': false,
    'Medical Test Results': false,
    'Nutrition & Hydration': false,
    'Mental Health & Sleep Patterns': false,
    'Medical Clearance': false,
  };

  String _searchQuery = '';
  late TabController _tabController;

  // Add these state variables for user info
String _userName = "";
String _userEmail = "";
String? _userAvatar;
bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 2, vsync: this);
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

  final Map<String, dynamic> reportData = {
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
  };

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute); // Navigate to the desired page
  }
  
  // Get color based on medical status
  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('fit') || 
        status.toLowerCase().contains('normal') || 
        status.toLowerCase().contains('healthy') ||
        status.toLowerCase().contains('cleared')) {
      return Colors.green.shade700;
    } else if (status.toLowerCase().contains('warning') || 
              status.toLowerCase().contains('caution')) {
      return Colors.amber.shade700;
    } else if (status.toLowerCase().contains('unfit') || 
              status.toLowerCase().contains('injury') || 
              status.toLowerCase().contains('abnormal')) {
      return Colors.red.shade700;
    }
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Report'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 2,
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.description),
                  text: 'Medical Details',
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: 'History',
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: medicalReportRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
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
          
          DrawerItem(icon: Icons.attach_money, title: 'Finances', route: playerFinancialViewRoute),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            // First tab - Medical Details
            Column(
              children: [
                // Search and summary bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          labelText: 'Search medical information',
                          hintText: 'e.g., heart rate, injuries, clearance',
                          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          fillColor: Colors.grey.shade50,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Medical status card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade50, Colors.green.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_circle,
                                size: 36,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Medical Status',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${reportData['medicalClearance']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Checkup',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${reportData['nextCheckupDate']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                
                // Main content with sections
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'General Health & Vitals',
                          icon: Icons.favorite,
                          isExpanded: _expandedSections['General Health & Vitals']!,
                          onToggle: () => _toggleSection('General Health & Vitals'),
                          children: [
                            _buildMetricRow('Height', '${reportData['height']} cm', Icons.height),
                            _buildMetricRow('Weight', '${reportData['weight']} kg', Icons.line_weight),
                            _buildMetricRow('BMI', '${reportData['bmi']}', Icons.monitor_weight),
                            _buildMetricRow('Resting Heart Rate', '${reportData['restingHeartRate']} bpm', Icons.monitor_heart),
                            _buildMetricRow('Blood Pressure', '${reportData['bloodPressure']} mmHg', Icons.bloodtype),
                            _buildMetricRow('Oxygen Saturation', '${reportData['oxygenSaturation']}%', Icons.air),
                            _buildMetricRow('Respiratory Rate', '${reportData['respiratoryRate']} bpm', Icons.air_rounded),
                            _buildMetricRow('Body Temperature', '${reportData['bodyTemperature']}°C', Icons.thermostat),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Fitness & Performance Metrics',
                          icon: Icons.directions_run,
                          isExpanded: _expandedSections['Fitness & Performance Metrics']!,
                          onToggle: () => _toggleSection('Fitness & Performance Metrics'),
                          children: [
                            _buildMetricRow('VO₂ Max', '${reportData['vo2Max']} ml/kg/min', Icons.speed),
                            _buildMetricRow('Sprint Speed', '${reportData['sprintSpeed']} m/s', Icons.shutter_speed),
                            _buildMetricRow('Agility Score', '${reportData['agilityScore']}', Icons.change_circle),
                            _buildMetricRow('Strength', '${reportData['strength']} kg', Icons.fitness_center),
                            _buildMetricRow('Flexibility Test', '${reportData['flexibilityTest']} cm', Icons.accessibility_new),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Injury History & Recovery',
                          icon: Icons.healing,
                          isExpanded: _expandedSections['Injury History & Recovery']!,
                          onToggle: () => _toggleSection('Injury History & Recovery'),
                          children: [
                            _buildInjuryHistorySection(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Medical Test Results',
                          icon: Icons.biotech,
                          isExpanded: _expandedSections['Medical Test Results']!,
                          onToggle: () => _toggleSection('Medical Test Results'),
                          children: [
                            _buildTestResultRow('Blood Test', '${reportData['bloodTest']}'),
                            _buildTestResultRow('Electrocardiogram (ECG)', '${reportData['ecg']}'),
                            _buildTestResultRow('Bone Density Scan', '${reportData['boneDensity']}'),
                            _buildTestResultRow('Lung Function Test', '${reportData['lungFunction']}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Nutrition & Hydration',
                          icon: Icons.restaurant_menu,
                          isExpanded: _expandedSections['Nutrition & Hydration']!,
                          onToggle: () => _toggleSection('Nutrition & Hydration'),
                          children: [
                            _buildNutritionSection(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Mental Health & Sleep Patterns',
                          icon: Icons.nightlight,
                          isExpanded: _expandedSections['Mental Health & Sleep Patterns']!,
                          onToggle: () => _toggleSection('Mental Health & Sleep Patterns'),
                          children: [
                            _buildMentalHealthSection(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCollapsibleCard(
                          title: 'Medical Clearance',
                          icon: Icons.verified_user,
                          isExpanded: _expandedSections['Medical Clearance']!,
                          onToggle: () => _toggleSection('Medical Clearance'),
                          children: [
                            _buildMedicalClearanceSection(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Second tab - History
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_edu,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Medical History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Historical medical reports will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Requesting updated medical report...'))
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    reportData['athleteName'].toString().substring(0, 1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reportData['athleteName'].toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reportData['sport']} | ID: ${reportData['athleteId']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reportData['organization']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.deepPurple.shade200,
                    ),
                  ),
                  child: Text(
                    'Age: ${reportData['age']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip('Report Date', reportData['date'].toString()),
                  _buildVerticalDivider(),
                  _buildInfoChip('Organization', reportData['organization'].toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isExpanded 
                          ? Colors.deepPurple.withOpacity(0.1) 
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isExpanded ? Colors.deepPurple : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeline(
          title: 'ACL Tear',
          date: '2023',
          description: 'Grade 2 tear in right knee, surgery performed in March 2023',
          isRecovered: true,
        ),
        _buildTimeline(
          title: 'Ankle Sprain',
          date: '2022',
          description: 'Grade 1 sprain in left ankle, conservative treatment with rest and PT',
          isRecovered: true,
          isLastItem: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Current Treatment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100),
          ),
          child: Text(
            reportData['ongoingTreatment'].toString(),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Status: ${reportData['returnToPlayStatus']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline({
    required String title,
    required String date,
    required String description,
    required bool isRecovered,
    bool isLastItem = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isRecovered ? Colors.green : Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
            if (!isLastItem)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              if (!isLastItem) const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

    Widget _buildTestResultRow(String test, String result) {
    final isNormal = result.toLowerCase() == 'normal' || 
                     result.toLowerCase() == 'healthy';
    final Color statusColor = isNormal ? Colors.green.shade600 : Colors.red.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),  // Increased padding for better spacing
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNormal ? Icons.check_circle : Icons.warning_amber_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Result: $result',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isNormal ? 'Normal' : 'Attention',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Caloric & Water Intake
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildNutritionMetric(
                      'Caloric Intake',
                      '${reportData['caloricIntake']} kcal',
                      Icons.local_fire_department,
                      Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNutritionMetric(
                      'Water Intake',
                      '${reportData['waterIntake']} L',
                      Icons.water_drop,
                      Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Nutrient Status
        _buildNutrientStatus(
          'Nutrient Deficiencies',
          reportData['nutrientDeficiencies'].toString(),
          reportData['nutrientDeficiencies'].toString().toLowerCase() == 'none',
        ),
        
        const SizedBox(height: 16),
        
        // Supplements Section with Cards
        const Text(
          'Recommended Supplements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Supplement Cards in a grid
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSupplementCard('Protein', 'For muscle recovery', Icons.fitness_center),
            _buildSupplementCard('Creatine', 'For strength gains', Icons.bolt),
            _buildSupplementCard('B12', 'For energy levels', Icons.battery_full),
            _buildSupplementCard('Omega-3', 'For joint health', Icons.healing),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientStatus(String label, String value, bool isGood) {
    final Color statusColor = isGood ? Colors.green.shade700 : Colors.red.shade700;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isGood ? Icons.check_circle : Icons.warning_amber,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplementCard(String name, String purpose, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            purpose,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMentalHealthSection() {
    final int stressLevel = reportData['stressLevel'] as int;
    final int sleepQuality = reportData['sleepQuality'] as int;
    final int cognitiveScore = reportData['cognitiveScore'] as int;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mental Health Metrics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMentalHealthSlider(
                'Stress Level',
                stressLevel,
                10,
                'Low',
                'High',
                _getStressLevelColor(stressLevel),
                Icons.sentiment_satisfied,
              ),
              const SizedBox(height: 20),
              _buildMentalHealthSlider(
                'Sleep Quality',
                sleepQuality,
                10,
                'Poor',
                'Excellent',
                _getSleepQualityColor(sleepQuality),
                Icons.nightlight,
              ),
              const SizedBox(height: 20),
              _buildMentalHealthSlider(
                'Cognitive Function',
                cognitiveScore,
                100,
                'Low',
                'High',
                _getCognitiveScoreColor(cognitiveScore),
                Icons.psychology,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildMentalHealthRecommendations(),
      ],
    );
  }

  Color _getStressLevelColor(int level) {
    if (level <= 3) return Colors.green.shade700;
    if (level <= 6) return Colors.amber.shade700;
    return Colors.red.shade700;
  }
  
  Color _getSleepQualityColor(int level) {
    if (level >= 8) return Colors.green.shade700;
    if (level >= 5) return Colors.amber.shade700;
    return Colors.red.shade700;
  }
  
  Color _getCognitiveScoreColor(int score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  Widget _buildMentalHealthSlider(
    String title,
    int value,
    int maxValue,
    String minLabel,
    String maxLabel,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$value/$maxValue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * (value / maxValue) * 0.7, // Width based on value
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              maxLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMentalHealthRecommendations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.deepPurple,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem('Get 8 hours of sleep per night'),
          _buildRecommendationItem('Practice mindfulness for 10 minutes daily'),
          _buildRecommendationItem('Maintain consistent sleep schedule'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalClearanceSection() {
    final bool isCleared = reportData['medicalClearance'].toString().contains('Fit');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCleared ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCleared ? Colors.green.shade300 : Colors.red.shade300,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isCleared 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.red.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isCleared ? Icons.verified : Icons.dangerous,
                  size: 36,
                  color: isCleared ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCleared ? 'Cleared for Play' : 'Not Cleared',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isCleared ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCleared 
                          ? 'Player is medically fit to participate in all team activities'
                          : 'Player is not medically cleared for competitive activities',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCleared ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.notes,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Doctor\'s Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reportData['doctorsNotes'].toString(),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade800,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Next Review Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reportData['nextCheckupDate'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Add to Calendar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}