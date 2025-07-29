import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/local_data_service.dart';
import 'screens/splash_screen.dart';
import 'screens/self_assessment/self_assessment_screen.dart';
import 'screens/career_results_screen.dart';
import 'screens/advisor/advisor_response_router.dart';
import 'screens/advisor/advisor_management_screen.dart';
import 'utils/theme.dart';

// Platform imports
import 'package:flutter/foundation.dart';

// Import all generated Hive adapters
import 'models/career_session.dart';
import 'models/career_response.dart';
import 'models/career_insight.dart';
import 'models/advisor_invitation.dart';
import 'models/advisor_response.dart';
import 'models/advisor_rating.dart';
import 'models/career_synthesis.dart';
import 'models/career_experiment.dart';
import 'models/experiment_result.dart';
import 'models/career_progress.dart';
import 'models/completion_status.dart';
import 'models/five_insights_model.dart';
import 'models/insight_analysis.dart';
import 'models/career_report.dart';
import 'models/report_visualization.dart';

/// Entry point for the Career Insight Engine
/// A reflective tool for career exploration and development
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise logging
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );
  
  try {
    // Initialize Hive and register all adapters
    await _initializeHive(logger);
    
    // Initialize local data service
    final localDataService = LocalDataService();
    await localDataService.initialize();
    
    logger.i('Career Insight Engine with local persistence initialized successfully');
    
    runApp(
      ProviderScope(
        overrides: [
          localDataServiceProvider.overrideWithValue(localDataService),
        ],
        child: const WiguCareerApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.e('Failed to initialise Career Insight Engine', error: e, stackTrace: stackTrace);
    
    // Show detailed error for debugging
    runApp(
      MaterialApp(
        title: 'Career Assessment - Initialization Error',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('When I grow up...'),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'The app encountered an error during startup. This may be due to browser storage restrictions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Error: ${e.toString()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (kIsWeb) {
                        // Use window.location.reload() equivalent
                        _reloadWeb();
                      }
                    },
                    child: Text('Reload Page'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Try to run the app anyway
                      runApp(
                        ProviderScope(
                          child: const WiguCareerApp(),
                        ),
                      );
                    },
                    child: Text('Continue Anyway'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Initialize Hive with all required adapters
Future<void> _initializeHive(Logger logger) async {
  logger.i('Initializing Hive database...');
  
  try {
    if (kIsWeb) {
      // Initialize Hive for web with more conservative approach
      await Hive.initFlutter('career_assessment_web');
      logger.i('Hive initialized for web environment');
    } else {
      // Initialize Hive for Flutter mobile/desktop
      await Hive.initFlutter();
      logger.i('Hive initialized for Flutter environment');
    }
    
    // Register all model adapters with error handling
    try {
      _registerHiveAdapters(logger);
      logger.i('Hive database initialized with all adapters registered');
    } catch (e, stackTrace) {
      logger.e('Failed to register Hive adapters', error: e, stackTrace: stackTrace);
      // Continue anyway - some functionality may be limited
    }
  } catch (e, stackTrace) {
    logger.e('Failed to initialize Hive', error: e, stackTrace: stackTrace);
    // Rethrow to trigger fallback in main()
    rethrow;
  }
}

/// Register all Hive type adapters for the career assessment models
void _registerHiveAdapters(Logger logger) {
  try {
    // Core career models
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(CareerSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(CareerResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(CareerInsightAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(CareerDomainAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(ExplorationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(InsightTypeAdapter());
    }
    
    // Advisor models
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(AdvisorInvitationAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(AdvisorRelationshipAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(InvitationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(AdvisorResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(AdvisorObservationPeriodAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(AdvisorConfidenceContextAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(AdvisorRatingAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(AdvisorStrengthAreaAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(AdvisorResponseTimelinessAdapter());
    }
    
    // Career synthesis models
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(CareerSynthesisAdapter());
    }
    if (!Hive.isAdapterRegistered(31)) {
      Hive.registerAdapter(SynthesisInsightAdapter());
    }
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(SynthesisCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(33)) {
      Hive.registerAdapter(SynthesisConfidenceAdapter());
    }
    
    // Insight analysis models
    if (!Hive.isAdapterRegistered(34)) {
      Hive.registerAdapter(InsightAnalysisAdapter());
    }
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(InsightPatternAdapter());
    }
    if (!Hive.isAdapterRegistered(36)) {
      Hive.registerAdapter(InsightCorrelationAdapter());
    }
    if (!Hive.isAdapterRegistered(37)) {
      Hive.registerAdapter(InsightTrendAnalysisAdapter());
    }
    if (!Hive.isAdapterRegistered(38)) {
      Hive.registerAdapter(InsightTypeStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(39)) {
      Hive.registerAdapter(PatternTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(40)) {
      Hive.registerAdapter(CorrelationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(41)) {
      Hive.registerAdapter(QualityTrendAdapter());
    }
    if (!Hive.isAdapterRegistered(42)) {
      Hive.registerAdapter(DiversityTrendAdapter());
    }
    
    // Career experiment models
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(CareerExperimentAdapter());
    }
    if (!Hive.isAdapterRegistered(51)) {
      Hive.registerAdapter(ExperimentMetricAdapter());
    }
    if (!Hive.isAdapterRegistered(52)) {
      Hive.registerAdapter(ExperimentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(53)) {
      Hive.registerAdapter(ExperimentStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(54)) {
      Hive.registerAdapter(ExperimentScopeAdapter());
    }
    if (!Hive.isAdapterRegistered(55)) {
      Hive.registerAdapter(ExperimentPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(56)) {
      Hive.registerAdapter(ExperimentComplexityAdapter());
    }
    if (!Hive.isAdapterRegistered(57)) {
      Hive.registerAdapter(MetricTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(58)) {
      Hive.registerAdapter(MetricFrequencyAdapter());
    }
    
    // Experiment result models
    if (!Hive.isAdapterRegistered(60)) {
      Hive.registerAdapter(ExperimentResultAdapter());
    }
    if (!Hive.isAdapterRegistered(61)) {
      Hive.registerAdapter(MetricResultAdapter());
    }
    if (!Hive.isAdapterRegistered(62)) {
      Hive.registerAdapter(ExperimentOutcomeAdapter());
    }
    if (!Hive.isAdapterRegistered(63)) {
      Hive.registerAdapter(ResultConfidenceAdapter());
    }
    if (!Hive.isAdapterRegistered(64)) {
      Hive.registerAdapter(ResultRatingAdapter());
    }
    if (!Hive.isAdapterRegistered(65)) {
      Hive.registerAdapter(MetricResultTypeAdapter());
    }
    
    // Career report models
    if (!Hive.isAdapterRegistered(70)) {
      Hive.registerAdapter(CareerReportAdapter());
    }
    if (!Hive.isAdapterRegistered(71)) {
      Hive.registerAdapter(ReportSectionAdapter());
    }
    if (!Hive.isAdapterRegistered(72)) {
      Hive.registerAdapter(ReportTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(73)) {
      Hive.registerAdapter(ReportFormatAdapter());
    }
    if (!Hive.isAdapterRegistered(74)) {
      Hive.registerAdapter(SectionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(75)) {
      Hive.registerAdapter(ReportConfidenceAdapter());
    }
    
    // Report visualization models
    if (!Hive.isAdapterRegistered(80)) {
      Hive.registerAdapter(ReportVisualizationAdapter());
    }
    if (!Hive.isAdapterRegistered(81)) {
      Hive.registerAdapter(VisualizationConfigAdapter());
    }
    if (!Hive.isAdapterRegistered(82)) {
      Hive.registerAdapter(VisualizationSizeAdapter());
    }
    if (!Hive.isAdapterRegistered(83)) {
      Hive.registerAdapter(VisualizationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(84)) {
      Hive.registerAdapter(SizePresetAdapter());
    }
    
    // Five insights models
    if (!Hive.isAdapterRegistered(90)) {
      Hive.registerAdapter(FiveInsightsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(91)) {
      Hive.registerAdapter(EnergisrengStrengthAdapter());
    }
    if (!Hive.isAdapterRegistered(92)) {
      Hive.registerAdapter(HiddenStrengthAdapter());
    }
    if (!Hive.isAdapterRegistered(93)) {
      Hive.registerAdapter(OverusedTalentAdapter());
    }
    if (!Hive.isAdapterRegistered(94)) {
      Hive.registerAdapter(AspirationalStrengthAdapter());
    }
    if (!Hive.isAdapterRegistered(95)) {
      Hive.registerAdapter(MisalignedEnergyAdapter());
    }
    if (!Hive.isAdapterRegistered(96)) {
      Hive.registerAdapter(InsightCategoryAdapter());
    }
    
    // Career progress models
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(CareerProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(101)) {
      Hive.registerAdapter(DomainProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(102)) {
      Hive.registerAdapter(ProgressMilestoneAdapter());
    }
    if (!Hive.isAdapterRegistered(103)) {
      Hive.registerAdapter(ProgressPhaseAdapter());
    }
    if (!Hive.isAdapterRegistered(104)) {
      Hive.registerAdapter(ProgressQualityAdapter());
    }
    if (!Hive.isAdapterRegistered(105)) {
      Hive.registerAdapter(DomainEngagementAdapter());
    }
    if (!Hive.isAdapterRegistered(106)) {
      Hive.registerAdapter(MilestoneTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(107)) {
      Hive.registerAdapter(MilestonePriorityAdapter());
    }
    
    // Completion status models
    if (!Hive.isAdapterRegistered(110)) {
      Hive.registerAdapter(CompletionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(111)) {
      Hive.registerAdapter(CompletionItemAdapter());
    }
    if (!Hive.isAdapterRegistered(112)) {
      Hive.registerAdapter(CategoryStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(113)) {
      Hive.registerAdapter(CompletionCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(114)) {
      Hive.registerAdapter(ItemPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(115)) {
      Hive.registerAdapter(CompletionLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(116)) {
      Hive.registerAdapter(UserReadinessAdapter());
    }
    
    logger.i('All Hive adapters registered successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to register Hive adapters', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Main application widget for the Career Insight Engine
class WiguCareerApp extends StatelessWidget {
  const WiguCareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'When I grow up - Career Insight Engine',
      debugShowCheckedModeBanner: false,
      
      // Use our custom Australian English-optimised theme
      theme: AppTheme.darkTheme,
      
      // Define application routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/assessment': (context) => const SelfAssessmentScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/results/') == true) {
          final sessionId = settings.name!.substring('/results/'.length);
          return MaterialPageRoute(
            builder: (context) => CareerResultsScreen(sessionId: sessionId),
          );
        }
        
        // Handle advisor response URLs
        if (settings.name?.startsWith('/advisor-response/') == true) {
          return MaterialPageRoute(
            builder: (context) => AdvisorResponseRouter.fromPath(settings.name!),
          );
        }
        
        // Handle advisor management URLs
        if (settings.name?.startsWith('/advisors/') == true) {
          final sessionId = settings.name!.substring('/advisors/'.length);
          return MaterialPageRoute(
            builder: (context) => AdvisorManagementScreen(sessionId: sessionId),
          );
        }
        
        return null;
      },
      
      // Error handling for production readiness
      builder: (context, widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return _buildErrorWidget(context, errorDetails);
        };
        return widget ?? const SizedBox.shrink();
      },
    );
  }

  /// Production-ready error widget
  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails errorDetails) {
    final logger = Logger();
    logger.e('Flutter error caught by error widget', error: errorDetails.exception, stackTrace: errorDetails.stack);
    
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.mutedTone1,
              borderRadius: BorderRadius.circular(12),
            ),
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
                  'We\'re sorry, but the application encountered an unexpected error. Please restart the app.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // In a production app, you might want to restart the app or navigate to a safe screen
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to reload the web page
void _reloadWeb() {
  if (kIsWeb) {
    // Simply throw an exception to restart the Flutter app
    // This will cause the error boundary to catch and reload
    throw Exception('App reload requested');
  }
}
