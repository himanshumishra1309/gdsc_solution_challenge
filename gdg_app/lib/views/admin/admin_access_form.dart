import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'package:flutter_3d_viewer/flutter_3d_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class AdminAccessForm extends StatefulWidget {
  const AdminAccessForm({super.key});

  @override
  _AdminAccessFormState createState() => _AdminAccessFormState();
}

class _AdminAccessFormState extends State<AdminAccessForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _positionController = TextEditingController();
  final _injuryDescriptionController = TextEditingController();
  final _causeDescriptionController = TextEditingController();
  final _treatmentDescriptionController = TextEditingController();
  final _recoveryDescriptionController = TextEditingController();
  final _authService = AuthService();
  DateTime? _injuryDate;
  String _selectedSport = 'Cricket';
  String _selectedInjuryType = 'Sprain';
  String _selectedRecoveryTime = '1 week';
  int _painIntensity = 1;
  bool _previousInjuries = false;
  bool _contactWithPlayer = false;
  bool _firstAidProvided = false;
  bool _doctorConsulted = false;
  bool _physiotherapyRequired = false;
  bool _isEditing = false;

  bool _isLoading = false;

  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    // Load user info when the screen initializes
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final userData = await _authService.getCurrentUser();
      
      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Admin";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _injuryDate = date;
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
    });
  }

  void _onInjuryTypeChanged(String? injuryType) {
    setState(() {
      _selectedInjuryType = injuryType!;
    });
  }

  void _onRecoveryTimeChanged(String? recoveryTime) {
    setState(() {
      _selectedRecoveryTime = recoveryTime!;
    });
  }

  void _onPainIntensityChanged(int intensity) {
    setState(() {
      _painIntensity = intensity;
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _handleLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
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
  
  // If user confirmed logout
  if (shouldLogout == true) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        );
      },
    );
    
    try {
      // First clear local data directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Then try server-side logout, but don't block on it
      _authService.logout().catchError((e) {
        print('Server logout error: $e');
      });
      
      // Navigate to login page
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          coachAdminPlayerRoute, // Make sure this constant is defined in your routes file
          (route) => false, // This clears the navigation stack
        );
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Injury Form'),
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
        selectedDrawerItem: editFormsRoute,
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
           
          DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
        ],
        onLogout: () => _handleLogout(context),
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedSport,
                    onChanged: _onSportChanged,
                    items: <String>['Cricket', 'Badminton', 'Football']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Athlete Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position/Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the position/role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Injury Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Injury',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        _onDateChanged(picked);
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: _injuryDate != null ? DateFormat('yyyy-MM-dd').format(_injuryDate!) : '',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedInjuryType,
                onChanged: _onInjuryTypeChanged,
                decoration: const InputDecoration(
                  labelText: 'Type of Injury',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Sprain', 'Fracture', 'Muscle Tear', 'Concussion']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location of Injury',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                child: Flutter3DViewer(
                  src: 'assets/models/human_body.glb',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pain Intensity (1-10 scale)',
                style: TextStyle(fontSize: 16),
              ),
              Slider(
                value: _painIntensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _painIntensity.toString(),
                onChanged: (double value) {
                  _onPainIntensityChanged(value.toInt());
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Previous Injuries?'),
                value: _previousInjuries,
                onChanged: (bool value) {
                  setState(() {
                    _previousInjuries = value;
                  });
                },
              ),
              if (_previousInjuries)
                TextFormField(
                  controller: _injuryDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'If Yes, Describe',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Cause of Injury',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _causeDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'How did the injury occur?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Was there any contact with another player?'),
                value: _contactWithPlayer,
                onChanged: (bool value) {
                  setState(() {
                    _contactWithPlayer = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Immediate Treatment Received',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('First Aid Provided?'),
                value: _firstAidProvided,
                onChanged: (bool value) {
                  setState(() {
                    _firstAidProvided = value;
                  });
                },
              ),
              if (_firstAidProvided)
                TextFormField(
                  controller: _treatmentDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Treatment Type',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Recovery & Rehabilitation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Doctor Consulted?'),
                value: _doctorConsulted,
                onChanged: (bool value) {
                  setState(() {
                    _doctorConsulted = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Physiotherapy Required?'),
                value: _physiotherapyRequired,
                onChanged: (bool value) {
                  setState(() {
                    _physiotherapyRequired = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedRecoveryTime,
                onChanged: _onRecoveryTimeChanged,
                decoration: const InputDecoration(
                  labelText: 'Estimated Recovery Time',
                  border: OutlineInputBorder(),
                ),
                items: <String>['1 week', '2 weeks', '1 month']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_selectedSport == 'Cricket') ...[
                const Text(
                  'Cricket-Specific Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Which role were you playing?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Were you wearing protective gear?'),
                  value: false,
                  onChanged: (bool value) {},
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Type of bowling/batting shot before injury?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Did the injury occur while catching or diving?'),
                  value: false,
                  onChanged: (bool value) {},
                ),
              ] else if (_selectedSport == 'Badminton') ...[
                const Text(
                  'Badminton-Specific Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Was the injury due to a sudden movement?'),
                  value: false,
                  onChanged: (bool value) {},
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Were you in a singles or doubles match?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Did the injury happen during a smash or net play?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else if (_selectedSport == 'Football') ...[
                const Text(
                  'Football-Specific Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Were you tackled before the injury?'),
                  value: false,
                  onChanged: (bool value) {},
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Did the injury occur while sprinting, passing, or shooting?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Type of surface played on?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Were you wearing shin guards?'),
                  value: false,
                  onChanged: (bool value) {},
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _toggleEditing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(_isEditing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}