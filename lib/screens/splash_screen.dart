import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';

/// Splash screen for the Career Insight Engine
/// Provides a calm, reflective introduction to the application
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Navigate to home screen after a brief pause
  Future<void> _navigateToHome() async {
    // Allow the splash screen to be visible for a moment
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon space
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppTheme.accentTeal.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.insights_outlined,
                    size: 60,
                    color: AppTheme.accentTeal,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
                
                const SizedBox(height: 32),
                
                // App name
                Text(
                  'Wigu',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.3, curve: Curves.easeOut),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Career Insight Engine',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.3, curve: Curves.easeOut),
                
                const SizedBox(height: 48),
                
                // Tagline
                Text(
                  'A reflective tool for career\nexploration and development',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mutedText,
                    height: 1.6,
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.2, curve: Curves.easeOut),
                
                const SizedBox(height: 64),
                
                // Loading indicator
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentTeal.withOpacity(0.6),
                    ),
                  ),
                )
                    .animate(delay: 1200.ms)
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                
                const SizedBox(height: 16),
                
                // Loading text with Australian English
                Text(
                  'Initialising your journey...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                  ),
                )
                    .animate(delay: 1400.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}