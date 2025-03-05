import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class SponsorHomeView extends StatefulWidget {
  const SponsorHomeView({super.key});

  @override
  _SponsorHomeViewState createState() => _SponsorHomeViewState();
}

class _SponsorHomeViewState extends State<SponsorHomeView> {
  List<dynamic> _newsArticles = [];
  String _selectedSport = 'cricket';
  int _currentPage = 1;
  final int _newsPerPage = 10;
  String _selectedDrawerItem = sponsorHomeViewRoute;
  String _searchQuery = '';

  Future<bool> _onWillPop(BuildContext context) async {
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout?'),
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
      Navigator.pushReplacementNamed(context, landingPageRoute); // Replace with your home route
    }

    return shouldLogout;
  }

  @override
  void initState() {
    super.initState();
    _loadNewsArticles();
  }

  Future<void> _loadNewsArticles() async {
    final String response = await rootBundle.loadString('assets/json_files/news_articles.json');
    final data = json.decode(response);
    setState(() {
      _newsArticles = data[_selectedSport] ?? [];
    });
  }

  void _onSportChanged(String? newSport) {
    if (newSport != null) {
      setState(() {
        _selectedSport = newSport;
        _currentPage = 1;
        _loadNewsArticles();
      });
    }
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
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
      _loadNewsArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (_newsArticles.length / _newsPerPage).ceil();
    final List<dynamic> currentNews = _newsArticles
        .where((news) => news['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .skip((_currentPage - 1) * _newsPerPage)
        .take(_newsPerPage)
        .toList();

    final List<DrawerItem> drawerItems = [
      DrawerItem(icon: Icons.article, title: 'News and Updates', route: sponsorHomeViewRoute),
      DrawerItem(icon: Icons.sports, title: 'Sports of Interest', route: sportsOfInterestRoute),
      DrawerItem(icon: Icons.mail, title: 'Invitations', route: invitationToSponsorRoute),
      DrawerItem(icon: Icons.request_page, title: 'Requests', route: requestToSponsorPageRoute),
      DrawerItem(icon: Icons.search, title: 'Find Organization or Players', route: findOrganizationOrPlayersRoute),
    ];

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sponsor Home'),
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(
            color: Colors.white, // Change this to the desired color
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          toolbarHeight: 65.0,
        ),
        drawer: CustomDrawer(
          selectedDrawerItem: _selectedDrawerItem,
          onSelectDrawerItem: (route) {
            Navigator.pop(context); // Close the drawer
            if (ModalRoute.of(context)?.settings.name != route) {
              Navigator.pushNamed(context, route);
            }
          },
          drawerItems: drawerItems,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: _filterNews,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedSport,
                    onChanged: _onSportChanged,
                    items: <String>['cricket', 'football', 'badminton']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.capitalize()),
                      );
                    }).toList(),
                    style: TextStyle(color: Colors.deepPurple, fontSize: 18),
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.deepPurple,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: currentNews.length,
                  itemBuilder: (context, index) {
                    final news = currentNews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(news['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              news['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              news['description'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Page $_currentPage of $totalPages',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _currentPage < totalPages ? () => _onPageChanged(_currentPage + 1) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}