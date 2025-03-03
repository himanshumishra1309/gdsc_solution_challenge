import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';
import 'landing_page_view.dart'; // Import the landing page view

class OrganizationRegistrationView extends StatefulWidget {
  const OrganizationRegistrationView({super.key});

  @override
  _OrganizationRegistrationViewState createState() => _OrganizationRegistrationViewState();
}

class _OrganizationRegistrationViewState extends State<OrganizationRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _organizationEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();
  final TextEditingController _adminAccountController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPageView()),
        );
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Organization Registration'),
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
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'REGISTER',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _organizationNameController,
                                decoration: InputDecoration(
                                  labelText: 'Name of Organization',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the name of the organization';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _organizationEmailController,
                                decoration: InputDecoration(
                                  labelText: 'Email of Organization',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the email of the organization';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _stateController,
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the state';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _countryController,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the country';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _certificateController,
                                decoration: InputDecoration(
                                  labelText: 'Certificate',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the certificate';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _adminAccountController,
                                decoration: InputDecoration(
                                  labelText: 'Register an Admin',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the admin account';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _adminPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Admin Account Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the admin account password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Process the registration
                                    Navigator.pushReplacementNamed(context, landingPageRoute);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: TextStyle(fontSize: 20),
                                ),
                                child: Text('Register',
                                style: TextStyle(color: Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }
}