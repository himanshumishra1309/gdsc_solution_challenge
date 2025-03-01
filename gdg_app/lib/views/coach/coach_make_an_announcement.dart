import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';

class CoachMakeAnAnnouncement extends StatefulWidget {
  const CoachMakeAnAnnouncement({super.key});

  @override
  _CoachMakeAnAnnouncementState createState() => _CoachMakeAnAnnouncementState();
}

class _CoachMakeAnAnnouncementState extends State<CoachMakeAnAnnouncement> {
  List<dynamic> _announcements = [];
  final TextEditingController _announcementController = TextEditingController();
  int _nextId = 3; // Assuming the next ID for a new announcement
  String _selectedDrawerItem = coachMakeAnAnnouncementRoute;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final String response = await rootBundle.loadString('assets/json_files/announcements.json');
      final data = await json.decode(response);
      setState(() {
        _announcements = data['announcements'];
      });
    } catch (e) {
      print('Error loading announcements: $e');
    }
  }

  void _addAnnouncement(String announcement) {
    setState(() {
      _announcements.add({
        "id": _nextId++,
        "coachName": "Current Coach", // Replace with the actual coach name
        "announcement": announcement,
        "timestamp": DateTime.now().toIso8601String(),
      });
    });
    _announcementController.clear();
  }

  void _editAnnouncement(int id, String newAnnouncement) {
    setState(() {
      final index = _announcements.indexWhere((announcement) => announcement['id'] == id);
      if (index != -1) {
        _announcements[index]['announcement'] = newAnnouncement;
        _announcements[index]['timestamp'] = DateTime.now().toIso8601String();
      }
    });
  }

  void _deleteAnnouncement(int id) {
    setState(() {
      _announcements.removeWhere((announcement) => announcement['id'] == id);
    });
  }

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route; // Store the route
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, route); // Navigate using the route
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
        title: Text('Make an Announcement'),
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
        child: Column(
          children: [
            TextField(
              controller: _announcementController,
              decoration: InputDecoration(
                labelText: 'Enter announcement',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_announcementController.text.isNotEmpty) {
                  _addAnnouncement(_announcementController.text);
                }
              },
              child: Text('Post Announcement'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  final announcement = _announcements[index];
                  return Card(
                    child: ListTile(
                      title: Text(announcement['announcement']),
                      subtitle: Text(
                        'By ${announcement['coachName']} on ${DateFormat.yMMMd().add_jm().format(DateTime.parse(announcement['timestamp']))}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _announcementController.text = announcement['announcement'];
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Edit Announcement'),
                                    content: TextField(
                                      controller: _announcementController,
                                      decoration: InputDecoration(
                                        labelText: 'Edit announcement',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          _editAnnouncement(announcement['id'], _announcementController.text);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Save'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteAnnouncement(announcement['id']);
                            },
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