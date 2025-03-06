import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class ViewCoach extends StatefulWidget {
  const ViewCoach({super.key});

  @override
  _ViewCoachState createState() => _ViewCoachState();
}

class _ViewCoachState extends State<ViewCoach> {
  String _selectedDrawerItem = viewCoachProfileRoute;
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  List<Map<String, String>> _coaches = [
    {
      'name': 'John Doe',
      'sport': 'Football',
      'image': 'assets/images/player1.png',
      'position': 'Head Coach',
      'email': 'john.doe@example.com',
      'dob': 'January 1, 1980',
      'gender': 'Male',
      'nationality': 'American',
      'phone': '+1 234 567 890',
      'country': 'USA',
      'state': 'California',
      'address': '123 Main St, Los Angeles, CA',
      'experience': '10',
      'certifications': 'Certified Professional Coach',
      'previousOrganizations': 'XYZ Sports Club, ABC Academy',
    },
    {
      'name': 'Jane Smith',
      'sport': 'Basketball',
      'image': 'assets/images/player2.jpg',
      'position': 'Assistant Coach',
      'email': 'jane.smith@example.com',
      'dob': 'February 2, 1985',
      'gender': 'Female',
      'nationality': 'Canadian',
      'phone': '+1 987 654 321',
      'country': 'Canada',
      'state': 'Ontario',
      'address': '456 Maple St, Toronto, ON',
      'experience': '8',
      'certifications': 'Certified Basketball Coach',
      'previousOrganizations': 'ABC Basketball Club, DEF Academy',
    },
    {
      'name': 'Alice Johnson',
      'sport': 'Tennis',
      'image': 'assets/images/player3.jpg',
      'position': 'Tennis Coach',
      'email': 'alice.johnson@example.com',
      'dob': 'March 3, 1990',
      'gender': 'Female',
      'nationality': 'British',
      'phone': '+44 123 456 789',
      'country': 'UK',
      'state': 'London',
      'address': '789 Elm St, London, UK',
      'experience': '6',
      'certifications': 'Certified Tennis Coach',
      'previousOrganizations': 'GHI Tennis Club, JKL Academy',
    },
    {
      'name': 'Bob Brown',
      'sport': 'Cricket',
      'image': 'assets/images/player4.png',
      'position': 'Cricket Coach',
      'email': 'bob.brown@example.com',
      'dob': 'April 4, 1975',
      'gender': 'Male',
      'nationality': 'Australian',
      'phone': '+61 987 654 321',
      'country': 'Australia',
      'state': 'New South Wales',
      'address': '101 Pine St, Sydney, NSW',
      'experience': '12',
      'certifications': 'Certified Cricket Coach',
      'previousOrganizations': 'MNO Cricket Club, PQR Academy',
    },
  ];
  List<Map<String, String>> _filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    _filteredCoaches = _coaches;
  }

  void _filterCoaches() {
    setState(() {
      _filteredCoaches = _coaches.where((coach) {
        return (coach['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                coach['sport']!.toLowerCase().contains(_searchQuery.toLowerCase())) &&
               (_selectedSport == 'All Sports' || coach['sport'] == _selectedSport);
      }).toList();
    });
  }

  void _showCoachInfo(Map<String, String> coach) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(coach['image']!),
                  radius: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  coach['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coach['position']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Address'),
                  subtitle: Text(coach['email']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Date of Birth'),
                  subtitle: Text(coach['dob']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.male),
                  title: const Text('Gender'),
                  subtitle: Text(coach['gender']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Nationality'),
                  subtitle: Text(coach['nationality']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone Number'),
                  subtitle: Text(coach['phone']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Country'),
                  subtitle: Text(coach['country']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('State'),
                  subtitle: Text(coach['state']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Address'),
                  subtitle: Text(coach['address']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('Years of Experience'),
                  subtitle: Text(coach['experience']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Certifications & Licenses'),
                  subtitle: Text(coach['certifications']!),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Previous Coaching Organizations'),
                  subtitle: Text(coach['previousOrganizations']!),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.deepPurple),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item);// Handle navigation based on the selected item
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerProfileRoute),
      DrawerItem(icon: Icons.people, title: 'View Coaches', route: viewCoachProfileRoute),
      DrawerItem(icon: Icons.bar_chart, title: 'View Stats', route: viewPlayerStatisticsRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Medical Reports', route: medicalReportRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Nutritional Plan', route: nutritionalPlanRoute),
      DrawerItem(icon: Icons.announcement, title: 'View Announcements', route: playerviewAnnouncementRoute),
      DrawerItem(icon: Icons.calendar_today, title: 'View Calendar', route: viewCalendarRoute),
      DrawerItem(icon: Icons.fitness_center, title: 'View Gym Plan', route: viewGymPlanRoute),
      DrawerItem(icon: Icons.edit, title: 'Fill Injury Form', route: fillInjuryFormRoute),
      DrawerItem(icon: Icons.attach_money, title: 'Finances', route: playerFinancialViewRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Coaches'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        toolbarHeight: 65.0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: drawerItems,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterCoaches();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedSport,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSport = newValue!;
                      _filterCoaches();
                    });
                  },
                  items: <String>[
                    'All Sports',
                    'Football',
                    'Basketball',
                    'Tennis',
                    'Cricket'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: _filteredCoaches.length,
                itemBuilder: (context, index) {
                  final coach = _filteredCoaches[index];
                  return GestureDetector(
                    onTap: () => _showCoachInfo(coach),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            coach['image']!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            coach['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            coach['sport']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}