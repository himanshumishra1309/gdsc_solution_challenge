import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, coachAdminPlayerRoute); // Replace with your home route
    }

    return shouldLogout;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Home'),
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
          selectedDrawerItem: adminHomeRoute,
          onSelectDrawerItem: (route) {
            Navigator.pop(context); // Close the drawer
            if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.pushNamed(context, route);
            }
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
            DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
          ],
        ),
        body: const Center(
          child: Text(
            'Admin Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}
