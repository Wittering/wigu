import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advisor_invitation.dart';
import '../../models/advisor_response.dart';
import '../../services/advisor_service.dart';
import '../../services/career_persistence_service.dart';
import '../../utils/theme.dart';
import '../../widgets/advisor/advisor_invitation_card.dart';
import '../../widgets/advisor/advisor_analytics_widget.dart';
import '../../widgets/advisor/advisor_feedback_summary_widget.dart';
import 'advisor_invitation_screen.dart';
import 'advisor_responses_screen.dart';

/// Main advisor management screen for users to manage their advisor invitations
/// and review feedback responses with Australian English throughout
class AdvisorManagementScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AdvisorManagementScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<AdvisorManagementScreen> createState() => _AdvisorManagementScreenState();
}

class _AdvisorManagementScreenState extends ConsumerState<AdvisorManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AdvisorService _advisorService;
  bool _isLoading = false;
  String? _error;
  List<AdvisorInvitation> _invitations = [];
  AdvisorFeedbackSummary? _feedbackSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _advisorService = AdvisorService();
    _initialiseService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialiseService() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _advisorService.initialise();
      await _loadData();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialise advisor service: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final invitations = _advisorService.getInvitationsForSession(widget.sessionId);
      final feedbackSummary = await _advisorService.generateFeedbackSummary(widget.sessionId);
      
      setState(() {
        _invitations = invitations;
        _feedbackSummary = feedbackSummary;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load advisor data: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _navigateToInviteAdvisor() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdvisorInvitationScreen(sessionId: widget.sessionId),
      ),
    );
    
    if (result == true) {
      await _refreshData();
    }
  }

  void _navigateToResponses(AdvisorInvitation invitation) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdvisorResponsesScreen(
          invitation: invitation,
          advisorService: _advisorService,
        ),
      ),
    );
    
    await _refreshData();
  }

  Future<void> _sendReminder(AdvisorInvitation invitation) async {
    try {
      // In a real app, get user name from session/profile
      const userName = 'Career Explorer';
      await _advisorService.sendReminderEmail(invitation.id, userName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder sent to ${invitation.advisorName}'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      
      await _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reminder: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Advisor Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialiseService,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildInvitationsList(),
            const SizedBox(height: 24),
            if (_feedbackSummary?.hasResponses == true)
              _buildQuickInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 28,
                  color: AppTheme.accentTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advisor Feedback',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gather external perspectives on your career strengths and potential',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _invitations.length < 4 ? _navigateToInviteAdvisor : null,
                icon: const Icon(Icons.person_add),
                label: Text(
                  _invitations.length < 4 
                      ? 'Invite Advisor'
                      : 'Maximum Advisors Reached (4)',
                ),
              ),
            ),
            if (_invitations.length < 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'We recommend inviting 3-4 advisors for comprehensive feedback',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningAmber,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedCount = _invitations.where((inv) => inv.status == InvitationStatus.completed).length;
    final pendingCount = _invitations.where((inv) => inv.status == InvitationStatus.sent).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Invited',
            _invitations.length.toString(),
            Icons.send,
            AppTheme.accentTeal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completedCount.toString(),
            Icons.check_circle,
            AppTheme.successGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            pendingCount.toString(),
            Icons.schedule,
            AppTheme.warningAmber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
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

  Widget _buildInvitationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Advisors',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_invitations.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.group_add,
                    size: 48,
                    color: AppTheme.mutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Advisors Invited Yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by inviting people who know your work well - managers, colleagues, mentors, or clients.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToInviteAdvisor,
                    child: const Text('Invite Your First Advisor'),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_invitations.map((invitation) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdvisorInvitationCard(
              invitation: invitation,
              onViewResponses: () => _navigateToResponses(invitation),
              onSendReminder: invitation.canSendReminder 
                  ? () => _sendReminder(invitation)
                  : null,
            ),
          ))),
      ],
    );
  }

  Widget _buildQuickInsights() {
    if (_feedbackSummary == null || !_feedbackSummary!.hasResponses) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._feedbackSummary!.insights.take(3).map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.accentTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View Detailed Analysis'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return AdvisorAnalyticsWidget(
      sessionId: widget.sessionId,
      advisorService: _advisorService,
    );
  }

  Widget _buildFeedbackTab() {
    return AdvisorFeedbackSummaryWidget(
      sessionId: widget.sessionId,
      advisorService: _advisorService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advisor Feedback'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentTeal,
          labelColor: AppTheme.primaryText,
          unselectedLabelColor: AppTheme.mutedText,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'), 
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }
}