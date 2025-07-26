import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../utils/theme.dart';

/// Centralised error handling utility for the Career Insight Engine
/// Provides consistent error handling and user-friendly error messages

class ErrorHandler {
  /// Handle and log errors, returning user-friendly messages
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Application error occurred', error, stackTrace);
    
    // Map specific errors to user-friendly messages in Australian English
    if (error is FormatException) {
      return 'There was an issue with the data format. Please try again.';
    } else if (error is StateError) {
      return 'The application state is inconsistent. Please restart the app.';
    } else if (error is ArgumentError) {
      return 'Invalid data was provided. Please check your input.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please check your device settings.';
    } else if (error.toString().contains('network')) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (error.toString().contains('storage') || error.toString().contains('file')) {
      return 'Storage issue. Please ensure you have sufficient space.';
    } else {
      return 'An unexpected error occurred. Please try again or restart the app.';
    }
  }

  /// Show error dialog with appropriate styling
  static void showErrorDialog(BuildContext context, dynamic error, [StackTrace? stackTrace]) {
    final message = handleError(error, stackTrace);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mutedTone1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Error',
              style: TextStyle(
                color: AppTheme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppTheme.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar with appropriate styling
  static void showErrorSnackBar(BuildContext context, dynamic error, [StackTrace? stackTrace]) {
    final message = handleError(error, stackTrace);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.primaryText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppTheme.primaryText,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.primaryText,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Handle specific career-related errors
  static String handleCareerError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Career-specific error occurred', error, stackTrace);
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('session')) {
      return 'There was an issue with your career exploration session. Please try again.';
    } else if (errorString.contains('response')) {
      return 'Unable to save your response. Please check your input and try again.';
    } else if (errorString.contains('insight')) {
      return 'Unable to generate insights at this time. Please try again later.';
    } else if (errorString.contains('domain')) {
      return 'There was an issue accessing career domain information.';
    } else if (errorString.contains('persistence') || errorString.contains('hive')) {
      return 'Unable to save your data locally. Please check device storage and permissions.';
    } else {
      return handleError(error, stackTrace);
    }
  }

  /// Handle async operations with error handling
  static Future<T?> handleAsyncOperation<T>(
    Future<T> operation, {
    String? operationName,
    bool showSnackBar = false,
    BuildContext? context,
  }) async {
    try {
      AppLogger.debug('Starting async operation: ${operationName ?? 'unnamed'}');
      final stopwatch = Stopwatch()..start();
      
      final result = await operation;
      
      stopwatch.stop();
      AppLogger.performance(
        operationName ?? 'async_operation',
        stopwatch.elapsed,
      );
      
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Async operation failed: ${operationName ?? 'unnamed'}',
        error,
        stackTrace,
      );
      
      if (showSnackBar && context != null && context.mounted) {
        showErrorSnackBar(context, error, stackTrace);
      }
      
      return null;
    }
  }

  /// Validate input and provide user-friendly feedback
  static String? validateCareerResponse(String? response) {
    if (response == null || response.trim().isEmpty) {
      return 'Please provide a response before continuing.';
    }
    
    if (response.trim().length < 10) {
      return 'Please provide a more detailed response (at least 10 characters).';
    }
    
    return null; // Valid response
  }

  /// Validate session name
  static String? validateSessionName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Please provide a name for your session.';
    }
    
    if (name.trim().length > 100) {
      return 'Session name must be 100 characters or less.';
    }
    
    return null; // Valid name
  }
}