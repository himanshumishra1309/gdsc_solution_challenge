import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualGameView extends StatefulWidget {
  const IndividualGameView({super.key});

  @override
  _IndividualGameViewState createState() => _IndividualGameViewState();
}

class _IndividualGameViewState extends State<IndividualGameView> {
  String _selectedDrawerItem = gameVideosRoute; // Highlight the current page
  String _selectedSport = 'Cricket';
  List<String> _uploadedVideos = [];

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  void _pickVideos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _uploadedVideos.addAll(result.paths.map((path) => path!).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.home, title: 'Home', route: individualHomeRoute),
      DrawerItem(icon: Icons.upload_file, title: 'Upload Achievement', route: uploadAchievementRoute),
      DrawerItem(icon: Icons.video_library, title: 'Game Videos', route: gameVideosRoute),
      DrawerItem(icon: Icons.contact_mail, title: 'View and Contact Sponsor', route: viewContactSponsorRoute),
      DrawerItem(icon: Icons.fastfood, title: 'Daily Diet Plan', route: individualDailyDietRoute),
      DrawerItem(icon: Icons.fitness_center, title: 'Gym Plan', route: individualGymPlanRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Videos'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Select Sport',
                border: OutlineInputBorder(),
              ),
              items: <String>['Cricket', 'Badminton', 'Football']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSport = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedVideos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.video_library),
                    title: Text(_uploadedVideos[index].split('/').last),
                    onTap: () {
                      // Implement video playback functionality
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideos,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}