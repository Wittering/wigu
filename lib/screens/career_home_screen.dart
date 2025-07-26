import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/career_persistence_service.dart';
import '../models/career_session.dart';
import '../utils/theme.dart';
import '../widgets/session_card.dart';
import '../widgets/domain_overview_card.dart';
import '../widgets/quick_reflection_card.dart';

/// Main home screen for the Career Insight Engine
/// Provides an overview of career exploration progress and quick access to features
class CareerHomeScreen extends ConsumerStatefulWidget {
  const CareerHomeScreen({super.key});

  @override
  ConsumerState<CareerHomeScreen> createState() => _CareerHomeScreenState();
}

class _CareerHomeScreenState extends ConsumerState<CareerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentSessionAsync = ref.watch(currentCareerSessionProvider);
    final allSessionsAsync = ref.watch(allCareerSessionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('Career Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: currentSessionAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(context, error),
          data: (currentSession) => _buildMainContent(context, currentSession, allSessionsAsync),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/assessment'),
        label: const Text('Self Assessment'),
        icon: const Icon(Icons.psychology_outlined),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    CareerSession? currentSession,
    AsyncValue<List<CareerSession>> allSessionsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // Welcome section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildWelcomeSection(context, currentSession),
          ),
        ),

        // Current session overview
        if (currentSession != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCurrentSessionSection(context, currentSession),
            ),
          ),

        // Career domains overview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCareerDomainsSection(context, currentSession),
          ),
        ),

        // Quick reflection section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildQuickReflectionSection(context),
          ),
        ),

        // Recent sessions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildRecentSessionsSection(context, allSessionsAsync),
          ),
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, CareerSession? currentSession) {
    final greeting = _getGreeting();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryText,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.1, curve: Curves.easeOut),
            
            const SizedBox(height: 8),
            
            Text(
              currentSession != null
                  ? 'Continue your career exploration journey'
                  : 'Welcome to your career insight journey. Start by creating a new exploration session.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryText,
                height: 1.5,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.1, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSessionSection(BuildContext context, CareerSession currentSession) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Current Session',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SessionCard(
          session: currentSession,
          isActive: true,
          onTap: () => _continueSession(context, currentSession),
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildCareerDomainsSection(BuildContext context, CareerSession? currentSession) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Career Domains',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: CareerDomain.values.length,
            itemBuilder: (context, index) {
              final domain = CareerDomain.values[index];
              final isCompleted = currentSession?.completedDomains.contains(domain) ?? false;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: 12.0,
                  left: index == 0 ? 0 : 0,
                ),
                child: DomainOverviewCard(
                  domain: domain,
                  isCompleted: isCompleted,
                  responseCount: currentSession?.getResponsesForDomain(domain).length ?? 0,
                  onTap: () => _exploreDomain(context, domain),
                ),
              );
            },
          ),
        )
            .animate(delay: 600.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildQuickReflectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Quick Reflection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        QuickReflectionCard(
          onStartReflection: () => _startQuickReflection(context),
        )
            .animate(delay: 800.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildRecentSessionsSection(BuildContext context, AsyncValue<List<CareerSession>> allSessionsAsync) {
    return allSessionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        
        final recentSessions = sessions.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...recentSessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SessionCard(
                session: session,
                isActive: false,
                onTap: () => _continueSession(context, session),
              ),
            )),
          ],
        )
            .animate(delay: 1000.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We encountered an error loading your career data. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _createNewSession(BuildContext context) async {
    try {
      final persistenceService = ref.read(careerPersistenceServiceProvider);
      await persistenceService.createNewCareerSession();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New career exploration session created'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating session: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _continueSession(BuildContext context, CareerSession session) {
    // TODO: Navigate to session detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening session: ${session.sessionName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exploreDomain(BuildContext context, CareerDomain domain) {
    // TODO: Navigate to domain exploration screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exploring ${domain.displayName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startQuickReflection(BuildContext context) {
    // TODO: Navigate to quick reflection screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting quick reflection...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}