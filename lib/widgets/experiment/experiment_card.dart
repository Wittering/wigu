import 'package:flutter/material.dart';
import '../../models/career_experiment.dart';
import '../../utils/theme.dart';

/// Card widget for displaying career experiments
/// Shows experiment details, status, and progress with Australian English
class ExperimentCard extends StatelessWidget {
  final CareerExperiment experiment;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final double? progressPercentage;
  final bool showActions;
  final bool isCompact;

  const ExperimentCard({
    Key? key,
    required this.experiment,
    this.onTap,
    this.onStart,
    this.onPause,
    this.onComplete,
    this.onCancel,
    this.progressPercentage,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 12),
              _buildContent(theme),
              if (!isCompact) ...[
                const SizedBox(height: 12),
                _buildMetrics(theme),
              ],
              if (progressPercentage != null) ...[
                const SizedBox(height: 12),
                _buildProgress(theme),
              ],
              if (showActions && !isCompact) ...[
                const SizedBox(height: 16),
                _buildActions(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                experiment.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildStatusChip(theme),
                  const SizedBox(width: 8),
                  _buildPriorityChip(theme),
                ],
              ),
            ],
          ),
        ),
        // Duration badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.mutedTone2.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${experiment.estimatedDurationDays} days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          experiment.description,
          style: theme.textTheme.bodyMedium,
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (!isCompact && experiment.hypothesis.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentTeal.withOpacity(0.2),
                width: 1,
              ),
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
                    'Hypothesis: ${experiment.hypothesis}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetrics(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildMetricItem(
          icon: Icons.flag_outlined,
          label: 'Success Criteria',
          value: '${experiment.successCriteria.length}',
          theme: theme,
        ),
        _buildMetricItem(
          icon: Icons.trending_up,
          label: 'Metrics',
          value: '${experiment.metrics.length}',
          theme: theme,
        ),
        _buildMetricItem(
          icon: Icons.inventory_2_outlined,
          label: 'Resources',
          value: '${experiment.requiredResources.length}',
          theme: theme,
        ),
        if (experiment.complexity != ExperimentComplexity.low)
          _buildMetricItem(
            icon: Icons.warning_amber_outlined,
            label: 'Complexity',
            value: experiment.complexity.displayName,
            theme: theme,
            valueColor: _getComplexityColor(),
          ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.mutedText,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedText,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? AppTheme.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(ThemeData theme) {
    final progress = progressPercentage ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.mutedTone2.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(progress),
          ),
        ),
        if (experiment.isOverdue) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 14,
                color: AppTheme.warningAmber,
              ),
              const SizedBox(width: 4),
              Text(
                'Overdue by ${experiment.daysSinceStarted! - experiment.estimatedDurationDays} days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningAmber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ] else if (experiment.daysUntilDue != null) ...[
          const SizedBox(height: 4),
          Text(
            'Due in ${experiment.daysUntilDue} days',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    final actions = <Widget>[];
    
    switch (experiment.status) {
      case ExperimentStatus.planned:
        if (onStart != null) {
          actions.add(
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 36),
              ),
            ),
          );
        }
        break;
        
      case ExperimentStatus.active:
        if (onPause != null) {
          actions.add(
            OutlinedButton.icon(
              onPressed: onPause,
              icon: const Icon(Icons.pause, size: 18),
              label: const Text('Pause'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningAmber,
                side: BorderSide(color: AppTheme.warningAmber),
                minimumSize: const Size(100, 36),
              ),
            ),
          );
        }
        if (onComplete != null) {
          actions.add(
            ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 36),
              ),
            ),
          );
        }
        break;
        
      case ExperimentStatus.paused:
        if (onStart != null) {
          actions.add(
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 36),
              ),
            ),
          );
        }
        break;
        
      case ExperimentStatus.completed:
        actions.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
        
      case ExperimentStatus.cancelled:
        actions.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.mutedText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  size: 16,
                  color: AppTheme.mutedText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cancelled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
        break;
    }
    
    // Add cancel action for active experiments
    if (experiment.status == ExperimentStatus.active || 
        experiment.status == ExperimentStatus.paused) {
      if (onCancel != null) {
        actions.add(
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
              minimumSize: const Size(100, 36),
            ),
          ),
        );
      }
    }
    
    if (actions.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        experiment.status.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        experiment.priority.displayName,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getPriorityColor(),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (experiment.type) {
      case ExperimentType.skillBuilding:
        return Icons.school_outlined;
      case ExperimentType.roleExploration:
        return Icons.explore_outlined;
      case ExperimentType.networking:
        return Icons.people_outline;
      case ExperimentType.visibilityBuilding:
        return Icons.visibility_outlined;
      case ExperimentType.leadershipDevelopment:
        return Icons.psychology_outlined;
      case ExperimentType.workEnvironment:
        return Icons.work_outline;
      case ExperimentType.industryExploration:
        return Icons.business_outlined;
      case ExperimentType.valueAlignment:
        return Icons.favorite_outline;
      case ExperimentType.creativityExpression:
        return Icons.palette_outlined;
      case ExperimentType.mentoring:
        return Icons.group_outlined;
    }
  }

  Color _getTypeColor() {
    switch (experiment.type) {
      case ExperimentType.skillBuilding:
        return CareerTheme.primaryBlue;
      case ExperimentType.roleExploration:
        return CareerTheme.accentOrange;
      case ExperimentType.networking:
        return CareerTheme.primaryGreen;
      case ExperimentType.visibilityBuilding:
        return CareerTheme.accentYellow;
      case ExperimentType.leadershipDevelopment:
        return CareerTheme.accentPurple;
      case ExperimentType.workEnvironment:
        return AppTheme.mutedTone2;
      case ExperimentType.industryExploration:
        return CareerTheme.primaryBlue;
      case ExperimentType.valueAlignment:
        return CareerTheme.primaryGreen;
      case ExperimentType.creativityExpression:
        return CareerTheme.accentOrange;
      case ExperimentType.mentoring:
        return CareerTheme.accentPurple;
    }
  }

  Color _getStatusColor() {
    switch (experiment.status) {
      case ExperimentStatus.planned:
        return AppTheme.mutedText;
      case ExperimentStatus.active:
        return AppTheme.successGreen;
      case ExperimentStatus.paused:
        return AppTheme.warningAmber;
      case ExperimentStatus.completed:
        return AppTheme.accentTeal;
      case ExperimentStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  Color _getPriorityColor() {
    switch (experiment.priority) {
      case ExperimentPriority.low:
        return AppTheme.mutedText;
      case ExperimentPriority.medium:
        return CareerTheme.primaryBlue;
      case ExperimentPriority.high:
        return AppTheme.warningAmber;
      case ExperimentPriority.urgent:
        return AppTheme.errorRed;
    }
  }

  Color _getComplexityColor() {
    switch (experiment.complexity) {
      case ExperimentComplexity.low:
        return AppTheme.successGreen;
      case ExperimentComplexity.medium:
        return AppTheme.warningAmber;
      case ExperimentComplexity.high:
        return AppTheme.errorRed;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.successGreen;
    if (progress >= 0.5) return AppTheme.accentTeal;
    if (progress >= 0.3) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }
}