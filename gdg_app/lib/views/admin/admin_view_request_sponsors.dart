import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminViewRequestSponsors extends StatefulWidget {
  const AdminViewRequestSponsors({super.key});

  @override
  _AdminViewRequestSponsorsState createState() => _AdminViewRequestSponsorsState();
}

class _AdminViewRequestSponsorsState extends State<AdminViewRequestSponsors> {
  List<dynamic> _viewSponsors = [];
  List<dynamic> _requestSponsors = [];
  List<dynamic> _filteredSponsors = [];
  String _searchQuery = '';
  String _selectedMode = 'View';
  String _selectedSport = 'All';

  @override
  void initState() {
    super.initState();
    _loadSponsors();
  }

  Future<void> _loadSponsors() async {
    final String viewResponse = await rootBundle.loadString('assets/json_files/sponsors_view.json');
    final String requestResponse = await rootBundle.loadString('assets/json_files/sponsors_request.json');
    final viewData = await json.decode(viewResponse);
    final requestData = await json.decode(requestResponse);
    setState(() {
      _viewSponsors = viewData;
      _requestSponsors = requestData;
      _filteredSponsors = viewData;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSponsors();
    });
  }

  void _onModeChanged(String? mode) {
    setState(() {
      _selectedMode = mode!;
      _filterSponsors();
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterSponsors();
    });
  }

  void _filterSponsors() {
    setState(() {
      if (_selectedMode == 'View') {
        _filteredSponsors = _viewSponsors.where((sponsor) {
          final matchesName = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesName;
        }).toList();
      } else {
        _filteredSponsors = _requestSponsors.where((sponsor) {
          final matchesName = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesSport = _selectedSport == 'All' || sponsor['sports'].contains(_selectedSport);
          return matchesName && matchesSport;
        }).toList();
      }
    });
  }

  void _showSponsorDetails(Map<String, dynamic> sponsor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(sponsor['name'] ?? 'N/A'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(sponsor['profilePhoto'] ?? 'assets/images/player1.png'),
                Text('Email: ${sponsor['email'] ?? 'N/A'}'),
                Text('Details: ${sponsor['details'] ?? 'N/A'}'),
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
        title: const Text('View/Request Sponsors'),
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
        selectedDrawerItem: requestViewSponsorsRoute,
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
                  value: _selectedMode,
                  onChanged: _onModeChanged,
                  items: <String>['View', 'Request']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (_selectedMode == 'Request') ...[
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
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSponsors.length,
                itemBuilder: (context, index) {
                  final sponsor = _filteredSponsors[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(sponsor['profilePhoto'] ?? 'assets/default_profile.png'),
                      ),
                      title: Text(sponsor['name'] ?? 'N/A'),
                      subtitle: Text(sponsor['email'] ?? 'N/A'),
                      onTap: () => _showSponsorDetails(sponsor),
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