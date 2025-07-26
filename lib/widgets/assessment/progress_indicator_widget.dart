import 'package:flutter/material.dart';
import '../../providers/career_assessment_provider.dart';
import '../../utils/theme.dart';

/// Widget showing overall assessment progress with visual indicators
/// Displays completion percentage and domain-by-domain progress
class ProgressIndicatorWidget extends StatelessWidget {
  final CareerAssessmentProvider provider;

  const ProgressIndicatorWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final progress = provider.overallProgress;
    final completedCount = provider.completedDomains.length;
    final totalCount = provider.topLineQuestions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: CareerTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Assessment Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: CareerTheme.primaryGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                CareerTheme.primaryGreen,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          
          // Progress text
          Text(
            '$completedCount of $totalCount domains completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          
          // Domain indicators
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            _buildDomainIndicators(),
          ],
        ],
      ),
    );
  }

  Widget _buildDomainIndicators() {
    final domains = _getCareerDomains();
    
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: domains.map((domain) {
        final isCompleted = provider.isDomainCompleted(domain['key']!);
        final isCurrent = provider.currentDomain == domain['key'];
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? CareerTheme.statusSuccess.withOpacity(0.1)
                : isCurrent
                    ? (domain['color'] as Color).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? CareerTheme.statusSuccess.withOpacity(0.3)
                  : isCurrent
                      ? (domain['color'] as Color).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: CareerTheme.statusSuccess,
                  size: 12,
                )
              else if (isCurrent)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: domain['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                domain['shortTitle'] ?? _getShortTitle(domain['title']!),
                style: TextStyle(
                  color: isCompleted
                      ? CareerTheme.statusSuccess
                      : isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getShortTitle(String title) {
    // Convert full titles to short versions
    switch (title) {
      case 'Joy & Energy':
        return 'Joy';
      case 'Natural Strengths':
        return 'Strengths';
      case 'Sought For':
        return 'Sought';
      case 'Values & Impact':
        return 'Values';
      case 'Life Design':
        return 'Design';
      default:
        return title.split(' ').first;
    }
  }

  List<Map<String, dynamic>> _getCareerDomains() {
    return [
      {
        'key': 'joy_energy',
        'title': 'Joy & Energy',
        'shortTitle': 'Joy',
        'color': CareerTheme.accentYellow,
      },
      {
        'key': 'strengths',
        'title': 'Natural Strengths',
        'shortTitle': 'Strengths',
        'color': CareerTheme.primaryBlue,
      },
      {
        'key': 'sought_for',
        'title': 'Sought For',
        'shortTitle': 'Sought',
        'color': CareerTheme.accentOrange,
      },
      {
        'key': 'values_impact',
        'title': 'Values & Impact',
        'shortTitle': 'Values',
        'color': CareerTheme.primaryGreen,
      },
      {
        'key': 'life_design',
        'title': 'Life Design',
        'shortTitle': 'Design',
        'color': CareerTheme.accentPurple,
      },
    ];
  }
}