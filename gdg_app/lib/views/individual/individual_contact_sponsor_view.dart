import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this package for contact actions

class IndividualContactSponsorView extends StatefulWidget {
  const IndividualContactSponsorView({super.key});

  @override
  _IndividualContactSponsorViewState createState() => _IndividualContactSponsorViewState();
}

class _IndividualContactSponsorViewState extends State<IndividualContactSponsorView> {
  String _selectedDrawerItem = viewContactSponsorRoute;
  String _selectedSport = 'All Sports';
  String _searchQuery = '';
  bool _showFavorites = false;
  final List<Map<String, dynamic>> _sponsors = [
    {
      'name': 'SportsTech Global',
      'logo': 'assets/sponsor_image.png',
      'category': 'Corporate',
      'sports': ['Cricket', 'Football'],
      'email': 'contact@sportstech.com',
      'phone': '+1 (555) 123-4567',
      'website': 'www.sportstechglobal.com',
      'address': '123 Corporate Plaza, Silicon Valley, CA',
      'description': 'Leading provider of sports technology solutions and equipment.',
      'isFavorite': true,
    },
    {
      'name': 'Athletic Gear Co.',
      'logo': 'assets/sponsor_image.png',
      'category': 'Equipment',
      'sports': ['Cricket', 'Badminton', 'Basketball'],
      'email': 'sponsors@athleticgear.com',
      'phone': '+1 (555) 234-5678',
      'website': 'www.athleticgear.com',
      'address': '456 Sports Avenue, New York, NY',
      'description': 'Premium sports equipment and apparel for professional athletes.',
      'isFavorite': false,
    },
    {
      'name': 'Champion Nutrition',
      'logo': 'assets/sponsor_image.png',
      'category': 'Nutrition',
      'sports': ['All Sports'],
      'email': 'partnerships@championnutrition.com',
      'phone': '+1 (555) 345-6789',
      'website': 'www.championnutrition.com',
      'address': '789 Health Blvd, Los Angeles, CA',
      'description': 'Science-backed nutrition solutions for peak athletic performance.',
      'isFavorite': true,
    },
    {
      'name': 'Victory Foundation',
      'logo': 'assets/sponsor_image.png',
      'category': 'Non-Profit',
      'sports': ['Football', 'Tennis'],
      'email': 'grants@victoryfoundation.org',
      'phone': '+1 (555) 456-7890',
      'website': 'www.victoryfoundation.org',
      'address': '321 Community Lane, Chicago, IL',
      'description': 'Supporting emerging athletes through grants and development programs.',
      'isFavorite': false,
    },
    {
      'name': 'Elite Training Academy',
      'logo': 'assets/sponsor_image.png',
      'category': 'Training',
      'sports': ['Cricket', 'Football', 'Tennis'],
      'email': 'info@elitetrainingacademy.com',
      'phone': '+1 (555) 567-8901',
      'website': 'www.elitetrainingacademy.com',
      'address': '555 Performance Drive, Miami, FL',
      'description': 'World-class training facilities and coaching for aspiring champions.',
      'isFavorite': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredSponsors {
    return _sponsors.where((sponsor) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          sponsor['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply sport filter
      final matchesSport = _selectedSport == 'All Sports' ||
          (sponsor['sports'] as List).contains(_selectedSport);
      
      // Apply favorites filter
      final matchesFavorite = !_showFavorites || sponsor['isFavorite'] == true;
      
      return matchesSearch && matchesSport && matchesFavorite;
    }).toList();
  }

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  void _toggleFavorite(int index) {
    setState(() {
      _sponsors[index]['isFavorite'] = !_sponsors[index]['isFavorite'];
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

  Future<void> _launchUrl(String url, String type) async {
    String scheme;
    switch (type) {
      case 'email':
        scheme = 'mailto:$url';
        break;
      case 'phone':
        scheme = 'tel:$url';
        break;
      case 'web':
        scheme = 'https://$url';
        break;
      case 'map':
        // For simplicity just showing a Google search for the address
        scheme = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(url)}';
        break;
      default:
        return;
    }

    if (await canLaunch(scheme)) {
      await launch(scheme);
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $type')),
      );
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Connect with Sponsors'),
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
        actions: [
          
        ],
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
      body: Column(
        children: [
          // Header section with search and filters
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                      hintText: 'Search sponsors...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
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
                
                const SizedBox(height: 12),
                
                // Sports filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSportFilterChip('All Sports'),
                      _buildSportFilterChip('Cricket'),
                      _buildSportFilterChip('Football'),
                      _buildSportFilterChip('Badminton'),
                      _buildSportFilterChip('Basketball'),
                      _buildSportFilterChip('Tennis'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sponsors list section
          Expanded(
            child: _filteredSponsors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSponsors.length,
                    itemBuilder: (context, index) {
                      final sponsor = _filteredSponsors[index];
                      // Find the actual index in the full sponsors list for favorite toggling
                      final originalIndex = _sponsors.indexOf(sponsor);
                      return _buildSponsorCard(sponsor, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSportFilterChip(String sport) {
    final isSelected = _selectedSport == sport;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(sport),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedSport = sport;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        checkmarkColor: Colors.deepPurple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        avatar: sport != 'All Sports'
            ? Icon(
                _getSportIcon(sport),
                color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                size: 16,
              )
            : null,
      ),
    );
  }
  
  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Football':
        return Icons.sports_soccer;
      case 'Badminton':
        return Icons.sports_tennis; // Using tennis as a close approximation
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Tennis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
  }
  
  Widget _buildSponsorCard(Map<String, dynamic> sponsor, int originalIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showSponsorDetails(sponsor),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and category badge
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Logo and name
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              sponsor['logo'],
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Colors.deepPurple.shade300,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sponsor['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(sponsor['category']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  sponsor['category'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        sponsor['isFavorite'] ? Icons.star : Icons.star_border,
                        color: sponsor['isFavorite'] ? Colors.amber : Colors.grey.shade400,
                      ),
                      onPressed: () => _toggleFavorite(originalIndex),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick description
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                sponsor['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Sports supported
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.sports,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Supports: ${(sponsor['sports'] as List).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contact actions
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactButton(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onTap: () => _launchUrl(sponsor['email'], 'email'),
                  ),
                  _buildContactButton(
                    icon: Icons.call_outlined,
                    label: 'Call',
                    onTap: () => _launchUrl(sponsor['phone'], 'phone'),
                  ),
                  _buildContactButton(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    onTap: () => _launchUrl(sponsor['website'], 'web'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Corporate':
        return Colors.blue.shade700;
      case 'Equipment':
        return Colors.green.shade700;
      case 'Nutrition':
        return Colors.orange.shade700;
      case 'Non-Profit':
        return Colors.purple.shade700;
      case 'Training':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Sponsors Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchQuery.isNotEmpty || _selectedSport != 'All Sports' || _showFavorites
                  ? 'Try adjusting your filters or favorites selection'
                  : 'Connect with sponsors to grow your athletic career',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedSport != 'All Sports' || _showFavorites)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedSport = 'All Sports';
                  _showFavorites = false;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
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
  
  void _showSponsorDetails(Map<String, dynamic> sponsor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              // Sponsor Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        sponsor['logo'],
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: 50,
                            color: Colors.deepPurple.shade300,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sponsor['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(sponsor['category']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                sponsor['category'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              icon: Icon(
                                sponsor['isFavorite'] ? Icons.star : Icons.star_border,
                                color: sponsor['isFavorite'] ? Colors.amber : Colors.grey,
                                size: 20,
                              ),
                              label: Text(
                                sponsor['isFavorite'] ? 'Favorited' : 'Add to Favorites',
                                style: TextStyle(
                                  color: sponsor['isFavorite'] ? Colors.amber : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                final index = _sponsors.indexWhere((s) => s['name'] == sponsor['name']);
                                if (index != -1) {
                                  _toggleFavorite(index);
                                  Navigator.pop(context);
                                  _showSponsorDetails(sponsor);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 32),
              
              // Description
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sponsor['description'],
                style: TextStyle(
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Supported Sports
              const Text(
                'Supported Sports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (sponsor['sports'] as List).map<Widget>((sport) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSportIcon(sport),
                          size: 16,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sport,
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              // Email
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.email, color: Colors.blue.shade700),
                ),
                title: const Text('Email'),
                subtitle: Text(sponsor['email']),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _launchUrl(sponsor['email'], 'email'),
                ),
              ),
              // Phone
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: Icon(Icons.phone, color: Colors.green.shade700),
                ),
                title: const Text('Phone'),
                subtitle: Text(sponsor['phone']),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _launchUrl(sponsor['phone'], 'phone'),
                ),
              ),
              // Website
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade50,
                  child: Icon(Icons.language, color: Colors.purple.shade700),
                ),
                title: const Text('Website'),
                subtitle: Text(sponsor['website']),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _launchUrl(sponsor['website'], 'web'),
                ),
              ),
              // Address
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade50,
                  child: Icon(Icons.location_on, color: Colors.orange.shade700),
                ),
                title: const Text('Address'),
                subtitle: Text(sponsor['address']),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => _launchUrl(sponsor['address'], 'map'),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Contact button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Request sent to ${sponsor['name']}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.handshake),
                  label: const Text(
                    'Request Sponsorship',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}