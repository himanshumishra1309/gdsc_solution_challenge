import 'package:flutter/material.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';

class IndividualGymPlanView extends StatefulWidget {
  const IndividualGymPlanView({super.key});

  @override
  _IndividualGymPlanViewState createState() => _IndividualGymPlanViewState();
}

class _IndividualGymPlanViewState extends State<IndividualGymPlanView> {
  String _selectedDrawerItem = individualGymPlanRoute; // Highlight the current page
  String _selectedPlan = 'Own Plan';
  String _selectedWeek = 'Week 1';
  String _selectedMonth = 'January';
  List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  Map<String, List<String>> _exercises = {};

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacementNamed(context, item); // Handle navigation based on the selected item
  }

  void _addExercise(String day) {
    setState(() {
      _exercises[day] = _exercises[day] ?? [];
      _exercises[day]!.add('');
    });
  }

  void _removeExercise(String day, int index) {
    setState(() {
      _exercises[day]!.removeAt(index);
    });
  }

  void _updateExercise(String day, int index, String value) {
    setState(() {
      _exercises[day]![index] = value;
    });
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
      appBar: AppBar(
        title: const Text('Gym Plan'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        toolbarHeight: 70,
        elevation: 10,
      ),
      drawer: CustomDrawer(
        selectedDrawerItem: _selectedDrawerItem,
        onSelectDrawerItem: _onSelectDrawerItem,
        drawerItems: drawerItems,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Plan Selection Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlan = 'Own Plan';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPlan == 'Own Plan' ? Colors.deepPurple : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Own Plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedPlan == 'Own Plan' ? Colors.white : Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlan = 'Recommended Plan';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPlan == 'Recommended Plan' ? Colors.deepPurple : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Recommended Plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedPlan == 'Recommended Plan' ? Colors.white : Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search and Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedWeek,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWeek = newValue!;
                    });
                  },
                  items: <String>['Week 1', 'Week 2', 'Week 3', 'Week 4']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue!;
                    });
                  },
                  items: <String>[
                    'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Plan Content
            Expanded(
              child: _selectedPlan == 'Own Plan' ? _buildOwnPlan() : _buildRecommendedPlan(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnPlan() {
    return ListView(
      children: _days.map((day) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              day,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.deepPurple),
                        onPressed: () => _addExercise(day),
                      ),
                    ),
                    ..._exercises[day]?.asMap().entries.map((entry) {
                      int index = entry.key;
                      String exercise = entry.value;
                      return ListTile(
                        title: TextField(
                          decoration: const InputDecoration(labelText: 'Exercise'),
                          onChanged: (value) => _updateExercise(day, index, value),
                          controller: TextEditingController(text: exercise),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeExercise(day, index),
                        ),
                      );
                    }).toList() ?? [],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendedPlan() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to answer questions page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Answer Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to view plan page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}