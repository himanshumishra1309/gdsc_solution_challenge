import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:intl/intl.dart';

class PlayerFinancialView extends StatefulWidget {
  const PlayerFinancialView({super.key});

  @override
  _PlayerFinancialViewState createState() => _PlayerFinancialViewState();
}

class _PlayerFinancialViewState extends State<PlayerFinancialView> with SingleTickerProviderStateMixin {
  String _selectedDrawerItem = playerFinancialViewRoute;
  late TabController _tabController;
  String _searchQuery = '';
  String _activeTab = 'All';
  bool _showSummaryView = false;
  
  final List<String> _categories = [
    'All', 'Income', 'Expenses', 'Pending'
  ];

  final Map<String, double> _financeData = {
    'Salary/Stipend': 5000.0,
    'Prize Money Allocation': 2000.0,
    'Sponsorship Deals': 10000.0,
    'Training & Facility Sponsorship': 3000.0,
    'Travel & Accommodation Support': 4000.0,
    'Medical & Insurance Coverage': 2000.0,
    'Coaching Fees': -1500.0,
    'Team Equipment & Gear Costs': -2500.0,
    'Medical & Physiotherapy': -1800.0,
    'Nutrition & Supplements': -600.0,
    'Tax Deductions': -500.0,
    'Fines & Penalties': -200.0,
    'Team/Club Budget Allocation': 7000.0,
    'Funding Requests & Approvals': 3000.0,
    'Financial Aid & Loans': 5000.0,
    'Salary & Payment Statements': 15000.0,
    'Expense Breakdown': -12000.0,
    'Pending Approvals': 2000.0,
    'Annual Financial Summary': 25000.0,
  };

  final Map<String, IconData> _categoryIcons = {
    'Salary/Stipend': Icons.account_balance_wallet,
    'Prize Money Allocation': Icons.emoji_events,
    'Sponsorship Deals': Icons.handshake,
    'Training & Facility Sponsorship': Icons.fitness_center,
    'Travel & Accommodation Support': Icons.flight,
    'Medical & Insurance Coverage': Icons.health_and_safety,
    'Coaching Fees': Icons.sports,
    'Team Equipment & Gear Costs': Icons.shopping_bag,
    'Medical & Physiotherapy': Icons.medical_services,
    'Nutrition & Supplements': Icons.restaurant,
    'Tax Deductions': Icons.receipt_long,
    'Fines & Penalties': Icons.gavel,
    'Team/Club Budget Allocation': Icons.account_balance,
    'Funding Requests & Approvals': Icons.request_page,
    'Financial Aid & Loans': Icons.volunteer_activism,
    'Salary & Payment Statements': Icons.payment,
    'Expense Breakdown': Icons.money_off,
    'Pending Approvals': Icons.pending_actions,
    'Annual Financial Summary': Icons.summarize,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTab = _categories[_tabController.index];
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editFinance(String key) {
    TextEditingController controller = TextEditingController(text: _financeData[key].toString().replaceAll('-', ''));
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update $key',
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _categoryIcons[key] ?? Icons.attach_money,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current: ${NumberFormat.currency(symbol: '\$').format(_financeData[key])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _financeData[key]! < 0,
                    onChanged: (value) {
                      setState(() {
                        // Toggle expense status
                        if (value == true && _financeData[key]! > 0) {
                          _financeData[key] = -_financeData[key]!;
                        } else if (value == false && _financeData[key]! < 0) {
                          _financeData[key] = _financeData[key]!.abs();
                        }
                      });
                      Navigator.pop(context);
                      _editFinance(key); // Reopen dialog with updated value
                    },
                    activeColor: Colors.deepPurple,
                  ),
                  const Text('Mark as expense'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  setState(() {
                    // Preserve the sign (income vs expense)
                    if (_financeData[key]! < 0) {
                      _financeData[key] = -newValue.abs();
                    } else {
                      _financeData[key] = newValue.abs();
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Get income total
  double get _totalIncome => _financeData.entries
      .where((entry) => entry.value > 0)
      .fold(0, (sum, entry) => sum + entry.value);

  // Get expenses total
  double get _totalExpenses => _financeData.entries
      .where((entry) => entry.value < 0)
      .fold(0, (sum, entry) => sum + entry.value.abs());

  // Get net balance
  double get _netBalance => _totalIncome - _totalExpenses;

  // Filter finance data based on category and search query
  List<MapEntry<String, double>> get _filteredFinanceData {
    var entries = _financeData.entries.toList();
    
    // Filter by tab category
    if (_activeTab == 'Income') {
      entries = entries.where((entry) => entry.value > 0).toList();
    } else if (_activeTab == 'Expenses') {
      entries = entries.where((entry) => entry.value < 0).toList();
    } else if (_activeTab == 'Pending') {
      entries = entries.where((entry) => entry.key.toLowerCase().contains('pending')).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      entries = entries
          .where((entry) => entry.key.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    return entries;
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, coachAdminPlayerRoute);
  }

  @override
  Widget build(BuildContext context) {
    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.show_chart, title: 'Graphs', route: playerHomeRoute),
      DrawerItem(icon: Icons.people, title: 'View Coaches', route: viewCoachProfileRoute),
      DrawerItem(icon: Icons.bar_chart, title: 'View Stats', route: viewPlayerStatisticsRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Medical Reports', route: medicalReportRoute),
      DrawerItem(icon: Icons.medical_services, title: 'View Nutritional Plan', route: nutritionalPlanRoute),
      DrawerItem(icon: Icons.announcement, title: 'View Announcements', route: playerviewAnnouncementRoute),
      DrawerItem(icon: Icons.calendar_today, title: 'View Calendar', route: viewCalendarRoute),
      DrawerItem(icon: Icons.fitness_center, title: 'View Gym Plan', route: viewGymPlanRoute),
      DrawerItem(icon: Icons.edit, title: 'Fill Injury Form', route: fillInjuryFormRoute),
      DrawerItem(icon: Icons.attach_money, title: 'Finances', route: playerFinancialViewRoute),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        toolbarHeight: 65.0,
        elevation: 0,
        actions: [
          // Toggle view button (table vs summary)
          IconButton(
            icon: Icon(
              _showSummaryView ? Icons.table_chart : Icons.pie_chart,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSummaryView = !_showSummaryView;
              });
            },
            tooltip: _showSummaryView ? 'Show Table View' : 'Show Summary View',
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
        onLogout: () => _handleLogout(),
      ),
      body: Column(
        children: [
          // Financial summary cards
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildSummaryCard(
                      'Income',
                      _totalIncome,
                      Colors.green.shade700,
                      Icons.arrow_upward,
                    ),
                    const SizedBox(width: 6),
                    _buildSummaryCard(
                      'Expenses',
                      _totalExpenses,
                      Colors.red.shade700,
                      Icons.arrow_downward,
                    ),
                    const SizedBox(width: 6),
                    _buildSummaryCard(
                      'Net Balance',
                      _netBalance,
                      _netBalance >= 0 ? Colors.blue.shade700 : Colors.orange.shade700,
                      _netBalance >= 0 ? Icons.account_balance_wallet : Icons.warning_amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search bar and category tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search financial records',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Category tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.deepPurple,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: _categories.map((category) => Tab(text: category)).toList(),
                ),
              ],
            ),
          ),
          
          // Main content area
          Expanded(
            child: _showSummaryView
                ? _buildSummaryView()
                : _buildDetailedListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Download or export financial data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Downloading financial report...'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.deepPurple,
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.download, color: Colors.white),
        tooltip: 'Export Financial Report',
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    final formattedAmount = NumberFormat.currency(symbol: '\$').format(amount.abs());
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedAmount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedListView() {
    if (_filteredFinanceData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No financial records found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFinanceData.length,
      itemBuilder: (context, index) {
        final entry = _filteredFinanceData[index];
        final icon = _categoryIcons[entry.key] ?? Icons.attach_money;
        final isExpense = entry.value < 0;
        final color = isExpense ? Colors.red.shade700 : Colors.green.shade700;
        final formattedAmount = NumberFormat.currency(symbol: '\$').format(entry.value.abs());
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isExpense ? Colors.red.shade100 : Colors.green.shade100,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            title: Text(
              entry.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              isExpense ? 'Expense' : 'Income',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.deepPurple,
                  onPressed: () => _editFinance(entry.key),
                ),
              ],
            ),
            onTap: () => _editFinance(entry.key),
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryView() {
    // Income vs Expenses visualization
    final incomeEntries = _financeData.entries.where((e) => e.value > 0).toList();
    final expenseEntries = _financeData.entries.where((e) => e.value < 0).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income section
          const Text(
            'Income Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: incomeEntries.isEmpty
                ? const Center(child: Text('No income entries'))
                : Column(
                    children: incomeEntries.map((entry) {
                      final percentage = (entry.value / _totalIncome * 100).toStringAsFixed(1);
                      final formattedAmount = NumberFormat.currency(symbol: '\$').format(entry.value);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$formattedAmount ($percentage%)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value / _totalIncome,
                              backgroundColor: Colors.green.shade50,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade500),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Expenses section
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: expenseEntries.isEmpty
                ? const Center(child: Text('No expense entries'))
                : Column(
                    children: expenseEntries.map((entry) {
                      final percentage = (entry.value.abs() / _totalExpenses * 100).toStringAsFixed(1);
                      final formattedAmount = NumberFormat.currency(symbol: '\$').format(entry.value.abs());
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$formattedAmount ($percentage%)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value.abs() / _totalExpenses,
                              backgroundColor: Colors.red.shade50,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade500),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}