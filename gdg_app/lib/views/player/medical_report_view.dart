// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class MedicalReport extends StatefulWidget {
  const MedicalReport({super.key});

  @override
  _MedicalReportState createState() => _MedicalReportState();
}

class _MedicalReportState extends State<MedicalReport> {
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
          DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerProfileRoute),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'General Information',
                      children: [
                        _buildSectionTitle('📅 Date: ${reportData['date']}'),
                        _buildSectionTitle('🏅 Sport: ${reportData['sport']}'),
                        _buildSectionTitle('👤 Athlete Name: ${reportData['athleteName']}'),
                        _buildSectionTitle('📌 Age: ${reportData['age']}'),
                        _buildSectionTitle('🆔 Athlete ID: ${reportData['athleteId']}'),
                        _buildSectionTitle('🏢 Organization: ${reportData['organization']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '1️⃣ General Health & Vitals',
                      isExpanded: _expandedSections['General Health & Vitals']!,
                      onToggle: () => _toggleSection('General Health & Vitals'),
                      children: [
                        _buildListItem('Height: ${reportData['height']} cm | Weight: ${reportData['weight']} kg | BMI: ${reportData['bmi']}'),
                        _buildListItem('Resting Heart Rate: ${reportData['restingHeartRate']} bpm | Blood Pressure: ${reportData['bloodPressure']} mmHg'),
                        _buildListItem('Oxygen Saturation (SpO2): ${reportData['oxygenSaturation']}% | Respiratory Rate: ${reportData['respiratoryRate']} bpm'),
                        _buildListItem('Body Temperature: ${reportData['bodyTemperature']}°C'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '2️⃣ Fitness & Performance Metrics',
                      isExpanded: _expandedSections['Fitness & Performance Metrics']!,
                      onToggle: () => _toggleSection('Fitness & Performance Metrics'),
                      children: [
                        _buildListItem('VO₂ Max: ${reportData['vo2Max']} ml/kg/min (Cardio Endurance)'),
                        _buildListItem('Sprint Speed: ${reportData['sprintSpeed']} m/s | Agility Score: ${reportData['agilityScore']}'),
                        _buildListItem('Strength (Bench Press/Squat): ${reportData['strength']} kg'),
                        _buildListItem('Flexibility Test: ${reportData['flexibilityTest']} cm'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '📊 Performance Graph',
                      isExpanded: _expandedSections['Performance Graph']!,
                      onToggle: () => _toggleSection('Performance Graph'),
                      children: [
                        _buildListItem('Attach RP & RPE trends over time'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '3️⃣ Injury History & Recovery',
                      isExpanded: _expandedSections['Injury History & Recovery']!,
                      onToggle: () => _toggleSection('Injury History & Recovery'),
                      children: [
                        _buildListItem('🩹 Past Injuries: ${reportData['pastInjuries']}'),
                        _buildListItem('💊 Ongoing Treatment: ${reportData['ongoingTreatment']}'),
                        _buildListItem('✅ Return-to-Play Status: ${reportData['returnToPlayStatus']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '4️⃣ Medical Test Results',
                      isExpanded: _expandedSections['Medical Test Results']!,
                      onToggle: () => _toggleSection('Medical Test Results'),
                      children: [
                        _buildListItem('Blood Test (Hemoglobin, Iron, Vitamin D): ${reportData['bloodTest']}'),
                        _buildListItem('Electrocardiogram (ECG): ${reportData['ecg']}'),
                        _buildListItem('Bone Density Scan: ${reportData['boneDensity']}'),
                        _buildListItem('Lung Function Test (FEV1): ${reportData['lungFunction']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '5️⃣ Nutrition & Hydration',
                      isExpanded: _expandedSections['Nutrition & Hydration']!,
                      onToggle: () => _toggleSection('Nutrition & Hydration'),
                      children: [
                        _buildListItem('🥗 Daily Caloric Intake: ${reportData['caloricIntake']} kcal | Water Intake: ${reportData['waterIntake']} L'),
                        _buildListItem('⚡ Nutrient Deficiencies: ${reportData['nutrientDeficiencies']}'),
                        _buildListItem('💊 Supplements Taken: ${reportData['supplements']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '6️⃣ Mental Health & Sleep Patterns',
                      isExpanded: _expandedSections['Mental Health & Sleep Patterns']!,
                      onToggle: () => _toggleSection('Mental Health & Sleep Patterns'),
                      children: [
                        _buildListItem('Stress Level (1-10): ${reportData['stressLevel']}'),
                        _buildListItem('Sleep Quality (Hours per Night): ${reportData['sleepQuality']} hrs'),
                        _buildListItem('Focus & Cognitive Score: ${reportData['cognitiveScore']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCollapsibleCard(
                      title: '📌 Medical Clearance',
                      isExpanded: _expandedSections['Medical Clearance']!,
                      onToggle: () => _toggleSection('Medical Clearance'),
                      children: [
                        _buildSectionTitle('📌 Medical Clearance: ${reportData['medicalClearance']}'),
                        _buildSectionTitle('📅 Next Checkup Date: ${reportData['nextCheckupDate']}'),
                        _buildSectionTitle('📝 Doctor\'s Notes: ${reportData['doctorsNotes']}'),
                        _buildSectionTitle('👨‍⚕️ Doctor\'s Name & Signature: _____________________'),
                      ],
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

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            ...children,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildListItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}