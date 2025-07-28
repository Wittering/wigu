import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../providers/career_assessment_provider.dart';
import '../models/career_session.dart';
import '../models/career_insight.dart';
import '../models/career_response.dart';
import '../services/career_ai_service.dart';
import '../widgets/visualizations/career_visualizations.dart';

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
  
  List<Map<String, dynamic>> _careerPaths = [];
  bool _loadingCareerPaths = true;
  bool _careerPathsError = false;
  final CareerAIService _aiService = CareerAIService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCareerPaths();
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

  Future<void> _loadCareerPaths() async {
    try {
      final provider = ref.read(careerAssessmentProvider);
      final session = widget.sessionId == 'sample' ? _createSampleSession() : provider.currentSession;
      
      if (session != null && session.responses.isNotEmpty) {
        final responses = session.responses.values.toList();
        final careerPaths = await _aiService.generateCareerPathSuggestions(
          responses: responses,
          sessionId: session.id,
        );
        
        if (mounted) {
          setState(() {
            _careerPaths = careerPaths;
            _loadingCareerPaths = false;
            _careerPathsError = false;
          });
        }
      } else {
        // No session data available
        if (mounted) {
          setState(() {
            _careerPaths = [];
            _loadingCareerPaths = false;
            _careerPathsError = true;
          });
        }
      }
    } catch (e) {
      // Error occurred - show error state
      if (mounted) {
        setState(() {
          _careerPaths = [];
          _loadingCareerPaths = false;
          _careerPathsError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(careerAssessmentProvider);
    final session = widget.sessionId == 'sample' ? _createSampleSession() : provider.currentSession;

    if (session == null && widget.sessionId != 'sample') {
      return _buildErrorState('No session found');
    }

    final nonNullSession = session!;

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
                  _buildHeader(nonNullSession),
                  Expanded(
                    child: _buildResultsContent(nonNullSession),
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
            'Based on your career exploration across multiple domains',
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
          
          // Visual insights section
          _buildVisualInsights(session),
          const SizedBox(height: 32),
          
          // Key insights section
          _buildKeyInsights(session),
          const SizedBox(height: 32),
          
          // Career path suggestions
          _buildCareerPathSuggestions(session),
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

  Widget _buildVisualInsights(CareerSession session) {
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
                Icons.insights,
                color: AppTheme.accentTeal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Visual Career Insights',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'These visualizations help you understand patterns in your career preferences and strengths.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Radar Chart Section
          _buildVisualizationSection(
            title: 'Career Orientation Profile',
            description: 'Shows your preferences across key career dimensions based on your responses',
            child: CareerVisualizations.buildCareerInsightRadarChart(
              session: session,
              width: double.infinity,
              height: 200,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Word Cloud and Progress Chart Row
          Row(
            children: [
              // Word Cloud
              Expanded(
                child: _buildVisualizationSection(
                  title: 'Key Themes',
                  description: 'Most frequent themes from your responses',
                  child: CareerVisualizations.buildThemeWordCloud(
                    session: session,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Response Quality Chart
              Expanded(
                child: _buildVisualizationSection(
                  title: 'Reflection Depth',
                  description: 'Shows the depth of exploration in each career domain',
                  child: CareerVisualizations.buildQualityBarChart(
                    session: session,
                    width: double.infinity,
                    height: 180,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // AI-Generated Career Insights
          _buildAICareerInsights(session),
          
          const SizedBox(height: 16),
          
          // AI Insights about visualizations
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
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
                      Icons.psychology,
                      color: AppTheme.warningAmber,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'What These Patterns Reveal',
                      style: TextStyle(
                        color: AppTheme.warningAmber,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _generateVisualizationInsight(session),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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

  Widget _buildCareerPathSuggestions(CareerSession session) {

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
                Icons.explore_outlined,
                color: AppTheme.warningAmber,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Career Paths to Explore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your responses, here are some directions where you might find joy and fulfilment at work.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Show loading, career paths, or error state
          if (_loadingCareerPaths) 
            _buildLoadingState()
          else if (_careerPathsError || _careerPaths.isEmpty)
            _buildCareerPathErrorState()
          else
            ..._careerPaths.map((path) => _buildCareerPathCard(path)).toList(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningAmber),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI is analyzing your responses to suggest career paths...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPathErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.6),
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to generate career path suggestions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This feature requires AI analysis of your assessment responses. Please try again later or complete more of your assessment.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _loadingCareerPaths = true;
                _careerPathsError = false;
              });
              _loadCareerPaths();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningAmber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPathCard(Map<String, dynamic> path) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Title and timeframe
          Row(
            children: [
              Expanded(
                child: Text(
                  path['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTimeframeColor(path['timeframe']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  path['timeframe'] ?? 'short-term',
                  style: TextStyle(
                    color: _getTimeframeColor(path['timeframe']),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            path['description'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Why this path
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this might bring you joy:',
                  style: TextStyle(
                    color: AppTheme.warningAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  path['whyThisPath'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Joy factors
          if (path['joyFactors'] != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (path['joyFactors'] as List).map((factor) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  factor.toString(),
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTimeframeColor(String? timeframe) {
    switch (timeframe) {
      case 'immediate':
        return AppTheme.successGreen;
      case 'short-term':
        return AppTheme.warningAmber;
      case 'long-term':
        return AppTheme.accentTeal;
      default:
        return AppTheme.mutedTone1;
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
                'Domains',
                '${session.completedDomains.length}/5',
                Icons.category_outlined,
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

  CareerSession _createSampleSession() {
    final now = DateTime.now();
    return CareerSession(
      id: 'sample',
      createdAt: now.subtract(const Duration(hours: 2)),
      lastModified: now.subtract(const Duration(minutes: 15)),
      responses: {
        'joy_energy_main': CareerResponse.create(
          questionId: 'joy_energy_main',
          questionText: 'What activities make you feel most energised and joyful at work?',
          response: 'When I\'m mentoring others and helping them solve complex problems, I completely lose track of time.',
          domain: CareerDomain.social,
        ),
        'strengths_main': CareerResponse.create(
          questionId: 'strengths_main',
          questionText: 'What are your natural strengths that others consistently recognise?',
          response: 'People tell me I\'m good at breaking down complex ideas and making them accessible.',
          domain: CareerDomain.analytical,
        ),
      },
      insights: _generatePlaceholderInsights(),
      sessionName: 'Sample Career Exploration',
      completedDomains: [CareerDomain.social, CareerDomain.analytical, CareerDomain.leadership],
      preferredExplorationType: ExplorationType.reflective,
    );
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

  Widget _buildVisualizationSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAICareerInsights(CareerSession session) {
    return _buildVisualizationSection(
      title: 'AI Career Pattern Analysis',
      description: 'AI-generated insights based on your response patterns and themes',
      child: FutureBuilder<String>(
        future: _generateAIInsights(session),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI is analyzing your career patterns...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unable to generate AI insights at this time. Your responses show rich patterns that would benefit from personalized analysis.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }
          
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.data ?? 'No insights available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> _generateAIInsights(CareerSession session) async {
    try {
      final responses = session.responses.values.toList();
      if (responses.isEmpty) {
        return 'Complete more of your assessment to receive personalized AI insights about your career patterns.';
      }

      // Use the AI service to generate insights about career patterns
      final insightsMap = await _aiService.generateVisualizationInsights(
        session: session,
      );
      
      // Extract the main insight or combine multiple insights
      final insights = insightsMap['career_patterns'] ?? 
                     insightsMap['radar_chart'] ?? 
                     insightsMap.values.first;
      
      return insights;
    } catch (e) {
      // Fallback to basic pattern analysis
      return _generateBasicPatternAnalysis(session);
    }
  }

  String _generateBasicPatternAnalysis(CareerSession session) {
    final responses = session.responses.values.toList();
    if (responses.isEmpty) {
      return 'Complete more of your assessment to see detailed insights.';
    }

    // Basic pattern analysis as fallback
    final allText = responses.map((r) => r.response.toLowerCase()).join(' ');
    
    // Look for key themes
    final themes = <String>[];
    if (allText.contains(RegExp(r'\b(team|people|collaborate|mentor)\b'))) themes.add('collaborative leadership');
    if (allText.contains(RegExp(r'\b(creative|design|innovative|idea)\b'))) themes.add('creative thinking');
    if (allText.contains(RegExp(r'\b(analyze|data|research|solve)\b'))) themes.add('analytical problem-solving');
    if (allText.contains(RegExp(r'\b(impact|change|meaningful|purpose)\b'))) themes.add('purpose-driven work');
    if (allText.contains(RegExp(r'\b(independent|freedom|flexible|autonomy)\b'))) themes.add('autonomy seeking');
    
    if (themes.isEmpty) {
      return 'Your responses reveal a unique career profile. Consider exploring how your interests align with different work environments and role types.';
    }
    
    final themeText = themes.length == 1 
        ? themes.first 
        : '${themes.take(themes.length - 1).join(', ')} and ${themes.last}';
    
    return 'Your responses consistently highlight themes of $themeText. This suggests you thrive in environments that allow you to leverage these strengths while aligning with your core values.';
  }

  String _generateVisualizationInsight(CareerSession session) {
    final responses = session.responses.values.toList();
    if (responses.isEmpty) {
      return 'Complete more of your assessment to see personalized insights about these visualizations.';
    }

    // Calculate domain with highest engagement
    final domainKeys = ['joy_energy', 'strengths', 'sought_for', 'values_impact', 'life_design'];
    final domainNames = ['Joy & Energy', 'Strengths', 'Sought For', 'Values & Impact', 'Life Design'];
    
    var maxScore = 0.0;
    var strongestDomain = 'your responses';
    
    for (int i = 0; i < domainKeys.length; i++) {
      final domainResponses = responses.where((r) => r.questionId.startsWith(domainKeys[i])).toList();
      if (domainResponses.isNotEmpty) {
        final avgQuality = domainResponses
            .map((r) => r.reflectionQualityScore)
            .reduce((a, b) => a + b) / domainResponses.length;
        if (avgQuality > maxScore) {
          maxScore = avgQuality;
          strongestDomain = domainNames[i];
        }
      }
    }

    // Extract most common themes
    final allThemes = responses.expand((r) => r.keyThemes).toList();
    final themeFrequency = <String, int>{};
    for (final theme in allThemes) {
      themeFrequency[theme] = (themeFrequency[theme] ?? 0) + 1;
    }
    
    final topThemes = themeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final completion = session.completionPercentage;
    
    if (completion > 0.8) {
      final topTheme = topThemes.isNotEmpty ? topThemes.first.key : 'engagement';
      return 'Your strongest reflection area is $strongestDomain, and "$topTheme" emerges as a central theme. This pattern suggests you have clear insights about what energizes you professionally. The visualizations show a well-rounded exploration that can guide your career decisions with confidence.';
    } else if (completion > 0.5) {
      return 'You\'re making good progress with $strongestDomain showing the deepest reflection. Continue exploring the remaining domains to reveal more patterns about your career preferences and build a complete picture of your professional identity.';
    } else {
      return 'These initial patterns from $strongestDomain provide a foundation for understanding your career preferences. Complete more domains to unlock deeper insights and see how different aspects of your work life connect.';
    }
  }
}