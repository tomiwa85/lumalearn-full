import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 1. Add SingleTickerProviderStateMixin for animation
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 2. Setup the "Beating" Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Speed of one beat
    )..repeat(reverse: true); // Makes it grow and shrink continuously

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000)); // Increased slightly to enjoy the animation
    if (!mounted) return;

    // 2. Check if user is already logged in
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is logged in -> Go straight to Home
      context.go('/home');
    } else {
      // User is Guest -> Go to Login
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Always clean up animations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3. Wrap the Logo in ScaleTransition
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.6), // Slightly stronger glow
                      blurRadius: 50,
                      spreadRadius: 2,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/icon_lumalearn.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // App Name (Static)
            Text(
              'LumaLearn',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}