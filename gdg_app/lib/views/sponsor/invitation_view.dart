// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class InvitationsView extends StatefulWidget {
  const InvitationsView({super.key});

  @override
  _InvitationsViewState createState() => _InvitationsViewState();
}

class _InvitationsViewState extends State<InvitationsView>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  List<Map<String, dynamic>> _invitations = [
    {
      'name': 'Kennedy Cricket Academy',
      'subject': 'Invitation to Annual Championship',
      'date': '2023-04-15',
      'type': 'Event',
      'message':
          'We would like to invite you to sponsor our annual cricket championship tournament which attracts over 500 participants from across the region.',
      'isRead': false,
    },
    {
      'name': 'Michael Johnson',
      'subject': 'Partnership Opportunity in Track Events',
      'date': '2023-04-12',
      'type': 'Partnership',
      'message':
          'As an Olympic gold medalist, I am looking for sponsors for my upcoming athletics clinic for underprivileged youth.',
      'isRead': true,
    },
    {
      'name': 'United Sports Foundation',
      'subject': 'Charity Tournament Sponsorship',
      'date': '2023-04-10',
      'type': 'Charity',
      'message':
          'Our annual charity tournament raises funds for sports equipment for schools in low-income areas. We invite you to be a title sponsor for this noble cause.',
      'isRead': false,
    },
    {
      'name': 'Basketball League Association',
      'subject': 'Season-long Sponsorship Opportunity',
      'date': '2023-04-08',
      'type': 'Season',
      'message':
          'We are looking for sponsors for our upcoming basketball season which includes 24 teams and over 300 games with media coverage.',
      'isRead': true,
    },
    {
      'name': 'World Tennis Organization',
      'subject': 'Junior Championship Sponsorship',
      'date': '2023-04-05',
      'type': 'Tournament',
      'message':
          'Our junior championship showcases the next generation of tennis stars. We offer prominent branding opportunities throughout the venue and broadcast.',
      'isRead': false,
    },
  ];

  List<Map<String, dynamic>> _filteredInvitations = [];
  String _searchQuery = '';
  String _selectedDrawerItem = invitationToSponsorRoute;
  late TabController _tabController;
  bool _showFilterOptions = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Unread',
    'Event',
    'Partnership',
    'Tournament',
    'Charity'
  ];
// Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _filteredInvitations = List.from(_invitations);
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();

      if (userData.isNotEmpty) {
        setState(() {
          _userName = userData['name'] ?? "Sponsor";
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
    _tabController.dispose();
    super.dispose();
  }

  void _filterInvitations(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredInvitations = _invitations.where((invitation) {
        // First apply search query filter
        bool matchesQuery = invitation['name']!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            invitation['subject']!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        // Then apply category filter
        if (_selectedFilter == 'All') {
          return matchesQuery;
        } else if (_selectedFilter == 'Unread') {
          return matchesQuery && invitation['isRead'] == false;
        } else {
          return matchesQuery && invitation['type'] == _selectedFilter;
        }
      }).toList();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _deleteInvitation(int index) {
    final invitation = _filteredInvitations[index];

    setState(() {
      _filteredInvitations.removeAt(index);
      _invitations.removeWhere((item) =>
          item['name'] == invitation['name'] &&
          item['subject'] == invitation['subject']);
    });
  }

  void _toggleReadStatus(int index) {
    final invitation = _filteredInvitations[index];

    setState(() {
      // Find in the main list and toggle
      final mainIndex = _invitations.indexWhere((item) =>
          item['name'] == invitation['name'] &&
          item['subject'] == invitation['subject']);

      if (mainIndex != -1) {
        _invitations[mainIndex]['isRead'] = !_invitations[mainIndex]['isRead'];
        _filteredInvitations[index]['isRead'] =
            _invitations[mainIndex]['isRead'];
      }
    });
  }

  void _viewInvitationDetails(Map<String, dynamic> invitation) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with type badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            _getTypeColor(invitation['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getTypeColor(invitation['type'])
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        invitation['type'],
                        style: TextStyle(
                          color: _getTypeColor(invitation['type']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      invitation['date'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title and sender
                Text(
                  invitation['subject'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'From: ${invitation['name']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const Divider(height: 32),

                // Message content
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      invitation['message'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Accepted invitation from ${invitation['name']}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });

    // Mark as read if it wasn't already
    if (!invitation['isRead']) {
      setState(() {
        invitation['isRead'] = true;

        // Update in the main list
        final mainIndex = _invitations.indexWhere((item) =>
            item['name'] == invitation['name'] &&
            item['subject'] == invitation['subject']);

        if (mainIndex != -1) {
          _invitations[mainIndex]['isRead'] = true;
        }
      });
    }
  }

  void _onSelectDrawerItem(String route) {
    if (route != _selectedDrawerItem) {
      setState(() {
        _selectedDrawerItem = route;
      });
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, landingPageRoute);
  }

  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Event':
        return Colors.blue;
      case 'Partnership':
        return Colors.green;
      case 'Tournament':
        return Colors.orange;
      case 'Charity':
        return Colors.pink;
      case 'Season':
        return Colors.purple;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(
          icon: Icons.article,
          title: 'News and Updates',
          route: sponsorHomeViewRoute),
      DrawerItem(
          icon: Icons.sports,
          title: 'Sports of Interest',
          route: sportsOfInterestRoute),
      DrawerItem(
          icon: Icons.mail,
          title: 'Invitations',
          route: invitationToSponsorRoute),
      DrawerItem(
          icon: Icons.request_page,
          title: 'Requests',
          route: requestToSponsorPageRoute),
      DrawerItem(
          icon: Icons.search,
          title: 'Find Organization or Players',
          route: findOrganizationOrPlayersRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invitations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        toolbarHeight: 65.0,
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _toggleFilterOptions,
            tooltip: 'Filter Options',
          ),
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
        onLogout: _handleLogout,
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: Column(
        children: [
          // Colored header area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                    onChanged: _filterInvitations,
                    decoration: InputDecoration(
                      hintText: 'Search invitations',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.deepPurple),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.deepPurple),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilters();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                // Invitation stats
                Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      _invitations.length.toString(),
                      Icons.mail,
                      Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Unread',
                      _invitations
                          .where((inv) => inv['isRead'] == false)
                          .length
                          .toString(),
                      Icons.mark_email_unread,
                      Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      _tabController.index == 0 ? 'Latest' : 'Archive',
                      _filteredInvitations.length.toString(),
                      _tabController.index == 0
                          ? Icons.new_releases
                          : Icons.archive,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter options panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilterOptions ? 60 : 0,
            color: Colors.grey.shade100,
            child: _showFilterOptions
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: _filterOptions.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            selectedColor: Colors.deepPurple.shade100,
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter
                                  ? Colors.deepPurple
                                  : Colors.black87,
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey.shade200,
                            onSelected: (selected) {
                              if (selected) {
                                _setFilter(filter);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : null,
          ),

          // Invitation list
          Expanded(
            child: _filteredInvitations.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredInvitations.length,
                    itemBuilder: (context, index) {
                      final invitation = _filteredInvitations[index];
                      final bool isRead = invitation['isRead'] as bool;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isRead ? 1 : 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isRead
                              ? BorderSide.none
                              : BorderSide(
                                  color: Colors.deepPurple.shade100, width: 1),
                        ),
                        child: InkWell(
                          onTap: () => _viewInvitationDetails(invitation),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status indicator and icon
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(invitation['type'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getInvitationIcon(invitation['type']),
                                        color:
                                            _getTypeColor(invitation['type']),
                                        size: 24,
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              invitation['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isRead
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                                color: isRead
                                                    ? Colors.grey.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(invitation['date']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        invitation['subject'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                          color: isRead
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _truncateText(
                                            invitation['message'], 80),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),

                                      // Action buttons
                                      Row(
                                        children: [
                                          // Type badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getTypeColor(
                                                      invitation['type'])
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              invitation['type'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getTypeColor(
                                                    invitation['type']),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          // Actions
                                          IconButton(
                                            icon: Icon(
                                              isRead
                                                  ? Icons
                                                      .mark_email_unread_outlined
                                                  : Icons
                                                      .mark_email_read_outlined,
                                              size: 20,
                                            ),
                                            color: Colors.grey.shade600,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () =>
                                                _toggleReadStatus(index),
                                            tooltip: isRead
                                                ? 'Mark as unread'
                                                : 'Mark as read',
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20),
                                            color: Colors.red.shade400,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () =>
                                                _deleteInvitation(index),
                                            tooltip: 'Delete',
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
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
            Icons.mail,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No invitations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your filters'
                : 'You have no invitations yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _applyFilters();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getInvitationIcon(String type) {
    switch (type) {
      case 'Event':
        return Icons.event;
      case 'Partnership':
        return Icons.handshake;
      case 'Tournament':
        return Icons.emoji_events;
      case 'Charity':
        return Icons.volunteer_activism;
      case 'Season':
        return Icons.calendar_today;
      default:
        return Icons.mail;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
