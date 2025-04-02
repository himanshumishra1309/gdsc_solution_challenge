import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class FillInjuryFormView extends StatefulWidget {
  const FillInjuryFormView({super.key});

  @override
  _FillInjuryFormViewState createState() => _FillInjuryFormViewState();
}

class _FillInjuryFormViewState extends State<FillInjuryFormView> {
  final _authService = AuthService();
  String _selectedMonth = 'January';
  String _searchQuery = '';

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _injuryForms = [
    {
      'date': '02/10/2025',
      'details': 'Sprain in the ankle during practice.',
      'time': '10:00 AM',
      'type': 'Sprain',
      'bodyPart': 'Ankle',
      'severity': 'Moderate',
      'cause': 'Bad ground conditions',
      'firstAid': 'Yes',
      'firstAidBy': 'Coach John Doe',
      'externalFactors': 'Bad Ground Conditions',
      'painLevel': 5,
      'symptoms': ['Swelling', 'Bruising'],
      'previousInjury': 'No',
    },
    {
      'date': '03/15/2025',
      'details': 'Fracture in the arm during a match.',
      'time': '3:00 PM',
      'type': 'Fracture',
      'bodyPart': 'Arm',
      'severity': 'Severe',
      'cause': 'Collision with another player',
      'firstAid': 'Yes',
      'firstAidBy': 'Coach Jane Smith',
      'externalFactors': 'Collision',
      'painLevel': 9,
      'symptoms': ['Swelling', 'Bruising', 'Difficulty Moving'],
      'previousInjury': 'Yes',
    },
    {
      'date': '04/20/2025',
      'details': 'Muscle tear in the thigh during training.',
      'time': '8:00 AM',
      'type': 'Muscle Tear',
      'bodyPart': 'Thigh',
      'severity': 'Moderate',
      'cause': 'Overexertion',
      'firstAid': 'No',
      'firstAidBy': '',
      'externalFactors': 'Overexertion',
      'painLevel': 7,
      'symptoms': ['Swelling', 'Weakness'],
      'previousInjury': 'No',
    },
    {
      'date': '05/25/2025',
      'details': 'Dislocated shoulder during a game.',
      'time': '6:00 PM',
      'type': 'Dislocation',
      'bodyPart': 'Shoulder',
      'severity': 'Severe',
      'cause': 'Fall during the game',
      'firstAid': 'Yes',
      'firstAidBy': 'Coach John Doe',
      'externalFactors': 'Fall',
      'painLevel': 8,
      'symptoms': ['Swelling', 'Bruising', 'Difficulty Moving'],
      'previousInjury': 'Yes',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Athlete";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredInjuryForms {
    return _injuryForms.where((form) {
      final matchesMonth = DateFormat('MM/dd/yyyy').parse(form['date']).month ==
          _getMonthNumber(_selectedMonth);
      final matchesSearchQuery = form['date'].contains(_searchQuery);
      return matchesMonth && matchesSearchQuery;
    }).toList();
  }

  int _getMonthNumber(String month) {
    return DateFormat('MMMM').parse(month).month;
  }

  void _onMonthChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedMonth = newValue;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showInjuryFormDetails(Map<String, dynamic> form) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Injury Form Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Date', form['date']),
                _buildDetailRow('Time', form['time']),
                _buildDetailRow('Type', form['type']),
                _buildDetailRow('Body Part', form['bodyPart']),
                _buildDetailRow('Severity', form['severity']),
                _buildDetailRow('Cause', form['cause']),
                _buildDetailRow('First Aid', form['firstAid']),
                _buildDetailRow('First Aid By', form['firstAidBy']),
                _buildDetailRow('External Factors', form['externalFactors']),
                _buildDetailRow('Pain Level', form['painLevel'].toString()),
                _buildDetailRow('Symptoms', form['symptoms'].join(', ')),
                _buildDetailRow('Previous Injury', form['previousInjury']),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewInjuryForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewInjuryForm()),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushReplacementNamed(
        context, coachAdminPlayerRoute); // Navigate to the desired page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill Injury Form'),
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
        selectedDrawerItem: '/fill-injury-form',
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(
              icon: Icons.show_chart, title: 'Graphs', route: playerHomeRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View Coaches',
              route: viewCoachProfileRoute),
          DrawerItem(
              icon: Icons.bar_chart,
              title: 'View Stats',
              route: viewPlayerStatisticsRoute),
          DrawerItem(
              icon: Icons.medical_services,
              title: 'View Medical Reports',
              route: medicalReportRoute),
          DrawerItem(
              icon: Icons.medical_services,
              title: 'View Nutritional Plan',
              route: nutritionalPlanRoute),
          DrawerItem(
              icon: Icons.announcement,
              title: 'View Announcements',
              route: playerviewAnnouncementRoute),
          DrawerItem(
              icon: Icons.calendar_today,
              title: 'View Calendar',
              route: viewCalendarRoute),
          DrawerItem(
              icon: Icons.fitness_center,
              title: 'View Gym Plan',
              route: viewGymPlanRoute),
          
          DrawerItem(
              icon: Icons.attach_money,
              title: 'Finances',
              route: playerFinancialViewRoute),
        ],
        onLogout: () => _handleLogout(context),
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      labelText: 'Search by Date',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.deepPurple, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 1.5),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedMonth,
                    onChanged: _onMonthChanged,
                    items: <String>[
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.deepPurple, size: 28),
                    dropdownColor: Colors.white,
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredInjuryForms.length,
                itemBuilder: (context, index) {
                  final form = _filteredInjuryForms[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        'Date: ${form['date']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Text(
                        form['details'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      onTap: () => _showInjuryFormDetails(form),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewInjuryForm,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NewInjuryForm extends StatefulWidget {
  const NewInjuryForm({super.key});

  @override
  _NewInjuryFormState createState() => _NewInjuryFormState();
}

class _NewInjuryFormState extends State<NewInjuryForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateOfInjury;
  TimeOfDay? _timeOfInjury;
  String _typeOfInjury = 'Sprain';
  String _affectedBodyPart = 'Head';
  String _injurySeverity = 'Minor (Can Play)'; // Initialize with a valid value
  bool _firstAidProvided = false;
  String _externalFactors = 'Bad Ground Conditions';
  double _painLevel = 5;
  List<String> _symptoms = [];
  bool _previousInjury = false;
  DateTime? _previousInjuryDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Injury Form'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '2️⃣ Injury Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Date of Injury'),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateOfInjury = picked;
                      });
                    }
                  },
                  validator: (value) {
                    if (_dateOfInjury == null) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                    text: _dateOfInjury == null
                        ? ''
                        : DateFormat('MM/dd/yyyy').format(_dateOfInjury!),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Time of Injury'),
                  readOnly: true,
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _timeOfInjury = picked;
                      });
                    }
                  },
                  validator: (value) {
                    if (_timeOfInjury == null) {
                      return 'Please select a time';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                    text: _timeOfInjury == null
                        ? ''
                        : _timeOfInjury!.format(context),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _typeOfInjury,
                  decoration:
                      const InputDecoration(labelText: 'Type of Injury'),
                  items: <String>[
                    'Sprain',
                    'Fracture',
                    'Muscle Tear',
                    'Dislocation',
                    'Concussion',
                    'Overuse Injury',
                    'Other'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _typeOfInjury = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _affectedBodyPart,
                  decoration:
                      const InputDecoration(labelText: 'Affected Body Part'),
                  items: <String>[
                    'Head',
                    'Neck',
                    'Shoulder',
                    'Arm',
                    'Wrist/Hand',
                    'Back',
                    'Hip',
                    'Knee',
                    'Ankle',
                    'Foot',
                    'Other'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _affectedBodyPart = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _injurySeverity,
                  decoration:
                      const InputDecoration(labelText: 'Injury Severity'),
                  items: <String>[
                    'Minor (Can Play)',
                    'Moderate (Needs Recovery)',
                    'Severe (Medical Attention Required)'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _injurySeverity = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Cause of Injury'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe the cause of injury';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Was First Aid Provided?'),
                  value: _firstAidProvided,
                  onChanged: (bool value) {
                    setState(() {
                      _firstAidProvided = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_firstAidProvided)
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Who Gave First Aid?'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name of the person who gave first aid';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _externalFactors,
                  decoration:
                      const InputDecoration(labelText: 'Any External Factors?'),
                  items: <String>[
                    'Bad Ground Conditions',
                    'Collision',
                    'Equipment Malfunction',
                    'Other'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _externalFactors = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '3️⃣ Pain & Symptoms Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Pain Level (Scale of 1-10): ${_painLevel.toInt()}'),
                Slider(
                  value: _painLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _painLevel.toInt().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _painLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Symptoms Experienced:'),
                CheckboxListTile(
                  title: const Text('Swelling'),
                  value: _symptoms.contains('Swelling'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Swelling');
                      } else {
                        _symptoms.remove('Swelling');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Bruising'),
                  value: _symptoms.contains('Bruising'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Bruising');
                      } else {
                        _symptoms.remove('Bruising');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Numbness'),
                  value: _symptoms.contains('Numbness'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Numbness');
                      } else {
                        _symptoms.remove('Numbness');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Weakness'),
                  value: _symptoms.contains('Weakness'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Weakness');
                      } else {
                        _symptoms.remove('Weakness');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Dizziness'),
                  value: _symptoms.contains('Dizziness'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Dizziness');
                      } else {
                        _symptoms.remove('Dizziness');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Loss of Balance'),
                  value: _symptoms.contains('Loss of Balance'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Loss of Balance');
                      } else {
                        _symptoms.remove('Loss of Balance');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Difficulty Moving'),
                  value: _symptoms.contains('Difficulty Moving'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _symptoms.add('Difficulty Moving');
                      } else {
                        _symptoms.remove('Difficulty Moving');
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Has This Injury Happened Before?'),
                  value: _previousInjury,
                  onChanged: (bool value) {
                    setState(() {
                      _previousInjury = value;
                    });
                  },
                ),
                if (_previousInjury)
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'If Yes, When?'),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _previousInjuryDate = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (_previousInjury && _previousInjuryDate == null) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                    controller: TextEditingController(
                      text: _previousInjuryDate == null
                          ? ''
                          : DateFormat('MM/dd/yyyy')
                              .format(_previousInjuryDate!),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the form data
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
