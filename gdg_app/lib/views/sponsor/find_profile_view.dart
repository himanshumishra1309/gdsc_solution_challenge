// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class FindProfilesView extends StatefulWidget {
  const FindProfilesView({super.key});

  @override
  _FindProfilesViewState createState() => _FindProfilesViewState();
}

class _FindProfilesViewState extends State<FindProfilesView> {
  List<Map<String, String>> _profiles = [];
  List<Map<String, String>> _filteredProfiles = [];
  String _searchQuery = '';
  String _selectedCategory = 'individuals';
  String _selectedDrawerItem = findOrganizationOrPlayersRoute;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    const String jsonData = '''
    {
      "individuals": [
        {"name": "John Doe", "username": "johndoe", "image": "assets/images/player1.png"},
        {"name": "Jane Smith", "username": "janesmith", "image": "assets/images/player2.jpg"},
        {"name": "Alice Johnson", "username": "alicejohnson", "image": "assets/images/player3.jpg"},
        {"name": "Bob Brown", "username": "bobbrown", "image": "assets/images/player4.png"},
        {"name": "Charlie Davis", "username": "charliedavis", "image": "assets/images/player5.jpg"},
        {"name": "Diana Evans", "username": "dianaevans", "image": "assets/images/player6.png"}
      ],
      "organizations": [
        {"name": "Org A", "username": "orga", "image": "assets/images/player1.png"},
        {"name": "Org B", "username": "orgb", "image": "assets/images/player2.jpg"},
        {"name": "Org C", "username": "orgc", "image": "assets/images/player3.jpg"},
        {"name": "Org D", "username": "orgd", "image": "assets/images/player4.png"},
        {"name": "Org E", "username": "orge", "image": "assets/images/player5.jpg"},
        {"name": "Org F", "username": "orgf", "image": "assets/images/player6.png"}
      ]
    }
    ''';
    final data = json.decode(jsonData);
    print(data); // Print the entire JSON data to check its structure
    setState(() {
      _profiles = List<Map<String, String>>.from(
        (data[_selectedCategory] as List).map((item) => Map<String, String>.from(item))
      );
      _filteredProfiles = _profiles;
    });
  }

  void _filterProfiles(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProfiles = _profiles.where((profile) {
        return profile['name']!.toLowerCase().contains(query.toLowerCase()) ||
               profile['username']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
        _loadProfiles();
      });
    }
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
        title: const Text('Find Organization or Players'),
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
                    onChanged: _filterProfiles,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: _onCategoryChanged,
                  items: <String>['individuals', 'organizations']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 32) / 3; // 16 padding on each side
                  final double cardHeight = cardWidth * 1.5; // Aspect ratio 2:3

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    itemCount: _filteredProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _filteredProfiles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              profile['image']!,
                              height: cardHeight * 0.4, // 40% of the card height
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                profile['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                profile['username']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}