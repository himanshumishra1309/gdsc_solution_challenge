import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart'; // For date formatting

class IndividualGameView extends StatefulWidget {
  const IndividualGameView({super.key});

  @override
  _IndividualGameViewState createState() => _IndividualGameViewState();
}

class _IndividualGameViewState extends State<IndividualGameView> {
  String _selectedDrawerItem = gameVideosRoute;
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  List<String> _uploadedVideos = [];
  bool _isLoading = false;
  
  // Sample video data
  final List<Map<String, dynamic>> _sampleVideos = [
    {
      'title': 'Match Highlights vs Regional Champions',
      'sport': 'Cricket',
      'duration': '6:24',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'thumbnail': 'assets/images/cricket_thumbnail.jpg',
      'views': 128,
    },
    {
      'title': 'Training Session - Batting Technique',
      'sport': 'Cricket',
      'duration': '12:05',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'thumbnail': 'assets/images/batting_thumbnail.jpg',
      'views': 92,
    },
    {
      'title': 'Tournament Final - Full Match',
      'sport': 'Football',
      'duration': '48:32',
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'thumbnail': 'assets/images/football_thumbnail.jpg',
      'views': 215,
    },
    {
      'title': 'Skill Analysis Session',
      'sport': 'Badminton',
      'duration': '8:47',
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'thumbnail': 'assets/images/badminton_thumbnail.jpg',
      'views': 67,
    },
  ];
  
  List<Map<String, dynamic>> get _filteredVideos {
    return _sampleVideos.where((video) {
      final matchesSearch = _searchQuery.isEmpty || 
          video['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSport = _selectedSport == 'All Sports' || 
          video['sport'] == _selectedSport;
      return matchesSearch && matchesSport;
    }).toList();
  }

  final List<String> _sports = ['All Sports', 'Cricket', 'Football', 'Badminton', 'Basketball', 'Tennis', 'Golf', 'Swimming'];

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  Future<void> _pickVideos() async {
    setState(() {
      _isLoading = true;
    });
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _uploadedVideos.addAll(result.paths.map((path) => path!).toList());
        // In a real app, you would upload these files to a server here
        
        // Add to sample videos
        for (var path in result.paths) {
          final fileName = path!.split('/').last;
          _sampleVideos.add({
            'title': fileName.replaceAll(RegExp(r'\.\w+$'), ''),
            'sport': _selectedSport == 'All Sports' ? 'Other' : _selectedSport,
            'duration': '0:00', // Would be extracted from actual video
            'date': DateTime.now(),
            'thumbnail': 'assets/images/default_thumbnail.jpg',
            'views': 0,
          });
        }
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  final AuthService _authService = AuthService();
  
  // Update your _handleLogout method
  Future<void> _handleLogout() async {
    bool success = await _authService.logout();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }
  }

  // Update your _onWillPop method to use _handleLogout
  Future<bool> _onWillPop() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      await _handleLogout();
    }
    
    return false; // Return false to prevent app from closing
  }

  void _playVideo(Map<String, dynamic> video) {
    // Show a dialog indicating this is where video would play
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Playing Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              video['title'],
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${video['sport']} • ${video['duration']}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Game Videos'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
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
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: drawerItems,
        onLogout: () => _onWillPop(),
      ),
      body: Stack(
        children: [
          // Header background
          Container(
            height: 70,
            color: Colors.deepPurple,
          ),
          
          // Main content area
          Column(
            children: [
              // Search and filter section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search videos...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.deepPurple),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              
              // Sports filter section
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sports.length,
                  itemBuilder: (context, index) {
                    final sport = _sports[index];
                    final isSelected = _selectedSport == sport;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSport = sport;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          sport,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Video grid
              Expanded(
                child: _filteredVideos.isEmpty
                    ? _buildEmptyView()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = _filteredVideos[index];
                          return _buildVideoCard(video);
                        },
                      ),
              ),
            ],
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickVideos,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.video_call),
        label: const Text('Upload'),
      ),
    );
  }
  
  Widget _buildVideoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.deepPurple.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['sport'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Video details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${video['views']} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(video['date']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Videos Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedSport != 'All Sports'
                ? 'Try adjusting your filters'
                : 'Upload your game videos to get started',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedSport != 'All Sports')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedSport = 'All Sports';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}