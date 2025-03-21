import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/serivces/coach_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gdg_app/constants/api_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:gdg_app/serivces/admin_services.dart';
import 'dart:math';
import 'package:gdg_app/serivces/admin_services.dart';

class AdminRegisterCoachView extends StatefulWidget {
  const AdminRegisterCoachView({super.key});

  @override
  _AdminRegisterCoachViewState createState() => _AdminRegisterCoachViewState();
}

class _AdminRegisterCoachViewState extends State<AdminRegisterCoachView> {
  final AdminService _adminService = AdminService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _previousOrganizationsController = TextEditingController();
  
  String _selectedDesignation = 'Assistant Coach';
  final List<String> _designations = [
    'Head Coach', 
    'Assistant Coach', 
    'Athletes',
    'Training and Conditioning Staff'
  ];
  
  String _selectedSport = 'Cricket';
  final List<String> _sports = [
    'Cricket', 
    'Football', 
    'Badminton', 
    'Basketball', 
    'Tennis', 
    'Hockey', 
    'Other'
  ];
  
  final List<String> _genders = ['Male', 'Female', 'Other'];
  bool _agreeToTerms = false;
  
  File? _profilePhotoFile;
  File? _idProofFile;
  File? _certificatesFile;
  String? _profilePhotoPath;
  String? _idProofPath;
  String? _certificatesPath;
  
  final CoachService _coachService = CoachService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _organizationId;

  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadOrganizationId();
  }

  Future<void> _loadUserInfo() async {
  try {
    final userData = await _authService.getCurrentUser();
    
    if (userData.isNotEmpty) {
      setState(() {
        _userName = userData['name'] ?? "Admin";
        _userEmail = userData['email'] ?? "";
        _userAvatar = userData['avatar'];
      });
    }
  } catch (e) {
    debugPrint('Error loading user info: $e');
  }
}

  Future<void> _loadOrganizationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? orgId = prefs.getString('organizationId');
      
      if (orgId != null) {
        setState(() {
          _organizationId = orgId;
        });
        print('Organization ID loaded: $_organizationId');
      } else {
        print('Organization ID not found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading organization ID: $e');
    }
  }

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
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _profilePhotoFile = File(image.path);
        _profilePhotoPath = image.name;
      });
    }
  }
  
  Future<void> _pickIdProof() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (file != null) {
      setState(() {
        _idProofFile = File(file.path);
        _idProofPath = file.name;
      });
    }
  }
  
  Future<void> _pickCertificates() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (file != null) {
      setState(() {
        _certificatesFile = File(file.path);
        _certificatesPath = file.name;
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
                      _cityController.clear();
                      _pincodeController.clear();
                      _addressController.clear();
                      _passwordController.clear();
                      _experienceController.clear();
                      _certificationsController.clear();
                      _previousOrganizationsController.clear();
                      setState(() {
                        _agreeToTerms = false;
                        _profilePhotoPath = null;
                        _profilePhotoFile = null;
                        _idProofPath = null;
                        _idProofFile = null;
                        _certificatesPath = null;
                        _certificatesFile = null;
                        _genderController.text = '';
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

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    // If user confirmed logout
    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          );
        },
      );
      
      try {
        // First clear local data directly
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Then try server-side logout, but don't block on it
        _authService.logout().catchError((e) {
          print('Server logout error: $e');
        });
        
        // Navigate to login page
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushNamedAndRemoveUntil(
            context,
            loginRoute, // Updated to use login route
            (route) => false, // This clears the navigation stack
          );
        }
      } catch (e) {
        // Handle errors
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Updated method to register coach directly using http to match controller exactly
  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use AdminService instead of direct HTTP implementation
      final result = await _adminService.registerCoach(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        dob: _dobController.text,
        gender: _genderController.text,
        nationality: _nationalityController.text,
        contactNumber: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        pincode: _pincodeController.text,
        sport: _selectedSport,
        experience: _experienceController.text,
        certifications: _certificationsController.text,
        previousOrganizations: _previousOrganizationsController.text,
        designation: _selectedDesignation,
        profilePhoto: _profilePhotoFile,
        idProof: _idProofFile, 
        certificatesFile: _certificatesFile,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        // Show success dialog
        _showSuccessDialog();
        
        // Reset form fields
        _nameController.clear();
        _emailController.clear();
        _dobController.clear();
        _genderController.clear();
        _nationalityController.clear();
        _phoneController.clear();
        _countryController.clear();
        _stateController.clear();
        _cityController.clear();
        _pincodeController.clear();
        _addressController.clear();
        _passwordController.clear();
        _experienceController.clear();
        _certificationsController.clear();
        _previousOrganizationsController.clear();
        
        setState(() {
          _agreeToTerms = false;
          _profilePhotoPath = null;
          _profilePhotoFile = null;
          _idProofPath = null;
          _idProofFile = null;
          _certificatesPath = null;
          _certificatesFile = null;
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: Colors.deepPurple),
            SizedBox(width: 10),
            Text('Coach Registration Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('Personal Information', 'Enter coach\'s name, date of birth, and gender'),
            _buildHelpItem('Contact Details', 'Add valid email and phone number for notifications'),
            _buildHelpItem('Address', 'Complete address information for official records'),
            _buildHelpItem('Professional Details', 'Select sport and add experience details'),
            _buildHelpItem('Documents', 'Upload clear images of required documents'),
            _buildHelpItem('Terms', 'Read and accept terms of service before submission'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
            child: const Text('Got it'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
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
           
          DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
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
                            // Organization ID display
                            if (_organizationId != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.business, color: Colors.deepPurple),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Organization ID: $_organizationId',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
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
                                    items: _genders,
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
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter the phone number';
                                } else if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                                  return 'Please enter a valid 10-digit number';
                                }
                                return null;
                              },
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              hintText: '10-digit number',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _passwordController,
                              labelText: 'Password',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a password';
                                } else if (value!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              icon: Icons.lock,
                              obscureText: true,
                              hintText: 'At least 6 characters',
                            ),
                            
                            const SizedBox(height: 20),
                            _buildSectionHeader('Address Information', Icons.location_on),
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _addressController,
                              labelText: 'Street Address',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter the address' : null,
                              icon: Icons.home,
                              maxLines: 2,
                              hintText: 'Street address, Landmark',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _cityController,
                                    labelText: 'City',
                                    validator: (value) => null,  // Optional
                                    icon: Icons.location_city,
                                    hintText: 'City name',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _pincodeController,
                                    labelText: 'Pincode',
                                    validator: (value) => null,  // Optional
                                    icon: Icons.pin_drop,
                                    hintText: 'e.g. 600001',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _stateController,
                                    labelText: 'State',
                                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    icon: Icons.location_city,
                                    hintText: 'e.g. Tamil Nadu',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEnhancedFormField(
                                    controller: _countryController,
                                    labelText: 'Country',
                                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    icon: Icons.public,
                                    hintText: 'e.g. India',
                                  ),
                                ),
                              ],
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
                            
                            // Sport selection
                            _buildDropdownField(
                              labelText: 'Sport',
                              icon: Icons.sports_baseball,
                              value: _selectedSport,
                              items: _sports,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSport = value!;
                                });
                              },
                              validator: (value) => value == null ? 'Please select a sport' : null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Designation selection
                            _buildDropdownField(
                              labelText: 'Designation',
                              icon: Icons.badge,
                              value: _selectedDesignation,
                              items: _designations,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDesignation = value!;
                                });
                              },
                              validator: (value) => value == null ? 'Please select designation' : null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _experienceController,
                              labelText: 'Years of Experience',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter years of experience' : null,
                              icon: Icons.timeline,
                              keyboardType: TextInputType.number,
                              hintText: 'e.g. 5',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _certificationsController,
                              labelText: 'Certifications',
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter certifications' : null,
                              icon: Icons.card_membership,
                              hintText: 'e.g. Level 1, First Aid (comma separated)',
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildEnhancedFormField(
                              controller: _previousOrganizationsController,
                              labelText: 'Previous Organizations (Optional)',
                              validator: (value) => null, // Optional field
                              icon: Icons.business,
                              hintText: 'e.g. Gujarat Cricket, Mumbai Indians (comma separated)',
                            ),
                            
                            const SizedBox(height: 20),
                            _buildSectionHeader('Document Upload', Icons.upload_file),
                            const SizedBox(height: 16),
                            
                            // Profile photo upload
                            _buildFileUploadField(
                              label: 'Profile Photo',
                              icon: Icons.photo_camera,
                              fileName: _profilePhotoPath,
                              onTap: _pickProfilePhoto,
                              validator: (_) => _profilePhotoFile == null ? 'Please upload a profile photo' : null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ID proof upload
                            _buildFileUploadField(
                              label: 'ID Proof',
                              icon: Icons.assignment_ind,
                              fileName: _idProofPath,
                              onTap: _pickIdProof,
                              validator: (_) => _idProofFile == null ? 'Please upload an ID proof' : null,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Certificates upload
                            _buildFileUploadField(
                              label: 'Certificates',
                              icon: Icons.cloud_upload,
                              fileName: _certificatesPath,
                              onTap: _pickCertificates,
                              validator: (_) => _certificatesFile == null ? 'Please upload certificates' : null,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Terms and conditions checkbox
                            FormField<bool>(
                              initialValue: _agreeToTerms,
                              validator: (value) {
                                if (value != true) {
                                  return 'You must accept the terms and conditions';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _agreeToTerms,
                                          activeColor: Colors.deepPurple,
                                          onChanged: (value) {
                                            setState(() {
                                              _agreeToTerms = value!;
                                              field.didChange(value);
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'I agree to the ',
                                              style: TextStyle(color: Colors.grey.shade700),
                                              children: [
                                                TextSpan(
                                                  text: 'Terms of Service',
                                                  style: const TextStyle(
                                                    color: Colors.deepPurple,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      // Show terms dialog
                                                    },
                                                ),
                                                const TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: 'Privacy Policy',
                                                  style: const TextStyle(
                                                    color: Colors.deepPurple,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      // Show privacy policy dialog
                                                    },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (field.errorText != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12, top: 5),
                                        child: Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Register Coach',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFormField({
    required TextEditingController controller,
    required String labelText,
    required FormFieldValidator<String> validator,
    required IconData icon,
    String hintText = '',
    bool isDateField = false,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: isDateField,
      onTap: isDateField ? () => _selectDate(context) : null,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFileUploadField({
    required String label,
    required IconData icon,
    required String? fileName,
    required VoidCallback onTap,
    required FormFieldValidator<String?> validator,
  }) {
    return FormField<String>(
      validator: validator,
      initialValue: fileName,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError ? Colors.red.shade400 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.deepPurple.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName ?? 'No file selected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: fileName != null ? FontWeight.w500 : FontWeight.normal,
                              color: fileName != null ? Colors.deepPurple : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.upload_file, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 5),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
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
    _cityController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _previousOrganizationsController.dispose();
    super.dispose();
  }
}