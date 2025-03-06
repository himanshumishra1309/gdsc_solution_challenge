import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/popups/alert_message.dart';

class AdminRegisterAdminView extends StatefulWidget {
  const AdminRegisterAdminView({super.key});

  @override
  _AdminRegisterAdminViewState createState() => _AdminRegisterAdminViewState();
}

class _AdminRegisterAdminViewState extends State<AdminRegisterAdminView> {
  String _searchQuery = '';
  final List<Map<String, String>> _admins = [
    {'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
  ];

  List<Map<String, String>> get _filteredAdmins {
    return _admins.where((admin) {
      final matchesName = admin['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesEmail = admin['email']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesName || matchesEmail;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showRegisterAdminForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegisterAdminForm(
          onRegister: (name, email, avatar) {
            setState(() {
              _admins.add({'name': name, 'email': email, 'avatar': avatar});
            });
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return Future.value(false); // Prevents default behavior
    }
    return Future.value(true); // Allows popping if no pages left
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register Admin'),
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          toolbarHeight: 65.0,
        ),
        drawer: CustomDrawer(
          selectedDrawerItem: registerAdminRoute,
          onSelectDrawerItem: (route) {
            Navigator.pop(context); // Close the drawer
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = _filteredAdmins[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: admin['avatar'] != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(admin['avatar']!)),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(admin['name']!),
                        subtitle: Text(admin['email']!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showRegisterAdminForm,
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class RegisterAdminForm extends StatefulWidget {
  final Function(String, String, String) onRegister;

  const RegisterAdminForm({required this.onRegister, super.key});

  @override
  _RegisterAdminFormState createState() => _RegisterAdminFormState();
}

class _RegisterAdminFormState extends State<RegisterAdminForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _avatarPath;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _avatarPath = result.files.single.path!;
      });
    }
  }

  void _showConfirmationDialog() {
    AlertMessage.showAlert(
      context,
      message: 'Are you sure you want to register the admin?',
      options: [
        AlertOption(
          label: 'Yes',
          onPressed: () {
            widget.onRegister(_nameController.text, _emailController.text, _avatarPath ?? '');
            Navigator.of(context).pop(); // Close the confirmation dialog
          },
        ),
        AlertOption(
          label: 'No',
          onPressed: () {
            Navigator.of(context).pop(); // Close the confirmation dialog
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register Admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _avatarPath != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(_avatarPath!)),
                          radius: 30,
                        )
                      : const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Upload Avatar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _showConfirmationDialog();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          child: const Text('Register', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}