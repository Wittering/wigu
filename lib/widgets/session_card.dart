import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/career_session.dart';
import '../utils/theme.dart';

/// Card widget displaying career session information
/// Shows session progress, completion status, and key metrics
class SessionCard extends StatelessWidget {
  final CareerSession session;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  const SessionCard({
    super.key,
    required this.session,
    this.isActive = false,
    this.onTap,
    this.onDelete,
    this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppTheme.accentTeal.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildProgressSection(context),
              const SizedBox(height: 12),
              _buildMetricsSection(context),
              if (session.latestInsight != null) ...[
                const SizedBox(height: 12),
                _buildLatestInsightSection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Session status indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentTeal : AppTheme.mutedTone2,
            shape: BoxShape.circle,
          ),
        )
            .animate(delay: 100.ms)
            .scale(begin: const Offset(0.5, 0.5))
            .then()
            .shimmer(
              duration: 2000.ms,
              colors: [
                isActive ? AppTheme.accentTeal : AppTheme.mutedTone2,
                isActive ? AppTheme.accentTeal.withOpacity(0.3) : AppTheme.mutedTone2.withOpacity(0.3),
              ],
            ),
        
        const SizedBox(width: 12),
        
        // Session name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.sessionName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                isActive ? 'Active Session' : _formatDate(session.lastModified),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? AppTheme.accentTeal : AppTheme.mutedText,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        
        // Action menu
        if (onDelete != null || onRename != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.mutedText,
              size: 20,
            ),
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  onRename?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onRename != null)
                const PopupMenuItem(
                  value: 'rename',
                  child: Text('Rename'),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final completionPercentage = session.completionPercentage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exploration Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(completionPercentage * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completionPercentage,
            backgroundColor: AppTheme.mutedTone2.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
            minHeight: 6,
          ),
        )
            .animate()
            .slideX(begin: -1.0, duration: 800.ms, curve: Curves.easeOut)
            .then()
            .shimmer(
              duration: 1500.ms,
              colors: [
                AppTheme.accentTeal,
                AppTheme.accentTeal.withOpacity(0.3),
              ],
            ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context) {
    return Row(
      children: [
        _buildMetric(
          context,
          icon: Icons.question_answer_outlined,
          label: 'Responses',
          value: session.totalResponses.toString(),
        ),
        const SizedBox(width: 24),
        _buildMetric(
          context,
          icon: Icons.insights_outlined,
          label: 'Insights',
          value: session.totalInsights.toString(),
        ),
        const SizedBox(width: 24),
        _buildMetric(
          context,
          icon: Icons.category_outlined,
          label: 'Domains',
          value: '${session.completedDomains.length}/${CareerDomain.values.length}',
        ),
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.mutedText,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLatestInsightSection(BuildContext context) {
    final insight = session.latestInsight!;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
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
                Icons.lightbulb_outline,
                size: 16,
                color: AppTheme.accentTeal,
              ),
              const SizedBox(width: 6),
              Text(
                'Latest Insight',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            insight.preview,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}