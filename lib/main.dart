import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'services/career_persistence_service.dart';
import 'screens/simple_career_home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/self_assessment/self_assessment_screen.dart';
import 'screens/career_results_screen.dart';
import 'utils/theme.dart';

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
    // Initialise career persistence service
    final careerPersistenceService = CareerPersistenceService();
    await careerPersistenceService.initialise();
    logger.i('Career Insight Engine initialised successfully');
    
    runApp(
      ProviderScope(
        overrides: [
          careerPersistenceServiceProvider.overrideWithValue(careerPersistenceService),
        ],
        child: const WiguCareerApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.e('Failed to initialise Career Insight Engine', error: e, stackTrace: stackTrace);
    // Run with basic configuration if initialisation fails
    runApp(
      ProviderScope(
        child: const WiguCareerApp(),
      ),
    );
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
        '/home': (context) => const SimpleCareerHomeScreen(),
        '/assessment': (context) => const SelfAssessmentScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/results/') == true) {
          final sessionId = settings.name!.substring('/results/'.length);
          return MaterialPageRoute(
            builder: (context) => CareerResultsScreen(sessionId: sessionId),
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
