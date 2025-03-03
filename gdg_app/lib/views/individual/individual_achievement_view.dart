import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualAchievementView extends StatefulWidget {
  const IndividualAchievementView({super.key});

  @override
  _IndividualAchievementViewState createState() => _IndividualAchievementViewState();
}

class _IndividualAchievementViewState extends State<IndividualAchievementView> {
  String _selectedDrawerItem = uploadAchievementRoute; // Highlight the current page
  String _selectedSport = 'Cricket';
  List<String> _uploadedFiles = [];

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _uploadedFiles.addAll(result.paths.map((path) => path!).toList());
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
      DrawerItem(icon: Icons.attach_money, title: 'Finances', route: individualFinancesRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Achievement'),
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
            ElevatedButton(
              onPressed: _pickFiles,
              child: const Text('Upload Achievement'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text(_uploadedFiles[index].split('/').last),
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