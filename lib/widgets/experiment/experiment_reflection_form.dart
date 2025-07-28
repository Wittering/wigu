import 'package:flutter/material.dart';
import '../../models/career_experiment.dart';
import '../../models/experiment_result.dart';
import '../../utils/theme.dart';

/// Form widget for reflecting on and completing experiments
/// Guides users through structured reflection process with Australian English
class ExperimentReflectionForm extends StatefulWidget {
  final CareerExperiment experiment;
  final Function(ExperimentReflectionData) onSubmit;
  final VoidCallback? onCancel;

  const ExperimentReflectionForm({
    Key? key,
    required this.experiment,
    required this.onSubmit,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ExperimentReflectionForm> createState() => _ExperimentReflectionFormState();
}

class _ExperimentReflectionFormState extends State<ExperimentReflectionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Form controllers
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _personalReflectionController = TextEditingController();
  
  // Form data
  double _successScore = 0.5;
  ExperimentOutcome _outcome = ExperimentOutcome.partiallySuccessful;
  ResultConfidence _confidence = ResultConfidence.medium;
  List<String> _keyLearnings = [];
  List<String> _challenges = [];
  List<String> _successFactors = [];
  List<String> _nextSteps = [];
  List<String> _unexpectedOutcomes = [];
  List<MetricResult> _metricResults = [];
  Map<String, String> _stakeholderFeedback = {};
  
  // UI state
  int _currentPage = 0;
  final int _totalPages = 5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeMetricResults();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _personalReflectionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeMetricResults() {
    _metricResults = widget.experiment.metrics.map((metric) {
      return MetricResult(
        metricName: metric.name,
        expectedValue: metric.targetValue ?? '',
        actualValue: '',
        metTarget: false,
        resultType: MetricResultType.missed,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment Reflection'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPage + 1} of $_totalPages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
                  _buildOverviewPage(),
                  _buildOutcomePage(),
                  _buildLearningsPage(),
                  _buildMetricsPage(),
                  _buildReflectionPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: (_currentPage + 1) / _totalPages,
        backgroundColor: AppTheme.mutedTone2.withOpacity(0.3),
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
      ),
    );
  }

  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Experiment Overview',
            'Let\'s review what you set out to achieve',
            Icons.flag_outlined,
          ),
          const SizedBox(height: 24),
          
          // Experiment summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.experiment.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.experiment.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  // Hypothesis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.accentTeal,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hypothesis: ${widget.experiment.hypothesis}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Success criteria reminder
          Text(
            'Success Criteria',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.experiment.successCriteria.map((criterion) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.accentTeal,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      criterion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOutcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Experiment Outcome',
            'How did the experiment go overall?',
            Icons.assessment_outlined,
          ),
          const SizedBox(height: 24),
          
          // Success score slider
          Text(
            'Success Score',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate how well the experiment achieved its objectives (0-100%)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Success Score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_successScore * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _successScore,
                  onChanged: (value) {
                    setState(() {
                      _successScore = value;
                      _updateOutcomeFromScore();
                    });
                  },
                  activeColor: AppTheme.accentTeal,
                  divisions: 20,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Outcome selection
          Text(
            'Experiment Outcome',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...ExperimentOutcome.values.map((outcome) {
            return RadioListTile<ExperimentOutcome>(
              title: Text(outcome.displayName),
              subtitle: Text(
                outcome.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
              value: outcome,
              groupValue: _outcome,
              onChanged: (value) {
                setState(() {
                  _outcome = value!;
                });
              },
              activeColor: AppTheme.accentTeal,
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Confidence level
          Text(
            'Confidence in Results',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...ResultConfidence.values.map((confidence) {
            return RadioListTile<ResultConfidence>(
              title: Text(confidence.displayName),
              subtitle: Text(
                confidence.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
              value: confidence,
              groupValue: _confidence,
              onChanged: (value) {
                setState(() {
                  _confidence = value!;
                });
              },
              activeColor: AppTheme.accentTeal,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLearningsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Learnings & Insights',
            'What did you discover about yourself and your career?',
            Icons.school_outlined,
          ),
          const SizedBox(height: 24),
          
          _buildStringListSection(
            title: 'Key Learnings',
            description: 'What are the most important things you learned?',
            items: _keyLearnings,
            onAdd: (item) => setState(() => _keyLearnings.add(item)),
            onRemove: (index) => setState(() => _keyLearnings.removeAt(index)),
            hintText: 'e.g., I discovered I enjoy strategic thinking more than I realised...',
          ),
          
          const SizedBox(height: 24),
          
          _buildStringListSection(
            title: 'Challenges Faced',
            description: 'What obstacles or difficulties did you encounter?',
            items: _challenges,
            onAdd: (item) => setState(() => _challenges.add(item)),
            onRemove: (index) => setState(() => _challenges.removeAt(index)),
            hintText: 'e.g., Finding time for networking activities was difficult...',
          ),
          
          const SizedBox(height: 24),
          
          _buildStringListSection(
            title: 'Success Factors',
            description: 'What helped you succeed in this experiment?',
            items: _successFactors,
            onAdd: (item) => setState(() => _successFactors.add(item)),
            onRemove: (index) => setState(() => _successFactors.removeAt(index)),
            hintText: 'e.g., Having a clear weekly schedule helped maintain momentum...',
          ),
          
          const SizedBox(height: 24),
          
          _buildStringListSection(
            title: 'Unexpected Outcomes',
            description: 'What surprised you during this experiment?',
            items: _unexpectedOutcomes,
            onAdd: (item) => setState(() => _unexpectedOutcomes.add(item)),
            onRemove: (index) => setState(() => _unexpectedOutcomes.removeAt(index)),
            hintText: 'e.g., I discovered a passion for mentoring junior colleagues...',
            isOptional: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Metrics & Measurements',
            'How did you perform against your specific metrics?',
            Icons.trending_up,
          ),
          const SizedBox(height: 24),
          
          if (_metricResults.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.mutedText,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No specific metrics were defined for this experiment.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can skip this section and move to the final reflection.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedText,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ..._metricResults.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;
              return _buildMetricResultCard(metric, index);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            'Final Reflection',
            'Wrap up with your thoughts and next steps',
            Icons.psychology_outlined,
          ),
          const SizedBox(height: 24),
          
          // Executive summary
          Text(
            'Executive Summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _summaryController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Summarise the experiment and its key outcomes in 2-3 sentences...',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide an executive summary';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          _buildStringListSection(
            title: 'Next Steps',
            description: 'Based on this experiment, what will you do next?',
            items: _nextSteps,
            onAdd: (item) => setState(() => _nextSteps.add(item)),
            onRemove: (index) => setState(() => _nextSteps.removeAt(index)),
            hintText: 'e.g., Schedule monthly networking coffees to maintain connections...',
          ),
          
          const SizedBox(height: 24),
          
          // Personal reflection
          Text(
            'Personal Reflection (Optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Any additional thoughts, feelings, or insights about this experiment?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _personalReflectionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share any personal insights, emotional responses, or broader reflections...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.accentTeal,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentTeal,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildStringListSection({
    required String title,
    required String description,
    required List<String> items,
    required Function(String) onAdd,
    required Function(int) onRemove,
    required String hintText,
    bool isOptional = false,
  }) {
    final controller = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.mutedText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Optional',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedText,
          ),
        ),
        const SizedBox(height: 12),
        
        // Add new item
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onAdd(controller.text.trim());
                  controller.clear();
                }
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // List items
        if (items.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mutedTone1.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOptional ? 'No items added (optional)' : 'No items added yet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.close),
                    iconSize: 16,
                    color: AppTheme.mutedText,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildMetricResultCard(MetricResult metric, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.metricName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Expected vs Actual
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        metric.expectedValue.isNotEmpty ? metric.expectedValue : 'Not specified',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actual Result',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormField(
                        initialValue: metric.actualValue,
                        onChanged: (value) {
                          setState(() {
                            _metricResults[index] = metric.copyWith(actualValue: value);
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter result...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Met target toggle
            CheckboxListTile(
              title: const Text('Target achieved'),
              value: metric.metTarget,
              onChanged: (value) {
                setState(() {
                  _metricResults[index] = metric.copyWith(
                    metTarget: value ?? false,
                    resultType: (value ?? false) ? MetricResultType.met : MetricResultType.missed,
                  );
                });
              },
              activeColor: AppTheme.accentTeal,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
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
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage == _totalPages - 1 ? _submitReflection : _nextPage,
              child: Text(
                _currentPage == _totalPages - 1 ? 'Complete Experiment' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    // Validate current page before proceeding
    if (_validateCurrentPage()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 1: // Outcome page
        return true; // All fields have defaults
      case 2: // Learnings page
        if (_keyLearnings.isEmpty) {
          _showValidationError('Please add at least one key learning');
          return false;
        }
        return true;
      case 4: // Reflection page
        if (_summaryController.text.trim().isEmpty) {
          _showValidationError('Please provide an executive summary');
          return false;
        }
        if (_nextSteps.isEmpty) {
          _showValidationError('Please add at least one next step');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  void _updateOutcomeFromScore() {
    if (_successScore >= 0.8) {
      _outcome = ExperimentOutcome.successful;
    } else if (_successScore >= 0.6) {
      _outcome = ExperimentOutcome.partiallySuccessful;
    } else if (_successScore >= 0.3) {
      _outcome = ExperimentOutcome.unsuccessful;
    } else {
      _outcome = ExperimentOutcome.inconclusive;
    }
  }

  void _submitReflection() {
    if (!_formKey.currentState!.validate() || !_validateCurrentPage()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reflectionData = ExperimentReflectionData(
      successScore: _successScore,
      outcome: _outcome,
      confidence: _confidence,
      executiveSummary: _summaryController.text.trim(),
      keyLearnings: _keyLearnings,
      challenges: _challenges,
      successFactors: _successFactors,
      nextSteps: _nextSteps,
      unexpectedOutcomes: _unexpectedOutcomes,
      metricResults: _metricResults,
      personalReflection: _personalReflectionController.text.trim().isNotEmpty 
          ? _personalReflectionController.text.trim() 
          : null,
      stakeholderFeedback: _stakeholderFeedback.isNotEmpty ? _stakeholderFeedback : null,
    );

    widget.onSubmit(reflectionData);
  }
}

/// Data class for experiment reflection form results
class ExperimentReflectionData {
  final double successScore;
  final ExperimentOutcome outcome;
  final ResultConfidence confidence;
  final String executiveSummary;
  final List<String> keyLearnings;
  final List<String> challenges;
  final List<String> successFactors;
  final List<String> nextSteps;
  final List<String> unexpectedOutcomes;
  final List<MetricResult> metricResults;
  final String? personalReflection;
  final Map<String, String>? stakeholderFeedback;

  ExperimentReflectionData({
    required this.successScore,
    required this.outcome,
    required this.confidence,
    required this.executiveSummary,
    required this.keyLearnings,
    required this.challenges,
    required this.successFactors,
    required this.nextSteps,
    required this.unexpectedOutcomes,
    required this.metricResults,
    this.personalReflection,
    this.stakeholderFeedback,
  });
}