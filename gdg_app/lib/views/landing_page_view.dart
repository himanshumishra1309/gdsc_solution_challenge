import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gdg_app/constants/routes.dart';
import 'package:gdg_app/popups/alert_message.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Show confirmation dialog
      final bool? shouldExit = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
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
      
      // Return true to exit app or false to stay
      return shouldExit ?? false;
    },
    child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background image with gradient overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/signupimages.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), 
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or icon
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sports_basketball,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Welcome text with animation
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                        ),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                          ),
                        ),
                        child: const Text(
                          'Welcome to AthleTech',
                          style: TextStyle(
                            fontFamily: 'Schyler',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                        ),
                      ),
                      child: const Text(
                        'Choose your path to get started',
                        style: TextStyle(
                          fontFamily: 'Schyler',
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Buttons with staggered animations
                    ..._buildAnimatedButtons(),
                    
                    const SizedBox(height: 40),
                    
                    // Footer
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: Text(
                        '© ${DateTime.now().year} AthleTech',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
  );
  }
  
  List<Widget> _buildAnimatedButtons() {
    final buttonData = [
      {
        'title': 'Individual Athlete',
        'icon': Icons.person,
        'color': Colors.blue,
        'onTap': () => Navigator.of(context).pushReplacementNamed(
          loginRoute,
          arguments: 'individualRegister',
        ),
      },
      {
        'title': 'Organization',
        'icon': Icons.business,
        'color': Colors.deepPurple,
        'onTap': () => _showOrganizationOptions(),
      },
      {
        'title': 'Sponsor',
        'icon': Icons.handshake,
        'color': Colors.amber.shade700,
        'onTap': () => Navigator.of(context).pushReplacementNamed(
          loginRoute,
          arguments: 'sponsorRegister',
        ),
      },
    ];
    
    return List.generate(
      buttonData.length,
      (index) => FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.4 + (index * 0.1),
              0.7 + (index * 0.1),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.4 + (index * 0.1),
                0.7 + (index * 0.1),
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRoleButton(
              title: buttonData[index]['title'] as String,
              icon: buttonData[index]['icon'] as IconData,
              color: buttonData[index]['color'] as Color,
              onTap: buttonData[index]['onTap'] as VoidCallback,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Schyler',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showOrganizationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade900.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Organization Options',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildOrganizationOption(
                icon: Icons.add_business,
                title: 'New Organization',
                description: 'Register your organization with us',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context, 
                    organizationRegistrationViewRoute,
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildOrganizationOption(
                icon: Icons.business,
                title: 'Existing Organization',
                description: 'Log in to your organization account',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context, 
                    coachAdminPlayerRoute,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOrganizationOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}