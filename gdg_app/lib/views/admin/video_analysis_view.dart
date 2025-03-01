import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:file_picker/file_picker.dart';

class VideoAnalysisView extends StatefulWidget {
  const VideoAnalysisView({super.key});

  @override
  _VideoAnalysisViewState createState() => _VideoAnalysisViewState();
}

class _VideoAnalysisViewState extends State<VideoAnalysisView> {
  String _searchQuery = '';
  String _selectedSport = 'All';
  DateTime? _selectedDate;
  String? _selectedFile;
  List<dynamic> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final String response = await rootBundle.loadString('assets/videos.json');
    final data = await json.decode(response);
    setState(() {
      _videos = data;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
    });
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _selectedFile = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  void _showUploadPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Video', style: TextStyle(color: Colors.deepPurple)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Choose File', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                Text('Selected File: $_selectedFile', style: const TextStyle(color: Colors.deepPurple)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              onPressed: _selectedFile != null ? _showConfirmationPopup : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(color: Colors.deepPurple)),
          content: const Text('Are you sure you want to upload this video?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No', style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                _uploadVideo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _uploadVideo() {
    // Implement the upload functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video uploaded successfully')),
    );
  }

  void _showVideoDetails(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(video['title'] ?? 'N/A', style: const TextStyle(color: Colors.deepPurple)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.asset(video['thumbnail'] ?? 'assets/default_thumbnail.png'),
                const SizedBox(height: 16),
                Text('Description: ${video['description'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Uploaded by: ${video['uploadedBy'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Date: ${video['date'] ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredVideos = _videos.where((video) {
      final matchesQuery = video['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSport = _selectedSport == 'All' || video['sport'] == _selectedSport;
      final matchesDate = _selectedDate == null || video['date'] == _selectedDate.toString();
      return matchesQuery && matchesSport && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Analysis'),
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
        selectedDrawerItem: videoAnalysisRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: _onSearchChanged,
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

            // Dropdown and Calendar in a Row
            Row(
              children: [
                // Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSport,
                    onChanged: _onSportChanged,
                    decoration: InputDecoration(
                      labelText: 'Sport',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    items: <String>['All', 'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),

                // Calendar Icon Button
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      _onDateChanged(picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Video List
            Expanded(
              child: ListView.builder(
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = filteredVideos[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(video['thumbnail'] ?? 'assets/default_thumbnail.png'),
                      ),
                      title: Text(video['title'] ?? 'N/A'),
                      subtitle: Text(video['description'] ?? 'N/A'),
                      onTap: () => _showVideoDetails(video),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadPopup,
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}