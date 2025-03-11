import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/views/login_view.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SponsorRegisterView extends StatefulWidget {
  const SponsorRegisterView({super.key});

  @override
  State<SponsorRegisterView> createState() => _SponsorRegisterViewState();
}

class _SponsorRegisterViewState extends State<SponsorRegisterView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _contactNo;
  late final TextEditingController _dob;
  late final TextEditingController _address;
  late final TextEditingController _password;
  late final TextEditingController _companyName;
  
  String? _selectedState;
  List<String> _states = [];
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  
  // Sponsorship range
  double _minSponsorAmount = 10000;
  double _maxSponsorAmount = 50000;
  
  // For profile image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _contactNo = TextEditingController();
    _dob = TextEditingController();
    _address = TextEditingController();
    _password = TextEditingController();
    _companyName = TextEditingController();
    _loadStates();
  }

  Future<void> _loadStates() async {
    final String response = await rootBundle.loadString('assets/json_files/states.json');
    final data = await json.decode(response);
    setState(() {
      _states = List<String>.from(data['states']);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _contactNo.dispose();
    _dob.dispose();
    _address.dispose();
    _password.dispose();
    _companyName.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _profileImage = File(photo.path);
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Profile Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.photo_library, color: Colors.amber),
                          onPressed: () {
                            _pickImage();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Gallery", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.amber),
                          onPressed: () {
                            _takePhoto();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text("Camera", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // Default to 30 years ago
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.amber, // header background color
              onPrimary: Colors.black87, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a profile photo'))
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      setState(() {
        _isSubmitting = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! You can now login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Navigate to login page after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, loginRoute);
      });
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLeave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Registration?'),
        content: const Text('Your progress will not be saved. Are you sure you want to leave?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
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

    if (shouldLeave) {
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }

    return false; // Prevent default back button behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _onWillPop(context),
          ),
        ),
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/sponsor_bg.jpg'), // Use sponsor-specific image
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
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
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // Header section
                          const Text(
                            'SPONSOR REGISTRATION',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join GDG Sports as a valued sponsor',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Registration form card
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Profile Photo Upload
                                          Center(
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: _showImageSourceActionSheet,
                                                  child: CircleAvatar(
                                                    radius: 50,
                                                    backgroundColor: Colors.white.withOpacity(0.3),
                                                    backgroundImage: _profileImage != null 
                                                        ? FileImage(_profileImage!) 
                                                        : null,
                                                    child: _profileImage == null 
                                                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Upload Profile Photo',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          
                                          _buildSectionTitle('Personal Information'),
                                          const SizedBox(height: 16),
                                          
                                          // Name field
                                          _buildTextFormField(
                                            controller: _name,
                                            labelText: 'Representative Name',
                                            prefixIcon: Icons.person_outline,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Email field
                                          _buildTextFormField(
                                            controller: _email,
                                            labelText: 'Email Address',
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Contact Number field
                                          _buildTextFormField(
                                            controller: _contactNo,
                                            labelText: 'Contact Number',
                                            prefixIcon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your contact number';
                                              }
                                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                                return 'Please enter a valid 10-digit number';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Date of birth field
                                          _buildDateField(
                                            context: context,
                                            controller: _dob,
                                            labelText: 'Date of Birth',
                                            prefixIcon: Icons.cake_outlined,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please select your date of birth';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Password field
                                          _buildPasswordField(
                                            controller: _password,
                                            labelText: 'Password',
                                            prefixIcon: Icons.lock_outline,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter a password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          
                                          _buildSectionTitle('Company Information'),
                                          const SizedBox(height: 16),
                                          
                                          // Company name field
                                          _buildTextFormField(
                                            controller: _companyName,
                                            labelText: 'Company Name',
                                            prefixIcon: Icons.business_outlined,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your company name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Address field
                                          _buildTextFormField(
                                            controller: _address,
                                            labelText: 'Company Address',
                                            prefixIcon: Icons.location_city_outlined,
                                            maxLines: 2,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your company address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // State dropdown
                                          _buildStateDropdown(),
                                          const SizedBox(height: 24),
                                          
                                          _buildSectionTitle('Sponsorship Range'),
                                          const SizedBox(height: 16),
                                          
                                          // Sponsorship range slider
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '₹${_minSponsorAmount.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.9),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_maxSponsorAmount.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.9),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RangeSlider(
                                                values: RangeValues(_minSponsorAmount, _maxSponsorAmount),
                                                min: 1000,
                                                max: 1000000,
                                                divisions: 100,
                                                activeColor: Colors.amber,
                                                inactiveColor: Colors.amber.withOpacity(0.2),
                                                labels: RangeLabels(
                                                  '₹${_minSponsorAmount.toStringAsFixed(0)}',
                                                  '₹${_maxSponsorAmount.toStringAsFixed(0)}'
                                                ),
                                                onChanged: (RangeValues values) {
                                                  setState(() {
                                                    _minSponsorAmount = values.start;
                                                    _maxSponsorAmount = values.end;
                                                  });
                                                },
                                              ),
                                              Text(
                                                'Sponsorship Range: ₹${_minSponsorAmount.toStringAsFixed(0)} - ₹${_maxSponsorAmount.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 32),
                                          
                                          // Register button
                                          _buildRegisterButton(),
                                          const SizedBox(height: 20),
                                          
                                          // Login link
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(context, loginRoute);
                                              },
                                              icon: const Icon(Icons.login, size: 18, color: Colors.white),
                                              label: const Text(
                                                "Already Registered? Login",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    bool _obscureText = true;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
            prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        );
      }
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7)),
          onPressed: () => _selectDate(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  Widget _buildStateDropdown() {
    return DropdownSearch<String>(
      items: _states,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "State",
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 300),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelText: 'Search State',
            filled: true,
          ),
        ),
        menuProps: MenuProps(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _selectedState = value;
        });
      },
      selectedItem: _selectedState,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a state';
        }
        return null;
      },
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? 'Select State',
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.amber.shade700.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'REGISTER AS SPONSOR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}