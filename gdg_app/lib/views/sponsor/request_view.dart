import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  _RequestsViewState createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _requests = [
    {
      'name': 'Regional Cricket Association',
      'subject': 'Equipment Sponsorship Request',
      'date': '2023-04-15',
      'type': 'Equipment',
      'message': 'We are seeking sponsorship for cricket equipment for our youth development program that serves over 200 children in underrepresented communities.',
      'status': 'New',
      'urgent': true,
    },
    {
      'name': 'Sarah Johnson',
      'subject': 'Athletic Scholarship Support',
      'date': '2023-04-12',
      'type': 'Financial',
      'message': 'I am a national-level track athlete seeking sponsorship to continue my training and participation in upcoming international championships.',
      'status': 'Under Review',
      'urgent': false,
    },
    {
      'name': 'Downtown Basketball League',
      'subject': 'Court Renovation Partnership',
      'date': '2023-04-10',
      'type': 'Facility',
      'message': "Our community basketball courts need renovation. We're looking for sponsors to help fund this project which will benefit over 5,000 local youths.",
      'status': 'New',
      'urgent': false,
    },
    {
      'name': 'Alex Rivera',
      'subject': 'Tennis Tournament Sponsorship',
      'date': '2023-04-08',
      'type': 'Event',
      'message': "I'm organizing a charity tennis tournament and looking for corporate sponsors. All proceeds will support athletic programs for children with disabilities.",
      'status': 'Pending',
      'urgent': true,
    },
    {
      'name': 'East Side Sports Club',
      'subject': 'Youth Program Funding Request',
      'date': '2023-04-05',
      'type': 'Program',
      'message': "We're expanding our after-school sports program for at-risk youth and seeking sponsors to help with coaching staff and equipment costs.",
      'status': 'Under Review',
      'urgent': false,
    },
  ];
  
  List<Map<String, dynamic>> _filteredRequests = [];
  String _searchQuery = '';
  String _selectedDrawerItem = requestToSponsorPageRoute;
  late TabController _tabController;
  bool _showFilterOptions = false;
  String _selectedStatusFilter = 'All';
  String _selectedTypeFilter = 'All';
  bool _showUrgentOnly = false;
  
  final List<String> _statusFilters = ['All', 'New', 'Pending', 'Under Review', 'Accepted', 'Declined'];
  final List<String> _typeFilters = ['All', 'Equipment', 'Financial', 'Facility', 'Event', 'Program'];

  @override
  void initState() {
    super.initState();
    _filteredRequests = List.from(_requests);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applyTabFilter();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterRequests(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyTabFilter() {
    setState(() {
      switch (_tabController.index) {
        case 0: // All
          _selectedStatusFilter = 'All';
          _applyFilters();
          break;
        case 1: // New
          _selectedStatusFilter = 'New';
          _applyFilters();
          break;
        case 2: // Under Review
          _selectedStatusFilter = 'Under Review';
          _applyFilters();
          break;
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRequests = _requests.where((request) {
        // First apply search query filter
        bool matchesQuery = 
          request['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request['subject']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request['message']!.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Then apply status filter
        bool matchesStatus = _selectedStatusFilter == 'All' || 
          request['status'] == _selectedStatusFilter;
        
        // Then apply type filter
        bool matchesType = _selectedTypeFilter == 'All' || 
          request['type'] == _selectedTypeFilter;
          
        // Then apply urgency filter
        bool matchesUrgency = !_showUrgentOnly || request['urgent'] == true;
        
        return matchesQuery && matchesStatus && matchesType && matchesUrgency;
      }).toList();
    });
  }

  void _setStatusFilter(String status) {
    setState(() {
      _selectedStatusFilter = status;
      _applyFilters();
    });
  }

  void _setTypeFilter(String type) {
    setState(() {
      _selectedTypeFilter = type;
      _applyFilters();
    });
  }

  void _toggleUrgentFilter(bool? value) {
    setState(() {
      _showUrgentOnly = value ?? false;
      _applyFilters();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatusFilter = 'All';
      _selectedTypeFilter = 'All';
      _showUrgentOnly = false;
      _tabController.animateTo(0);
      _applyFilters();
    });
  }

  void _deleteRequest(int index) {
    final request = _filteredRequests[index];
    
    setState(() {
      _filteredRequests.removeAt(index);
      _requests.removeWhere((item) => 
        item['name'] == request['name'] && 
        item['subject'] == request['subject']
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request from ${request['name']} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _requests.add(request);
              _applyFilters();
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _viewRequestDetails(Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTypeColor(request['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTypeIcon(request['type']),
                        color: _getTypeColor(request['type']),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['subject'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From: ${request['name']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(request['status']).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        request['status'],
                        style: TextStyle(
                          color: _getStatusColor(request['status']),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Request details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(request['date']),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(request['type']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  request['type'],
                                  style: TextStyle(
                                    color: _getTypeColor(request['type']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (request['urgent'] == true)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.priority_high,
                                        color: Colors.red.shade700,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Urgent',
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Message
                      const Text(
                        'Message:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          request['message'],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Additional information (placeholder)
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow('Request Type', request['type']),
                              _buildInfoRow('Received on', _formatDate(request['date'])),
                              _buildInfoRow('Status', request['status']),
                              _buildInfoRow('Priority', request['urgent'] ? 'High' : 'Normal'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Notes section (placeholder)
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add your notes here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
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
                          // Update request status
                          setState(() {
                            final index = _requests.indexWhere((item) => 
                              item['name'] == request['name'] && 
                              item['subject'] == request['subject']
                            );
                            if (index != -1) {
                              _requests[index]['status'] = 'Accepted';
                              _applyFilters();
                            }
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Request from ${request['name']} accepted'),
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
              ),
            ],
          ),
        );
      },
    );
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'Pending':
        return Colors.amber.shade700;
      case 'Under Review':
        return Colors.purple;
      case 'Accepted':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  Color _getTypeColor(String type) {
    switch (type) {
      case 'Equipment':
        return Colors.indigo;
      case 'Financial':
        return Colors.green;
      case 'Facility':
        return Colors.amber.shade700;
      case 'Event':
        return Colors.pink;
      case 'Program':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
  
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Equipment':
        return Icons.sports_baseball;
      case 'Financial':
        return Icons.attach_money;
      case 'Facility':
        return Icons.location_city;
      case 'Event':
        return Icons.event;
      case 'Program':
        return Icons.school;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.article, title: 'News and Updates', route: sponsorHomeViewRoute),
      DrawerItem(icon: Icons.sports, title: 'Sports of Interest', route: sportsOfInterestRoute),
      DrawerItem(icon: Icons.mail, title: 'Invitations', route: invitationToSponsorRoute),
      DrawerItem(icon: Icons.request_page, title: 'Requests', route: requestToSponsorPageRoute),
      DrawerItem(icon: Icons.search, title: 'Find Organization or Players', route: findOrganizationOrPlayersRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sponsorship Requests',
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
      ),
      body: Column(
        children: [
          // Header with tabs and search
          Container(
            color: Colors.deepPurple,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
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
                      onChanged: _filterRequests,
                      decoration: InputDecoration(
                        hintText: 'Search requests',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.deepPurple),
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
                ),
                
                // Tab bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: [
                    const Tab(text: 'All Requests'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('New'),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _requests.where((req) => req['status'] == 'New').length.toString(),
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(text: 'Under Review'),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter options panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilterOptions ? 120 : 0,
            color: Colors.grey.shade100,
            child: _showFilterOptions
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter type row
                        Row(
                          children: [
                            const Text(
                              'Type:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _typeFilters.map((filter) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(filter),
                                        selected: _selectedTypeFilter == filter,
                                        selectedColor: Colors.deepPurple.shade100,
                                        labelStyle: TextStyle(
                                          color: _selectedTypeFilter == filter
                                              ? Colors.deepPurple
                                              : Colors.black87,
                                          fontWeight: _selectedTypeFilter == filter
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        backgroundColor: Colors.white,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _setTypeFilter(filter);
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Status and urgency row
                        Row(
                          children: [
                            // Status filter
                            const Text(
                              'Status:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _selectedStatusFilter,
                              onChanged: (String? value) {
                                if (value != null) {
                                  _setStatusFilter(value);
                                }
                              },
                              underline: Container(),
                              items: _statusFilters.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                            ),
                            
                            const Spacer(),
                            
                            // Urgent filter
                            Row(
                              children: [
                                Checkbox(
                                  value: _showUrgentOnly,
                                  onChanged: _toggleUrgentFilter,
                                  activeColor: Colors.deepPurple,
                                ),
                                const Text('Urgent only'),
                              ],
                            ),
                            
                            const SizedBox(width: 12), // Added space here
                            
                            // Reset button
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                              onPressed: _resetFilters,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          
          // Request list
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = _filteredRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _viewRequestDetails(request),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with sender name and date
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        request['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDate(request['date']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Subject and urgent badge
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Important: align to top
                                  children: [
                                    Expanded(
                                      child: Text(
                                        request['subject'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8), // Add space
                                    if (request['urgent'] == true)
                                      Container(
                                                                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.red.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.priority_high,
                                              color: Colors.red.shade700,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Urgent',
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Preview of message
                                Text(
                                  _truncateText(request['message'], 100),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Status and type badges with actions
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(request['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _getStatusColor(request['status']).withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        request['status'],
                                        style: TextStyle(
                                          color: _getStatusColor(request['status']),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    
                                    // Type badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(request['type']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getTypeIcon(request['type']),
                                            size: 12,
                                            color: _getTypeColor(request['type']),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            request['type'],
                                            style: TextStyle(
                                              color: _getTypeColor(request['type']),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Quick action buttons - now in a separate Wrap to prevent overflow
                                    if (request['status'] == 'New' || request['status'] == 'Under Review')
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          // Decline button
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                final index = _requests.indexWhere((item) => 
                                                  item['name'] == request['name'] && 
                                                  item['subject'] == request['subject']
                                                );
                                                if (index != -1) {
                                                  _requests[index]['status'] = 'Declined';
                                                  _applyFilters();
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey.shade200,
                                              foregroundColor: Colors.grey.shade800,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                              minimumSize: const Size(0, 36),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            child: const Text('Decline'),
                                          ),
                                          
                                          // Accept button
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                final index = _requests.indexWhere((item) => 
                                                  item['name'] == request['name'] && 
                                                  item['subject'] == request['subject']
                                                );
                                                if (index != -1) {
                                                  _requests[index]['status'] = 'Accepted';
                                                  _applyFilters();
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.deepPurple,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                              minimumSize: const Size(0, 36),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            child: const Text('Accept'),
                                          ),
                                        ],
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () => _viewRequestDetails(request),
                                        tooltip: 'More options',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
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

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || 
            _selectedStatusFilter != 'All' || 
            _selectedTypeFilter != 'All' || 
            _showUrgentOnly
                ? 'Try adjusting your filters'
                : 'You have no pending requests',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || 
              _selectedStatusFilter != 'All' || 
              _selectedTypeFilter != 'All' || 
              _showUrgentOnly)
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}