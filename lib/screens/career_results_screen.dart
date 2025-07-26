import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../providers/career_assessment_provider.dart';
import '../models/career_session.dart';
import '../models/career_insight.dart';

/// Comprehensive results screen showing career insights and recommendations
/// Generated after completing all 5 domains of the assessment
class CareerResultsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CareerResultsScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<CareerResultsScreen> createState() => _CareerResultsScreenState();
}

class _CareerResultsScreenState extends ConsumerState<CareerResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(careerAssessmentProvider);
    final session = provider.currentSession;

    if (session == null) {
      return _buildErrorState('No session found');
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 2.0,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(session),
                  Expanded(
                    child: _buildResultsContent(session),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CareerSession session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with back button and completion badge
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.successGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ASSESSMENT COMPLETE',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Results title
          Text(
            'Your Career Insights',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your exploration of ${session.completedDomains.length} career domains',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent(CareerSession session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain completion overview
          _buildDomainOverview(session),
          const SizedBox(height: 32),
          
          // Key insights section
          _buildKeyInsights(session),
          const SizedBox(height: 32),
          
          // Response summary
          _buildResponseSummary(session),
          const SizedBox(height: 32),
          
          // Next steps and actions
          _buildNextSteps(session),
          const SizedBox(height: 32),
          
          // Export and sharing options
          _buildExportOptions(session),
        ],
      ),
    );
  }

  Widget _buildDomainOverview(CareerSession session) {
    final domains = [
      {'key': 'joy_energy', 'title': 'Joy & Energy', 'icon': '⚡', 'color': AppTheme.warningAmber},
      {'key': 'strengths', 'title': 'Natural Strengths', 'icon': '💪', 'color': AppTheme.accentTeal},
      {'key': 'sought_for', 'title': 'Sought For', 'icon': '🎯', 'color': AppTheme.warningAmber},
      {'key': 'values_impact', 'title': 'Values & Impact', 'icon': '🌟', 'color': AppTheme.successGreen},
      {'key': 'life_design', 'title': 'Life Design', 'icon': '🎨', 'color': AppTheme.mutedTone1},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentTeal.withOpacity(0.1),
            AppTheme.accentTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentTeal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_outlined,
                color: AppTheme.accentTeal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Domain Exploration Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Domain grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final domain = domains[index];
              final responseCount = session.responses.values
                  .where((r) => r.questionId.startsWith(domain['key'] as String))
                  .length;
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (domain['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (domain['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      domain['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$responseCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'responses',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights(CareerSession session) {
    final insights = session.insights.isNotEmpty 
        ? session.insights 
        : _generatePlaceholderInsights();

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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.successGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Key Career Insights',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...insights.take(3).map((insight) => _buildInsightCard(insight)).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(CareerInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.type.displayName,
            style: TextStyle(
              color: _getInsightColor(insight.type),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.pattern:
        return AppTheme.accentTeal;
      case InsightType.strength:
        return AppTheme.successGreen;
      case InsightType.value:
        return AppTheme.warningAmber;
      case InsightType.interest:
        return AppTheme.mutedTone1;
      case InsightType.development:
        return AppTheme.accentTeal;
      case InsightType.compatibility:
        return AppTheme.successGreen;
      case InsightType.barrier:
        return AppTheme.errorRed;
      case InsightType.nextStep:
        return AppTheme.warningAmber;
    }
  }

  Widget _buildResponseSummary(CareerSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
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
                color: AppTheme.mutedTone1,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Assessment Summary',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildSummaryMetric(
                'Total Responses',
                '${session.responses.length}',
                Icons.chat_bubble_outline,
              ),
              const SizedBox(width: 24),
              _buildSummaryMetric(
                'Session Duration',
                _formatSessionDuration(session),
                Icons.schedule,
              ),
              const SizedBox(width: 24),
              _buildSummaryMetric(
                'Completion',
                '${(session.completionPercentage * 100).round()}%',
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.accentTeal,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps(CareerSession session) {
    final nextSteps = [
      'Review and reflect on your key insights',
      'Share results with trusted advisors for feedback',
      'Identify 2-3 specific career experiments to try',
      'Schedule regular check-ins to track progress',
      'Consider additional assessments in 6 months',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warningAmber.withOpacity(0.1),
            AppTheme.warningAmber.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningAmber.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.warningAmber,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recommended Next Steps',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...nextSteps.map((step) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildExportOptions(CareerSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export & Share',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportResults('pdf'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentTeal,
                    side: BorderSide(color: AppTheme.accentTeal.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Export PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareResults(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share Results'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  List<CareerInsight> _generatePlaceholderInsights() {
    return [
      CareerInsight(
        id: 'insight_1',
        type: InsightType.strength,
        title: 'Strong collaborative leadership style',
        content: 'You consistently energise when working with teams and guiding others toward shared goals.',
        confidence: 0.85,
        sourceQuestionIds: ['joy_energy_main'],
        keyThemes: ['leadership', 'collaboration', 'energy'],
        domain: CareerDomain.leadership,
        generatedAt: DateTime.now(),
      ),
      CareerInsight(
        id: 'insight_2',
        type: InsightType.pattern,
        title: 'Natural systems thinking ability',
        content: 'Your responses reveal a talent for seeing connections and patterns that others miss.',
        confidence: 0.78,
        sourceQuestionIds: ['strengths_main'],
        keyThemes: ['systems thinking', 'pattern recognition'],
        domain: CareerDomain.analytical,
        generatedAt: DateTime.now(),
      ),
      CareerInsight(
        id: 'insight_3',
        type: InsightType.value,
        title: 'Desire for meaningful impact',
        content: 'You\'re drawn to work that creates positive change and contributes to something larger.',
        confidence: 0.92,
        sourceQuestionIds: ['values_impact_main'],
        keyThemes: ['meaningful work', 'impact', 'purpose'],
        domain: CareerDomain.social,
        generatedAt: DateTime.now(),
      ),
    ];
  }

  String _formatSessionDuration(CareerSession session) {
    final duration = session.lastModified.difference(session.createdAt);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _exportResults(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting results as $format...'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing functionality coming soon'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }
}