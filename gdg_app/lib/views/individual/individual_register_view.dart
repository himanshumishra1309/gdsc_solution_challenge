import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:gdg_app/views/login_view.dart';
import 'package:intl/intl.dart';
import '../landing_page_view.dart'; // Import the landing page view

class IndividualRegisterView extends StatefulWidget {
  const IndividualRegisterView({super.key});

  @override
  State<IndividualRegisterView> createState() => _IndividualRegisterViewState();
}

class _IndividualRegisterViewState extends State<IndividualRegisterView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _dob;
  late final TextEditingController _address;
  late final TextEditingController _highestLevelPlayed;
  String? _selectedState;
  List<String> _states = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _dob = TextEditingController();
    _address = TextEditingController();
    _highestLevelPlayed = TextEditingController();
    _loadStates();
  }

  Future<void> _loadStates() async {
    final String response = await rootBundle.loadString('assets/json_files/states.json');
    final data = await json.decode(response);
    setState(() {
      _states = List<String>.from(data['states']);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _dob.dispose();
    _address.dispose();
    _highestLevelPlayed.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white.withOpacity(0.9),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dob.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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
          title: const Text('Register'),
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
                            TextField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _dob,
                              decoration: InputDecoration(
                                labelText: 'DOB',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                ),
                              ),
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _address,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            DropdownSearch<String>(
                              items: _states,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "State",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Search State',
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                menuProps: MenuProps(
                                  backgroundColor: Colors.white.withOpacity(0.9),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                _selectedState = value;
                              },
                              selectedItem: _selectedState,
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _highestLevelPlayed,
                              decoration: InputDecoration(
                                labelText: 'Highest Level Played',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Handle registration logic
                              },
                              child: Text('Register'),
                            ),
                            SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginView(sourcePage: '',)),
                                );
                              },
                              child: Text(
                                "Already Registered? Login",
                                style: TextStyle(color: Colors.blue),
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
          ],
        ),
      ),
    );
  }
}