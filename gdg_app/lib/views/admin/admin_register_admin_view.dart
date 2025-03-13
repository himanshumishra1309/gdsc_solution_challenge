import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/popups/alert_message.dart';
import 'package:intl/intl.dart';

class AdminRegisterAdminView extends StatefulWidget {
  const AdminRegisterAdminView({super.key});

  @override
  _AdminRegisterAdminViewState createState() => _AdminRegisterAdminViewState();
}

class _AdminRegisterAdminViewState extends State<AdminRegisterAdminView> {
  String _searchQuery = '';
  final List<Map<String, dynamic>> _admins = [
    {
      'name': 'John Doe', 
      'email': 'john.doe@example.com',
      'role': 'Admin',
      'dateCreated': '2023-01-15',
      'lastLogin': '2023-03-04',
      'isActive': true
    },
    {
      'name': 'Jane Smith', 
      'email': 'jane.smith@example.com',
      'role': 'Admin',
      'dateCreated': '2023-02-10',
      'lastLogin': '2023-03-05',
      'isActive': true
    },
    {
      'name': 'Mike Johnson', 
      'email': 'mike.j@example.com',
      'role': 'Admin',
      'dateCreated': '2023-02-20',
      'lastLogin': '2023-02-28',
      'isActive': false
    },
  ];

  List<Map<String, dynamic>> get _filteredAdmins {
    return _admins.where((admin) {
      final matchesName = admin['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesEmail = admin['email']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = admin['role']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesName || matchesEmail || matchesRole;
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
          onRegister: (name, email, avatar, role) {
            setState(() {
              _admins.add({
                'name': name, 
                'email': email, 
                'avatar': avatar,
                'role': role,
                'dateCreated': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                'lastLogin': '-',
                'isActive': true
              });
            });
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('$name has been registered as an admin successfully'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'DISMISS',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Management'),
          backgroundColor: Colors.deepPurple,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          toolbarHeight: 65.0,
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                // Show help dialog about admin management
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Admin Management Help'),
                    content: const SingleChildScrollView(
                      child: Text(
                        'This screen allows you to manage administrators who have access to the system. '
                        'You can add new admins, view existing ones, and manage their access privileges.\n\n'
                        'Use the search bar to filter admins by name, email or role.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('GOT IT'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
          onLogout: () => _handleLogout(context),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top stats section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.admin_panel_settings,
                        color: Colors.deepPurple,
                        title: 'Total Admins',
                        value: _admins.length.toString(),
                      ),
                      const Spacer(),
                      _buildStatCard(
                        icon: Icons.person,
                        color: Colors.green,
                        title: 'Active',
                        value: _admins.where((admin) => admin['isActive'] == true).length.toString(),
                      ),
                      const Spacer(),
                      _buildStatCard(
                        icon: Icons.person_off,
                        color: Colors.red,
                        title: 'Inactive',
                        value: _admins.where((admin) => admin['isActive'] == false).length.toString(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Search bar with title
                Row(
                  children: [
                    const Text(
                      'Administrator List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Sort or filter functionality
                        showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text('Sort by'),
                            children: [
                              ListTile(
                                leading: const Icon(Icons.sort_by_alpha),
                                title: const Text('Name'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Implement sorting
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.date_range),
                                title: const Text('Date Added'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Implement sorting
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.sort, size: 18),
                      label: const Text('Sort'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Enhanced search bar
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or role...',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Admin list
                Expanded(
                  child: _filteredAdmins.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredAdmins.length,
                          itemBuilder: (context, index) {
                            final admin = _filteredAdmins[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: admin['avatar'] != null
                                          ? FileImage(File(admin['avatar']!))
                                          : null,
                                      child: admin['avatar'] == null
                                          ? const Icon(Icons.person, size: 32, color: Colors.deepPurple)
                                          : null,
                                    ),
                                    if (admin['isActive'] == true)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  admin['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      admin['email']!,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(admin['role']).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            admin['role']!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getRoleColor(admin['role']),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Added: ${admin['dateCreated']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: admin['isActive'] ? 'deactivate' : 'activate',
                                      child: Row(
                                        children: [
                                          Icon(
                                            admin['isActive'] ? Icons.block : Icons.check_circle,
                                            size: 18,
                                            color: admin['isActive'] ? Colors.red : Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(admin['isActive'] ? 'Deactivate' : 'Activate'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    // Handle popup menu actions
                                    if (value == 'edit') {
                                      // Edit admin
                                    } else if (value == 'deactivate') {
                                      setState(() {
                                        admin['isActive'] = false;
                                      });
                                    } else if (value == 'activate') {
                                      setState(() {
                                        admin['isActive'] = true;
                                      });
                                    }
                                  },
                                ),
                                onTap: () {
                                  // View admin details
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showRegisterAdminForm,
          backgroundColor: Colors.deepPurple,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No administrators found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'You haven\'t added any administrators yet'
                : 'Try adjusting your search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return Colors.deepPurple;
      case 'Admin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class RegisterAdminForm extends StatefulWidget {
  final Function(String, String, String, String) onRegister;

  const RegisterAdminForm({required this.onRegister, super.key});

  @override
  _RegisterAdminFormState createState() => _RegisterAdminFormState();
}

class _RegisterAdminFormState extends State<RegisterAdminForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _avatarPath;
  String _selectedRole = 'Admin';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return Colors.deepPurple;
      case 'Admin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  final List<String> _availableRoles = ['Admin', 'Super Admin'];

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
      message: 'Register ${_nameController.text} as a new ${_selectedRole}?',
      options: [
        AlertOption(
          label: 'Yes',
          onPressed: () {
            widget.onRegister(
              _nameController.text, 
              _emailController.text, 
              _avatarPath ?? '',
              _selectedRole
            );
            Navigator.of(context).pop(); // Close the confirmation dialog
            Navigator.of(context).pop(); // Close the form dialog
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.deepPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Register New Administrator',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Create a new admin account with appropriate access privileges',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Avatar and name section
                Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: _avatarPath != null
                                  ? FileImage(File(_avatarPath!))
                                  : null,
                              radius: 50,
                              backgroundColor: Colors.grey.shade200,
                              child: _avatarPath == null
                                  ? const Icon(Icons.person, size: 50, color: Colors.deepPurple)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Administrator Photo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Personal Information section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Full name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Account Security section
                const Text(
                  'Account Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepPurple),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm the password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Access level section
                const Text(
                  'Access Level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Role selector
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                  ),
                  items: _availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Role description
                // Role description container
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: Colors.grey.shade200,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            _selectedRole == 'Super Admin' 
                ? Icons.security 
                : Icons.admin_panel_settings,
            color: _getRoleColor(_selectedRole),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "Role Details",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _getRoleColor(_selectedRole),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        _selectedRole == 'Super Admin'
            ? 'Super Administrators have full access to all system features and can manage other administrators.'
            : 'Administrators can manage coaches and players, view reports, and perform most administrative tasks.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _generatePermissionChips(),
      ),
    ],
  ),
),

const SizedBox(height: 24),
const Divider(),
const SizedBox(height: 16),

// Terms and conditions checkbox
Row(
  children: [
    Checkbox(
      value: _agreeToTerms,
      activeColor: Colors.deepPurple,
      onChanged: (value) {
        setState(() {
          _agreeToTerms = value!;
        });
      },
    ),
    Expanded(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          children: [
            const TextSpan(
              text: 'I confirm that I have read and agree to the ',
            ),
            TextSpan(
              text: 'Terms of Service',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Show terms of service
                },
            ),
            const TextSpan(
              text: ' and ',
            ),
            TextSpan(
              text: 'Privacy Policy',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Show privacy policy
                },
            ),
          ],
        ),
      ),
    ),
  ],
),

const SizedBox(height: 24),

// Action buttons
Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade800,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('CANCEL'),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: !_agreeToTerms ? null : () {
          if (_formKey.currentState!.validate()) {
            _showConfirmationDialog();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: const Text('REGISTER'),
      ),
    ),
  ],
),

],
          ),
        ),
      ),
    ),
  );
}

// Generate permission chips based on selected role
List<Widget> _generatePermissionChips() {
  final List<Map<String, dynamic>> permissions = _selectedRole == 'Super Admin'
      ? [
          {'name': 'Manage Admins', 'icon': Icons.admin_panel_settings},
          {'name': 'System Settings', 'icon': Icons.settings},
          {'name': 'Manage All Users', 'icon': Icons.people},
          {'name': 'Financial Access', 'icon': Icons.attach_money},
          {'name': 'Data Analytics', 'icon': Icons.analytics},
          {'name': 'Sponsor Management', 'icon': Icons.handshake},
        ]
      : [
          {'name': 'Manage Coaches', 'icon': Icons.sports},
          {'name': 'Manage Players', 'icon': Icons.person},
          {'name': 'View Reports', 'icon': Icons.bar_chart},
          {'name': 'Basic Settings', 'icon': Icons.settings_applications},
        ];

  return permissions.map((permission) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(_selectedRole).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRoleColor(_selectedRole).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            permission['icon'],
            size: 12,
            color: _getRoleColor(_selectedRole),
          ),
          const SizedBox(width: 4),
          Text(
            permission['name'],
            style: TextStyle(
              fontSize: 11,
              color: _getRoleColor(_selectedRole),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }).toList();
}

@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
}
}