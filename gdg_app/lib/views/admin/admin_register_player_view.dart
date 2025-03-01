import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AdminRegisterPlayerView extends StatefulWidget {
  const AdminRegisterPlayerView({super.key});

  @override
  _AdminRegisterPlayerViewState createState() => _AdminRegisterPlayerViewState();
}

class _AdminRegisterPlayerViewState extends State<AdminRegisterPlayerView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _schoolController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _organizationEmailController = TextEditingController();
  final _organizationWebsiteController = TextEditingController();
  final _playingPositionController = TextEditingController();
  final _trainingStartDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String _athleteId = '';
  int _age = 0;
  String _gender = 'Male';
  String _grade = '10th';
  String _primarySport = 'Football';
  String? _secondarySport;
  String _currentLevel = 'Beginner';
  String _coachAssigned = 'Coach A';
  String _gymTrainerAssigned = 'Trainer A';
  String _medicalStaffAssigned = 'Medical Staff A';
  String _bloodGroup = 'A+';
  String _dominantHandLeg = 'Right';

  @override
  void initState() {
    super.initState();
    _generateAthleteId();
  }

  void _generateAthleteId() {
    final random = Random();
    _athleteId = 'ATH${random.nextInt(1000000).toString().padLeft(6, '0')}';
  }

  void _calculateAge() {
    if (_dobController.text.isNotEmpty) {
      final dob = DateFormat('MM/dd/yyyy').parse(_dobController.text);
      final today = DateTime.now();
      _age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        _age--;
      }
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          title: const Text('Success', style: TextStyle(color: Colors.deepPurple)),
          content: const Text('Player registered successfully'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.deepPurple),
            border: InputBorder.none,
            icon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          ),
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Player', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: registerPlayerRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
        },
        drawerItems: [
          DrawerItem(icon: Icons.home, title: 'Admin Home', route: adminHomeRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Admin', route: registerAdminRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Coach', route: registerCoachRoute),
          DrawerItem(icon: Icons.person_add, title: 'Register Player', route: registerPlayerRoute),
          DrawerItem(icon: Icons.people, title: 'View All Players', route: viewAllPlayersRoute),
          DrawerItem(icon: Icons.people, title: 'View All Coaches', route: viewAllCoachesRoute),
          DrawerItem(icon: Icons.request_page, title: 'Request/View Sponsors', route: requestViewSponsorsRoute),
          DrawerItem(icon: Icons.video_library, title: 'Video Analysis', route: videoAnalysisRoute),
          DrawerItem(icon: Icons.edit, title: 'Edit Forms', route: editFormsRoute),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nameController,
                labelText: 'Full Name',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the full name' : null,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.badge, color: Colors.deepPurple),
                    title: Text('Athlete ID: $_athleteId', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _dobController,
                labelText: 'Date of Birth',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the date of birth' : null,
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
                      _calculateAge();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.cake, color: Colors.deepPurple),
                    title: Text('Age: $_age', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.transgender, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a gender' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nationalityController,
                labelText: 'Nationality',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the nationality' : null,
                icon: Icons.flag,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _addressController,
                labelText: 'Address',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the address' : null,
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                labelText: 'Phone Number',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the phone number' : null,
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                labelText: 'Email ID',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the email ID' : null,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              // Profile Photo Upload Field
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.photo, color: Colors.deepPurple),
                    title: const Text('Profile Photo', style: TextStyle(color: Colors.deepPurple)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Implement photo upload functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Upload', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('2️⃣ Academic & Organizational Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _schoolController,
                labelText: 'School/College/Organization Name',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the school/college/organization name' : null,
                icon: Icons.school,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _grade,
                    decoration: const InputDecoration(
                      labelText: 'Grade/Year',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.grade, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: '10th', child: Text('10th')),
                      DropdownMenuItem(value: '11th', child: Text('11th')),
                      DropdownMenuItem(value: '12th', child: Text('12th')),
                      DropdownMenuItem(value: 'UG', child: Text('UG')),
                      DropdownMenuItem(value: 'PG', child: Text('PG')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _grade = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a grade/year' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _studentIdController,
                labelText: 'Student ID (If Applicable)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the student ID' : null,
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _organizationEmailController,
                labelText: 'Organization Email (If Any)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the organization email' : null,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _organizationWebsiteController,
                labelText: 'Organization Website (If Any)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the organization website' : null,
                icon: Icons.web,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('3️⃣ Sports & Training Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _primarySport,
                    decoration: const InputDecoration(
                      labelText: 'Primary Sport',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.sports, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Football', child: Text('Football')),
                      DropdownMenuItem(value: 'Cricket', child: Text('Cricket')),
                      DropdownMenuItem(value: 'Basketball', child: Text('Basketball')),
                      DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                      DropdownMenuItem(value: 'Badminton', child: Text('Badminton')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _primarySport = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a primary sport' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _secondarySport,
                    decoration: const InputDecoration(
                      labelText: 'Secondary Sport (If Any)',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.sports, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'None', child: Text('None')),
                      DropdownMenuItem(value: 'Football', child: Text('Football')),
                      DropdownMenuItem(value: 'Cricket', child: Text('Cricket')),
                      DropdownMenuItem(value: 'Basketball', child: Text('Basketball')),
                      DropdownMenuItem(value: 'Tennis', child: Text('Tennis')),
                      DropdownMenuItem(value: 'Badminton', child: Text('Badminton')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _secondarySport = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a secondary sport' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _playingPositionController,
                labelText: 'Playing Position (If Applicable)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the playing position' : null,
                icon: Icons.sports_soccer,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _trainingStartDateController,
                labelText: 'Training Start Date',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the training start date' : null,
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _trainingStartDateController.text = DateFormat('MM/dd/yyyy').format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _currentLevel,
                    decoration: const InputDecoration(
                      labelText: 'Current Level',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.assessment, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                      DropdownMenuItem(value: 'Professional', child: Text('Professional')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentLevel = value!;
                      });
                                        },
                    validator: (value) => value == null ? 'Please select a current level' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _coachAssigned,
                    decoration: const InputDecoration(
                      labelText: 'Coach Assigned',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.person, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Coach A', child: Text('Coach A')),
                      DropdownMenuItem(value: 'Coach B', child: Text('Coach B')),
                      DropdownMenuItem(value: 'Coach C', child: Text('Coach C')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _coachAssigned = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a coach' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _gymTrainerAssigned,
                    decoration: const InputDecoration(
                      labelText: 'Gym Trainer Assigned',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.fitness_center, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Trainer A', child: Text('Trainer A')),
                      DropdownMenuItem(value: 'Trainer B', child: Text('Trainer B')),
                      DropdownMenuItem(value: 'Trainer C', child: Text('Trainer C')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _gymTrainerAssigned = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a gym trainer' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _medicalStaffAssigned,
                    decoration: const InputDecoration(
                      labelText: 'Medical Staff Assigned',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.medical_services, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Medical Staff A', child: Text('Medical Staff A')),
                      DropdownMenuItem(value: 'Medical Staff B', child: Text('Medical Staff B')),
                      DropdownMenuItem(value: 'Medical Staff C', child: Text('Medical Staff C')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _medicalStaffAssigned = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a medical staff' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('4️⃣ Physical Attributes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _heightController,
                labelText: 'Height (cm)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the height' : null,
                icon: Icons.height,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _weightController,
                labelText: 'Weight (kg)',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the weight' : null,
                icon: Icons.fitness_center,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calculate, color: Colors.deepPurple),
                    title: Text('Body Mass Index (BMI): ${_calculateBMI()}', style: const TextStyle(color: Colors.deepPurple)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _dominantHandLeg,
                    decoration: const InputDecoration(
                      labelText: 'Dominant Hand/Leg',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.accessibility, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Right', child: Text('Right')),
                      DropdownMenuItem(value: 'Left', child: Text('Left')),
                      DropdownMenuItem(value: 'Both', child: Text('Both')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _dominantHandLeg = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a dominant hand/leg' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('5️⃣ Medical & Health Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: InputBorder.none,
                      icon: Icon(Icons.bloodtype, color: Colors.deepPurple),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _bloodGroup = value!;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a blood group' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _allergiesController,
                labelText: 'Known Allergies',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter known allergies' : null,
                icon: Icons.warning,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _medicalConditionsController,
                labelText: 'Pre-existing Medical Conditions',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter pre-existing medical conditions' : null,
                icon: Icons.medical_services,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSuccessPopup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateBMI() {
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      final height = double.parse(_heightController.text) / 100;
      final weight = double.parse(_weightController.text);
      return weight / (height * height);
    }
    return 0.0;
  }
}
