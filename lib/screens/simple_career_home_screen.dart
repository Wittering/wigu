import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../widgets/detailed_assessment_widget.dart';

/// Simplified main home screen for the Career Insight Engine
/// Features a simple "What do you want to be when you grow up?" entry point
/// with detailed assessment available in a secondary tab
class SimpleCareerHomeScreen extends ConsumerStatefulWidget {
  const SimpleCareerHomeScreen({super.key});

  @override
  ConsumerState<SimpleCareerHomeScreen> createState() => _SimpleCareerHomeScreenState();
}

class _SimpleCareerHomeScreenState extends ConsumerState<SimpleCareerHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildAssessmentTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentTeal.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 24,
                  color: AppTheme.accentTeal,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wigu',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Career Insight Engine',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryText,
                        letterSpacing: 0.5,
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1),
                  ],
                ),
              ),
              
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showSettingsDialog(context),
                tooltip: 'Settings',
                color: AppTheme.mutedText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return const DetailedAssessmentWidget();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mutedTone1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: AppTheme.primaryText),
        ),
        content: Text(
          'Settings functionality will be implemented here.',
          style: TextStyle(color: AppTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
        ],
      ),
    );
  }
}