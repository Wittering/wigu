import 'package:flutter/material.dart';
import '../../models/advisor_response.dart';
import '../../models/career_session.dart';
import '../../services/advisor_service.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../assessment/loading_state_widget.dart';
import '../assessment/error_state_widget.dart';

/// Widget displaying comprehensive advisor feedback summary
/// Shows synthesised insights, themes, and detailed analysis
class AdvisorFeedbackSummaryWidget extends StatefulWidget {
  final String sessionId;
  final AdvisorService advisorService;

  const AdvisorFeedbackSummaryWidget({
    super.key,
    required this.sessionId,
    required this.advisorService,
  });

  @override
  State<AdvisorFeedbackSummaryWidget> createState() => _AdvisorFeedbackSummaryWidgetState();
}

class _AdvisorFeedbackSummaryWidgetState extends State<AdvisorFeedbackSummaryWidget> {
  AdvisorFeedbackSummary? _feedbackSummary;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedbackSummary();
  }

  Future<void> _loadFeedbackSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await widget.advisorService.generateFeedbackSummary(widget.sessionId);
      setState(() {
        _feedbackSummary = summary;
      });
    } catch (e) {
      AppLogger.error('Failed to load feedback summary', e);
      setState(() {
        _error = 'Failed to load feedback summary: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingStateWidget(message: 'Generating feedback summary...');
    }

    if (_error != null) {
      return ErrorStateWidget(
        title: 'Feedback Error',
        message: _error!,
        onRetry: _loadFeedbackSummary,
      );
    }

    if (_feedbackSummary == null || !_feedbackSummary!.hasResponses) {
      return _buildNoFeedbackState();
    }

    return RefreshIndicator(
      onRefresh: _loadFeedbackSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryOverview(),
            const SizedBox(height: 24),
            _buildKeyInsights(),
            const SizedBox(height: 24),
            _buildTopThemes(),
            const SizedBox(height: 24),
            _buildDomainBreakdown(),
            const SizedBox(height: 24),
            _buildDetailedFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFeedbackState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 64,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              'No Advisor Feedback Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Once your advisors complete their responses, you\'ll see a comprehensive summary of their feedback here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadFeedbackSummary,
              icon: const Icon(Icons.refresh),
              label: const Text('Check for Updates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.accentTeal,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feedback Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Generated ${_formatDate(_feedbackSummary!.generatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    'Advisors',
                    _feedbackSummary!.completedResponses.toString(),
                    'responded',
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryMetric(
                    'Response Rate',
                    '${(_feedbackSummary!.responseRate * 100).round()}%',
                    'completion',
                    _feedbackSummary!.responseRate > 0.6 ? AppTheme.successGreen : AppTheme.warningAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    'Quality Score',
                    '${(_feedbackSummary!.averageResponseQuality * 100).round()}%',
                    'average',
                    _feedbackSummary!.hasGoodQuality ? AppTheme.successGreen : AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryMetric(
                    'Credibility',
                    '${(_feedbackSummary!.averageCredibilityWeight * 100).round()}%',
                    'weighted',
                    _feedbackSummary!.hasHighCredibility ? AppTheme.successGreen : AppTheme.accentTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights() {
    if (_feedbackSummary!.insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.accentTeal,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._feedbackSummary!.insights.map((insight) => Padding(
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
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThemes() {
    if (_feedbackSummary!.topThemes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common Themes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Patterns mentioned across multiple advisor responses',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _feedbackSummary!.topThemes.map((theme) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
                ),
                child: Text(
                  _formatThemeName(theme),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainBreakdown() {
    if (_feedbackSummary!.responsesByDomain.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feedback by Domain',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'How advisors see you across different career areas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ..._feedbackSummary!.responsesByDomain.entries.map((entry) {
              final domain = entry.key;
              final responses = entry.value;
              final avgQuality = responses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / responses.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDomainItem(domain, responses.length, avgQuality),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainItem(CareerDomain domain, int responseCount, double avgQuality) {
    final qualityColor = avgQuality >= 0.7 ? AppTheme.successGreen :
                        avgQuality >= 0.4 ? AppTheme.warningAmber : AppTheme.errorRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.mutedTone2.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                domain.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  domain.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(avgQuality * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: qualityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$responseCount advisor${responseCount == 1 ? '' : 's'} provided feedback on this area',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeedback() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Feedback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'All advisor responses organised by question',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_feedbackSummary!.responsesByQuestion.isEmpty)
              Center(
                child: Text(
                  'No detailed responses available yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedText,
                  ),
                ),
              )
            else
              ..._feedbackSummary!.responsesByQuestion.entries.map((entry) {
                final questionId = entry.key;
                final responses = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildQuestionResponses(questionId, responses),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResponses(String questionId, List<AdvisorResponse> responses) {
    if (responses.isEmpty) return const SizedBox.shrink();

    final questionText = responses.first.questionText;
    final domain = responses.first.domain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    domain.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      questionText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${responses.length} advisor${responses.length == 1 ? '' : 's'} responded',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...responses.asMap().entries.map((entry) {
          final index = entry.key;
          final response = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildIndividualResponse(response, index + 1),
          );
        }),
      ],
    );
  }

  Widget _buildIndividualResponse(AdvisorResponse response, int responseNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.mutedTone2.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    responseNumber.toString(),
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response.isAnonymous ? 'Anonymous Advisor' : 'Advisor Response',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getQualityColor(response.responseQualityScore).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(response.responseQualityScore * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getQualityColor(response.responseQualityScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.response,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          if (response.specificExamples != null && response.specificExamples!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Examples:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ...response.specificExamples!.map((example) => Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      example,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Color _getQualityColor(double quality) {
    if (quality >= 0.7) return AppTheme.successGreen;
    if (quality >= 0.4) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatThemeName(String theme) {
    // Convert snake_case to readable format
    return theme.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}