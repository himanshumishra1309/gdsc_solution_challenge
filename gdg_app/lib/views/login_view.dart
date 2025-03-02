import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';

class LoginView extends StatefulWidget {
  final String sourcePage;

  const LoginView({super.key, required this.sourcePage});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Perform login logic here

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
      Navigator.pushReplacementNamed(context, playerProfileRoute);
    } else if (widget.sourcePage == 'sponsorRegister') {
      Navigator.pushReplacementNamed(context, sponsorHomeViewRoute);
    } else {
      // Default navigation
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, landingPageRoute);
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Colors.deepPurple,
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          toolbarHeight: 65.0,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lgin.jpg'), // Ensure you have this image in your assets folder
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Transparent background with very low opacity
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              textStyle: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            child: Text('Login',
                            style: TextStyle(color: Colors.white),
                            ),
                          ),
                          if (widget.sourcePage != 'coachHome' && widget.sourcePage !='playerHome' && widget.sourcePage !='adminHome') ...[
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, individualRegisterRoute);
                              },
                              child: Text(
                                "Don't have an account? Register yourself",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
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
    );
  }
}