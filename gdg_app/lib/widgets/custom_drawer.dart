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

  const CustomDrawer({
    Key? key,
    required this.selectedDrawerItem,
    required this.onSelectDrawerItem,
    required this.drawerItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
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
        ],
      ),
    );
  }
}