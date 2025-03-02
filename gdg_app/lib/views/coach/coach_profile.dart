import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class CoachProfile extends StatefulWidget {
  const CoachProfile({super.key});

  @override
  _CoachProfileState createState() => _CoachProfileState();
}

class _CoachProfileState extends State<CoachProfile> {
  String _selectedDrawerItem = coachProfileRoute;

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.people, title: 'View all players', route: coachHomeRoute),
      DrawerItem(icon: Icons.announcement, title: 'Make announcement', route: coachMakeAnAnnouncementRoute),
      DrawerItem(icon: Icons.request_page, title: 'Send admins a request', route: '/send-request'),
      DrawerItem(icon: Icons.schedule, title: 'Mark upcoming sessions', route: '/mark-sessions'),
      DrawerItem(icon: Icons.medical_services, title: 'View Medical records', route: '/view-medical-records'),
      DrawerItem(icon: Icons.person, title: 'View Profile', route: coachProfileRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Profile'),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to the desired color
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        toolbarHeight: 65.0,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: _onSelectDrawerItem,
        drawerItems: drawerItems,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/coach_profile.jpg'), // Ensure you have this image in your assets folder
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach Name',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Position',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Full Name'),
                      subtitle: Text('John Doe'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email Address'),
                      subtitle: Text('john.doe@example.com'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.cake),
                      title: Text('Date of Birth'),
                      subtitle: Text('January 1, 1980'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.male),
                      title: Text('Gender'),
                      subtitle: Text('Male'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.flag),
                      title: Text('Nationality'),
                      subtitle: Text('American'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone Number'),
                      subtitle: Text('+1 234 567 890'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Country'),
                      subtitle: Text('USA'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text('State'),
                      subtitle: Text('California'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Address'),
                      subtitle: Text('123 Main St, Los Angeles, CA'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.timeline),
                      title: Text('Years of Experience'),
                      subtitle: Text('10'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.school),
                      title: Text('Certifications & Licenses'),
                      subtitle: Text('Certified Professional Coach'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.business),
                      title: Text('Previous Coaching Organizations'),
                      subtitle: Text('XYZ Sports Club, ABC Academy'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}