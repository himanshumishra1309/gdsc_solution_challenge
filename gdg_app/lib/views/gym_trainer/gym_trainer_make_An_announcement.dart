import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';

class GymTrainerMakeAnAnnouncement extends StatefulWidget {
  const GymTrainerMakeAnAnnouncement({super.key});

  @override
  _GymTrainerMakeAnAnnouncementState createState() =>
      _GymTrainerMakeAnAnnouncementState();
}

class _GymTrainerMakeAnAnnouncementState
    extends State<GymTrainerMakeAnAnnouncement> {
  final _authService = AuthService();
  List<dynamic> _announcements = [];
  final TextEditingController _announcementController = TextEditingController();
  int _nextId = 3; // Assuming the next ID for a new announcement
  String _selectedDrawerItem = trainerMakeAnAnnouncementRoute;
  bool _isLoading = true;
  final FocusNode _announcementFocusNode = FocusNode();

  // Current trainer info - in a real app, this would come from authentication/user profile
  final String _currentTrainerName = "Trainer Smith";
  final String _currentTrainerId = "trainer123";

  // Sport selection
  String _selectedSport = "All Sports";
  final List<String> _sportsList = [
    "All Sports",
    "Cricket",
    "Football",
    "Basketball",
    "Badminton",
    "Tennis"
  ];

  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadAnnouncements();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Trainer";
          _userEmail = userData['email'] ?? "";
          _userAvatar = userData['avatar'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  @override
  void dispose() {
    _announcementController.dispose();
    _announcementFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String response =
          await rootBundle.loadString('assets/json_files/announcements.json');
      final data = await json.decode(response);
      setState(() {
        _announcements = List.from(data['announcements'])
          ..sort((a, b) => DateTime.parse(b['timestamp'])
              .compareTo(DateTime.parse(a['timestamp'])));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading announcements: $e');
      setState(() {
        _isLoading = false;
        // Initialize with empty list if JSON couldn't be loaded
        _announcements = [];
      });
    }
  }

  void _addAnnouncement(String announcement) {
    if (announcement.trim().isEmpty) return;

    setState(() {
      _announcements.insert(0, {
        "id": _nextId++,
        "trainerName": _currentTrainerName,
        "trainerId": _currentTrainerId,
        "announcement": announcement,
        "timestamp": DateTime.now().toIso8601String(),
        "sport": _selectedSport,
        "fromTrainer": true, // Flag to identify trainer announcements
      });
    });
    _announcementController.clear();

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Training announcement posted for ${_selectedSport == "All Sports" ? "all sports" : _selectedSport}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _editAnnouncement(int id, String newAnnouncement, String sport) {
    if (newAnnouncement.trim().isEmpty) return;

    setState(() {
      final index =
          _announcements.indexWhere((announcement) => announcement['id'] == id);
      if (index != -1) {
        _announcements[index]['announcement'] = newAnnouncement;
        _announcements[index]['timestamp'] = DateTime.now().toIso8601String();
        _announcements[index]['sport'] = sport;
      }
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Announcement updated successfully!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Check if the current trainer can edit the announcement
  bool _canEditAnnouncement(Map<String, dynamic> announcement) {
    // If the announcement has a trainerId field, check it
    if (announcement.containsKey('trainerId')) {
      return announcement['trainerId'] == _currentTrainerId;
    }

    // For backward compatibility with older data structure
    if (announcement.containsKey('coachId')) {
      return false; // Trainers can't edit coach announcements
    }

    // For backward compatibility - check trainer name
    return announcement.containsKey('trainerName') &&
        announcement['trainerName'] == _currentTrainerName;
  }

  Future<void> _confirmDeleteAnnouncement(int id) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            const Text('Are you sure you want to delete this announcement?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteAnnouncement(id);
    }
  }

  void _deleteAnnouncement(int id) {
    setState(() {
      _announcements.removeWhere((announcement) => announcement['id'] == id);
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Announcement deleted!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _onSelectDrawerItem(String route) {
    setState(() {
      _selectedDrawerItem = route;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return to Home'),
        content: const Text('Do you want to return to the home page?'),
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
      Navigator.pushReplacementNamed(context, trainerHomeRoute);
    }

    return shouldLogout;
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, trainerHomeRoute);
  }

  void _showEditDialog(Map<String, dynamic> announcement) {
    final TextEditingController editController =
        TextEditingController(text: announcement['announcement']);
    String sport = announcement.containsKey('sport')
        ? announcement['sport']
        : "All Sports";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Announcement'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sport:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: sport,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            sport = newValue;
                          });
                        }
                      },
                      items: _sportsList
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Announcement:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: editController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _editAnnouncement(
                      announcement['id'], editController.text, sport);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Filter announcements by sport
  List<dynamic> _filterAnnouncements(String sportFilter) {
    if (sportFilter == "All") {
      return _announcements;
    } else {
      return _announcements.where((announcement) {
        String announcementSport = announcement.containsKey('sport')
            ? announcement['sport']
            : "All Sports";
        return announcementSport == "All Sports" ||
            announcementSport == sportFilter;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          icon: Icons.people,
          title: 'View all players',
          route: trainerHomeRoute),
      DrawerItem(
          icon: Icons.announcement,
          title: 'Make announcement',
          route: trainerMakeAnAnnouncementRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Mark upcoming sessions',
          route: trainerMarkSessionRoute),
      DrawerItem(
          icon: Icons.schedule,
          title: 'Update Gym Plan',
          route: trainerUpdateGymPlanRoute),
      DrawerItem(
          icon: Icons.medical_services,
          title: 'View Medical records',
          route: trainerViewPlayerMedicalReportRoute),
      DrawerItem(
          icon: Icons.person,
          title: 'View Profile',
          route: trainerProfileRoute),
    ];

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Training Announcements'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
          onLogout: _handleLogout,
          userName: _userName,
          userEmail: _userEmail,
          userAvatarUrl: _userAvatar,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Create announcement card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Create New Training Announcement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sport selection dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sports, color: Colors.deepPurple),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSport,
                                  isExpanded: true,
                                  hint: const Text("Select Sport"),
                                  items: _sportsList.map((String sport) {
                                    return DropdownMenuItem<String>(
                                      value: sport,
                                      child: Text(sport),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSport = newValue!;
                                    });
                                  },
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: _announcementController,
                        focusNode: _announcementFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Type your training announcement here...',
                          labelText: 'Announcement',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.deepPurple, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_announcementController.text.isNotEmpty) {
                            _addAnnouncement(_announcementController.text);
                            _announcementFocusNode.unfocus();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Post Announcement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Announcements filter and header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Colors.deepPurple),
                            onPressed: _loadAnnouncements,
                            tooltip: 'Refresh announcements',
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Announcements list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                        ),
                      )
                    : _announcements.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.announcement_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No announcements yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first training announcement above',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _announcements.length,
                            itemBuilder: (context, index) {
                              final announcement = _announcements[index];
                              final DateTime announcementTime =
                                  DateTime.parse(announcement['timestamp']);
                              final String formattedTime = DateFormat.yMMMd()
                                  .add_jm()
                                  .format(announcementTime);
                              final bool isRecent = DateTime.now()
                                      .difference(announcementTime)
                                      .inDays <
                                  1;
                              final bool isOwnAnnouncement =
                                  _canEditAnnouncement(announcement);
                              final String sport =
                                  announcement.containsKey('sport')
                                      ? announcement['sport']
                                      : "All Sports";

                              // Get the correct name field based on announcement type
                              final String authorName = announcement.containsKey('trainerName')
                                  ? announcement['trainerName']
                                  : announcement.containsKey('coachName')
                                      ? announcement['coachName']
                                      : "Unknown";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: announcement
                                              .containsKey('fromTrainer') &&
                                          announcement['fromTrainer'] == true
                                      ? Border.all(
                                          color: Colors.orange.shade200,
                                          width: 1.5)
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author and timestamp header
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: announcement.containsKey(
                                                    'fromTrainer') &&
                                                announcement['fromTrainer'] ==
                                                    true
                                            ? Colors.orange.withOpacity(0.05)
                                            : Colors.deepPurple
                                                .withOpacity(0.05),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: announcement
                                                        .containsKey(
                                                            'fromTrainer') &&
                                                    announcement[
                                                            'fromTrainer'] ==
                                                        true
                                                ? Colors.orange
                                                : Colors.deepPurple,
                                            radius: 18,
                                            child: Icon(
                                              announcement.containsKey(
                                                          'fromTrainer') &&
                                                      announcement[
                                                              'fromTrainer'] ==
                                                          true
                                                  ? Icons.fitness_center
                                                  : Icons.person,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  authorName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      formattedTime,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .deepPurple.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Colors
                                                                .deepPurple
                                                                .shade200),
                                                      ),
                                                      child: Text(
                                                        sport,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .deepPurple[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isRecent)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'New',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Announcement content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        announcement['announcement'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),

                                    // Action buttons - only show if current trainer created the announcement
                                    if (isOwnAnnouncement)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined),
                                              color: Colors.blue,
                                              onPressed: () =>
                                                  _showEditDialog(announcement),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              color: Colors.red,
                                              onPressed: () =>
                                                  _confirmDeleteAnnouncement(
                                                      announcement['id']),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}