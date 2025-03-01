// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class SportsOfInterestView extends StatefulWidget {
  const SportsOfInterestView({super.key});

  @override
  _SportsOfInterestViewState createState() => _SportsOfInterestViewState();
}

class _SportsOfInterestViewState extends State<SportsOfInterestView> {
  List<String> _allSports = ['Cricket', 'Football', 'Badminton', 'Tennis', 'Basketball', 'Hockey'];
  List<String> _filteredSports = [];
  List<String> _selectedSports = [];
  String _searchQuery = '';
  String _selectedDrawerItem = sportsOfInterestRoute;

  @override
  void initState() {
    super.initState();
    _filteredSports = _allSports;
  }

  void _filterSports(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSports = _allSports.where((sport) => sport.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _toggleSelection(String sport) {
    setState(() {
      if (_selectedSports.contains(sport)) {
        _selectedSports.remove(sport);
      } else {
        _selectedSports.add(sport);
      }
    });
  }

  void _onSelectDrawerItem(String route) {
    if (route != _selectedDrawerItem) {
      setState(() {
        _selectedDrawerItem = route;
      });
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.article, title: 'News and Updates', route: sponsorHomeViewRoute),
      DrawerItem(icon: Icons.sports, title: 'Sports of Interest', route: sportsOfInterestRoute),
      DrawerItem(icon: Icons.mail, title: 'Invitations', route: invitationToSponsorRoute),
      DrawerItem(icon: Icons.request_page, title: 'Requests', route: requestToSponsorPageRoute),
      DrawerItem(icon: Icons.search, title: 'Find Organization or Players', route: findOrganizationOrPlayersRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports of Interest'),
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
              onChanged: _filterSports,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _filteredSports.length,
                itemBuilder: (context, index) {
                  final sport = _filteredSports[index];
                  final isSelected = _selectedSports.contains(sport);
                  return GestureDetector(
                    onTap: () => _toggleSelection(sport),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple.withOpacity(0.5) : Colors.white,
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/${sport.toLowerCase()}.jpg', // Ensure you have images named accordingly in your assets folder
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8),
                          Text(
                            sport,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle edit action
                  },
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle save action
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}