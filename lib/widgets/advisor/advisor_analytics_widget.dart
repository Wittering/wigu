import 'package:flutter/material.dart';
import '../../models/advisor_invitation.dart';
import '../../services/advisor_service.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../assessment/loading_state_widget.dart';
import '../assessment/error_state_widget.dart';

/// Widget displaying advisor analytics and metrics
/// Shows comprehensive statistics about advisor invitations and responses
class AdvisorAnalyticsWidget extends StatefulWidget {
  final String sessionId;
  final AdvisorService advisorService;

  const AdvisorAnalyticsWidget({
    super.key,
    required this.sessionId,
    required this.advisorService,
  });

  @override
  State<AdvisorAnalyticsWidget> createState() => _AdvisorAnalyticsWidgetState();
}

class _AdvisorAnalyticsWidgetState extends State<AdvisorAnalyticsWidget> {
  AdvisorAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analytics = widget.advisorService.getAdvisorAnalytics(sessionId: widget.sessionId);
      setState(() {
        _analytics = analytics;
      });
    } catch (e) {
      AppLogger.error('Failed to load advisor analytics', e);
      setState(() {
        _error = 'Failed to load analytics: ${e.toString()}';
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
      return const LoadingStateWidget(message: 'Loading analytics...');
    }

    if (_error != null) {
      return ErrorStateWidget(
        title: 'Analytics Error',
        message: _error!,
        onRetry: _loadAnalytics,
      );
    }

    if (_analytics == null) {
      return const Center(
        child: Text('No analytics data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 24),
            _buildCompletionRates(),
            const SizedBox(height: 24),
            _buildRelationshipDistribution(),
            const SizedBox(height: 24),
            _buildResponseTimeDistribution(),
            const SizedBox(height: 24),
            _buildQualityMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Invitations',
                _analytics!.totalInvitations.toString(),
                Icons.send,
                AppTheme.accentTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Completed',
                _analytics!.completedInvitations.toString(),
                Icons.check_circle,
                AppTheme.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Pending',
                _analytics!.pendingInvitations.toString(),
                Icons.schedule,
                AppTheme.warningAmber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Total Responses',
                _analytics!.totalResponses.toString(),
                Icons.chat_bubble,
                AppTheme.accentTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildCompletionRates() {
    final completionRate = _analytics!.completionRate;
    final declineRate = _analytics!.declineRate;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Rates',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Completion Rate',
              completionRate,
              AppTheme.successGreen,
              '${(completionRate * 100).round()}%',
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Decline Rate',
              declineRate,
              AppTheme.errorRed,
              '${(declineRate * 100).round()}%',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.mutedText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A completion rate above 60% is considered excellent for advisor feedback.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, String displayValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: AppTheme.mutedTone2.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRelationshipDistribution() {
    if (_analytics!.relationshipTypeDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advisor Relationships',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Types of advisors you\'ve invited',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ..._analytics!.relationshipTypeDistribution.entries.map((entry) {
              final relationship = entry.key;
              final count = entry.value;
              final total = _analytics!.totalInvitations;
              final percentage = total > 0 ? (count / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRelationshipItem(relationship, count, percentage),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipItem(AdvisorRelationship relationship, int count, double percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getRelationshipColor(relationship),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                relationship.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(percentage * 100).round()}% ($count invited)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRelationshipColor(AdvisorRelationship relationship) {
    switch (relationship) {
      case AdvisorRelationship.manager:
        return AppTheme.successGreen;
      case AdvisorRelationship.colleague:
        return AppTheme.accentTeal;
      case AdvisorRelationship.mentor:
        return Colors.purple;
      case AdvisorRelationship.friend:
        return Colors.orange;
      case AdvisorRelationship.family:
        return Colors.pink;
      case AdvisorRelationship.client:
        return Colors.blue;
      case AdvisorRelationship.sponsor:
        return Colors.indigo;
      case AdvisorRelationship.peer:
        return Colors.cyan;
      case AdvisorRelationship.other:
        return AppTheme.mutedText;
    }
  }

  Widget _buildResponseTimeDistribution() {
    if (_analytics!.responseTimeDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Times',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'How quickly advisors responded',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ..._analytics!.responseTimeDistribution.entries.map((entry) {
              final category = entry.key;
              final count = entry.value;
              final total = _analytics!.completedInvitations;
              final percentage = total > 0 ? (count / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildResponseTimeItem(category, count, percentage),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeItem(String category, int count, double percentage) {
    Color color = _getResponseTimeColor(category);
    
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '${(percentage * 100).round()}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getResponseTimeColor(String category) {
    if (category.contains('Very Quick')) return AppTheme.successGreen;
    if (category.contains('Quick')) return AppTheme.accentTeal;
    if (category.contains('Reasonable')) return AppTheme.warningAmber;
    if (category.contains('Slow')) return AppTheme.errorRed;
    return AppTheme.mutedText;
  }

  Widget _buildQualityMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quality Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Overall quality of advisor feedback',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQualityMetric(
                    'Response Quality',
                    _analytics!.averageResponseQuality,
                    Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQualityMetric(
                    'Advisor Rating',
                    _analytics!.averageRating / 5.0, // Convert 5-point scale to 0-1
                    Icons.thumb_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Higher quality responses include specific examples, detailed explanations, and demonstrate good understanding of your capabilities.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetric(String label, double value, IconData icon) {
    final percentage = (value * 100).round();
    Color color = value >= 0.8 ? AppTheme.successGreen :
                  value >= 0.6 ? AppTheme.warningAmber :
                  AppTheme.errorRed;

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$percentage%',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}