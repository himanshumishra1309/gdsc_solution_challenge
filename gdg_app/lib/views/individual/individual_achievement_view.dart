import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gdg_app/serivces/auth_service.dart';
import 'package:gdg_app/widgets/custom_drawer.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:dotted_border/dotted_border.dart'; // Add this package to your pubspec.yaml

class IndividualAchievementView extends StatefulWidget {
  const IndividualAchievementView({super.key});

  @override
  _IndividualAchievementViewState createState() => _IndividualAchievementViewState();
}

class _IndividualAchievementViewState extends State<IndividualAchievementView> {
  String _selectedDrawerItem = uploadAchievementRoute;
  String _selectedSport = 'Cricket';
  List<String> _uploadedFiles = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _sports = [
    'Cricket', 'Badminton', 'Football', 'Basketball', 'Tennis', 
    'Swimming', 'Golf', 'Hockey', 'Volleyball', 'Athletics'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSelectDrawerItem(String item) {
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, item);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _uploadedFiles.addAll(result.paths.map((path) => path!).toList());
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  void _handleSubmit() {
    // Here you would typically upload the files and form data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Achievement submitted successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Clear form
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _uploadedFiles.clear();
      _selectedDate = DateTime.now();
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

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'image';
    } else if (extension == 'pdf') {
      return 'pdf';
    } else {
      return 'file';
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
      appBar: AppBar(
        title: const Text('Upload Achievement'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        toolbarHeight: 65.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Previous uploads',
            onPressed: () {
              // Show history of uploads
            },
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
        onLogout: () => _onWillPop(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Header background
            Container(
              height: 50,
              color: Colors.deepPurple,
            ),
            
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section with instructions
                  Container(
                    color: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: const Text(
                      'Share your achievements to showcase your progress and get recognition from potential sponsors.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  // Form area
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Achievement details section
                        const Text(
                          'Achievement Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Title field
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Achievement Title',
                            hintText: 'E.g., First Place at Regional Tournament',
                            prefixIcon: const Icon(Icons.emoji_events, color: Colors.deepPurple),
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
                        
                        const SizedBox(height: 16),
                        
                        // Sport and date in one row
                        Row(
                          children: [
                            // Sport dropdown
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: _selectedSport,
                                decoration: InputDecoration(
                                  labelText: 'Sport',
                                  prefixIcon: const Icon(Icons.sports, color: Colors.deepPurple),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: _sports.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSport = newValue!;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Date picker
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description field
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Describe your achievement and its significance',
                            alignLabelWithHint: true,
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
                        
                        const SizedBox(height: 24),
                        
                        // Files section
                        const Text(
                          'Upload Evidence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Add photos, certificates, or any documents as proof of your achievement',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // File upload area
                        GestureDetector(
                          onTap: _pickFiles,
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            dashPattern: const [8, 4],
                            color: Colors.deepPurple.shade300,
                            strokeWidth: 2,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 40,
                                    color: Colors.deepPurple.shade300,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload files',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.deepPurple.shade300,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'JPG, PNG, PDF (max 10MB each)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Uploaded files list
                        if (_uploadedFiles.isNotEmpty) ...[
                          Text(
                            'Uploaded Files (${_uploadedFiles.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _uploadedFiles.length,
                            itemBuilder: (context, index) {
                              final fileName = _uploadedFiles[index].split('/').last;
                              final fileType = _getFileIcon(fileName);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: fileType == 'image' 
                                        ? Colors.blue.shade100 
                                        : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        fileType == 'image' 
                                          ? Icons.image
                                          : fileType == 'pdf' 
                                              ? Icons.picture_as_pdf 
                                              : Icons.insert_drive_file,
                                        color: fileType == 'image' 
                                          ? Colors.blue.shade700 
                                          : Colors.red.shade700,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${(index + 1) * 2} MB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () => _removeFile(index),
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Achievement',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}