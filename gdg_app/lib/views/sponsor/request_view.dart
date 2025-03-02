// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  _RequestsViewState createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  List<Map<String, String>> _requests = [
    {'name': 'Organization X', 'subject': 'Request for Sponsorship'},
    {'name': 'Individual Y', 'subject': 'Request for Support'},
    {'name': 'Organization Z', 'subject': 'Request for Collaboration'},
  ];
  List<Map<String, String>> _filteredRequests = [];
  String _searchQuery = '';
  String _selectedDrawerItem = requestToSponsorPageRoute;

  @override
  void initState() {
    super.initState();
    _filteredRequests = _requests;
  }

  void _filterRequests(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRequests = _requests.where((request) {
        return request['name']!.toLowerCase().contains(query.toLowerCase()) ||
               request['subject']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _deleteRequest(int index) {
    setState(() {
      _filteredRequests.removeAt(index);
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
        title: const Text('Requests'),
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
              onChanged: _filterRequests,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = _filteredRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.mail, color: Colors.deepPurple),
                      title: Text(
                        request['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(request['subject']!),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRequest(index),
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