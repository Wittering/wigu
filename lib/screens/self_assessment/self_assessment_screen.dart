import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/career_assessment_provider.dart';
import '../../models/career_session.dart';
import '../../widgets/assessment/domain_overview_card.dart';
import '../../widgets/assessment/question_flow_screen.dart';
import '../../widgets/assessment/progress_indicator_widget.dart';
import '../../widgets/assessment/session_setup_dialog.dart';
import '../../utils/theme.dart';

/// Main self-assessment screen showing the 5 career domains
/// Provides overview and entry points into each domain exploration
class SelfAssessmentScreen extends ConsumerStatefulWidget {
  const SelfAssessmentScreen({super.key});

  @override
  ConsumerState<SelfAssessmentScreen> createState() => _SelfAssessmentScreenState();
}

class _SelfAssessmentScreenState extends ConsumerState<SelfAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _checkForExistingSession();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkForExistingSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(careerAssessmentProvider);
      if (provider.currentSession == null) {
        _showSessionSetupDialog();
      }
    });
  }

  Future<void> _showSessionSetupDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SessionSetupDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
            opacity: _fadeInAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final provider = ref.watch(careerAssessmentProvider);
    return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with status and actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentTeal.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'CAREER SELF-ASSESSMENT',
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (provider.isAiThinking) _buildAiThinkingIndicator(),
                  const SizedBox(width: 16),
                  _buildActionButtons(provider),
                ],
              ),
              const SizedBox(height: 24),
              
              // Title and description
              const Text(
                'Discover Your Career Direction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore five essential areas to understand your unique career path. Each domain offers deep reflection and AI-powered insights.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              
              // Progress indicator if session exists
              if (provider.currentSession != null) ...[
                const SizedBox(height: 24),
                ProgressIndicatorWidget(provider: provider),
              ],
            ],
          ),
        );
  }

  Widget _buildAiThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.warningAmber.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.warningAmber,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI THINKING...',
            style: TextStyle(
              color: AppTheme.warningAmber,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CareerAssessmentProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // New session button
        OutlinedButton.icon(
          onPressed: provider.isLoading ? null : _showSessionSetupDialog,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.successGreen,
            side: BorderSide(color: AppTheme.successGreen),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'New Session',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        if (provider.currentSession != null) ...[
          const SizedBox(width: 12),
          // Delete session button
          OutlinedButton.icon(
            onPressed: provider.isLoading ? null : () => _confirmDeleteSession(provider),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.withOpacity(0.8),
              side: BorderSide(color: Colors.red.withOpacity(0.8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text(
              'Delete Session',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    final provider = ref.watch(careerAssessmentProvider);
    if (provider.currentSession == null) {
      return _buildWelcomeContent();
    }

    if (provider.errorMessage != null) {
      return _buildErrorContent(provider);
    }

    return _buildDomainOverview(provider);
  }

  Widget _buildWelcomeContent() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: AppTheme.accentTeal,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ready to Begin?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a new session to start your career exploration journey. Each session is saved automatically, so you can pause and resume at any time.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showSessionSetupDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.start, size: 20),
              label: const Text(
                'Start New Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(CareerAssessmentProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'An unexpected error occurred',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Try to start a new session
                _showSessionSetupDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainOverview(CareerAssessmentProvider provider) {
    final domains = _getCareerDomains();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info
          if (provider.currentSession != null) ...[
            _buildSessionInfo(provider.currentSession!),
            const SizedBox(height: 32),
          ],
          
          // Domain cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 
                                   constraints.maxWidth > 800 ? 2 : 1;
              final childAspectRatio = constraints.maxWidth > 800 ? 1.2 : 0.9;
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: domains.length,
                itemBuilder: (context, index) {
                  final domain = domains[index];
                  final isCompleted = provider.isDomainCompleted(domain['key']!);
                  final isCurrent = provider.currentDomain == domain['key'];
                  
                  return DomainOverviewCard(
                    title: domain['title']!,
                    description: domain['description']!,
                    icon: domain['icon']!,
                    color: domain['color'] as Color,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLoading: provider.isLoading && isCurrent,
                    onTap: () => _startDomainExploration(provider, domain['key']!),
                    onReset: isCompleted ? () => _confirmResetDomain(provider, domain['key']!) : null,
                  );
                },
              );
            },
          ),
          
          // Completion message
          if (provider.overallProgress >= 1.0) ...[
            const SizedBox(height: 32),
            _buildCompletionMessage(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionInfo(CareerSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started ${session.durationAustralian} ago • ${session.preferredExplorationType.displayName} approach',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(session.completionPercentage * 100).round()}% complete',
            style: TextStyle(
              color: AppTheme.successGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionMessage(CareerAssessmentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48,
            color: AppTheme.successGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'Assessment Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve explored all five career domains. Your insights and recommendations are ready for review.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to insights screen
              _showInsights(provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.insights, size: 20),
            label: const Text(
              'View Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCareerDomains() {
    return [
      {
        'key': 'joy_energy',
        'title': 'Joy & Energy',
        'description': 'What activities make you feel most energised and joyful at work?',
        'icon': '⚡',
        'color': AppTheme.warningAmber,
      },
      {
        'key': 'strengths',
        'title': 'Natural Strengths',
        'description': 'What are your natural talents that others consistently recognise?',
        'icon': '💪',
        'color': AppTheme.accentTeal,
      },
      {
        'key': 'sought_for',
        'title': 'Sought For',
        'description': 'What do people typically come to you for help with?',
        'icon': '🎯',
        'color': AppTheme.warningAmber,
      },
      {
        'key': 'values_impact',
        'title': 'Values & Impact',
        'description': 'What kind of impact do you want to make in the world?',
        'icon': '🌟',
        'color': AppTheme.successGreen,
      },
      {
        'key': 'life_design',
        'title': 'Life Design',
        'description': 'How do you want to design your ideal working life?',
        'icon': '🎨',
        'color': AppTheme.mutedTone1,
      },
    ];
  }

  Future<void> _startDomainExploration(CareerAssessmentProvider provider, String domainKey) async {
    await provider.startDomainExploration(domainKey);
    
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionFlowScreen(domainKey: domainKey),
        ),
      );
    }
  }

  Future<void> _confirmResetDomain(CareerAssessmentProvider provider, String domainKey) async {
    final domain = _getCareerDomains().firstWhere((d) => d['key'] == domainKey);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Reset ${domain['title']}?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will delete all your responses for this domain. You\'ll need to answer the questions again.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.resetCurrentDomain();
    }
  }

  Future<void> _confirmDeleteSession(CareerAssessmentProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Delete Session?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete your current session and all responses. This action cannot be undone.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteCurrentSession();
    }
  }

  void _showInsights(CareerAssessmentProvider provider) {
    // TODO: Navigate to insights screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Insights screen coming soon!'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }
}