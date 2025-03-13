import 'package:flutter/material.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}

class CustomDrawer extends StatelessWidget {
  final String selectedDrawerItem;
  final Function(String) onSelectDrawerItem;
  final List<DrawerItem> drawerItems;
  final VoidCallback onLogout; // Callback for logout

  const CustomDrawer({
    Key? key,
    required this.selectedDrawerItem,
    required this.onSelectDrawerItem,
    required this.drawerItems,
    required this.onLogout, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('User Name'),
            accountEmail: Text('user@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/player5.jpg'),
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ...drawerItems.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              selected: selectedDrawerItem == item.route, // Compare with route
              onTap: () => onSelectDrawerItem(item.route), // Use route for navigation
            );
          }).toList(),
          const Divider(), // Add a divider before the logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), // Logout icon
            title: const Text('Logout', style: TextStyle(color: Colors.red)), // Logout text
            onTap: onLogout, // Call the logout callback
          ),
        ],
      ),
    );
  }
}