import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/career_assessment_provider.dart';
import '../../utils/theme.dart';
import 'question_card.dart';
import 'response_input_widget.dart';

/// Screen handling the one-question-at-a-time probing flow
/// Manages AI probing questions and response collection
class QuestionFlowScreen extends ConsumerStatefulWidget {
  final String domainKey;

  const QuestionFlowScreen({
    super.key,
    required this.domainKey,
  });

  @override
  ConsumerState<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends ConsumerState<QuestionFlowScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  List<String> _allQuestions = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeQuestions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

  void _initializeQuestions() {
    final provider = ref.read(careerAssessmentProvider);
    final mainQuestion = provider.topLineQuestions[widget.domainKey];
    if (mainQuestion != null) {
      _allQuestions = [mainQuestion['question']!];
    }
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
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildQuestionFlow(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final provider = ref.watch(careerAssessmentProvider);
    final domainData = _getDomainData();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
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
          Text(
            domainData['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (provider.isAiThinking) _buildAiThinkingIndicator(),
        ],
      ),
    );
  }

  Widget _buildAiThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningAmber.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.warningAmber.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'AI',
            style: TextStyle(
              color: AppTheme.warningAmber.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuestionFlow() {
    final provider = ref.watch(careerAssessmentProvider);
    
    // Build current question list (main + probes)
    final mainQuestion = provider.topLineQuestions[widget.domainKey];
    if (mainQuestion == null) {
      return _buildErrorState('Question not found');
    }

    final currentQuestions = [mainQuestion['question']!];
    currentQuestions.addAll(provider.currentProbes);
    
    // Update questions list if it changed
    if (currentQuestions.length != _allQuestions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _allQuestions = currentQuestions;
        });
      });
    }

    if (_allQuestions.isEmpty) {
      return _buildErrorState('No questions available');
    }

    return PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentQuestionIndex = index;
            });
          },
          itemCount: _allQuestions.length,
          itemBuilder: (context, index) {
            final isMainQuestion = index == 0;
            final questionText = _allQuestions[index];
            
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: [
                  Expanded(
                    child: QuestionCard(
                      question: questionText,
                      isMainQuestion: isMainQuestion,
                      domainColor: _getDomainData()['color'],
                      questionNumber: index + 1,
                      totalQuestions: _allQuestions.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResponseInputWidget(
                    onSubmit: (response) => _handleResponse(response, index, provider),
                    isLoading: provider.isLoading,
                    domainColor: _getDomainData()['color'],
                    isMainQuestion: isMainQuestion,
                  ),
                  const SizedBox(height: 12),
                  _buildPersistentActions(provider),
                ],
              ),
            );
          },
        );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.8),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

  Future<void> _handleResponse(String response, int questionIndex, CareerAssessmentProvider provider) async {
    if (questionIndex == 0) {
      // Main question response
      await provider.submitResponse(response);
    } else {
      // Probe question response
      final probeQuestion = _allQuestions[questionIndex];
      await provider.submitProbeResponse(probeQuestion, response);
    }

    // Check if we should move to next question or wait for more probes
    if (questionIndex < _allQuestions.length - 1) {
      // Move to next question
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Wait for AI to generate more probes - don't auto-complete
      await Future.delayed(const Duration(seconds: 2)); // Give AI time to think
      
      final updatedQuestions = [provider.topLineQuestions[widget.domainKey]!['question']!];
      updatedQuestions.addAll(provider.currentProbes);
      
      if (updatedQuestions.length > _allQuestions.length) {
        // More probes were added, continue with them
        setState(() {
          _allQuestions = updatedQuestions;
        });
        // Move to the new question
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      // No popup - user can continue with persistent buttons
    }
  }

  Widget _buildPersistentActions(CareerAssessmentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _requestMoreQuestions(provider),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentTeal.withOpacity(0.8),
                side: BorderSide(color: AppTheme.accentTeal.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                minimumSize: const Size(0, 32),
              ),
              icon: const Icon(Icons.add, size: 14),
              label: const Text(
                'More',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _finishDomain(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen.withOpacity(0.9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
                minimumSize: const Size(0, 32),
              ),
              icon: const Icon(Icons.check, size: 14),
              label: const Text(
                'Complete',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestMoreQuestions(CareerAssessmentProvider provider) {
    // Add a generic probe to encourage more exploration
    setState(() {
      _allQuestions.add("Is there anything else about this topic you'd like to explore or reflect on?");
    });
    // Move to the new question
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishDomain(CareerAssessmentProvider provider) {
    provider.completeDomainByUser(widget.domainKey).then((_) {
      _showCompletionDialog(provider);
    });
  }

  void _showCompletionDialog(CareerAssessmentProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_getDomainData()['title']} Complete!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Great work! You\'ve thoroughly explored this domain. Your insights are being processed.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog  
                        Navigator.of(context).pop(); // Go back to main screen
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.7),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Continue Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back to main screen
                        
                        // Check if all domains are completed
                        final provider = ref.read(careerAssessmentProvider);
                        if (provider.overallProgress >= 1.0) {
                          // Navigate to results screen
                          Navigator.of(context).pushNamed('/results/${provider.currentSession?.id}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        ref.read(careerAssessmentProvider).overallProgress >= 1.0 
                            ? 'View Results' 
                            : 'Next Domain',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getDomainData() {
    switch (widget.domainKey) {
      case 'joy_energy':
        return {
          'title': 'Joy & Energy',
          'description': 'What activities make you feel most energised and joyful at work?',
          'icon': '⚡',
          'color': AppTheme.warningAmber,
        };
      case 'strengths':
        return {
          'title': 'Natural Strengths',
          'description': 'What are your natural talents that others consistently recognise?',
          'icon': '💪',
          'color': AppTheme.accentTeal,
        };
      case 'sought_for':
        return {
          'title': 'Sought For',
          'description': 'What do people typically come to you for help with?',
          'icon': '🎯',
          'color': AppTheme.warningAmber,
        };
      case 'values_impact':
        return {
          'title': 'Values & Impact',
          'description': 'What kind of impact do you want to make in the world?',
          'icon': '🌟',
          'color': AppTheme.successGreen,
        };
      case 'life_design':
        return {
          'title': 'Life Design',
          'description': 'How do you want to design your ideal working life?',
          'icon': '🎨',
          'color': AppTheme.mutedTone1,
        };
      default:
        return {
          'title': 'Career Domain',
          'description': 'Explore this aspect of your career',
          'icon': '❓',
          'color': AppTheme.accentTeal,
        };
    }
  }
}