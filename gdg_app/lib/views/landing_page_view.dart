import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/popups/alert_message.dart'; // Import the alert message

class LandingPageView extends StatelessWidget {
  const LandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Perform any additional actions here if needed
        return true; // Return true to allow the back button press
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Athlete Management'),
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false, // Hide the back button
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
                  image: AssetImage('assets/images/signupimages.jpg'), // Ensure you have this image in your assets folder
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
                      padding: const EdgeInsets.all(50.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Transparent background with very low opacity
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 20,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome!',
                            style: TextStyle(
                              fontFamily: 'Schyler',
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please select your role',
                            style: TextStyle(
                              fontFamily: 'Schyler',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 36),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                loginRoute,
                                arguments: 'individualRegister',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                              textStyle: TextStyle(fontSize: 20),
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return 10;
                                  }
                                  return 5;
                                },
                              ),
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.deepPurpleAccent;
                                  }
                                  return Colors.deepPurple;
                                },
                              ),
                            ),
                            child: Text(
                              'Individual',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              AlertMessage.showAlert(
                                context,
                                message: 'Which organization?',
                                options: [
                                  AlertOption(
                                    label: 'New Organization',
                                    onPressed: () {
                                      Navigator.of(context).pushReplacementNamed(organizationRegistrationViewRoute);
                                      print('New Organization selected');
                                    },
                                  ),
                                  AlertOption(
                                    label: 'Existing Organization',
                                    onPressed: () {
                                      Navigator.of(context).pushReplacementNamed(coachAdminPlayerRoute);
                                      print('Existing Organization selected');
                                    },
                                  ),
                                ],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: 42, vertical: 16),
                              textStyle: TextStyle(fontSize: 20),
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return 10;
                                  }
                                  return 5;
                                },
                              ),
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.deepPurpleAccent;
                                  }
                                  return Colors.deepPurple;
                                },
                              ),
                            ),
                            child: Text(
                              'Organization',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                loginRoute,
                                arguments: 'sponsorRegister',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.symmetric(horizontal: 62, vertical: 16),
                              textStyle: TextStyle(fontSize: 20),
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return 10;
                                  }
                                  return 5;
                                },
                              ),
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.deepPurpleAccent;
                                  }
                                  return Colors.deepPurple;
                                },
                              ),
                            ),
                            child: Text(
                              'Sponsor',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}