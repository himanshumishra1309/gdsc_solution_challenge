import 'package:flutter/material.dart';
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

  // Success popup
  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          title: const Text('Success', style: TextStyle(color: Colors.deepPurple)),
          content: const Text('Coach registered successfully'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }

  // Reusable form field widget
  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.deepPurple),
            border: InputBorder.none,
            icon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Coach', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: registerCoachRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nameController,
                labelText: 'Full Name',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the full name' : null,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _emailController,
                labelText: 'Email Address',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the email address' : null,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _dobController,
                labelText: 'Date of Birth',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the date of birth' : null,
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _genderController,
                labelText: 'Gender',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the gender' : null,
                icon: Icons.transgender,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _nationalityController,
                labelText: 'Nationality',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the nationality' : null,
                icon: Icons.flag,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _phoneController,
                labelText: 'Phone Number',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the phone number' : null,
                icon: Icons.phone,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _countryController,
                labelText: 'Country',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the country' : null,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _stateController,
                labelText: 'State',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the state' : null,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _addressController,
                labelText: 'Address',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the address' : null,
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _experienceController,
                labelText: 'Years of Experience',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the years of experience' : null,
                icon: Icons.work,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _certificationsController,
                labelText: 'Certifications & Licenses',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the certifications & licenses' : null,
                icon: Icons.assignment,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                controller: _previousOrganizationsController,
                labelText: 'Previous Coaching Organizations',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter the previous coaching organizations' : null,
                icon: Icons.business,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSuccessPopup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}