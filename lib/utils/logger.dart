import 'package:logger/logger.dart';

/// Centralised logging utility for the Career Insight Engine
/// Provides consistent logging across the application with appropriate levels
class AppLogger {
  static Logger? _instance;

  /// Get the singleton logger instance
  static Logger get instance {
    _instance ??= Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _getLogLevel(),
    );
    return _instance!;
  }

  /// Determine log level based on build mode
  static Level _getLogLevel() {
    // In production, you might want to reduce log level
    // For now, keeping debug level for development
    return Level.debug;
  }

  /// Log debug information
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      instance.d(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      instance.d(message, error: error);
    } else {
      instance.d(message);
    }
  }

  /// Log general information
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      instance.i(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      instance.i(message, error: error);
    } else {
      instance.i(message);
    }
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      instance.w(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      instance.w(message, error: error);
    } else {
      instance.w(message);
    }
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      instance.e(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      instance.e(message, error: error);
    } else {
      instance.e(message);
    }
  }

  /// Log fatal errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      instance.f(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      instance.f(message, error: error);
    } else {
      instance.f(message);
    }
  }

  /// Log career-specific events with context
  static void careerEvent(String event, Map<String, dynamic> context) {
    instance.i('Career Event: $event', error: context);
  }

  /// Log user interactions for analytics
  static void userInteraction(String action, Map<String, dynamic> details) {
    instance.d('User Interaction: $action', error: details);
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, [Map<String, dynamic>? context]) {
    instance.d('Performance: $operation took ${duration.inMilliseconds}ms', error: context);
  }
}