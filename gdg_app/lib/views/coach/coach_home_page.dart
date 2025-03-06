import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';

class CoachHomePage extends StatefulWidget {
  const CoachHomePage({super.key});

  @override
  _CoachHomePageState createState() => _CoachHomePageState();
}

class _CoachHomePageState extends State<CoachHomePage> {
  Map<String, List<dynamic>> _players = {};
  String _selectedSport = 'Cricket';
  List<dynamic> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedDrawerItem = coachHomeRoute; // Use route for selection

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, coachAdminPlayerRoute); // Replace with your home route
    }

    return shouldLogout;
  }

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final String response = await rootBundle.loadString('assets/json_files/players.json');
    final data = await json.decode(response);
    setState(() {
      _players = Map<String, List<dynamic>>.from(data['players']);
      _filterPlayers();
    });
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players[_selectedSport]!.where((player) {
        return player['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
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

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Coach Home Page'),
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(fontSize: 20, color: Colors.white),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterPlayers();
                      },
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedSport,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSport = newValue!;
                        _filterPlayers();
                      });
                    },
                    items: <String>['Cricket', 'Football', 'Badminton']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPlayers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(_filteredPlayers[index]['profileImage']),
                      ),
                      title: Text(
                        _filteredPlayers[index]['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_filteredPlayers[index]['role']),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}