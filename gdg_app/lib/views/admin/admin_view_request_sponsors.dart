// Import statements remain the same
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminViewRequestSponsors extends StatefulWidget {
  const AdminViewRequestSponsors({super.key});

  @override
  _AdminViewRequestSponsorsState createState() => _AdminViewRequestSponsorsState();
}

class _AdminViewRequestSponsorsState extends State<AdminViewRequestSponsors> with SingleTickerProviderStateMixin {
  // Service and user data
  final _authService = AuthService();
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  
  // Sponsor data
  List<dynamic> _currentSponsors = [];
  List<dynamic> _potentialSponsors = [];
  List<dynamic> _filteredSponsors = [];
  List<dynamic> _sponsorTiers = [];
  List<dynamic> _sportFilters = [];
  List<dynamic> _contactFormFields = [];
  List<dynamic> _addSponsorFields = [];
  
  // UI state
  String _searchQuery = '';
  String _selectedMode = 'View';
  String _selectedSport = 'All';
  String _selectedTier = 'All';
  bool _isLoading = true;
  bool _isGridView = false;
  late TabController _tabController;

  @override
  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);  // Change from 2 to 3
  _tabController.addListener(_handleTabChange);
  _loadUserInfo();
  _loadSponsorsData();
}

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
  if (_tabController.indexIsChanging) {
    setState(() {
      if (_tabController.index == 0) {
        _selectedMode = 'View';
        _filteredSponsors = _currentSponsors;
      } else if (_tabController.index == 1) {
        _selectedMode = 'Request';
        _filteredSponsors = _potentialSponsors;
      } else {
        _selectedMode = 'All';
        _filteredSponsors = [..._currentSponsors, ..._potentialSponsors];
      }
      _filterSponsors();
    });
  }
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

  Future<void> _loadSponsorsData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load the comprehensive sponsors data JSON file
      final String response = await rootBundle.loadString('assets/json_files/sponsors_data.json');
      final data = await json.decode(response);
      
      setState(() {
        _currentSponsors = data['currentSponsors'] ?? [];
        _potentialSponsors = data['potentialSponsors'] ?? [];
        _sponsorTiers = data['sponsorTiers'] ?? [];
        _sportFilters = data['sportFilters'] ?? [];
        _contactFormFields = data['contactFormFields'] ?? [];
        _addSponsorFields = data['addSponsorFields'] ?? [];
        
        _filteredSponsors = _tabController.index == 0 ? _currentSponsors : _potentialSponsors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentSponsors = [];
        _potentialSponsors = [];
        _filteredSponsors = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading sponsors: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterSponsors();
    });
  }

  void _onModeChanged(String? mode) {
    setState(() {
      _selectedMode = mode!;
      _filterSponsors();
      _tabController.animateTo(_selectedMode == 'View' ? 0 : 1);
    });
  }

  void _onSportChanged(String? sport) {
    setState(() {
      _selectedSport = sport!;
      _filterSponsors();
    });
  }
  
  void _onTierChanged(String? tier) {
    setState(() {
      _selectedTier = tier!;
      _filterSponsors();
    });
  }
  
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  Color _getTierColor(String tier) {
    final tierItem = _sponsorTiers.firstWhere(
      (item) => item['name'] == tier,
      orElse: () => {'color': 'deepPurple'}
    );
    
    return _getColorFromString(tierItem['color']);
  }
  
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blueGrey700': return Colors.blueGrey.shade700;
      case 'amber700': return Colors.amber.shade700;
      case 'blueGrey400': return Colors.blueGrey.shade400;
      case 'brown500': return Colors.brown.shade500;
      case 'deepPurple': 
      default: return Colors.deepPurple;
    }
  }
  
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'sports': return Icons.sports;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'sports_cricket': return Icons.sports_cricket;
      case 'sports_basketball': return Icons.sports_basketball;
      case 'sports_tennis': return Icons.sports_tennis;
      case 'sports_volleyball': return Icons.sports_volleyball;
      case 'pool': return Icons.pool;
      default: return Icons.sports;
    }
  }

  void _filterSponsors() {
    setState(() {
      if (_selectedMode == 'View') {
        _filteredSponsors = _currentSponsors.where((sponsor) {
          final matchesSearch = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                               (sponsor['contactPerson']?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
          final matchesTier = _selectedTier == 'All' || sponsor['tier'] == _selectedTier;
          final matchesSport = _selectedSport == 'All' || 
                              (sponsor['supportedSports'] as List).contains(_selectedSport);
          return matchesSearch && matchesTier && matchesSport;
        }).toList();
      } else {
        _filteredSponsors = _potentialSponsors.where((sponsor) {
          final matchesSearch = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                               (sponsor['contactPerson']?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
          final matchesSport = _selectedSport == 'All' || 
                              (sponsor['sports'] as List).contains(_selectedSport);
          return matchesSearch && matchesSport;
        }).toList();
      }
    });
  }

  void _showSponsorDetails(Map<String, dynamic> sponsor) {
  final isCurrentSponsor = sponsor['isCurrentSponsor'] == true || sponsor.containsKey('tier');
  final sponsorColor = isCurrentSponsor 
      ? _getTierColor(sponsor['tier'] ?? 'Bronze') 
      : Colors.deepPurple;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Ensure dialog fits on screen properly
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with sponsor profile
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: sponsorColor.withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: sponsorColor.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(sponsor['profilePhoto'] ?? 'assets/images/player1.png'),
                          onBackgroundImageError: (_, __) => const Icon(Icons.business, size: 30),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sponsor['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (isCurrentSponsor)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sponsorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: sponsorColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  sponsor['tier'] ?? 'Bronze',
                                  style: TextStyle(
                                    color: sponsorColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(Icons.sports, size: 14, color: Colors.grey.shade700),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      ((sponsor['sports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []).join(', '),
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 30),
                  
                  // Contact information
                  _buildInfoRow(Icons.email, 'Email', sponsor['email'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone, 'Phone', sponsor['phone'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on, 'Location', sponsor['location'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.person, 'Contact Person', sponsor['contactPerson'] ?? 'N/A'),
                  const SizedBox(height: 10),
                  
                  // Sponsor-type specific information
                  if (isCurrentSponsor) ...[
                    _buildInfoRow(Icons.calendar_today, 'Since', sponsor['since'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.attach_money, 'Contribution', sponsor['contribution'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.sports, 
                      'Supported Sports', 
                      ((sponsor['supportedSports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []).join(', '),
                    ),
                  ] else ...[
                    _buildInfoRow(Icons.interests, 'Interest Level', sponsor['interestLevel'] ?? 'N/A'),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.business, 'Company', sponsor['company'] ?? sponsor['name'] ?? 'N/A'),
                    const SizedBox(height: 10),
                  ],
                  
                  const SizedBox(height: 10),
                  const Text(
                    'Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      sponsor['details'] ?? 'No additional details available.',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons at the bottom
                  Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.end,
    children: [
      if (!isCurrentSponsor) ...[
        // For potential sponsors
        ElevatedButton.icon(
          icon: const Icon(Icons.add_business, size: 18),
          label: const Text('Add as Sponsor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _addAsSponsor(sponsor);
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Remove'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _removeFromPotential(sponsor);
          },
        ),
      ],
      // Add this new section for current sponsors
      if (isCurrentSponsor) ... [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_task, size: 18),
          label: const Text('Add to Potential'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _addToPotentialSponsors(sponsor);
          },
        ),
      ],
      // Contact button for all types
      ElevatedButton.icon(
        icon: const Icon(Icons.email, size: 18),
        label: const Text('Contact'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          _showContactSponsorDialog(sponsor);
        },
      ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.deepPurple,
          side: const BorderSide(color: Colors.deepPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Method to add a potential sponsor as a current sponsor
void _addAsSponsor(Map<String, dynamic> potentialSponsor) {
  // Create a new current sponsor entry from the potential sponsor
  final newCurrentSponsor = {
    "id": "c${_currentSponsors.length + 1}",
    "name": potentialSponsor['name'],
    "profilePhoto": potentialSponsor['profilePhoto'],
    "email": potentialSponsor['email'],
    "phone": potentialSponsor['phone'],
    "location": potentialSponsor['location'],
    "contactPerson": potentialSponsor['contactPerson'],
    "tier": "Bronze", // Default tier for new sponsors
    "since": "${DateTime.now().year}",
    "contribution": "New Sponsor",
    "supportedSports": potentialSponsor['sports'],
    "details": potentialSponsor['details'],
    "website": potentialSponsor['website'] ?? ""
  };
  
  setState(() {
    // Add to current sponsors
    _currentSponsors.add(newCurrentSponsor);
    
    // Remove from potential sponsors
    _potentialSponsors.removeWhere((s) => s['id'] == potentialSponsor['id']);
    
    // Update filtered list
    _filterSponsors();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${potentialSponsor['name']} added as a sponsor'),
        backgroundColor: Colors.green,
      ),
    );
  });
}

// Method to remove a sponsor from potential list
void _removeFromPotential(Map<String, dynamic> potentialSponsor) {
  setState(() {
    _potentialSponsors.removeWhere((s) => s['id'] == potentialSponsor['id']);
    
    // Update filtered list
    _filterSponsors();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${potentialSponsor['name']} removed from potential sponsors'),
        backgroundColor: Colors.red,
      ),
    );
  });
}

  // New method to add a current sponsor to potential sponsors list
  void _addToPotentialSponsors(Map<String, dynamic> currentSponsor) {
    // Create a new potential sponsor entry from the current sponsor
    final newPotentialSponsor = {
      "id": "p${currentSponsor['id']}",
      "name": currentSponsor['name'],
      "profilePhoto": currentSponsor['profilePhoto'],
      "email": currentSponsor['email'],
      "phone": currentSponsor['phone'],
      "location": currentSponsor['location'],
      "company": currentSponsor['name'],
      "interestLevel": "High",
      "sports": currentSponsor['supportedSports'],
      "details": "Converting from current sponsor to potential new partnership. ${currentSponsor['details']}",
      "contactPerson": currentSponsor['contactPerson'],
      "notes": "Previously a ${currentSponsor['tier']} tier sponsor. Contributed ${currentSponsor['contribution']}.",
      "website": currentSponsor['website'] ?? ""
    };
    
    setState(() {
      // Check if this sponsor is already in the potential list
      final alreadyExists = _potentialSponsors.any((s) => s['id'] == newPotentialSponsor['id']);
      
      if (!alreadyExists) {
        _potentialSponsors.add(newPotentialSponsor);
        
        // Update filtered list if in potential sponsors tab
        if (_selectedMode == 'Request') {
          _filterSponsors();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentSponsor['name']} added to potential sponsors'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentSponsor['name']} is already in potential sponsors'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showContactSponsorDialog(Map<String, dynamic> sponsor) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    
    // Pre-fill with template for better UX
    subjectController.text = "Partnership opportunity with ${sponsor['name']}";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact ${sponsor['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your message here...'
                  ),
                ),
                const SizedBox(height: 16),
                // Show recipient info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipient Information:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${sponsor['contactPerson'] ?? sponsor['name']}'),
                      Text('Email: ${sponsor['email']}'),
                      if (sponsor['phone'] != null)
                        Text('Phone: ${sponsor['phone']}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message sent to ${sponsor['name']}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showAddSponsorDialog() {
    // Create controllers for each field
    final Map<String, TextEditingController> controllers = {};
    final selectedSports = <String>[];
    String selectedInterestLevel = 'Medium';
    
    for (final field in _addSponsorFields) {
      if (field['type'] != 'multiselect' && field['type'] != 'select') {
        controllers[field['id']] = TextEditingController();
      }
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Sponsor Lead'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Generate form fields from JSON
                    ..._addSponsorFields.map((field) {
                      if (field['type'] == 'multiselect') {
                        // Sport selection
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field['label'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _sportFilters
                                  .where((sport) => sport['name'] != 'All')
                                  .map<Widget>((sport) {
                                final sportName = sport['name'];
                                final isSelected = selectedSports.contains(sportName);
                                
                                return FilterChip(
                                  label: Text(sportName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedSports.add(sportName);
                                      } else {
                                        selectedSports.remove(sportName);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.deepPurple.withOpacity(0.2),
                                  checkmarkColor: Colors.deepPurple,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      } else if (field['type'] == 'select') {
                        // Interest level dropdown
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              field['label'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedInterestLevel,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: (field['options'] as List).map<DropdownMenuItem<String>>((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedInterestLevel = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      } else {
                        // Text fields
                        return Column(
                          children: [
                            TextField(
                              controller: controllers[field['id']],
                              maxLines: field['maxLines'] ?? 1,
                              decoration: InputDecoration(
                                labelText: field['label'],
                                hintText: field['placeholder'] ?? '',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Validate required fields
                    for (final field in _addSponsorFields) {
                      if (field['required'] == true) {
                        if (field['type'] == 'multiselect' && selectedSports.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select at least one sport'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                          // Continuing from where the code was cut off in the _showAddSponsorDialog method
                        } else if (field['type'] != 'multiselect' && 
                                  field['type'] != 'select' && 
                                  controllers[field['id']]!.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill in the ${field['label']} field'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }
                    }
                    
                    // Create new sponsor object
                    final newSponsor = {
                      "id": "p${_potentialSponsors.length + 1}",
                      "name": controllers['name']!.text,
                      "profilePhoto": "assets/images/sponsors/default.png", // Default image
                      "email": controllers['email']!.text,
                      "phone": controllers['phone']!.text,
                      "location": controllers['location']!.text,
                      "company": controllers['name']!.text,
                      "interestLevel": selectedInterestLevel,
                      "sports": selectedSports,
                      "details": controllers['details']?.text ?? "",
                      "contactPerson": controllers['contactPerson']!.text,
                      "notes": "",
                      "website": controllers['website']?.text ?? ""
                    };
                    
                    setState(() {
                      _potentialSponsors.add(newSponsor);
                      
                      // Update filtered list if in potential sponsors tab
                      if (_selectedMode == 'Request') {
                        _filterSponsors();
                      }
                    });
                    
                    Navigator.pop(context);
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${newSponsor['name']} added as a potential sponsor!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Add Sponsor'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerItems = [
      DrawerItem(icon: Icons.home, title: 'Admin Home', route: adminHomeRoute),
      DrawerItem(icon: Icons.person_add, title: 'Register Admin', route: registerAdminRoute),
      DrawerItem(icon: Icons.person_add, title: 'Register Coach', route: registerCoachRoute),
      DrawerItem(icon: Icons.person_add, title: 'Register Player', route: registerPlayerRoute),
      DrawerItem(icon: Icons.people, title: 'View All Players', route: viewAllPlayersRoute),
      DrawerItem(icon: Icons.people, title: 'View All Coaches', route: viewAllCoachesRoute),
      DrawerItem(icon: Icons.request_page, title: 'Request/View Sponsors', route: requestViewSponsorsRoute),
      DrawerItem(icon: Icons.video_library, title: 'Video Analysis', route: videoAnalysisRoute),
      DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sponsorship Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSponsorDialog,
            tooltip: 'Add Potential Sponsor',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: requestViewSponsorsRoute,
        onSelectDrawerItem: (route) {
          Navigator.pushReplacementNamed(context, route);
        },
        drawerItems: drawerItems,
        onLogout: () async {
          await _authService.logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
          }
        },
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Column(
              children: [
                // Search and filters header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search sponsors...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tab selector
                      Container(
  height: 56,
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(10),
  ),
  child: TabBar(
    controller: _tabController,
    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
    indicator: BoxDecoration(
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(10),
    ),
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey[700],
    tabs: [
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Current',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handshake, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Potential',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'All',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
                      
                      const SizedBox(height: 16),
                      
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Sport filters
                            ..._sportFilters.map((sport) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(sport['name']),
                                selected: _selectedSport == sport['name'],
                                onSelected: (selected) {
                                  _onSportChanged(sport['name']);
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.deepPurple.withOpacity(0.1),
                                checkmarkColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: _selectedSport == sport['name'] 
                                        ? Colors.deepPurple 
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            )),
                            
                            // Tier filters (only show for current sponsors tab)
                            if (_tabController.index == 0) ...[
                              const VerticalDivider(
                                width: 24,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                                color: Colors.grey,
                              ),
                              ..._sponsorTiers.map((tier) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(tier['name']),
                                  selected: _selectedTier == tier['name'],
                                  onSelected: (selected) {
                                    _onTierChanged(tier['name']);
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: _getColorFromString(tier['color']).withOpacity(0.1),
                                  checkmarkColor: _getColorFromString(tier['color']),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: _selectedTier == tier['name'] 
                                          ? _getColorFromString(tier['color']) 
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Sponsor list/grid
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Current Sponsors Tab
                      _buildSponsorsList(_currentSponsors, true),
                      
                      // Potential Sponsors Tab
                      _buildSponsorsList(_potentialSponsors, false),
                      
                      // All Sponsors Tab (New Tab)
                      _buildAllSponsorsList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  // Add this new method to build the All Sponsors list
  Widget _buildAllSponsorsList() {
  // Create a safe copy of the sponsors with proper null checks
  final List<Map<String, dynamic>> allSponsors = [];
  
  // Process current sponsors
  for (final sponsor in _currentSponsors) {
    final safeSponsor = Map<String, dynamic>.from(sponsor);
    
    // Ensure supportedSports is not null
    if (!safeSponsor.containsKey('supportedSports') || safeSponsor['supportedSports'] == null) {
      safeSponsor['supportedSports'] = <String>[];
    }
    
    // Ensure we know it's a current sponsor
    safeSponsor['isCurrentSponsor'] = true;
    allSponsors.add(safeSponsor);
  }
  
  // Process potential sponsors
  for (final sponsor in _potentialSponsors) {
    final safeSponsor = Map<String, dynamic>.from(sponsor);
    
    // Ensure sports is not null
    if (!safeSponsor.containsKey('sports') || safeSponsor['sports'] == null) {
      safeSponsor['sports'] = <String>[];
    }
    
    // Flag as not a current sponsor
    safeSponsor['isCurrentSponsor'] = false;
    allSponsors.add(safeSponsor);
  }
  
  // Filter based on search and sport
  final filteredList = allSponsors.where((sponsor) {
    // Handle null-safe search
    final nameMatch = (sponsor['name']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    final contactMatch = (sponsor['contactPerson']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    final matchesSearch = nameMatch || contactMatch;
    
    // Determine which sports field to use and handle null-safe comparison
    final List<dynamic> sportsField = sponsor['isCurrentSponsor'] == true
        ? (sponsor['supportedSports'] ?? [])
        : (sponsor['sports'] ?? []);
    
    final matchesSport = _selectedSport == 'All' || 
                         sportsField.any((sport) => sport.toString() == _selectedSport);
    
    return matchesSearch && matchesSport;
  }).toList();

  // Return appropriate view based on grid/list setting
  if (_isGridView) {
    return filteredList.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sponsors found matching your filters.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final sponsor = filteredList[index];
              return _buildSponsorGridItem(sponsor);
            },
          );
  } else {
    return filteredList.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sponsors found matching your filters.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final sponsor = filteredList[index];
              final isCurrentSponsor = sponsor['isCurrentSponsor'] == true;
              return _buildSponsorListItem(sponsor, isCurrentSponsor);
            },
          );
  }
}
  
  Widget _buildSponsorGridItem(Map<String, dynamic> sponsor) {
  final isCurrent = sponsor['isCurrentSponsor'] == true;
  final Color cardColor = Colors.white;
  final Color accentColor = isCurrent 
      ? _getTierColor(sponsor['tier'] ?? 'Bronze')
      : Colors.deepPurple;
  
  return AnimationConfiguration.staggeredGrid(
    position: 0, // Use a constant to avoid errors if not in filtered list
    columnCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
    duration: const Duration(milliseconds: 375),
    child: ScaleAnimation(
      child: FadeInAnimation(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          color: cardColor,
          child: InkWell(
            onTap: () => _showSponsorDetails(sponsor),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(sponsor['profilePhoto'] ?? 'assets/images/player1.png'),
                      onBackgroundImageError: (_, __) => const Icon(Icons.business, size: 36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sponsor['name'] ?? 'Unknown',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        sponsor['tier'] ?? 'Bronze',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        sponsor['interestLevel'] ?? 'Medium',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          sponsor['details'] ?? 'No details available',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Material(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${sponsor['contactPerson'] ?? sponsor['name']}...'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.phone, size: 20, color: accentColor),
                          ),
                        ),
                      ),
                      Material(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => _showContactSponsorDialog(sponsor),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.email, size: 20, color: accentColor),
                          ),
                        ),
                      ),
                      Material(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => _showSponsorDetails(sponsor),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.info_outline, size: 20, color: accentColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSponsorsList(List<dynamic> sponsors, bool isCurrentSponsors) {
    // Filter sponsors based on search query and selected filters
    final filteredList = sponsors.where((sponsor) {
      final matchesSearch = sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          (sponsor['contactPerson']?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
      
      final List<dynamic> sportsField = isCurrentSponsors 
          ? sponsor['supportedSports'] ?? [] 
          : sponsor['sports'] ?? [];
      
      final matchesSport = _selectedSport == 'All' || sportsField.contains(_selectedSport);
      
      // Only check tier for current sponsors
      final matchesTier = !isCurrentSponsors || _selectedTier == 'All' || sponsor['tier'] == _selectedTier;
      
      return matchesSearch && matchesSport && matchesTier;
    }).toList();
    
    if (_isGridView) {
      return filteredList.isEmpty
          ? const Center(child: Text('No sponsors found matching your filters.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final sponsor = filteredList[index];
                return _buildSponsorGridItem(sponsor);
              },
            );
    } else {
      return filteredList.isEmpty
          ? const Center(child: Text('No sponsors found matching your filters.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final sponsor = filteredList[index];
                return _buildSponsorListItem(sponsor, isCurrentSponsors);
              },
            );
    }
  }
  
  Widget _buildSponsorListItem(Map<String, dynamic> sponsor, bool isCurrentSponsor) {
     final Color borderColor = isCurrentSponsor 
      ? _getTierColor(sponsor['tier'] ?? 'Bronze').withOpacity(0.2)
      : Colors.deepPurple.withOpacity(0.2);
        
    return AnimationConfiguration.staggeredList(
      position: _filteredSponsors.indexOf(sponsor),
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
            ),
            elevation: 1,
            color: Colors.white,
            child: InkWell(
              onTap: () => _showSponsorDetails(sponsor),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(sponsor['profilePhoto'] ?? 'assets/images/player1.png'),
                      onBackgroundImageError: (_, __) => const Icon(Icons.business, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sponsor['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isCurrentSponsor)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTierColor(sponsor['tier'] ?? 'Bronze').withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _getTierColor(sponsor['tier'] ?? 'Bronze').withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    sponsor['tier'] ?? 'Bronze',
                                    style: TextStyle(
                                      color: _getTierColor(sponsor['tier'] ?? 'Bronze'),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    sponsor['interestLevel'] ?? 'Medium',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                sponsor['contactPerson'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.sports, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isCurrentSponsor
                                      ? ((sponsor['supportedSports'] as List<dynamic>?)?.join(', ') ?? 'N/A')
                                      : ((sponsor['sports'] as List<dynamic>?)?.join(', ') ?? 'N/A'),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action buttons column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.email, size: 20),
                          onPressed: () => _showContactSponsorDialog(sponsor),
                          color: Colors.deepPurple,
                          tooltip: 'Contact',
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 20),
                          onPressed: () => _showSponsorDetails(sponsor),
                          color: Colors.deepPurple,
                          tooltip: 'Details',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}