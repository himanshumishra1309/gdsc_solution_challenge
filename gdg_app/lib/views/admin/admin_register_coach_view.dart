import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminRegisterCoachView extends StatefulWidget {
  const AdminRegisterCoachView({super.key});

  @override
  _AdminRegisterCoachViewState createState() => _AdminRegisterCoachViewState();
}

class _AdminRegisterCoachViewState extends State<AdminRegisterCoachView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _previousOrganizationsController = TextEditingController();
  
  // Add new controller for sport selection
  String _selectedSport = 'Cricket';
  final List<String> _sports = ['Cricket', 'Football', 'Badminton', 'Basketball'];
  bool _agreeToTerms = false;
  
  // File placeholders
  String? _profilePhotoPath;
  String? _idProofPath;
  String? _certificatesPath;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default to age 25
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Coach registration completed successfully.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Clear form fields
                      _nameController.clear();
                      _emailController.clear();
                      _dobController.clear();
                      _genderController.clear();
                      _nationalityController.clear();
                      _phoneController.clear();
                      _countryController.clear();
                      _stateController.clear();
                      _addressController.clear();
                      _experienceController.clear();
                      _certificationsController.clear();
                      _previousOrganizationsController.clear();
                      setState(() {
                        _agreeToTerms = false;
                        _profilePhotoPath = null;
                        _idProofPath = null;
                        _certificatesPath = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Coach'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: registerCoachRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
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
        onLogout: () => _handleLogout(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coach Registration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Please fill in all the required information',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Form Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form Section Headers
                            _buildSectionHeader('Personal Information', Icons.person_outline),
                            
                            const SizedBox(height: 16),
                            
                            // Personal Information Fields
                            _buildEnhancedFormField(
                              controller: _nameController,
                              labelText: 'Full Name',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter the full name' : null,
                              icon: Icons.person,
                              hintText: 'Enter full name as per ID',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Two fields in one row - DOB and Gender
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _dobController,
                                    labelText: 'Date of Birth',
                                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    icon: Icons.calendar_today,
                                    isDateField: true,
                                    hintText: 'YYYY-MM-DD',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    labelText: 'Gender',
                                    icon: Icons.person_outline,
                                    value: _genderController.text.isEmpty ? null : _genderController.text,
                                    items: ['Male', 'Female', 'Other'],
                                    onChanged: (value) {
                                      setState(() {
                                        _genderController.text = value!;
                                      });
                                    },
                                    validator: (value) => value == null ? 'Please select gender' : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            _buildSectionHeader('Contact Details', Icons.contact_phone),
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _emailController,
                              labelText: 'Email Address',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter the email address';
                                } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'coach@example.com',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _phoneController,
                              labelText: 'Phone Number',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter the phone number' : null,
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              hintText: 'XXXXX XXXXX',
                              prefixText: '+91 ',
                            ),
                            
                            const SizedBox(height: 20),
                            _buildSectionHeader('Address Information', Icons.location_on),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _countryController,
                                    labelText: 'Country',
                                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    icon: Icons.public,
                                    hintText: 'India',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _stateController,
                                    labelText: 'State',
                                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    icon: Icons.location_city,
                                    hintText: 'e.g. Tamil Nadu',
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _addressController,
                              labelText: 'Address',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter the address' : null,
                              icon: Icons.home,
                              maxLines: 2,
                              hintText: 'Street address, Landmark, City, Pincode',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _nationalityController,
                              labelText: 'Nationality',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter the nationality' : null,
                              icon: Icons.flag,
                              hintText: 'e.g. Indian',
                            ),
                            
                            const SizedBox(height: 20),
                            _buildSectionHeader('Professional Details', Icons.work),
                            const SizedBox(height: 16),
                            
                            // Sport Selection with enhanced dropdown
                            _buildDropdownField(
                              labelText: 'Primary Sport',
                              icon: Icons.sports,
                              value: _selectedSport,
                              items: _sports,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSport = value!;
                                });
                              },
                              validator: (value) => null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _experienceController,
                              labelText: 'Years of Experience',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter years of experience' : null,
                              icon: Icons.timer,
                              keyboardType: TextInputType.number,
                              hintText: 'e.g. 5',
                              suffixText: 'years',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _certificationsController,
                              labelText: 'Certifications & Licenses',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter certifications' : null,
                              icon: Icons.badge,
                              maxLines: 3,
                              hintText: 'List all relevant certifications and licenses',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _previousOrganizationsController,
                              labelText: 'Previous Coaching Organizations',
                              validator: (value) => value?.isEmpty ?? true ? 'Please list previous organizations' : null,
                              icon: Icons.business,
                              maxLines: 3,
                              hintText: 'List previous coaching roles and organizations',
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // File Upload Section
                            _buildSectionHeader('Documents', Icons.file_present),
                            const SizedBox(height: 10),
                            
                            _buildFileUploadButton(
                              'Upload Profile Photo',
                              Icons.photo_camera,
                              Colors.blue,
                              _profilePhotoPath,
                              () {
                                // Simulate file selection
                                setState(() {
                                  _profilePhotoPath = 'profile_photo.jpg';
                                });
                              },
                            ),
                            
                            const SizedBox(height: 10),
                            
                            _buildFileUploadButton(
                              'Upload ID Proof',
                              Icons.badge,
                              Colors.green,
                              _idProofPath,
                              () {
                                // Simulate file selection
                                setState(() {
                                  _idProofPath = 'id_proof.pdf';
                                });
                              },
                            ),
                            
                            const SizedBox(height: 10),
                            
                            _buildFileUploadButton(
                              'Upload Certificates',
                              Icons.file_copy,
                              Colors.orange,
                              _certificatesPath,
                              () {
                                // Simulate file selection
                                setState(() {
                                  _certificatesPath = 'certificates.zip';
                                });
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Terms and Conditions Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  activeColor: Colors.deepPurple,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                      children: [
                                        const TextSpan(
                                          text: 'I agree to the ',
                                        ),
                                        TextSpan(
                                          text: 'Terms of Service',
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Show terms of service
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Terms of Service'),
                                                  backgroundColor: Colors.deepPurple,
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(
                                          text: ' and ',
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: const TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // Show privacy policy
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Privacy Policy'),
                                                  backgroundColor: Colors.deepPurple,
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Register Button
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !_agreeToTerms ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _showSuccessDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register Coach', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced form field widget with better styling
  Widget _buildEnhancedFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    IconData? icon,
    bool isDateField = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    String? prefixText,
    String? suffixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixText: prefixText,
          suffixText: suffixText,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        readOnly: isDateField,
        onTap: isDateField ? () => _selectDate(context) : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  // Section header widget
  Widget _buildSectionHeader(String title, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.deepPurple,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  // Dropdown field widget
  Widget _buildDropdownField({
    required String labelText,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.deepPurple, size: 20),
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
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  // File upload button widget
  Widget _buildFileUploadButton(String label, IconData icon, Color color, String? filePath, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  filePath ?? 'No file selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: filePath != null ? color : Colors.grey.shade600,
                    fontWeight: filePath != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(filePath != null ? 'Change' : 'Browse'),
          ),
        ],
      ),
    );
  }

  // Help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        Icons.help_outline,
                        color: Colors.deepPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Coach Registration Help',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'This form allows you to register a new coach in the system. Make sure to fill out all required fields accurately.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Required Documents:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildHelpBulletPoint('A recent photograph of the coach'),
                      _buildHelpBulletPoint('Valid ID proof (Passport, Aadhar, etc.)'),
                      _buildHelpBulletPoint('Copies of relevant certifications'),
                      _buildHelpBulletPoint('Previous experience documentation if available'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Help bullet point
  Widget _buildHelpBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Handle will pop to confirm before leaving
  Future<bool> _onWillPop() async {
    if (_formHasChanges()) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('YES, LEAVE'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  // Check if form has any changes
  bool _formHasChanges() {
    return _nameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _dobController.text.isNotEmpty ||
        _genderController.text.isNotEmpty ||
        _nationalityController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _countryController.text.isNotEmpty ||
        _stateController.text.isNotEmpty ||
        _addressController.text.isNotEmpty ||
        _experienceController.text.isNotEmpty ||
        _certificationsController.text.isNotEmpty ||
        _previousOrganizationsController.text.isNotEmpty ||
        _profilePhotoPath != null ||
        _idProofPath != null ||
        _certificatesPath != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _nationalityController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _previousOrganizationsController.dispose();
    super.dispose();
  }
}