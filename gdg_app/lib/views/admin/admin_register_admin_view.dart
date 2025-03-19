import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/serivces/admin_services.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/popups/alert_message.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:gdg_app/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class AdminRegisterAdminView extends StatefulWidget {
  const AdminRegisterAdminView({super.key});

  @override
  _AdminRegisterAdminViewState createState() => _AdminRegisterAdminViewState();
}

class _AdminRegisterAdminViewState extends State<AdminRegisterAdminView> {
  // Search and filter state
  String _searchQuery = '';
  
  // Admin data state
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  
  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalAdmins = 0;
  int _itemsPerPage = 10;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadAdmins();
    _debugSharedPreferences(); // Debug to check organization ID
  }
  
  // Debug function to check SharedPreferences
  Future<void> _debugSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔍 DEBUG SHARED PREFERENCES:');
      final keys = prefs.getKeys();
      if (keys.isEmpty) {
        print('No keys found in SharedPreferences');
      } else {
        for (String key in keys) {
          print('$key: ${prefs.get(key)}');
        }
      }
      
      // Specifically check for organization ID
      final organizationId = prefs.getString('organizationId');
      print('organizationId from prefs: $organizationId');
      
      final userData = prefs.getString('userData');
      if (userData != null) {
        try {
          final userDataMap = jsonDecode(userData);
          print('userData parsed: $userDataMap');
          
          // Check if organization exists directly
          if (userDataMap.containsKey('organization')) {
            print('Found organization directly: ${userDataMap['organization']}');
          }
        } catch (e) {
          print('Error parsing userData: $e');
        }
      }
      
      // Also check adminResponseData which should contain complete admin details
      final adminResponseData = prefs.getString('adminResponseData');
      if (adminResponseData != null) {
        try {
          final adminDataMap = jsonDecode(adminResponseData);
          print('Found admin response data: $adminDataMap');
          
          if (adminDataMap['admin'] != null && 
              adminDataMap['admin']['organization'] != null) {
            print('Found organization in adminResponseData: ${adminDataMap['admin']['organization']}');
          }
        } catch (e) {
          print('Error parsing adminResponseData: $e');
        }
      }
    } catch (e) {
      print('Error debugging SharedPreferences: $e');
    }
  }

  // Load admins from API
  Future<void> _loadAdmins({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final result = await AdminService().getAllAdmins(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery,
      );

      setState(() {
        _isLoading = false;
        
        if (result['success']) {
          if (refresh) {
            _admins = [];
          }
          
          final List<dynamic> adminsData = result['admins'];
          // Map API data to UI format
          _admins = adminsData.map<Map<String, dynamic>>((admin) => {
            'id': admin['_id'],
            'name': admin['name'] ?? 'Unknown',
            'email': admin['email'] ?? '',
            'role': admin['role'] == 'superadmin' ? 'Super Admin' : 'Admin',
            'dateCreated': admin['createdAt'] != null 
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(admin['createdAt']))
                : '-',
            'lastLogin': admin['lastLogin'] != null 
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(admin['lastLogin']))
                : '-',
            'isActive': admin['isActive'] ?? true,
            'organization': admin['organization'] != null ? 
                (admin['organization'] is Map ? admin['organization']['name'] : '-') : '-',
            'avatar': admin['avatar']
          }).toList();
          
          // Update pagination info
          if (result['pagination'] != null) {
            _totalPages = result['pagination']['totalPages'] ?? 1;
            _currentPage = result['pagination']['currentPage'] ?? 1;
            _totalAdmins = result['pagination']['totalAdmins'] ?? 0;
          }
        } else {
          _isError = true;
          _errorMessage = result['message'] ?? 'Failed to load administrators';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // Show dialog for registering a new admin
  void _showRegisterAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => RegisterAdminForm(
        onRegister: _handleRegisterAdmin,
      ),
    );
  }

  // Handle registering a new admin
  Future<void> _handleRegisterAdmin(
    String name, 
    String email, 
    String password,
    String? avatarPath, 
    String role
  ) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use the fixed AdminService implementation
      final result = await FixedAdminService().registerAdmin(
        name: name,
        email: email,
        password: password,
        role: role.toLowerCase() == 'super admin' ? 'superadmin' : 'admin',
        avatarFile: avatarPath != null ? File(avatarPath) : null,
      );
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success']) {
        _loadAdmins(refresh: true);
        
        CustomSnackBar.showSuccess(
          context, 
          '${name} has been registered as an admin successfully',
        );
      } else {
        String errorMessage = result['message'] ?? 'Failed to register admin';
        
        // Add specific error guidance for organization ID issues
        if (errorMessage.contains('Organization ID not found')) {
          errorMessage += '\n\nTry logging out and logging back in to refresh your session.';
        }
        
        CustomSnackBar.showError(
          context,
          errorMessage,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      CustomSnackBar.showError(
        context,
        'Unexpected error: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadAdmins(refresh: true),
          ),
        ],
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: registerAdminRoute,
        onSelectDrawerItem: (route) {
          Navigator.pop(context);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamed(context, route);
          }
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
          DrawerItem(icon: Icons.attach_money, title: 'Manage Player Finances', route: adminManagePlayerFinancesRoute),
        ],
        onLogout: () async {
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
            // First clear local data directly - don't rely on server response
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            
            // Then try server-side logout, but don't block on it
            _authService.logout().catchError((e) {
              print('Server logout error: $e');
              // We still proceed with local logout
            });
            
            // Close loading dialog and navigate to login
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog
              
              // Navigate to login page rather than coachAdminPlayerRoute
              Navigator.pushNamedAndRemoveUntil(
                context, 
                coachAdminPlayerRoute, // Change this to your login route constant
                (route) => false,
              );
            }
          } catch (e) {
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
      },
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : _isError
                    ? _buildErrorView()
                    : _buildAdminList(),
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Administrators',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showRegisterAdminDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search administrators...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.isEmpty || value.length > 2) {
                  _loadAdmins(refresh: true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminList() {
    if (_admins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No administrators found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Try a different search term'
                  : 'Add your first admin to get started',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showRegisterAdminDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAdmins(refresh: true),
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      edgeOffset: 16,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _admins.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final admin = _admins[index];
          return AdminCard(
            admin: admin,
            onDelete: () => _showDeleteConfirmation(admin['id'], admin['name']),
            onEdit: () => _showEditAdminDialog(admin),
            onViewDetails: () => _showAdminDetails(admin),
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Administrators',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadAdmins(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalAdmins == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${_admins.length} of $_totalAdmins',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left,
                onTap: _currentPage > 1 ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _loadAdmins();
                } : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_currentPage of $_totalPages',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildPaginationButton(
                icon: Icons.chevron_right,
                onTap: _currentPage < _totalPages ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _loadAdmins();
                } : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? Colors.deepPurple : Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String adminId, String adminName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $adminName?'),
        content: Text('Are you sure you want to remove $adminName from administrators? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality here
              CustomSnackBar.showInfo(context, 'Delete functionality coming soon');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    // In a real app, you'd prepopulate the form with admin data
    CustomSnackBar.showInfo(context, 'Edit functionality coming soon');
  }

  void _showAdminDetails(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: admin['avatar'] != null && admin['avatar'].toString().isNotEmpty
                        ? NetworkImage('${ApiConstants.baseUrl}/${admin['avatar']}')
                        : null,
                    child: admin['avatar'] == null || admin['avatar'].toString().isEmpty
                        ? Text(
                            admin['name'].substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: admin['isActive'] ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      admin['isActive'] ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                admin['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  admin['role'],
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Email', admin['email'], Icons.email),
                    _buildDetailRow('Organization', admin['organization'], Icons.business),
                    _buildDetailRow('Registered On', admin['dateCreated'], Icons.calendar_today),
                    _buildDetailRow('Last Login', admin['lastLogin'], Icons.login),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditAdminDialog(admin);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Admin card widget with improved styling
class AdminCard extends StatelessWidget {
  final Map<String, dynamic> admin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewDetails;

  const AdminCard({
    super.key,
    required this.admin,
    required this.onDelete,
    required this.onEdit,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar section
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: admin['avatar'] != null && admin['avatar'].toString().isNotEmpty
                    ? NetworkImage('${ApiConstants.baseUrl}/${admin['avatar']}')
                    : null,
                child: admin['avatar'] == null || admin['avatar'].toString().isEmpty
                    ? Text(
                        admin['name'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Admin details section - wrapped in Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and role row
                    Row(
                      children: [
                        // Name with overflow handling
                        Expanded(
                          child: Text(
                            admin['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                                                    child: Text(
                            admin['role'],
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 12, // Reduced font size to avoid overflow
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Email - with overflow handling
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        admin['email'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Organization and date info - with overflow protection
                    Row(
                      children: [
                        // We use Expanded to prevent overflow
                        Expanded(
                          child: Text(
                            'Organization: ${admin['organization']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Registration date and active status 
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          admin['dateCreated'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: admin['isActive'] ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          admin['isActive'] ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: admin['isActive'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'view') {
                    onViewDetails();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fixed version of AdminService with better organization ID handling
class FixedAdminService {
  // Get authentication token from shared preferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    
    return {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }
  
  // Register a new admin with improved organization ID handling
  Future<Map<String, dynamic>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
    File? avatarFile,
  }) async {
    try {
      // Debug - print available data to help troubleshoot
      final prefs = await SharedPreferences.getInstance();
      
      // Look for organization ID in multiple places
      String? organizationId = prefs.getString('organizationId');
      
      // If organizationId is not found directly, try to get it from userData
      if (organizationId == null) {
        final userData = prefs.getString('userData');
        if (userData != null) {
          try {
            final Map<String, dynamic> userDataMap = jsonDecode(userData);
            
            if (userDataMap['organization'] != null) {
              if (userDataMap['organization'] is String) {
                organizationId = userDataMap['organization'];
              } else if (userDataMap['organization'] is Map && 
                         userDataMap['organization']['_id'] != null) {
                organizationId = userDataMap['organization']['_id'];
              }
            }
          } catch (e) {
            print('Error parsing userData: $e');
          }
        }
      }
      
      // If still not found, try adminResponseData
      if (organizationId == null) {
        final adminData = prefs.getString('adminResponseData');
        if (adminData != null) {
          try {
            final Map<String, dynamic> adminDataMap = jsonDecode(adminData);
            
            if (adminDataMap['admin'] != null && 
                adminDataMap['admin']['organization'] != null) {
              organizationId = adminDataMap['admin']['organization'].toString();
            }
          } catch (e) {
            print('Error parsing adminResponseData: $e');
          }
        }
      }
      
      // If organization ID is still null, return error
      if (organizationId == null) {
        return {
          'success': false,
          'message': 'Organization ID not found. Please try logging out and logging back in.',
        };
      }
      
      print('Using organization ID for admin registration: $organizationId');
      
      // Create the request
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/register');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      
      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['organizationId'] = organizationId;
      request.fields['role'] = role;
      
      // Add avatar file if provided
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Register admin response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'admin': data['admin'],
          'message': data['message'] ?? 'Admin registered successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to register admin',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error registering admin: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  
  // Get all admins with pagination and filtering (no changes needed here)
  Future<Map<String, dynamic>> getAllAdmins({
    int page = 1,
    int limit = 10,
    String sort = 'name',
    String order = 'asc',
    String search = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'order': order,
        if (search.isNotEmpty) 'search': search,
      };
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/admins/administrators')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      print('Get admins response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'admins': data['data']['admins'] ?? [],
          'pagination': data['data']['pagination'] ?? {},
          'message': data['message'] ?? 'Administrators fetched successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch administrators',
        };
      }
    } catch (e) {
      print('Error fetching admins: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
}

// Form to register a new admin - the success message is already handled in _handleRegisterAdmin
class RegisterAdminForm extends StatefulWidget {
  final Function(String, String, String, String?, String) onRegister;
  
  const RegisterAdminForm({required this.onRegister, super.key});
  
  @override
  _RegisterAdminFormState createState() => _RegisterAdminFormState();
}

class _RegisterAdminFormState extends State<RegisterAdminForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'Admin';
  String? _avatarPath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _avatarPath = result.files.first.path;
        });
      }
    } catch (e) {
      print('Error picking avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
  AlertMessage.showAlert(
    context,
    message: 'Register ${_nameController.text} as a new $_selectedRole?',
    options: [
      AlertOption(
        label: 'Yes',
        onPressed: () {
          // First close the confirmation dialog
          Navigator.of(context).pop();
          
          // Then close the form dialog
          Navigator.of(context).pop();
          
          // AFTER closing dialogs, register the admin
          // This prevents any navigation issues as dialogs are already gone
          widget.onRegister(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
            _avatarPath,
            _selectedRole,
          );
        },
      ),
      AlertOption(
        label: 'No',
        onPressed: () {
          Navigator.of(context).pop(); // Close the confirmation dialog
        },
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Center(
                child: Text(
                  'Register New Administrator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Avatar selection
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _avatarPath != null
                            ? FileImage(File(_avatarPath!))
                            : null,
                        child: _avatarPath == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  // Basic email validation
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Confirm password field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm the password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Role selection
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Super Admin', child: Text('Super Admin')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Register Admin'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}