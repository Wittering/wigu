import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../providers/career_assessment_provider.dart';
import '../models/career_session.dart';
import '../widgets/domain_overview_card.dart';
import '../widgets/assessment/session_setup_dialog.dart';

/// Detailed assessment widget for the comprehensive 5-domain career assessment
/// Contains the structured assessment flow with domains and AI probing
class DetailedAssessmentWidget extends ConsumerStatefulWidget {
  const DetailedAssessmentWidget({super.key});

  @override
  ConsumerState<DetailedAssessmentWidget> createState() => _DetailedAssessmentWidgetState();
}

class _DetailedAssessmentWidgetState extends ConsumerState<DetailedAssessmentWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(careerAssessmentProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentSession == null) 
            _buildDirectStartSection()
          else
            Expanded(child: _buildAssessmentContent(provider)),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover your career direction',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Text(
          'Explore five key areas to understand what you want to be when you grow up',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.secondaryText.withOpacity(0.8),
            height: 1.4,
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Five career domains',
      'AI-powered questions',
      'Progress tracking',
    ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppTheme.successGreen.withOpacity(0.7),
              size: 12,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryText.withOpacity(0.7),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDirectStartSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          _buildSimpleHeader(),
          const SizedBox(height: 40),
          
          // Start session button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showNewSessionDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.backgroundBlack,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.psychology_outlined, size: 18),
              label: const Text(
                'Start Your Assessment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 400.ms)
              .scale(begin: const Offset(0.9, 0.9)),
          
          const SizedBox(height: 40),
          
          // Domain preview cards
          _buildDomainPreview(),
        ],
      ),
    );
  }

  Widget _buildAssessmentContent(CareerAssessmentProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info
          if (provider.currentSession != null) ...[
            _buildSessionInfo(provider.currentSession!),
            const SizedBox(height: 24),
          ],
          
          // Progress overview
          _buildProgressOverview(provider),
          const SizedBox(height: 24),
          
          // Domain cards
          _buildDomainGrid(provider),
          
          // Quick actions
          const SizedBox(height: 32),
          _buildQuickActions(provider),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(CareerSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mutedTone2.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_open,
            color: AppTheme.accentTeal,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.sessionName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started ${_formatDuration(DateTime.now().difference(session.createdAt))} ago',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${(session.completionPercentage * 100).round()}%',
              style: TextStyle(
                color: AppTheme.successGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(CareerAssessmentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successGreen.withOpacity(0.1),
            AppTheme.successGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: provider.overallProgress,
              backgroundColor: AppTheme.mutedTone1.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${provider.completedDomains.length} of ${provider.topLineQuestions.length} domains completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainGrid(CareerAssessmentProvider provider) {
    // Use the 5 domains from the assessment questions instead of all CareerDomain values
    final domainKeys = provider.topLineQuestions.keys.toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if we can fit all domains in one row
        final availableWidth = constraints.maxWidth;
        final cardWidth = (availableWidth - (domainKeys.length - 1) * 12) / domainKeys.length; // 12px spacing between cards
        
        if (cardWidth > 140) {
          // Use single row if cards can be reasonably sized
          return SizedBox(
            height: 160, // Fixed height for single row
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: domainKeys.length,
              itemBuilder: (context, index) {
                final domainKey = domainKeys[index];
                final domain = _getDomainFromKey(domainKey);
                final isCompleted = provider.completedDomains.contains(domainKey);
                final responseCount = provider.currentSession?.responses.values
                    .where((r) => r.questionId.startsWith(domainKey)).length ?? 0;
                
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(right: index < domainKeys.length - 1 ? 12 : 0),
                  child: DomainOverviewCard(
                    domain: domain,
                    isCompleted: isCompleted,
                    responseCount: responseCount,
                    onTap: () => _exploreDomain(domain),
                  ),
                );
              },
            ),
          );
        } else {
          // Fall back to 2-column grid for smaller screens
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: domainKeys.length,
            itemBuilder: (context, index) {
              final domainKey = domainKeys[index];
              final domain = _getDomainFromKey(domainKey);
              final isCompleted = provider.completedDomains.contains(domainKey);
              final responseCount = provider.currentSession?.responses.values
                  .where((r) => r.questionId.startsWith(domainKey)).length ?? 0;
              
              return DomainOverviewCard(
                domain: domain,
                isCompleted: isCompleted,
                responseCount: responseCount,
                onTap: () => _exploreDomain(domain),
              );
            },
          );
        }
      },
    );
  }
  
  Widget _buildDomainPreview() {
    final domains = [
      {'key': 'joy_energy', 'title': 'Joy & Energy', 'icon': '⚡', 'color': AppTheme.warningAmber},
      {'key': 'strengths', 'title': 'Natural Strengths', 'icon': '💪', 'color': AppTheme.accentTeal},
      {'key': 'sought_for', 'title': 'Sought For', 'icon': '🎯', 'color': AppTheme.warningAmber},
      {'key': 'values_impact', 'title': 'Values & Impact', 'icon': '🌟', 'color': AppTheme.successGreen},
      {'key': 'life_design', 'title': 'Life Design', 'icon': '🎨', 'color': AppTheme.mutedTone1},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: domains.length,
        itemBuilder: (context, index) {
          final domain = domains[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < domains.length - 1 ? 16 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (domain['color'] as Color).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (domain['color'] as Color).withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  domain['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  domain['title'] as String,
                  style: TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  CareerDomain _getDomainFromKey(String domainKey) {
    // Map the 5 assessment domains to CareerDomain enum values
    switch (domainKey) {
      case 'joy_energy':
        return CareerDomain.creative;
      case 'strengths':
        return CareerDomain.technical;
      case 'sought_for':
        return CareerDomain.social;
      case 'values_impact':
        return CareerDomain.leadership;
      case 'life_design':
        return CareerDomain.analytical;
      default:
        return CareerDomain.creative;
    }
  }

  Widget _buildQuickActions(CareerAssessmentProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showNewSessionDialog(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.mutedText,
              side: BorderSide(color: AppTheme.mutedTone2.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Session'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.currentSession != null ? () => _continueAssessment() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentTeal,
              foregroundColor: AppTheme.backgroundBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  void _navigateToAssessment() {
    Navigator.of(context).pushNamed('/assessment');
  }

  void _exploreDomain(CareerDomain domain) {
    // Navigate to domain exploration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exploring ${domain.displayName}'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }

  void _continueAssessment() {
    Navigator.of(context).pushNamed('/assessment');
  }

  void _showNewSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => const SessionSetupDialog(),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
  }
}