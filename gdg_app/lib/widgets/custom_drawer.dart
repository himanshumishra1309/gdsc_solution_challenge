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
  
  // User info parameters
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
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean header with user info
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 24,
                left: 24,
                right: 24
              ),
              color: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    backgroundImage: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                        ? NetworkImage(userAvatarUrl!)
                        : null,
                    child: userAvatarUrl == null || userAvatarUrl!.isEmpty
                        ? Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // User name
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // User email
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  
                  // Menu items
                  ...drawerItems.map((item) {
                    final isSelected = selectedDrawerItem == item.route;
                    
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.deepPurple : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.deepPurple.withOpacity(0.08),
                      onTap: () => onSelectDrawerItem(item.route),
                    );
                  }).toList(),
                  
                  // Simple divider
                  const Divider(height: 32),
                  
                  // Logout button
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.red.shade400,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                    onTap: onLogout,
                  ),
                  
                  // Version info
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}