import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gdg_app/serivces/auth_service.dart';

class LoginView extends StatefulWidget {
  final String sourcePage;

  const LoginView({super.key, required this.sourcePage});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  final AuthService _authService = AuthService(); // Add auth service instance
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    
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
    _email.dispose();
    _password.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Modified login handler to work with the auth service
  void _handleLogin() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Determine user type from source page
      final userType = _authService.getUserTypeFromSourcePage(widget.sourcePage);
      
      // Call login service
      final result = await _authService.login(
        email: _email.text.trim(),
        password: _password.text,
        userType: userType,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (result['success']) {
          _navigateToHomePage();
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Login failed. Please check your credentials.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
      print('Login error: $e');
    }
  }

  // Navigate based on user type
  void _navigateToHomePage() {
    // Navigate to different pages based on the sourcePage
    if (widget.sourcePage == 'individualRegister') {
      Navigator.pushReplacementNamed(context, individualHomeRoute);
    } else if (widget.sourcePage == 'landingPage') {
      Navigator.pushReplacementNamed(context, landingPageRoute);
    } else if (widget.sourcePage == 'coachHome') {
      Navigator.pushReplacementNamed(context, coachHomeRoute);
    } else if (widget.sourcePage == 'adminHome') {
      Navigator.pushReplacementNamed(context, adminHomeRoute);
    } else if (widget.sourcePage == 'playerHome') {
      Navigator.pushReplacementNamed(context, playerHomeRoute);
    } else if (widget.sourcePage == 'sponsorRegister') {
      Navigator.pushReplacementNamed(context, sponsorHomeViewRoute);
    } else {
      // Default navigation
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, landingPageRoute);
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background image with gradient overlay
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
              child: SingleChildScrollView(
                child: Container(
                  height: size.height - MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      // App bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, landingPageRoute);
                              },
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Logo space
                      SizedBox(height: size.height * 0.08),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            Icons.sports_basketball,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _getUserTypeTitle(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Login form
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Error message if login fails
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      border: Border.all(color: Colors.red.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                
                                // Email field
                                TextFormField(
                                  controller: _email,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
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
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                  ),
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
                                
                                SizedBox(height: 20),
                                
                                // Password field
                                TextFormField(
                                  controller: _password,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
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
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(color: Colors.red.shade300),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                
                                SizedBox(height: 12),
                                
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Handle forgot password
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                SizedBox(height: 30),
                                
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                      shadowColor: Colors.deepPurple.withOpacity(0.5),
                                      disabledBackgroundColor: Colors.deepPurple.withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            )
                                          )
                                        : Text(
                                            'LOGIN',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                if (widget.sourcePage != 'coachHome' && 
                                    widget.sourcePage != 'playerHome' && 
                                    widget.sourcePage != 'adminHome') ...[
                                  SizedBox(height: 30),
                                  
                                  // Register option
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account?",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (widget.sourcePage == 'sponsorRegister') {
                                            Navigator.pushReplacementNamed(context, sponsorRegisterViewRoute);
                                          } else {
                                            Navigator.pushReplacementNamed(context, individualRegisterRoute);
                                          }
                                        },
                                        child: Text(
                                          'Register',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get a user-friendly title based on source page
  String _getUserTypeTitle() {
    switch (widget.sourcePage) {
      case 'adminHome':
        return 'Sign in as Admin';
      case 'coachHome':
        return 'Sign in as Coach';
      case 'playerHome':
        return 'Sign in as Player';
      case 'sponsorRegister':
        return 'Sign in as Sponsor';
      case 'individualRegister':
        return 'Sign in as Individual Athlete';
      default:
        return 'Sign in to continue';
    }
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}