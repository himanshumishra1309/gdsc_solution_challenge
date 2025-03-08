import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';
import 'landing_page_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrganizationRegistrationView extends StatefulWidget {
  const OrganizationRegistrationView({super.key});

  @override
  _OrganizationRegistrationViewState createState() => _OrganizationRegistrationViewState();
}

class _OrganizationRegistrationViewState extends State<OrganizationRegistrationView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Form controllers
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _organizationEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();
  final TextEditingController _adminAccountController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  List<String> certificateTypes = [
    'Business Registration',
    'Tax Certificate',
    'Non-profit Status',
    'Sports Association Membership',
    'Other'
  ];
  String selectedCertificate = 'Business Registration';
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _organizationEmailController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _certificateController.dispose();
    _adminAccountController.dispose();
    _adminPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate network delay for API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Process registration logic would go here
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Registration Successful'),
            ],
          ),
          content: Text('Your organization has been registered successfully. Please check your email for verification.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, landingPageRoute);
              },
              child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPageView()),
        );
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lgin.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.deepPurple.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom app bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LandingPageView()),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Organization Registration',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (_currentStep + 1) / 3,
                              backgroundColor: Colors.white30,
                              color: Colors.white,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Step ${_currentStep + 1} of 3",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Text(
                                _currentStep == 0
                                    ? 'Organization Information'
                                    : _currentStep == 1
                                        ? 'Location & Certification'
                                        : 'Admin Account Setup',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              
                              SizedBox(height: 8),
                              
                              Text(
                                _currentStep == 0
                                    ? 'Please enter your organization details'
                                    : _currentStep == 1
                                        ? 'Provide location and certification information'
                                        : 'Create admin account for organization management',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              
                              SizedBox(height: 32),
                              
                              // Step 1: Organization Information
                              if (_currentStep == 0) ...[
                                _buildInputField(
                                  controller: _organizationNameController,
                                  label: 'Organization Name',
                                  icon: Icons.business,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the name of the organization';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                _buildInputField(
                                  controller: _organizationEmailController,
                                  label: 'Organization Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter email';
                                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.upload_file,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Organization Logo',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Upload your organization logo (optional)',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Handle upload
                                        },
                                        icon: Icon(Icons.add_circle, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Step 2: Location & Certification
                              if (_currentStep == 1) ...[
                                _buildInputField(
                                  controller: _addressController,
                                  label: 'Address',
                                  icon: Icons.location_on_outlined,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the address';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        controller: _stateController,
                                        label: 'State/Province',
                                        icon: Icons.map_outlined,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter state';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        controller: _countryController,
                                        label: 'Country',
                                        icon: Icons.public,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter country';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                
                                SizedBox(height: 20),
                                
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCertificate,
                                      dropdownColor: Colors.deepPurple[800],
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                      style: TextStyle(color: Colors.white),
                                      items: certificateTypes.map((String item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified_outlined, color: Colors.white70, size: 20),
                                              SizedBox(width: 12),
                                              Text(item),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      hint: Text(
                                        'Certificate Type',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCertificate = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 20),
                                
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.file_present_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Upload Certificate',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'PDF, JPG or PNG (max 5MB)',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Handle upload
                                        },
                                        icon: Icon(Icons.add_circle, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Step 3: Admin Account
                              if (_currentStep == 2) ...[
                                _buildInputField(
                                  controller: _adminAccountController,
                                  label: 'Admin Username',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter admin username';
                                    } else if (value.length < 4) {
                                      return 'Username must be at least 4 characters';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                _buildInputField(
                                  controller: _adminPasswordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                _buildInputField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm password';
                                    } else if (value != _adminPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 32),
                                
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'This admin account will have full access to manage your organization, teams, and players.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: 20),
                                
                                Row(
                                  children: [
                                    Checkbox(
                                      value: true,
                                      onChanged: (value) {},
                                      fillColor: MaterialStateProperty.all(Colors.deepPurple[400]),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              SizedBox(height: 40),
                              
                              // Navigation buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_currentStep > 0)
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _currentStep--;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(color: Colors.white),
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.arrow_back, size: 20),
                                          SizedBox(width: 8),
                                          Text('Previous'),
                                        ],
                                      ),
                                    )
                                  else
                                    SizedBox(width: 40), // Empty space for alignment
                                  
                                  if (_currentStep < 2)
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            _currentStep++;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple[400],
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.deepPurple.withOpacity(0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Continue'),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 20),
                                        ],
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _submitRegistration,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple[400],
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.deepPurple.withOpacity(0.5),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Register'),
                                                SizedBox(width: 8),
                                                Icon(Icons.check_circle, size: 20),
                                              ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        errorStyle: TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}