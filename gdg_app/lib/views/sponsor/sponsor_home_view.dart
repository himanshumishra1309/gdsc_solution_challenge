import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class SponsorHomeView extends StatefulWidget {
  const SponsorHomeView({super.key});

  @override
  _SponsorHomeViewState createState() => _SponsorHomeViewState();
}

class _SponsorHomeViewState extends State<SponsorHomeView>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  List<dynamic> _newsArticles = [];
  List<String> _sports = [
    'cricket',
    'football',
    'badminton',
    'tennis',
    'basketball'
  ];
  String _selectedSport = 'cricket';
  int _currentPage = 1;
  final int _newsPerPage = 8;
  String _selectedDrawerItem = sponsorHomeViewRoute;
  String _searchQuery = '';
  bool _isLoading = true;
  bool _showFilterOptions = false;
  late TabController _tabController;
  // Add these state variables for user info
  String _userName = "";
  String _userEmail = "";
  String? _userAvatar;

  // Define sports icons for better visual representation
  final Map<String, IconData> _sportIcons = {
    'cricket': Icons.sports_cricket,
    'football': Icons.sports_soccer,
    'badminton': Icons.sports_tennis,
    'tennis': Icons.sports_tennis,
    'basketball': Icons.sports_basketball,
  };

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: _sports.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedSport = _sports[_tabController.index];
          _currentPage = 1;
          _loadNewsArticles();
        });
      }
    });
    _loadNewsArticles();
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

  Future<void> _loadNewsArticles() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final String response =
        await rootBundle.loadString('assets/json_files/news_articles.json');
    final data = json.decode(response);
    setState(() {
      _newsArticles = data[_selectedSport] ?? [];
      _isLoading = false;
    });
  }

  void _onSportChanged(String? newSport) {
    if (newSport != null) {
      final sportIndex = _sports.indexOf(newSport);
      if (sportIndex != -1) {
        _tabController.animateTo(sportIndex);
      }
      setState(() {
        _selectedSport = newSport;
        _currentPage = 1;
        _loadNewsArticles();
      });
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
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

    if (shouldLogout) {
      Navigator.pushReplacementNamed(context, landingPageRoute);
    }

    return shouldLogout;
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });

    // Scroll to top when page changes
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

  void _filterNews(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, landingPageRoute);
  }

  void _toggleFilterOptions() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Filter news based on search query
    final filteredNews = _newsArticles
        .where((news) =>
            news['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final int totalPages = (filteredNews.length / _newsPerPage).ceil();
    final List<dynamic> currentNews = filteredNews
        .skip((_currentPage - 1) * _newsPerPage)
        .take(_newsPerPage)
        .toList();

    // Ensure current page is valid
    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = totalPages;
    }

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

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sponsorship Hub',
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                      onChanged: _filterNews,
                      decoration: InputDecoration(
                        hintText: 'Search news articles',
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
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),

                  // Sport tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: _sports
                        .map((sport) => Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_sportIcons[sport]),
                                  const SizedBox(width: 8),
                                  Text(sport.capitalize()),
                                ],
                              ),
                            ))
                        .toList(),
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
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Sort by:'),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Latest'),
                            selected: true,
                            selectedColor: Colors.deepPurple.shade100,
                            labelStyle:
                                const TextStyle(color: Colors.deepPurple),
                            onSelected: (_) {},
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Popular'),
                            selected: false,
                            backgroundColor: Colors.grey.shade200,
                            onSelected: (_) {},
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _currentPage = 1;
                                _showFilterOptions = false;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),

            // News articles
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : currentNews.isEmpty
                      ? _buildEmptyView()
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: RefreshIndicator(
                            color: Colors.deepPurple,
                            onRefresh: _loadNewsArticles,
                            child: GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio:
                                    0.8, // Adjusted ratio to prevent overflow
                              ),
                              itemCount: currentNews.length,
                              itemBuilder: (context, index) {
                                final news = currentNews[index];
                                return _buildNewsCard(news, context);
                              },
                            ),
                          ),
                        ),
            ),

            // Pagination controls
            if (!_isLoading && filteredNews.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1
                          ? () => _onPageChanged(_currentPage - 1)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 12),
                          SizedBox(width: 4),
                          Text('Previous', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          for (int i = 1; i <= totalPages; i++)
                            if (i == 1 ||
                                i == totalPages ||
                                (i >= _currentPage - 1 &&
                                    i <= _currentPage + 1))
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: i == _currentPage
                                      ? Colors.deepPurple
                                      : Colors.grey.shade200,
                                  child: TextButton(
                                    onPressed: () => _onPageChanged(i),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(32, 32),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      '$i',
                                      style: TextStyle(
                                        color: i == _currentPage
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                        fontWeight: i == _currentPage
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (i == 2 && _currentPage > 3 ||
                                i == totalPages - 1 &&
                                    _currentPage < totalPages - 2)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: const Text('...',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _currentPage < totalPages
                          ? () => _onPageChanged(_currentPage + 1)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Next', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_forward, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(dynamic news, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // View detail page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing: ${news['title']}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                Hero(
                  tag: 'news_${news['id'] ?? news['title']}',
                  child: Container(
                    height: 100, // Reduced height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(news['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedSport.capitalize(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Date badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news['date'] ?? '2023-03-15',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'],
                      style: const TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    Expanded(
                      child: Text(
                        news['description'],
                        style: TextStyle(
                          fontSize: 12, // Reduced font size
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Simplified footer
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 0, 12, 8), // Reduced padding
              child: Row(
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    size: 14, // Smaller icon
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${news['views'] ?? '1.2K'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading $_selectedSport news...',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
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
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No articles found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Try selecting a different sport'
                : 'Try adjusting your search',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Search'),
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
