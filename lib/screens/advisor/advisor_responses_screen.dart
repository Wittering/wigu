import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advisor_invitation.dart';
import '../../models/advisor_response.dart';
import '../../services/advisor_service.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../../widgets/assessment/loading_state_widget.dart';
import '../../widgets/assessment/error_state_widget.dart';

/// Screen displaying advisor responses for a specific invitation
/// Shows response details, quality metrics, and allows response management
class AdvisorResponsesScreen extends ConsumerStatefulWidget {
  final AdvisorInvitation invitation;
  final AdvisorService advisorService;

  const AdvisorResponsesScreen({
    super.key,
    required this.invitation,
    required this.advisorService,
  });

  @override
  ConsumerState<AdvisorResponsesScreen> createState() => _AdvisorResponsesScreenState();
}

class _AdvisorResponsesScreenState extends ConsumerState<AdvisorResponsesScreen> {
  List<AdvisorResponse> _responses = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final responses = widget.advisorService.getResponsesForInvitation(widget.invitation.id);
      setState(() {
        _responses = responses;
      });
    } catch (e) {
      AppLogger.error('Failed to load advisor responses', e);
      setState(() {
        _error = 'Failed to load responses: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshResponses() async {
    await _loadResponses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.invitation.advisorName}\'s Responses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshResponses,
            tooltip: 'Refresh responses',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget(message: 'Loading advisor responses...');
    }

    if (_error != null) {
      return ErrorStateWidget(
        title: 'Loading Error',
        message: _error!,
        onRetry: _loadResponses,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshResponses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdvisorInfoCard(),
            const SizedBox(height: 16),
            if (_responses.isEmpty)
              _buildNoResponsesCard()
            else ...[
              _buildResponsesOverview(),
              const SizedBox(height: 16),
              _buildResponsesList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvisorInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accentTeal.withOpacity(0.2),
                  child: Text(
                    widget.invitation.advisorName.isNotEmpty
                        ? widget.invitation.advisorName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.invitation.advisorName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.invitation.relationshipType.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusChip(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.mutedText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Invited ${widget.invitation.daysSinceSent} days ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (widget.invitation.respondedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.successGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Responded ${_getDaysAgo(widget.invitation.respondedAt!)} days ago',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (widget.invitation.status) {
      case InvitationStatus.completed:
        backgroundColor = AppTheme.successGreen;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case InvitationStatus.viewed:
        backgroundColor = AppTheme.warningAmber;
        textColor = Colors.white;
        icon = Icons.visibility;
        break;
      case InvitationStatus.sent:
        backgroundColor = AppTheme.accentTeal.withOpacity(0.2);
        textColor = AppTheme.accentTeal;
        icon = Icons.send;
        break;
      case InvitationStatus.declined:
        backgroundColor = AppTheme.errorRed;
        textColor = Colors.white;
        icon = Icons.cancel;
        break;
      case InvitationStatus.expired:
        backgroundColor = AppTheme.mutedText;
        textColor = Colors.white;
        icon = Icons.schedule_send;
        break;
      case InvitationStatus.draft:
        backgroundColor = AppTheme.mutedText;
        textColor = Colors.white;
        icon = Icons.drafts;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            widget.invitation.status.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResponsesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              'No Responses Yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.invitation.status == InvitationStatus.completed
                  ? 'This advisor has completed their responses, but they haven\'t been loaded yet.'
                  : 'This advisor hasn\'t completed their responses yet.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (widget.invitation.status == InvitationStatus.sent && widget.invitation.canSendReminder) ...[
              const SizedBox(height: 16),
              Text(
                'It\'s been ${widget.invitation.daysSinceSent} days since the invitation was sent.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement reminder functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder functionality coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send Reminder'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesOverview() {
    if (_responses.isEmpty) return const SizedBox.shrink();

    final avgQuality = _responses.map((r) => r.responseQualityScore).reduce((a, b) => a + b) / _responses.length;
    final avgCredibility = _responses.map((r) => r.credibilityWeight).reduce((a, b) => a + b) / _responses.length;
    final totalWords = _responses.map((r) => r.wordCount).reduce((a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Quality Score',
                    '${(avgQuality * 100).round()}%',
                    Icons.star,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Credibility',
                    '${(avgCredibility * 100).round()}%',
                    Icons.verified,
                    AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Words',
                    totalWords.toString(),
                    Icons.text_fields,
                    AppTheme.warningAmber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    final advisorQuestions = widget.advisorService.getAdvisorQuestions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Responses',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ..._responses.asMap().entries.map((entry) {
          final index = entry.key;
          final response = entry.value;
          final questionData = advisorQuestions[response.questionId];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildResponseCard(response, questionData, index + 1),
          );
        }),
      ],
    );
  }

  Widget _buildResponseCard(AdvisorResponse response, Map<String, dynamic>? questionData, int questionNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: TextStyle(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionData?['question'] ?? response.questionText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        response.domain.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                response.response,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
            if (response.specificExamples != null && response.specificExamples!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Specific Examples:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...response.specificExamples!.map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
            const SizedBox(height: 16),
            Row(
              children: [
                _buildResponseMetric(
                  'Quality',
                  '${(response.responseQualityScore * 100).round()}%',
                  response.responseQualityScore > 0.7 ? AppTheme.successGreen : 
                  response.responseQualityScore > 0.4 ? AppTheme.warningAmber : AppTheme.errorRed,
                ),
                const SizedBox(width: 16),
                _buildResponseMetric(
                  'Words',
                  response.wordCount.toString(),
                  AppTheme.accentTeal,
                ),
                const SizedBox(width: 16),
                _buildResponseMetric(
                  'Confidence',
                  response.confidenceContextDescription,
                  AppTheme.mutedText,
                ),
              ],
            ),
            if (response.additionalContext != null && response.additionalContext!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Context:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response.additionalContext!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedText,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  int _getDaysAgo(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }
}