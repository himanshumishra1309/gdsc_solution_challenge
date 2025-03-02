import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminPlayerCoachOption extends StatelessWidget {
  const AdminPlayerCoachOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Ensure you have this image in your assets folder
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
                          'Who are you?',
                          style: TextStyle(
                            fontFamily: 'Schyler',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 36),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              loginRoute,
                              arguments: 'adminHome',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                            textStyle: TextStyle(fontSize: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
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
                            'Admin',
                            style: TextStyle(
                              fontFamily: 'Schyler',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              loginRoute,
                              arguments: 'playerHome',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                            textStyle: TextStyle(fontSize: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
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
                            'Player',
                            style: TextStyle(
                              fontFamily: 'Schyler',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              loginRoute,
                              arguments: 'coachHome',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 52, vertical: 16),
                            textStyle: TextStyle(fontSize: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
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
                            'Coach',
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
    );
  }
}