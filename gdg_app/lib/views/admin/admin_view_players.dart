import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminViewPlayers extends StatefulWidget {
  const AdminViewPlayers({super.key});

  @override
  _AdminViewPlayersState createState() => _AdminViewPlayersState();
}

class _AdminViewPlayersState extends State<AdminViewPlayers> {
  List<dynamic> _players = [];
  List<dynamic> _filteredPlayers = [];
  String _searchQuery = '';
  String _selectedSport = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final String response = await rootBundle.loadString('assets/json_files/players_profiles.json');
    final data = await json.decode(response);
    setState(() {
      _players = data;
      _filteredPlayers = data;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterPlayers();
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterPlayers();
    });
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        final matchesName = player['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesSport = _selectedSport == 'All' || player['primarySport'] == _selectedSport;
        return matchesName && matchesSport;
      }).toList();
    });
  }

  void _showPlayerDetails(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(player['name'], style: const TextStyle(color: Colors.deepPurple)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(player['profilePhoto'], height: 150, fit: BoxFit.cover),
                const SizedBox(height: 16),
                _buildDetailRow('Athlete ID', player['athleteId']),
                _buildDetailRow('Date of Birth', player['dob']),
                _buildDetailRow('Age', player['age'].toString()),
                _buildDetailRow('Gender', player['gender']),
                _buildDetailRow('Nationality', player['nationality']),
                _buildDetailRow('Address', player['address']),
                _buildDetailRow('Phone', player['phone']),
                _buildDetailRow('Email', player['email']),
                _buildDetailRow('School', player['school']),
                _buildDetailRow('Grade', player['grade']),
                _buildDetailRow('Student ID', player['studentId']),
                _buildDetailRow('Organization Email', player['organizationEmail']),
                _buildDetailRow('Organization Website', player['organizationWebsite']),
                _buildDetailRow('Primary Sport', player['primarySport']),
                _buildDetailRow('Secondary Sport', player['secondarySport']),
                _buildDetailRow('Playing Position', player['playingPosition']),
                _buildDetailRow('Training Start Date', player['trainingStartDate']),
                _buildDetailRow('Current Level', player['currentLevel']),
                _buildDetailRow('Coach Assigned', player['coachAssigned']),
                _buildDetailRow('Gym Trainer Assigned', player['gymTrainerAssigned']),
                _buildDetailRow('Medical Staff Assigned', player['medicalStaffAssigned']),
                _buildDetailRow('Height', '${player['height']} cm'),
                _buildDetailRow('Weight', '${player['weight']} kg'),
                _buildDetailRow('BMI', player['bmi'].toString()),
                _buildDetailRow('Dominant Hand/Leg', player['dominantHandLeg']),
                _buildDetailRow('Blood Group', player['bloodGroup']),
                _buildDetailRow('Allergies', player['allergies']),
                _buildDetailRow('Medical Conditions', player['medicalConditions']),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Players', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: viewAllPlayersRoute,
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
          DrawerItem(icon: Icons.request_page, title: 'Request/View Sponsors', route: 'requestViewSponsorsRoute'),
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
                itemCount: _filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = _filteredPlayers[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(player['profilePhoto']),
                      ),
                      title: Text(player['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(player['primarySport'], style: const TextStyle(color: Colors.deepPurple)),
                      onTap: () => _showPlayerDetails(player),
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