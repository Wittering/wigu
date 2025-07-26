import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advisor_invitation.dart';
import '../../models/advisor_response.dart';
import '../../models/career_session.dart';
import '../../services/advisor_service.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../../utils/advisor_response_validator.dart';
import '../../widgets/assessment/loading_state_widget.dart';
import '../../widgets/assessment/error_state_widget.dart';

/// Web-based advisor response collection interface
/// Mobile-friendly form for advisors to provide career insight feedback
/// Uses Australian English throughout with calm, reflective design
class AdvisorResponseFormScreen extends ConsumerStatefulWidget {
  final String invitationId;

  const AdvisorResponseFormScreen({
    super.key,
    required this.invitationId,
  });

  @override
  ConsumerState<AdvisorResponseFormScreen> createState() => _AdvisorResponseFormScreenState();
}

class _AdvisorResponseFormScreenState extends ConsumerState<AdvisorResponseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advisorService = AdvisorService();
  final _pageController = PageController();
  
  // Form state
  AdvisorInvitation? _invitation;
  Map<String, Map<String, dynamic>>? _advisorQuestions;
  final Map<String, TextEditingController> _responseControllers = {};
  final Map<String, List<TextEditingController>> _exampleControllers = {};
  final Map<String, int> _confidenceLevels = {};
  
  AdvisorObservationPeriod? _observationPeriod;
  AdvisorConfidenceContext? _confidenceContext;
  bool _isAnonymous = false;
  final _additionalContextController = TextEditingController();
  
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initialiseForm();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _responseControllers.values.forEach((controller) => controller.dispose());
    _exampleControllers.values.forEach((controllers) {
      controllers.forEach((controller) => controller.dispose());
    });
    _additionalContextController.dispose();
    super.dispose();
  }

  Future<void> _initialiseForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _advisorService.initialise();
      
      // Load invitation details via public method
      _invitation = await _advisorService.getInvitationById(widget.invitationId);
      
      if (_invitation == null) {
        throw Exception('Invitation not found or may have expired');
      }

      // Check invitation status
      if (_invitation!.status == InvitationStatus.completed) {
        setState(() {
          _hasSubmitted = true;
        });
        return;
      }

      if (_invitation!.status == InvitationStatus.expired) {
        throw Exception('This invitation has expired');
      }

      // Mark invitation as viewed
      await _advisorService.markInvitationViewed(widget.invitationId);

      // Load advisor questions
      _advisorQuestions = _advisorService.getAdvisorQuestions();
      
      // Initialize response controllers
      for (final questionId in _advisorQuestions!.keys) {
        _responseControllers[questionId] = TextEditingController();
        _exampleControllers[questionId] = [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ];
        _confidenceLevels[questionId] = 3; // Default to middle confidence
      }

    } catch (e) {
      AppLogger.error('Failed to initialise advisor response form', e);
      setState(() {
        _error = 'Failed to load invitation: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitResponses() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_observationPeriod == null || _confidenceContext == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare responses
      final responses = <String, String>{};
      final specificExamples = <String, List<String>>{};

      for (final entry in _responseControllers.entries) {
        final questionId = entry.key;
        final response = entry.value.text.trim();
        
        if (response.isNotEmpty) {
          responses[questionId] = response;
          
          // Collect specific examples
          final examples = _exampleControllers[questionId]!
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();
          
          if (examples.isNotEmpty) {
            specificExamples[questionId] = examples;
          }
        }
      }

      // Submit responses
      await _advisorService.submitAdvisorResponses(
        invitationId: widget.invitationId,
        responses: responses,
        confidenceLevels: _confidenceLevels,
        observationPeriod: _observationPeriod!,
        confidenceContext: _confidenceContext!,
        specificExamples: specificExamples,
        additionalContext: _additionalContextController.text.trim().isEmpty 
            ? null : _additionalContextController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      setState(() {
        _hasSubmitted = true;
      });

    } catch (e) {
      AppLogger.error('Failed to submit advisor responses', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit responses: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: const LoadingStateWidget(message: 'Loading invitation...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: ErrorStateWidget(
          title: 'Loading Error',
          message: _error!,
          onRetry: _initialiseForm,
        ),
      );
    }

    if (_hasSubmitted) {
      return _buildThankYouScreen();
    }

    if (_invitation == null || _advisorQuestions == null) {
      return Scaffold(
        body: ErrorStateWidget(
          title: 'Invitation Error',
          message: 'Unable to load invitation details',
          onRetry: _initialiseForm,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Insight Feedback'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _showDeclineDialog(),
            child: const Text('Decline'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildWelcomePage(),
                ..._buildQuestionPages(),
                _buildContextPage(),
                _buildReviewPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalPages = 3 + _advisorQuestions!.length; // Welcome + Questions + Context + Review
    final progress = (_currentPage + 1) / totalPages;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.mutedTone2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.waving_hand,
            size: 48,
            color: AppTheme.accentTeal,
          ),
          const SizedBox(height: 24),
          Text(
            'G\'day ${_invitation!.advisorName}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you for agreeing to provide career insight feedback. Your perspective will be incredibly valuable for this person\'s career exploration.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.accentTeal,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'What to Expect',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpectationItem(
                    '5 thoughtful questions',
                    'About their strengths, reputation, growth potential, working style, and career direction',
                  ),
                  _buildExpectationItem(
                    '10-15 minutes',
                    'This should take about 10-15 minutes to complete thoughtfully',
                  ),
                  _buildExpectationItem(
                    'Honest feedback',
                    'Please be candid and specific - this will help them most',
                  ),
                  _buildExpectationItem(
                    'Confidential process',
                    'Your responses will be used solely to help with their career reflection',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.accentTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your honest, specific feedback will be most helpful. Include concrete examples where possible.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionPages() {
    return _advisorQuestions!.entries.map((entry) {
      final questionId = entry.key;
      final questionData = entry.value;
      final questionNumber = _advisorQuestions!.keys.toList().indexOf(questionId) + 1;

      return _buildQuestionPage(questionId, questionData, questionNumber);
    }).toList();
  }

  Widget _buildQuestionPage(String questionId, Map<String, dynamic> questionData, int questionNumber) {
    return Form(
      key: questionNumber == 1 ? _formKey : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Question $questionNumber of ${_advisorQuestions!.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              questionData['question'] as String,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              (questionData['domain'] as CareerDomain).displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _responseControllers[questionId],
              decoration: InputDecoration(
                labelText: 'Your Response',
                hintText: questionData['placeholder'] as String,
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a response to this question';
                }
                if (value.trim().split(' ').length < 10) {
                  return 'Please provide a more detailed response (at least 10 words)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Confidence Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _confidenceLevels[questionId]!.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _getConfidenceLabel(_confidenceLevels[questionId]!),
              onChanged: (value) {
                setState(() {
                  _confidenceLevels[questionId] = value.round();
                });
              },
            ),
            Text(
              _getConfidenceDescription(_confidenceLevels[questionId]!),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Specific Examples (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Include specific examples or situations that support your response',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ..._exampleControllers[questionId]!.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Example ${index + 1}',
                    hintText: 'Describe a specific situation or example...',
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              );
            }),
            const SizedBox(height: 16),
            if (questionData['followUpPrompts'] != null) ...[
              ExpansionTile(
                title: Text(
                  'Need inspiration? Try these prompts',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.accentTeal,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (questionData['followUpPrompts'] as List<String>)
                          .map((prompt) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: TextStyle(color: AppTheme.accentTeal)),
                                Expanded(
                                  child: Text(
                                    prompt,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContextPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A bit about your perspective',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us understand the context of your feedback',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Text(
            'How long have you observed this person professionally?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...AdvisorObservationPeriod.values.map((period) => RadioListTile<AdvisorObservationPeriod>(
            value: period,
            groupValue: _observationPeriod,
            onChanged: (value) => setState(() => _observationPeriod = value),
            title: Text(period.displayName),
            subtitle: Text(period.description),
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 32),
          Text(
            'How confident are you in your assessments?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...AdvisorConfidenceContext.values.map((context) => RadioListTile<AdvisorConfidenceContext>(
            value: context,
            groupValue: _confidenceContext,
            onChanged: (value) => setState(() => _confidenceContext = value),
            title: Text(context.displayName),
            subtitle: Text(context.description),
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 32),
          SwitchListTile(
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            title: const Text('Make my responses anonymous'),
            subtitle: const Text('Your name won\'t be associated with specific responses'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),
          Text(
            'Additional Context (Optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Any other thoughts or context you\'d like to share?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _additionalContextController,
            decoration: const InputDecoration(
              hintText: 'Share any additional thoughts or context...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Responses',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your responses before submitting',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ..._advisorQuestions!.entries.map((entry) {
            final questionId = entry.key;
            final questionData = entry.value;
            final response = _responseControllers[questionId]!.text.trim();
            final questionNumber = _advisorQuestions!.keys.toList().indexOf(questionId) + 1;

            if (response.isEmpty) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question $questionNumber',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      questionData['question'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      response,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${_getConfidenceLabel(_confidenceLevels[questionId]!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitResponses,
                icon: const Icon(Icons.send),
                label: const Text('Submit Responses'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage < (2 + _advisorQuestions!.length) ? () {
                if (_currentPage == 0 || _validateCurrentPage()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } : _submitResponses,
              child: Text(_currentPage < (2 + _advisorQuestions!.length) ? 'Next' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentPage() {
    if (_currentPage <= _advisorQuestions!.length) {
      // Question pages - use validator
      final questionIds = _advisorQuestions!.keys.toList();
      if (_currentPage > 0 && _currentPage <= questionIds.length) {
        final questionId = questionIds[_currentPage - 1];
        final response = _responseControllers[questionId]!.text.trim();
        final examples = _exampleControllers[questionId]!
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
        
        // Use comprehensive validation
        final validation = AdvisorResponseValidator.validateResponseText(response);
        
        if (!validation.isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validation.errors.first),
              backgroundColor: AppTheme.errorRed,
            ),
          );
          return false;
        }
        
        // Show warnings and suggestions
        if (validation.hasWarnings || validation.hasSuggestions) {
          _showValidationFeedback(validation);
        }
      }
    } else if (_currentPage == _advisorQuestions!.length + 1) {
      // Context page
      if (_observationPeriod == null || _confidenceContext == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please complete all required fields'),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
        return false;
      }
    }
    
    return true;
  }
  
  /// Show validation feedback to the advisor
  void _showValidationFeedback(ValidationResult validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.accentTeal,
            ),
            const SizedBox(width: 8),
            const Text('Feedback on Your Response'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (validation.warnings.isNotEmpty) ...[
                Text(
                  'Things to Consider:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(height: 8),
                ...validation.warnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning, size: 14, color: AppTheme.warningAmber),
                      const SizedBox(width: 6),
                      Expanded(child: Text(warning, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
              ],
              if (validation.suggestions.isNotEmpty) ...[
                Text(
                  'Suggestions to Improve:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(height: 8),
                ...validation.suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates, size: 14, color: AppTheme.accentTeal),
                      const SizedBox(width: 6),
                      Expanded(child: Text(suggestion, style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 12),
              Text(
                'You can continue as is, or go back to revise your response.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Don't advance to next page, stay on current
            },
            child: const Text('Revise Response'),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Thank You!',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your feedback has been submitted successfully. Your insights will be incredibly valuable for this person\'s career exploration.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentTeal,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your thoughtful feedback matters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'External perspectives like yours are crucial for career development. Thank you for taking the time to provide honest, specific feedback.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  // In a web context, this would close the tab or redirect
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeclineDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Invitation'),
        content: const Text(
          'Are you sure you want to decline this invitation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Decline',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _advisorService.declineInvitation(
          widget.invitationId,
          reason: 'Declined by advisor',
        );
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline invitation: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  String _getConfidenceLabel(int level) {
    switch (level) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Medium';
      case 4: return 'High';
      case 5: return 'Very High';
      default: return 'Medium';
    }
  }

  String _getConfidenceDescription(int level) {
    switch (level) {
      case 1: return 'I\'m not very confident about this assessment';
      case 2: return 'I have some uncertainty about this assessment';
      case 3: return 'I\'m moderately confident about this assessment';
      case 4: return 'I\'m quite confident about this assessment';
      case 5: return 'I\'m very confident about this assessment';
      default: return 'I\'m moderately confident about this assessment';
    }
  }
}