import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminViewCoaches extends StatefulWidget {
  const AdminViewCoaches({super.key});

  @override
  _AdminViewCoachesState createState() => _AdminViewCoachesState();
}

class _AdminViewCoachesState extends State<AdminViewCoaches> {
  List<dynamic> _coaches = [];
  List<dynamic> _filteredCoaches = [];
  String _searchQuery = '';
  String _selectedSport = 'All';

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    final String response = await rootBundle.loadString('assets/json_files/coaches_profiles.json');
    final data = await json.decode(response);
    setState(() {
      _coaches = data;
      _filteredCoaches = data;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterCoaches();
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterCoaches();
    });
  }

  void _filterCoaches() {
    setState(() {
      _filteredCoaches = _coaches.where((coach) {
        final matchesName = coach['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final matchesSport = _selectedSport == 'All' || coach['primarySport'] == _selectedSport;
        return matchesName && matchesSport;
      }).toList();
    });
  }

  void _showCoachDetails(Map<String, dynamic> coach) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(coach['name'] ?? 'N/A'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(coach['profilePhoto'] ?? 'assets/default_profile.png'),
                Text('Email: ${coach['email'] ?? 'N/A'}'),
                Text('Date of Birth: ${coach['dob'] ?? 'N/A'}'),
                Text('Gender: ${coach['gender'] ?? 'N/A'}'),
                Text('Nationality: ${coach['nationality'] ?? 'N/A'}'),
                Text('Phone: ${coach['phone'] ?? 'N/A'}'),
                Text('Country: ${coach['country'] ?? 'N/A'}'),
                Text('State: ${coach['state'] ?? 'N/A'}'),
                Text('Address: ${coach['address'] ?? 'N/A'}'),
                Text('Years of Experience: ${coach['experience'] ?? 'N/A'}'),
                Text('Certifications: ${coach['certifications'] ?? 'N/A'}'),
                Text('Previous Organizations: ${coach['previousOrganizations'] ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Coaches'),
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
        selectedDrawerItem: viewAllCoachesRoute,
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
                  items: <String>['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton']
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
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCoaches.length,
                itemBuilder: (context, index) {
                  final coach = _filteredCoaches[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(coach['profilePhoto'] ?? 'assets/default_profile.png'),
                      ),
                      title: Text(coach['name'] ?? 'N/A'),
                      subtitle: Text(coach['primarySport'] ?? 'N/A'),
                      onTap: () => _showCoachDetails(coach),
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