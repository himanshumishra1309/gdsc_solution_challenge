import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart'; // Add this package for animations

class AdminRegisterPlayerView extends StatefulWidget {
  const AdminRegisterPlayerView({super.key});

  @override
  _AdminRegisterPlayerViewState createState() => _AdminRegisterPlayerViewState();
}

class _AdminRegisterPlayerViewState extends State<AdminRegisterPlayerView> {
  // Controllers remain the same
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
  String? _profilePhotoPath;

  int _currentSectionIndex = 0;
  bool _formChanged = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _generateAthleteId();
  }

  void _generateAthleteId() {
    final random = Random();
    final now = DateTime.now();
    _athleteId = 'ATH${now.year}${random.nextInt(10000).toString().padLeft(4, '0')}';
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
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
      });
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 70,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Player ${_nameController.text} has been registered successfully with ID: $_athleteId',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetForm();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add Another Player'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, viewAllPlayersRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('View All Players'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _resetForm() {
    _nameController.clear();
    _dobController.clear();
    _nationalityController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _schoolController.clear();
    _studentIdController.clear();
    _organizationEmailController.clear();
    _organizationWebsiteController.clear();
    _playingPositionController.clear();
    _trainingStartDateController.clear();
    _heightController.clear();
    _weightController.clear();
    _allergiesController.clear();
    _medicalConditionsController.clear();
    
    setState(() {
      _age = 0;
      _gender = 'Male';
      _grade = '10th';
      _primarySport = 'Football';
      _secondarySport = null;
      _currentLevel = 'Beginner';
      _coachAssigned = 'Coach A';
      _gymTrainerAssigned = 'Trainer A';
      _medicalStaffAssigned = 'Medical Staff A';
      _bloodGroup = 'A+';
      _dominantHandLeg = 'Right';
      _profilePhotoPath = null;
      _formChanged = false;
      _generateAthleteId();
      _currentSectionIndex = 0;
    });
  }

  Widget _buildEnhancedFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    Widget? suffix,
  }) {
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
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple, size: 20) : null,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 14),
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (value) {
          if (!_formChanged) {
            setState(() {
              _formChanged = true;
            });
          }
        },
      ),
    );
  }

  Widget _buildEnhancedDropdown<T>({
    required String labelText,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
    IconData? icon,
  }) {
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
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple, size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        items: items,
        onChanged: (value) {
          onChanged(value);
          if (!_formChanged) {
            setState(() {
              _formChanged = true;
            });
          }
        },
        validator: validator,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentSectionIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: _currentSectionIndex == index 
                  ? Colors.deepPurple 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: _currentSectionIndex == index
                  ? null
                  : Border.all(color: Colors.deepPurple, width: 1),
              boxShadow: _currentSectionIndex == index
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getSectionIcon(index),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _currentSectionIndex == index 
                        ? Colors.white 
                        : Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getSectionIcon(int index) {
    switch (index) {
      case 0:
        return Icon(
          Icons.person_outline, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
      case 1:
        return Icon(
          Icons.school_outlined, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
      case 2:
        return Icon(
          Icons.sports_outlined, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
      case 3:
        return Icon(
          Icons.accessibility_new_outlined, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
      case 4:
        return Icon(
          Icons.medical_services_outlined, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
      default:
        return Icon(
          Icons.circle_outlined, 
          size: 16, 
          color: _currentSectionIndex == index ? Colors.white : Colors.deepPurple
        );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.deepPurple).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.deepPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Upload a recent photo of the player',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: _profilePhotoPath != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      _profilePhotoPath!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Implement photo upload functionality
                          setState(() {
                            _profilePhotoPath = 'https://via.placeholder.com/500';
                            _formChanged = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Upload Photo'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_currentSectionIndex) {
      case 0:
        return _buildGeneralInfoSection();
      case 1:
        return _buildAcademicAndOrganizationalDetailsSection();
      case 2:
        return _buildSportsAndTrainingSection();
      case 3:
        return _buildPhysicalAttributesSection();
      case 4:
        return _buildMedicalAndHealthSection();
      default:
        return Container();
    }
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Personal Information', Icons.person),
        _buildInfoCard(
          title: 'Athlete ID',
          value: _athleteId,
          icon: Icons.badge,
          backgroundColor: Colors.blue.shade50,
          iconColor: Colors.blue,
        ),
        _buildUploadCard(),
        _buildEnhancedFormField(
          controller: _nameController,
          labelText: 'Full Name',
          hintText: 'Enter player\'s full name',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the full name' : null,
          icon: Icons.person,
        ),
        _buildEnhancedFormField(
          controller: _dobController,
          labelText: 'Date of Birth',
          hintText: 'MM/DD/YYYY',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the date of birth' : null,
          icon: Icons.calendar_today,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.deepPurple,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
                _calculateAge();
                _formChanged = true;
              });
            }
          },
          suffix: _age > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_age years',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
        ),
        _buildEnhancedDropdown<String>(
          labelText: 'Gender',
          value: _gender,
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
          icon: Icons.transgender,
        ),
        _buildEnhancedFormField(
          controller: _nationalityController,
          labelText: 'Nationality',
          hintText: 'Enter nationality',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the nationality' : null,
          icon: Icons.flag,
        ),
        _buildEnhancedFormField(
          controller: _addressController,
          labelText: 'Address',
          hintText: 'Enter complete address',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the address' : null,
          icon: Icons.home,
          maxLines: 2,
        ),
        _buildEnhancedFormField(
          controller: _phoneController,
          labelText: 'Phone Number',
          hintText: 'Enter contact number',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the phone number' : null,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        _buildEnhancedFormField(
          controller: _emailController,
          labelText: 'Email ID',
          hintText: 'Enter email address',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter the email ID';
            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildAcademicAndOrganizationalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Academic & Organizational Details', Icons.school),
        _buildEnhancedFormField(
          controller: _schoolController,
          labelText: 'School/College/Organization Name',
          hintText: 'Enter institution name',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the school/college/organization name' : null,
          icon: Icons.school,
        ),
        _buildEnhancedDropdown<String>(
          labelText: 'Grade/Year',
          value: _grade,
          items: const [
            DropdownMenuItem(value: '10th', child: Text('10th')),
            DropdownMenuItem(value: '11th', child: Text('11th')),
            DropdownMenuItem(value: '12th', child: Text('12th')),
            DropdownMenuItem(value: 'UG', child: Text('Undergraduate')),
            DropdownMenuItem(value: 'PG', child: Text('Postgraduate')),
          ],
          onChanged: (value) {
            setState(() {
              _grade = value!;
            });
          },
          validator: (value) => value == null ? 'Please select a grade/year' : null,
          icon: Icons.grade,
        ),
        _buildEnhancedFormField(
          controller: _studentIdController,
          labelText: 'Student ID (If Applicable)',
          hintText: 'Enter student ID number',
          validator: (value) => null, // Not mandatory
          icon: Icons.badge,
        ),
        _buildEnhancedFormField(
          controller: _organizationEmailController,
          labelText: 'Organization Email (If Any)',
          hintText: 'Enter organization email',
          validator: (value) => null, // Not mandatory
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildEnhancedFormField(
          controller: _organizationWebsiteController,
          labelText: 'Organization Website (If Any)',
          hintText: 'Enter website URL',
          validator: (value) => null, // Not mandatory
          icon: Icons.web,
        ),
        // Additional document upload section
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.file_copy, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Academic Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload relevant academic documents such as transcripts, certificates, or ID cards.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Document upload buttons with enhanced styling
              Row(
                children: [
                  Expanded(
                    child: _buildDocumentUploadButton(
                      title: 'School ID',
                      icon: Icons.badge,
                      color: Colors.blue.shade700,
                      onTap: () {
                        // Implement document upload
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDocumentUploadButton(
                      title: 'Transcripts',
                      icon: Icons.description,
                      color: Colors.green.shade700,
                      onTap: () {
                        // Implement document upload
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDocumentUploadButton(
                      title: 'Certificates',
                      icon: Icons.card_membership,
                      color: Colors.orange.shade700,
                      onTap: () {
                        // Implement document upload
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDocumentUploadButton(
                      title: 'Other Documents',
                      icon: Icons.insert_drive_file,
                      color: Colors.purple.shade700,
                      onTap: () {
                        // Implement document upload
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsAndTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Sports & Training Information', Icons.sports),
        
        // Primary sport selection with visual indicators
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Primary Sport',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSportSelectionChip('Football', Icons.sports_soccer),
                  _buildSportSelectionChip('Cricket', Icons.sports_cricket),
                  _buildSportSelectionChip('Basketball', Icons.sports_basketball),
                  _buildSportSelectionChip('Tennis', Icons.sports_tennis),
                  _buildSportSelectionChip('Volleyball', Icons.sports_volleyball),
                  _buildSportSelectionChip('Badminton', Icons.sports_handball),
                  _buildSportSelectionChip('Swimming', Icons.pool),
                ],
              ),
            ],
          ),
        ),
        
        // Secondary sport with dropdown
        _buildEnhancedDropdown<String?>(
          labelText: 'Secondary Sport (Optional)',
          value: _secondarySport,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('No Secondary Sport')),
            ...['Football', 'Cricket', 'Basketball', 'Tennis', 'Volleyball', 'Badminton', 'Swimming']
                .where((sport) => sport != _primarySport)
                .map((sport) => DropdownMenuItem(value: sport, child: Text(sport))),
          ],
          onChanged: (value) {
            setState(() {
              _secondarySport = value;
            });
          },
          validator: (value) => null, // Optional field
          icon: Icons.sports,
        ),
        
        // Playing position
        _buildEnhancedFormField(
          controller: _playingPositionController,
          labelText: 'Playing Position/Role',
          hintText: 'E.g., Striker, Bowler, Point Guard',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the playing position/role' : null,
          icon: Icons.person_pin,
        ),

        // Skill level
        _buildEnhancedDropdown<String>(
          labelText: 'Current Skill Level',
          value: _currentLevel,
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
          validator: (value) => value == null ? 'Please select the current skill level' : null,
          icon: Icons.trending_up,
        ),

        // Training start date
        _buildEnhancedFormField(
          controller: _trainingStartDateController,
          labelText: 'Training Start Date',
          hintText: 'MM/DD/YYYY',
          validator: (value) => value?.isEmpty ?? true ? 'Please enter the training start date' : null,
          icon: Icons.event,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.deepPurple,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _trainingStartDateController.text = DateFormat('MM/dd/yyyy').format(picked);
                _formChanged = true;
              });
            }
          },
        ),

        // Coaching staff assignment
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coaching Staff Assignment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              
              // Coach assignment
              _buildStaffAssignmentRow(
                title: 'Primary Coach',
                value: _coachAssigned,
                icon: Icons.sports,
                color: Colors.green.shade800,
                options: ['Coach A', 'Coach B', 'Coach C', 'Coach D'],
                onChanged: (value) {
                  setState(() {
                    _coachAssigned = value!;
                    _formChanged = true;
                  });
                },
              ),
              
              const Divider(height: 24),
              
              // Gym trainer assignment
              _buildStaffAssignmentRow(
                title: 'Gym Trainer',
                value: _gymTrainerAssigned,
                icon: Icons.fitness_center,
                color: Colors.orange.shade800,
                options: ['Trainer A', 'Trainer B', 'Trainer C', 'Trainer D'],
                onChanged: (value) {
                  setState(() {
                    _gymTrainerAssigned = value!;
                    _formChanged = true;
                  });
                },
              ),
              
              const Divider(height: 24),
              
              // Medical staff assignment
              _buildStaffAssignmentRow(
                title: 'Medical Staff',
                value: _medicalStaffAssigned,
                icon: Icons.medical_services,
                color: Colors.red.shade800,
                options: ['Medical Staff A', 'Medical Staff B', 'Medical Staff C', 'Medical Staff D'],
                onChanged: (value) {
                  setState(() {
                    _medicalStaffAssigned = value!;
                    _formChanged = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaffAssignmentRow({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select from available staff',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: DropdownButton<String>(
            value: value,
            icon: Icon(Icons.arrow_drop_down, color: color),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
            underline: Container(height: 0),
            onChanged: onChanged,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSportSelectionChip(String sport, IconData icon) {
    final isSelected = _primarySport == sport;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.deepPurple,
          ),
          const SizedBox(width: 6),
          Text(sport),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _primarySport = sport;
            if (_secondarySport == sport) {
              _secondarySport = null;
            }
            _formChanged = true;
          });
        }
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.deepPurple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.deepPurple,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 2 : 0,
      shadowColor: isSelected ? Colors.deepPurple.withOpacity(0.3) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.deepPurple.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPhysicalAttributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Physical Attributes', Icons.accessibility_new),
        
        // Height and weight in a row
        Row(
          children: [
            Expanded(
              child: _buildEnhancedFormField(
                controller: _heightController,
                labelText: 'Height (cm)',
                hintText: 'Enter height in cm',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                icon: Icons.height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedFormField(
                controller: _weightController,
                labelText: 'Weight (kg)',
                hintText: 'Enter weight in kg',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                icon: Icons.line_weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        
        // Blood group dropdown
        _buildEnhancedDropdown<String>(
          labelText: 'Blood Group',
          value: _bloodGroup,
          items: const [
            DropdownMenuItem(value: 'A+', child: Text('A+')),
            DropdownMenuItem(value: 'A-', child: Text('A-')),
            DropdownMenuItem(value: 'B+', child: Text('B+')),
            DropdownMenuItem(value: 'B-', child: Text('B-')),
            DropdownMenuItem(value: 'AB+', child: Text('AB+')),
            DropdownMenuItem(value: 'AB-', child: Text('AB-')),
            DropdownMenuItem(value: 'O+', child: Text('O+')),
            DropdownMenuItem(value: 'O-', child: Text('O-')),
          ],
          onChanged: (value) {
            setState(() {
              _bloodGroup = value!;
            });
          },
          validator: (value) => value == null ? 'Please select blood group' : null,
          icon: Icons.bloodtype,
        ),

        // Dominant hand/leg dropdown
        _buildEnhancedDropdown<String>(
          labelText: 'Dominant Hand/Leg',
          value: _dominantHandLeg,
          items: const [
            DropdownMenuItem(value: 'Right', child: Text('Right')),
            DropdownMenuItem(value: 'Left', child: Text('Left')),
            DropdownMenuItem(value: 'Ambidextrous', child: Text('Ambidextrous')),
          ],
          onChanged: (value) {
            setState(() {
              _dominantHandLeg = value!;
            });
          },
          validator: (value) => value == null ? 'Please select dominant hand/leg' : null,
          icon: Icons.front_hand,
        ),
        
        // Physical attributes visualization
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Physical Assessment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              
              // Mock radar chart for physical attributes
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.radar,
                        size: 48,
                        color: Colors.deepPurple.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Physical Attributes Visualization',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete the registration to generate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Physical attribute indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttributeIndicator('Speed', 0.0),
                  _buildAttributeIndicator('Strength', 0.0),
                  _buildAttributeIndicator('Stamina', 0.0),
                  _buildAttributeIndicator('Flexibility', 0.0),
                ],
              ),
            ],
          ),
        ),

        // Notes section
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'A detailed physical assessment will be conducted by the assigned trainer after registration. This will update the physical attribute indicators.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeIndicator(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              width: 50 * value,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'N/A',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalAndHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Medical & Health Information', Icons.medical_services),
        
        // Info card about medical info
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_information,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Please provide accurate medical information for safety purposes. This will be kept confidential.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Blood group info card
        _buildInfoCard(
          title: 'Blood Group',
          value: _bloodGroup,
          icon: Icons.bloodtype,
          backgroundColor: Colors.red.shade50,
          iconColor: Colors.red,
        ),
        
        // Allergies
        _buildEnhancedFormField(
          controller: _allergiesController,
          labelText: 'Allergies (if any)',
          hintText: 'List any allergies or sensitivities',
          validator: (value) => null, // Not mandatory
          icon: Icons.healing,
          maxLines: 2,
        ),
        
        // Medical conditions
        _buildEnhancedFormField(
          controller: _medicalConditionsController,
          labelText: 'Medical Conditions (if any)',
          hintText: 'List any relevant medical conditions',
          validator: (value) => null, // Not mandatory
          icon: Icons.health_and_safety,
          maxLines: 3,
        ),
        
        // Medical documents upload
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.upload_file, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    'Medical Documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload any relevant medical documents (optional)',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildMedicalDocumentUploadButton(
                title: 'Medical Certificate',
                description: 'General fitness certificate',
                icon: Icons.health_and_safety,
                onTap: () {
                  // Implement document upload
                },
              ),
              const SizedBox(height: 12),
              _buildMedicalDocumentUploadButton(
                title: 'Vaccination Records',
                description: 'Required for certain sports/events',
                icon: Icons.vaccines,
                onTap: () {
                  // Implement document upload
                },
              ),
              const SizedBox(height: 12),
              _buildMedicalDocumentUploadButton(
                title: 'Previous Injuries Report',
                description: 'If applicable',
                icon: Icons.healing,
                onTap: () {
                  // Implement document upload
                },
              ),
            ],
          ),
        ),
        
        // Emergency contact section
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEnhancedFormField(
                controller: TextEditingController(),
                labelText: 'Emergency Contact Name',
                hintText: 'Name of emergency contact person',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                icon: Icons.person_outline,
              ),
              _buildEnhancedFormField(
                controller: TextEditingController(),
                labelText: 'Emergency Contact Number',
                hintText: 'Phone number of emergency contact',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildEnhancedFormField(
                controller: TextEditingController(),
                labelText: 'Relationship to Player',
                hintText: 'E.g., Parent, Sibling, Guardian',
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                icon: Icons.family_restroom,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDocumentUploadButton({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Container(
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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.upload_file, size: 16),
          label: const Text('Upload', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formChanged) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('DISCARD'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
                appBar: AppBar(
          title: const Text('Register Player'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // Show help dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.sports_outlined, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        const Text('Player Registration Help'),
                      ],
                    ),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'This form allows you to register a new player with detailed information across multiple categories:',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          Text('• Personal Information - Basic details of the player',
                              style: TextStyle(fontSize: 13)),
                          Text('• Academic Details - School/college information',
                              style: TextStyle(fontSize: 13)),
                          Text('• Sports Information - Primary sport and skills',
                              style: TextStyle(fontSize: 13)),
                          Text('• Physical Attributes - Height, weight, etc.',
                              style: TextStyle(fontSize: 13)),
                          Text('• Medical Information - Health records and contacts',
                              style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                        ),
                        child: const Text('GOT IT'),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_formChanged)
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset form',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset form?'),
                      content: const Text(
                          'This will clear all entered information. Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetForm();
                          },
                          child: const Text('RESET'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        drawer: CustomDrawer(
          selectedDrawerItem: registerPlayerRoute,
          onSelectDrawerItem: (route) {
            Navigator.pop(context); // Close the drawer
            if (_formChanged) {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text(
                      'You have unsaved changes. Are you sure you want to navigate away?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, route);
                      },
                      child: const Text('DISCARD'),
                    ),
                  ],
                ),
              );
            } else if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.pushNamed(context, route);
            }
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
            DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
          ],
          onLogout: () {
            // Implement logout functionality
          },
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade100, Colors.white],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Enhanced Section Navigation
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.app_registration,
                              color: Colors.deepPurple,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'New Player Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.sports, color: Colors.green, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  _primarySport,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Scrollable section tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSectionTitle('Personal', 0),
                            _buildSectionTitle('Academic', 1),
                            _buildSectionTitle('Sports', 2),
                            _buildSectionTitle('Physical', 3),
                            _buildSectionTitle('Medical', 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Section content with better styling
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: _buildSectionContent(),
                      ),
                    ),
                  ),
                ),
                
                // Navigation and Submit Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentSectionIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentSectionIndex--;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (_currentSectionIndex > 0)
                        const SizedBox(width: 16),
                      Expanded(
                        child: _currentSectionIndex < 4
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentSectionIndex++;
                                  });
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    _showSuccessPopup();
                                  }
                                },
                                icon: _isSubmitting
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(2),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle),
                                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Registration'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.green.withOpacity(0.5),
                                ),
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _schoolController.dispose();
    _studentIdController.dispose();
    _organizationEmailController.dispose();
    _organizationWebsiteController.dispose();
    _playingPositionController.dispose();
    _trainingStartDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }
}