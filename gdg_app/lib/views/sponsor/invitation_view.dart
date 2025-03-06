// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class InvitationsView extends StatefulWidget {
  const InvitationsView({super.key});

  @override
  _InvitationsViewState createState() => _InvitationsViewState();
}

class _InvitationsViewState extends State<InvitationsView> {
  List<Map<String, String>> _invitations = [
    {'name': 'Organization A', 'subject': 'Invitation to Event A'},
    {'name': 'Individual B', 'subject': 'Invitation to Join B'},
    {'name': 'Organization C', 'subject': 'Invitation to Event C'},
  ];
  List<Map<String, String>> _filteredInvitations = [];
  String _searchQuery = '';
  String _selectedDrawerItem = invitationToSponsorRoute;

  @override
  void initState() {
    super.initState();
    _filteredInvitations = _invitations;
  }

  void _filterInvitations(String query) {
    setState(() {
      _searchQuery = query;
      _filteredInvitations = _invitations.where((invitation) {
        return invitation['name']!.toLowerCase().contains(query.toLowerCase()) ||
               invitation['subject']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _deleteInvitation(int index) {
    setState(() {
      _filteredInvitations.removeAt(index);
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
        title: const Text('Invitations'),
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
            TextField(
              onChanged: _filterInvitations,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredInvitations.length,
                itemBuilder: (context, index) {
                  final invitation = _filteredInvitations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.mail, color: Colors.deepPurple),
                      title: Text(
                        invitation['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(invitation['subject']!),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteInvitation(index),
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