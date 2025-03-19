import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gdg_app/constants/routes.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this package for SVG support

class AdminPlayerCoachOption extends StatefulWidget {
  const AdminPlayerCoachOption({super.key});

  @override
  State<AdminPlayerCoachOption> createState() => _AdminPlayerCoachOptionState();
}

class _AdminPlayerCoachOptionState extends State<AdminPlayerCoachOption> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedOption = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacementNamed(context, landingPageRoute);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: Stack(
          children: [
            // Background image with gradient overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/signupimages.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // App logo/branding (optional)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/logo.png', // Add your logo here
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.sports_basketball,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutQuad,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: const Text(
                            'Log in as',
                            style: TextStyle(
                              fontFamily: 'Schyler',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Role selection cards
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRoleCard(
                                index: 0,
                                icon: Icons.admin_panel_settings,
                                title: 'Administrator',
                                description: 'Manage players, coaches, and teams',
                                color: Colors.deepPurple,
                                route: 'adminHome',
                                delay: 0,
                              ),
                              const SizedBox(height: 20),
                              _buildRoleCard(
                                index: 1,
                                icon: Icons.sports_basketball,
                                title: 'Player',
                                description: 'View your schedule and performance',
                                color: Colors.blue,
                                route: 'playerHome',
                                delay: 0.2,
                              ),
                              const SizedBox(height: 20),
                              _buildRoleCard(
                                index: 2,
                                icon: Icons.sports,
                                title: 'Coach',
                                description: 'Manage your teams and training sessions',
                                color: Colors.green,
                                route: 'coachHome',
                                delay: 0.4,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Footer with powered-by message
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Powered by AthleTech',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
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

  Widget _buildRoleCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String route,
    required double delay,
  }) {
    final isSelected = _selectedOption == index;
    
    // Delay the animation based on the delay parameter
    final Animation<double> delayedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay * 0.5, // Start point (0.0 to 1.0)
        1.0,
        curve: Curves.easeOutQuint,
      ),
    );
    
    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        final value = delayedAnimation.value;
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedOption = index);
          
          // Show selection animation before navigating
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushNamed(
              context,
              loginRoute,
              arguments: route,
            );
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withBlue((color.blue + 40).clamp(0, 255)),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.6 : 0.3),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          transform: isSelected 
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          child: Row(
            children: [
              // Role icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Role details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}