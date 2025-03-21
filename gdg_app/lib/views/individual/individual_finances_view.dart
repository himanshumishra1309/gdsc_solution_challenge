import 'package:flutter/material.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class IndividualFinances extends StatefulWidget {
  const IndividualFinances({super.key});

  @override
  _IndividualFinancesState createState() => _IndividualFinancesState();
}

class _IndividualFinancesState extends State<IndividualFinances> with SingleTickerProviderStateMixin {
  String _selectedDrawerItem = individualFinancesRoute;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late TabController _tabController;
  
  final List<String> _categories = ['All', 'Income', 'Expenses', 'Investments', 'Planning'];
  
  // Sample finance data structure with categories
  final Map<String, Map<String, dynamic>> _financeData = {
    'Prize Money': {'amount': 5000.0, 'category': 'Income', 'trend': 'up', 'lastUpdate': '2024-03-01'},
    'Sponsorship Deals': {'amount': 10000.0, 'category': 'Income', 'trend': 'up', 'lastUpdate': '2024-02-15'},
    'Grants & Scholarships': {'amount': 2000.0, 'category': 'Income', 'trend': 'stable', 'lastUpdate': '2024-01-20'},
    'Freelance Training Income': {'amount': 1500.0, 'category': 'Income', 'trend': 'up', 'lastUpdate': '2024-03-05'},
    'Crowdfunding/Donations': {'amount': 800.0, 'category': 'Income', 'trend': 'down', 'lastUpdate': '2024-02-28'},
    'Training & Coaching Fees': {'amount': 3000.0, 'category': 'Expenses', 'trend': 'up', 'lastUpdate': '2024-03-01'},
    'Gym & Sports Facility Costs': {'amount': 1200.0, 'category': 'Expenses', 'trend': 'stable', 'lastUpdate': '2024-03-10'},
    'Equipment & Gear': {'amount': 2500.0, 'category': 'Expenses', 'trend': 'down', 'lastUpdate': '2024-02-20'},
    'Travel & Accommodation': {'amount': 4000.0, 'category': 'Expenses', 'trend': 'up', 'lastUpdate': '2024-02-05'},
    'Medical & Physiotherapy': {'amount': 1800.0, 'category': 'Expenses', 'trend': 'stable', 'lastUpdate': '2024-01-15'},
    'Nutrition & Supplements': {'amount': 600.0, 'category': 'Expenses', 'trend': 'up', 'lastUpdate': '2024-03-08'},
    'Insurance Costs': {'amount': 1000.0, 'category': 'Expenses', 'trend': 'stable', 'lastUpdate': '2024-01-01'},
    'Taxes & Compliance': {'amount': 500.0, 'category': 'Expenses', 'trend': 'stable', 'lastUpdate': '2024-01-30'},
    'Personal Savings': {'amount': 7000.0, 'category': 'Investments', 'trend': 'up', 'lastUpdate': '2024-03-01'},
    'Sports Equipment Investment': {'amount': 3000.0, 'category': 'Investments', 'trend': 'down', 'lastUpdate': '2024-02-10'},
    'Retirement Planning': {'amount': 5000.0, 'category': 'Investments', 'trend': 'up', 'lastUpdate': '2024-01-15'},
    'Expense Tracking': {'amount': 15000.0, 'category': 'Planning', 'trend': 'stable', 'lastUpdate': '2024-03-01'},
    'Budget Planning': {'amount': 12000.0, 'category': 'Planning', 'trend': 'up', 'lastUpdate': '2024-02-20'},
    'Pending Payments/Dues': {'amount': 2000.0, 'category': 'Planning', 'trend': 'down', 'lastUpdate': '2024-03-05'},
  };

  // Add these state variables for user info
String _userName = "";
String _userEmail = "";
String? _userAvatar;
bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadUserInfo() async {
  try {
    final userData = await _authService.getCurrentUser();
    
    if (userData.isNotEmpty) {
      setState(() {
        _userName = userData['name'] ?? "Athlete";
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

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  void _editFinance(String key) {
    final currentAmount = _financeData[key]!['amount'];
    TextEditingController controller = TextEditingController(text: currentAmount.toString());
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Amount: ${NumberFormat.currency(symbol: '\$').format(currentAmount)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'New Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  setState(() {
                    // Determine trend based on previous value
                    String trend = 'stable';
                    if (newValue > currentAmount) {
                      trend = 'up';
                    } else if (newValue < currentAmount) {
                      trend = 'down';
                    }
                    
                    _financeData[key]!['amount'] = newValue;
                    _financeData[key]!['trend'] = trend;
                    _financeData[key]!['lastUpdate'] = DateTime.now().toString().substring(0, 10);
                  });
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$key updated successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add new finance item
  void _addNewFinance() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Income';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Financial Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedCategory,
                    items: ['Income', 'Expenses', 'Investments', 'Planning']
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final amount = double.tryParse(amountController.text);
                    
                    if (name.isEmpty || amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid name and amount'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    
                    this.setState(() {
                      _financeData[name] = {
                        'amount': amount,
                        'category': selectedCategory,
                        'trend': 'stable',
                        'lastUpdate': DateTime.now().toString().substring(0, 10),
                      };
                    });
                    
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name added successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Filter finance data based on search query and category
  List<MapEntry<String, Map<String, dynamic>>> get _filteredFinanceData {
    final filtered = _financeData.entries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          entry.value['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    
    // Sort by amount (descending)
    filtered.sort((a, b) => b.value['amount'].compareTo(a.value['amount']));
    return filtered;
  }

  double get _totalIncome {
    return _financeData.entries
        .where((entry) => entry.value['category'] == 'Income')
        .fold(0.0, (sum, entry) => sum + entry.value['amount']);
  }

  double get _totalExpenses {
    return _financeData.entries
        .where((entry) => entry.value['category'] == 'Expenses')
        .fold(0.0, (sum, entry) => sum + entry.value['amount']);
  }

  double get _totalInvestments {
    return _financeData.entries
        .where((entry) => entry.value['category'] == 'Investments')
        .fold(0.0, (sum, entry) => sum + entry.value['amount']);
  }

  double get _netBalance {
    return _totalIncome - _totalExpenses;
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

    final formatter = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Export Data'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Financial data exported'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.analytics),
                        title: const Text('View Detailed Analytics'),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to analytics page
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Transaction History'),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to transaction history
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'DETAILS'),
          ],
        ),
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
        userName: _userName,
        userEmail: _userEmail,
        userAvatarUrl: _userAvatar,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // OVERVIEW TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    _buildSummaryCard(
                      'Net Balance',
                      _netBalance,
                      _netBalance >= 0 ? Colors.green : Colors.red,
                      _netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        _totalIncome,
                        Colors.blue,
                        Icons.account_balance_wallet,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Expenses',
                        _totalExpenses,
                        Colors.orange,
                        Icons.shopping_cart,
                        compact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Investments',
                        _totalInvestments,
                        Colors.purple,
                        Icons.show_chart,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Savings',
                        _financeData['Personal Savings']?['amount'] ?? 0.0,
                        Colors.teal,
                        Icons.savings,
                        compact: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                
                // Add financial chart
                _buildFinancialChart(),

                const SizedBox(height: 20),
                
                // Add financial goal card
                _buildFinancialGoalCard(),

                const SizedBox(height: 20),
                const Text(
                  'Recent Updates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Recent Updates List
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredFinanceData.take(5).length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = _filteredFinanceData[index];
                      final name = entry.key;
                      final data = entry.value;
                      
                      return ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Updated: ${data['lastUpdate']} • ${data['category']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatter.format(data['amount']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data['category'] == 'Income'
                                    ? Colors.green
                                    : data['category'] == 'Expenses'
                                        ? Colors.red
                                        : Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              data['trend'] == 'up'
                                  ? Icons.trending_up
                                  : data['trend'] == 'down'
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                              size: 16,
                              color: data['trend'] == 'up'
                                  ? Colors.green
                                  : data['trend'] == 'down'
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () => _editFinance(name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // DETAILS TAB
          Column(
            children: [
              Container(
                color: Colors.deepPurple,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search financial items...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category Filter Chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_categories[index]),
                              selected: _selectedCategory == _categories[index],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = _categories[index];
                                });
                              },
                              backgroundColor: Colors.white.withOpacity(0.2),
                              selectedColor: Colors.white,
                              checkmarkColor: Colors.deepPurple,
                              labelStyle: TextStyle(
                                color: _selectedCategory == _categories[index]
                                    ? Colors.deepPurple
                                    : Colors.grey.shade700,
                                fontWeight: _selectedCategory == _categories[index]
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Finance Items List
              Expanded(
                child: _filteredFinanceData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching financial items found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Clear Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredFinanceData.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredFinanceData[index];
                          final name = entry.key;
                          final data = entry.value;
                          
                          return _buildEnhancedFinanceCard(name, data);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFinance,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon, {
    bool compact = false,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: compact ? 18 : 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 8 : 12),
              Text(
                NumberFormat.currency(symbol: '\$').format(amount),
                style: TextStyle(
                  fontSize: compact ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      amount > 0 ? Icons.trending_up : Icons.trending_flat,
                      color: amount > 0 ? Colors.green : Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amount > 0
                          ? '+${_getPercentageIncrease(amount)}% from last month'
                          : 'No change from last month',
                      style: TextStyle(
                        fontSize: 12,
                        color: amount > 0 ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for demo percentages
  String _getPercentageIncrease(double amount) {
    // This is just demo data
    final random = math.Random();
    return (random.nextInt(20) + 5).toString();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Income':
        return Colors.green.shade700;
      case 'Expenses':
        return Colors.red.shade700;
      case 'Investments':
        return Colors.blue.shade700;
      case 'Planning':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildFinancialChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade800,
            Colors.deepPurple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Last 6 Months',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: _ChartPainter(),
              size: const Size(double.infinity, 120),
            ),
          ),
          const SizedBox(height: 16),
          Row(
                        mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Income', Colors.green),
              const SizedBox(width: 16),
              _buildChartLegend('Expenses', Colors.red),
              const SizedBox(width: 16),
              _buildChartLegend('Investments', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialGoalCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Goal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Annual Equipment Budget',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '65%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade500),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$3,250 saved',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Text(
                      'Target: \$5,000',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add contribution
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Contribution'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFinanceCard(String name, Map<String, dynamic> data) {
  final formatter = NumberFormat.currency(symbol: '\$');
  final categoryColor = _getCategoryColor(data['category']);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _editFinance(name),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getFinanceIcon(data['category']),
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Make this row horizontally scrollable
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data['category'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              data['trend'] == 'up'
                                  ? Icons.trending_up
                                  : data['trend'] == 'down'
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                              size: 12,
                              color: data['trend'] == 'up'
                                  ? Colors.green
                                  : data['trend'] == 'down'
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Last updated: ${data['lastUpdate']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatter.format(data['amount']),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: data['category'] == 'Income'
                        ? Colors.green.shade700
                        : data['category'] == 'Expenses'
                            ? Colors.red.shade700
                            : categoryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            // Make buttons scrollable horizontally
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // View history
                    },
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _editFinance(name),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
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

  IconData _getFinanceIcon(String category) {
    switch (category) {
      case 'Income':
        return Icons.account_balance_wallet;
      case 'Expenses':
        return Icons.shopping_cart;
      case 'Investments':
        return Icons.show_chart;
      case 'Planning':
        return Icons.calendar_today;
      default:
        return Icons.attach_money;
    }
  }
}

// Custom painter for the chart
class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final incomePath = Path();
    final expensePath = Path();
    final investPath = Path();
    
    final width = size.width;
    final height = size.height;
    
    // Generate random points for demo chart
    final random = math.Random(42); // Fixed seed for consistent results
    
    // Income line (green)
    incomePath.moveTo(0, height * 0.7);
    for (int i = 1; i <= 6; i++) {
      final x = i * (width / 6);
      final y = height * (0.7 - random.nextDouble() * 0.5);
      incomePath.lineTo(x, y);
    }
    
    // Expense line (red)
    expensePath.moveTo(0, height * 0.4);
    for (int i = 1; i <= 6; i++) {
      final x = i * (width / 6);
      final y = height * (0.4 + random.nextDouble() * 0.3);
      expensePath.lineTo(x, y);
    }
    
    // Investment line (blue)
    investPath.moveTo(0, height * 0.6);
    for (int i = 1; i <= 6; i++) {
      final x = i * (width / 6);
      final y = height * (0.6 - random.nextDouble() * 0.3);
      investPath.lineTo(x, y);
    }
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    
    for (int i = 0; i <= 4; i++) {
      final y = i * (height / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
    
    for (int i = 0; i <= 6; i++) {
      final x = i * (width / 6);
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    
    // Draw lines
    final incomePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final expensePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final investPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);
    canvas.drawPath(investPath, investPaint);
    
    // Draw dots at data points
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i <= 6; i++) {
      final x = i * (width / 6);
      
      // Only draw dots if there's a valid path
      if (i > 0 && i <= incomePath.computeMetrics().length) {
        try {
          final incomeMetrics = incomePath.computeMetrics().first;
          final tangent = incomeMetrics.getTangentForOffset(x);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4, dotPaint..color = Colors.green);
          }
        } catch (e) {
          // Handle any potential errors from path calculations
        }
      }
      
      if (i > 0 && i <= expensePath.computeMetrics().length) {
        try {
          final expenseMetrics = expensePath.computeMetrics().first;
          final tangent = expenseMetrics.getTangentForOffset(x);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4, dotPaint..color = Colors.red);
          }
        } catch (e) {
          // Handle any potential errors
        }
      }
      
      if (i > 0 && i <= investPath.computeMetrics().length) {
        try {
          final investMetrics = investPath.computeMetrics().first;
          final tangent = investMetrics.getTangentForOffset(x);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4, dotPaint..color = Colors.blue);
          }
        } catch (e) {
          // Handle any potential errors
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}