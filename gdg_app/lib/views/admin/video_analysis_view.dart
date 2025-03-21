import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/serivces/auth_service.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class VideoAnalysisView extends StatefulWidget {
  const VideoAnalysisView({super.key});

  @override
  _VideoAnalysisViewState createState() => _VideoAnalysisViewState();
}

class _VideoAnalysisViewState extends State<VideoAnalysisView> {
  final _authService = AuthService();
  String _searchQuery = '';
  String _selectedSport = 'All';
  DateTime? _selectedDate;
  String? _selectedFile;
  List<dynamic> _videos = [];
  bool _isLoading = true;
  bool _isGridView = false;
  bool _showFilterOptions = false;
  String _sortBy = 'Date (Newest)';
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  final List<String> _sportOptions = [
    'All',
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Badminton',
    'Swimming',
    'Volleyball'
  ];
  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Title (A-Z)',
    'Title (Z-A)',
    'Most Viewed'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadVideos();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Admin";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 800));
      final String response = await rootBundle.loadString('assets/videos.json');
      final data = await json.decode(response);
      setState(() {
        _videos = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _videos = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading videos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  void _onSortByChanged(String? sortOption) {
    setState(() {
      _sortBy = sortOption!;
    });
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSport = 'All';
      _selectedDate = null;
      _sortBy = 'Date (Newest)';
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
    String title = '';
    String description = '';
    String selectedSport = 'Football';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.upload_file, color: Colors.deepPurple),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Upload Video',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    description = value;
                  },
                ),
                const SizedBox(height: 16),

                // Sport dropdown
                DropdownButtonFormField<String>(
                  value: selectedSport,
                  decoration: InputDecoration(
                    labelText: 'Sport',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.sports),
                  ),
                  items: _sportOptions
                      .where((sport) => sport != 'All')
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selectedSport = value!;
                  },
                ),
                const SizedBox(height: 24),

                // File selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Choose Video File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedFile != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.video_file,
                                  color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFile!,
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _selectedFile != null
                  ? () {
                      Navigator.pop(context);
                      _uploadVideo(title, description, selectedSport);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  void _uploadVideo(String title, String description, String sport) {
    // In a real app, you'd send this to your backend

    // Create a mock entry to add to the list
    final newVideo = {
      'id': _videos.length + 1,
      'title': title.isEmpty ? 'Untitled Video' : title,
      'description':
          description.isEmpty ? 'No description provided' : description,
      'sport': sport,
      'uploadedBy': 'Current User',
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'views': 0,
      'thumbnail': 'assets/images/video_thumbnail.jpg', // Default thumbnail
    };

    // Add to the list
    setState(() {
      _videos = [newVideo, ..._videos];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showVideoDetails(Map<String, dynamic> video) {
    // For demo purposes, we'll increase the view count when a video is viewed
    final updatedVideo = Map<String, dynamic>.from(video);
    updatedVideo['views'] = (video['views'] ?? 0) + 1;

    // Update the video in the list
    setState(() {
      final videoIndex = _videos.indexWhere((v) => v['id'] == video['id']);
      if (videoIndex != -1) {
        _videos[videoIndex] = updatedVideo;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video preview area
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      video['thumbnail'] ?? 'assets/default_thumbnail.png',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Video play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.7),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Sport tag in the top right
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        video['sport'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Video details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            video['title'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharing video...')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          video['date'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.remove_red_eye,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${updatedVideo['views'] ?? 0} views',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['description'] ?? 'No description available.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploaded by:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              video['uploadedBy'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Downloading video...')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
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

    // If user confirmed logout
    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Logging out...'),
                ],
              ),
            ),
          );
        },
      );

      try {
        // First clear local data directly
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Then try server-side logout, but don't block on it
        _authService.logout().catchError((e) {
          print('Server logout error: $e');
        });

        // Navigate to login page
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushNamedAndRemoveUntil(
            context,
            coachAdminPlayerRoute, // Make sure this constant is defined in your routes file
            (route) => false, // This clears the navigation stack
          );
        }
      } catch (e) {
        // Handle errors
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.filter_list,
                            color: Colors.deepPurple),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Filter Videos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _selectedSport = 'All';
                            _selectedDate = null;
                            _sortBy = 'Date (Newest)';
                          });
                          setState(() {
                            _selectedSport = 'All';
                            _selectedDate = null;
                            _sortBy = 'Date (Newest)';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sport',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sportOptions.map((sport) {
                      return FilterChip(
                        label: Text(sport),
                        selected: _selectedSport == sport,
                        selectedColor: Colors.deepPurple.withOpacity(0.2),
                        checkmarkColor: Colors.deepPurple,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedSport = sport;
                          });
                          setState(() {
                            _selectedSport = sport;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: _sortBy == option,
                        selectedColor: Colors.deepPurple.withOpacity(0.2),
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = option;
                          });
                          setState(() {
                            _sortBy = option;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : DateFormat('MMM d, yyyy')
                                    .format(_selectedDate!),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setModalState(() {
                                _selectedDate = picked;
                              });
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setModalState(() {
                              _selectedDate = null;
                            });
                            setState(() {
                              _selectedDate = null;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<dynamic> _getFilteredAndSortedVideos() {
    List<dynamic> filteredVideos = _videos.where((video) {
      final matchesQuery = (video['title'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesSport =
          _selectedSport == 'All' || video['sport'] == _selectedSport;
      final matchesDate = _selectedDate == null ||
          video['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate!);
      return matchesQuery && matchesSport && matchesDate;
    }).toList();

    // Sort the videos based on the selected option
    switch (_sortBy) {
      case 'Date (Newest)':
        filteredVideos
            .sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
        break;
      case 'Date (Oldest)':
        filteredVideos
            .sort((a, b) => (a['date'] ?? '').compareTo(b['date'] ?? ''));
        break;
      case 'Title (A-Z)':
        filteredVideos.sort((a, b) => (a['title'] ?? '')
            .toString()
            .compareTo((b['title'] ?? '').toString()));
        break;
      case 'Title (Z-A)':
        filteredVideos.sort((a, b) => (b['title'] ?? '')
            .toString()
            .compareTo((a['title'] ?? '').toString()));
        break;
      case 'Most Viewed':
        filteredVideos
            .sort((a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0));
        break;
    }

    return filteredVideos;
  }

  @override
  Widget build(BuildContext context) {
    final filteredVideos = _getFilteredAndSortedVideos();

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
        toolbarHeight: 60,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            color: Colors.white,
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: Colors.white,
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: videoAnalysisRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context); // Close the drawer
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
        },
        drawerItems: [
          DrawerItem(
              icon: Icons.home, title: 'Admin Home', route: adminHomeRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Admin',
              route: registerAdminRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Coach',
              route: registerCoachRoute),
          DrawerItem(
              icon: Icons.person_add,
              title: 'Register Player',
              route: registerPlayerRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View All Players',
              route: viewAllPlayersRoute),
          DrawerItem(
              icon: Icons.people,
              title: 'View All Coaches',
              route: viewAllCoachesRoute),
          DrawerItem(
              icon: Icons.request_page,
              title: 'Request/View Sponsors',
              route: requestViewSponsorsRoute),
          DrawerItem(
              icon: Icons.video_library,
              title: 'Video Analysis',
              route: videoAnalysisRoute),
          DrawerItem(
              icon: Icons.edit, title: 'Edit Forms', route: editFormsRoute),
          DrawerItem(
              icon: Icons.attach_money,
              title: 'Manage Player Finances',
              route: adminManagePlayerFinancesRoute),
        ],
        onLogout: () => _handleLogout(context),
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Column(
        children: [
          // Search bar in purple container
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search videos by title...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Active filters display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Selected sport chip
                  if (_selectedSport != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedSport),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedSport = 'All';
                          });
                        },
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        side: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.3)),
                      ),
                    ),

                  // Selected date chip
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(
                            DateFormat('MMM d, yyyy').format(_selectedDate!)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        side: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.3)),
                      ),
                    ),

                  // Sort chip
                  Chip(
                    label: Text('Sort: $_sortBy'),
                    avatar: const Icon(Icons.sort, size: 18),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Video count chip
                  Chip(
                    label: Text('${filteredVideos.length} Videos'),
                    avatar: const Icon(Icons.video_library, size: 18),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content - Videos grid/list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple))
                : filteredVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No videos found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your search criteria\nor upload a new video',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      )
                    : _isGridView
                        ? AnimationLimiter(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredVideos.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  columnCount: 2,
                                  duration: const Duration(milliseconds: 500),
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: _buildVideoGridCard(
                                          filteredVideos[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              itemCount: filteredVideos.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildVideoListCard(
                                          filteredVideos[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadPopup,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Upload Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGridCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () => _showVideoDetails(video),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with play icon and sport tag
              Stack(
                children: [
                  Image.asset(
                    video['thumbnail'] ?? 'assets/default_thumbnail.png',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  // Sport tag
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSportColor(video['sport'] ?? 'Default'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        video['sport'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  // Duration
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '3:45', // Placeholder for video duration
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
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
                      // Title
                      Text(
                        video['title'] ?? 'N/A',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Metadata
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatDate(video['date'] ?? ''),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.remove_red_eye,
                                    size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '${video['views'] ?? 0} views',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoListCard(Map<String, dynamic> video) {
    final sport = video['sport'] ?? 'Default';
    final sportColor = _getSportColor(sport);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showVideoDetails(video),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.asset(
                    video['thumbnail'] ?? 'assets/default_thumbnail.png',
                    height: 90,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Duration
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '3:45', // Placeholder for video duration
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and sport badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            video['title'] ?? 'N/A',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sportColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: sportColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            sport,
                            style: TextStyle(
                              color: sportColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Metadata
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(video['date'] ?? ''),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${video['views'] ?? 0} views',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${video['uploadedBy'] ?? 'Unknown'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getSportColor(String sport) {
    switch (sport) {
      case 'Football':
        return Colors.green;
      case 'Cricket':
        return Colors.blue;
      case 'Basketball':
        return Colors.orange;
      case 'Tennis':
        return Colors.red;
      case 'Badminton':
        return Colors.purple;
      case 'Swimming':
        return Colors.cyan;
      case 'Volleyball':
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }
}
