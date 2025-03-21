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
  final VoidCallback onLogout;
  
  // Add user info parameters
  final String userName;
  final String userEmail;
  final String? userAvatarUrl;

  const CustomDrawer({
    Key? key,
    required this.selectedDrawerItem,
    required this.onSelectDrawerItem,
    required this.drawerItems,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    this.userAvatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              backgroundImage: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                  ? NetworkImage(userAvatarUrl!) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
              child: userAvatarUrl == null || userAvatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ...drawerItems.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              selected: selectedDrawerItem == item.route,
              onTap: () => onSelectDrawerItem(item.route),
            );
          }).toList(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}