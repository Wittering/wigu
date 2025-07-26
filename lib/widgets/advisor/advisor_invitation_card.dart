import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/advisor_invitation.dart';
import '../../utils/theme.dart';

/// Card widget displaying advisor invitation details and status
/// Includes actions for viewing responses and sending reminders
class AdvisorInvitationCard extends StatelessWidget {
  final AdvisorInvitation invitation;
  final VoidCallback? onViewResponses;
  final VoidCallback? onSendReminder;

  const AdvisorInvitationCard({
    super.key,
    required this.invitation,
    this.onViewResponses,
    this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildStatusSection(context),
            const SizedBox(height: 12),
            _buildDetailsSection(context),
            if (_shouldShowActions()) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.accentTeal.withOpacity(0.2),
          radius: 20,
          child: Text(
            invitation.advisorName.isNotEmpty
                ? invitation.advisorName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: AppTheme.accentTeal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invitation.advisorName,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                invitation.relationshipType.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (invitation.status) {
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
        backgroundColor = invitation.isOverdue 
            ? AppTheme.errorRed 
            : AppTheme.accentTeal.withOpacity(0.2);
        textColor = invitation.isOverdue 
            ? Colors.white 
            : AppTheme.accentTeal;
        icon = invitation.isOverdue ? Icons.schedule : Icons.send;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            invitation.status.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: AppTheme.mutedText,
        ),
        const SizedBox(width: 6),
        Text(
          invitation.statusDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (invitation.isOverdue) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'OVERDUE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.errorRed,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.email,
              size: 16,
              color: AppTheme.mutedText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                invitation.advisorEmail,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.copy,
                size: 16,
                color: AppTheme.mutedText,
              ),
              onPressed: () => _copyToClipboard(context, invitation.advisorEmail),
              tooltip: 'Copy email address',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        if (invitation.advisorPhone != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: AppTheme.mutedText,
              ),
              const SizedBox(width: 6),
              Text(
                invitation.advisorPhone!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
        if (invitation.reminderCount > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.notifications,
                size: 16,
                color: AppTheme.warningAmber,
              ),
              const SizedBox(width: 6),
              Text(
                '${invitation.reminderCount} reminder${invitation.reminderCount == 1 ? '' : 's'} sent',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.warningAmber,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (invitation.status == InvitationStatus.completed && onViewResponses != null)
          _buildActionButton(
            'View Responses',
            Icons.visibility,
            AppTheme.accentTeal,
            onViewResponses!,
          ),
        if (invitation.canSendReminder && onSendReminder != null)
          _buildActionButton(
            'Send Reminder',
            Icons.send,
            AppTheme.warningAmber,
            onSendReminder!,
          ),
        _buildShareButton(context),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _shareInvitationLink(context),
      icon: const Icon(Icons.share, size: 16),
      label: const Text('Share Link'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.accentTeal,
        side: BorderSide(color: AppTheme.accentTeal),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  bool _shouldShowActions() {
    return (invitation.status == InvitationStatus.completed && onViewResponses != null) ||
           (invitation.canSendReminder && onSendReminder != null) ||
           (invitation.status != InvitationStatus.declined && invitation.status != InvitationStatus.expired);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _shareInvitationLink(BuildContext context) {
    final invitationUrl = invitation.generateInvitationUrl();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Invitation Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this link with ${invitation.advisorName}:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedTone1.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.mutedTone2),
              ),
              child: SelectableText(
                invitationUrl,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This link is unique to this invitation and expires in 30 days.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _copyToClipboard(context, invitationUrl);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }
}