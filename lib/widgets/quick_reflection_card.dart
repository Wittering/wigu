import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';

/// Card widget for quick reflection entry
/// Provides a fast way to capture career thoughts and insights
class QuickReflectionCard extends StatelessWidget {
  final VoidCallback? onStartReflection;

  const QuickReflectionCard({
    super.key,
    this.onStartReflection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onStartReflection,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentTeal.withOpacity(0.1),
                AppTheme.accentTeal.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: AppTheme.accentTeal.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDescription(context),
              const SizedBox(height: 16),
              _buildPrompts(context),
              const SizedBox(height: 16),
              _buildCallToAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            size: 22,
            color: AppTheme.accentTeal,
          ),
        )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms)
            .then()
            .shimmer(
              duration: 3000.ms,
              colors: [
                AppTheme.accentTeal.withOpacity(0.2),
                AppTheme.accentTeal.withOpacity(0.05),
              ],
            ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Reflection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Capture a thought or insight',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.mutedText,
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'Sometimes the best insights come unexpectedly. Use this space to quickly capture career thoughts, realisations, or questions as they arise.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.secondaryText,
        height: 1.5,
      ),
    );
  }

  Widget _buildPrompts(BuildContext context) {
    final prompts = [
      'What energised me most at work today?',
      'What career thought has been on my mind?',
      'What skill would I love to develop further?',
      'What kind of work environment suits me best?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reflection prompts:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...prompts.asMap().entries.map((entry) {
          final index = entry.key;
          final prompt = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    prompt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(delay: (200 + index * 100).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, curve: Curves.easeOut);
        }),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppTheme.accentTeal,
          ),
          const SizedBox(width: 8),
          Text(
            'Start Quick Reflection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOut)
        .then()
        .shimmer(
          duration: 2000.ms,
          colors: [
            AppTheme.accentTeal.withOpacity(0.1),
            AppTheme.accentTeal.withOpacity(0.05),
          ],
        );
  }
}