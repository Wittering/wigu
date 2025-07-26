import 'package:flutter/material.dart';
import '../models/advisor_invitation.dart';
import '../services/advisor_service.dart';
import '../utils/logger.dart';
import '../utils/theme.dart';

/// Comprehensive error handling for advisor system
/// Provides user-friendly error messages and recovery options
class AdvisorErrorHandler {
  /// Handle advisor service exceptions
  static AdvisorErrorInfo handleAdvisorServiceException(dynamic error) {
    if (error is AdvisorServiceException) {
      switch (error.type) {
        case AdvisorServiceErrorType.advisorLimitExceeded:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.userError,
            title: 'Advisor Limit Reached',
            message: 'You\'ve already invited the maximum number of advisors (4) for this session. You can manage your existing invitations or wait for responses.',
            userFriendlyMessage: 'Maximum advisors reached - manage existing invitations instead.',
            canRetry: false,
            suggestedActions: ['Review existing invitations', 'Send reminders to pending advisors'],
          );
          
        case AdvisorServiceErrorType.duplicateAdvisor:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.userError,
            title: 'Advisor Already Invited',
            message: 'You\'ve already sent an invitation to this email address for this session.',
            userFriendlyMessage: 'This advisor has already been invited for this session.',
            canRetry: false,
            suggestedActions: ['Check your existing invitations', 'Try a different email address'],
          );
          
        case AdvisorServiceErrorType.invitationNotFound:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.notFound,
            title: 'Invitation Not Found',
            message: 'The invitation link may be invalid or has expired.',
            userFriendlyMessage: 'This invitation link is no longer valid.',
            canRetry: false,
            suggestedActions: ['Contact the person who sent the invitation', 'Request a new invitation link'],
          );
          
        case AdvisorServiceErrorType.invitationAlreadyCompleted:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.userError,
            title: 'Already Completed',
            message: 'This invitation has already been completed. Thank you for your previous response.',
            userFriendlyMessage: 'You\'ve already provided feedback for this invitation.',
            canRetry: false,
            suggestedActions: ['Contact the requester if you need to update your response'],
          );
          
        case AdvisorServiceErrorType.invitationExpired:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.expired,
            title: 'Invitation Expired',
            message: 'This invitation has expired. Invitations are valid for 30 days from the send date.',
            userFriendlyMessage: 'This invitation has expired and is no longer accepting responses.',
            canRetry: false,
            suggestedActions: ['Contact the requester for a new invitation'],
          );
          
        case AdvisorServiceErrorType.emailServiceUnavailable:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.serviceError,
            title: 'Email Service Issue',
            message: 'Unable to send the invitation email at this time. The invitation has been created but not sent.',
            userFriendlyMessage: 'Invitation created but email couldn\'t be sent automatically.',
            canRetry: true,
            suggestedActions: ['Try again in a few minutes', 'Share the invitation link manually'],
          );
          
        case AdvisorServiceErrorType.invalidResponseData:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.validationError,
            title: 'Invalid Response Data',
            message: 'Some of the response data is invalid or incomplete.',
            userFriendlyMessage: 'Please check your responses and try again.',
            canRetry: true,
            suggestedActions: ['Review all required fields', 'Ensure responses meet minimum requirements'],
          );
          
        case AdvisorServiceErrorType.persistenceError:
          return AdvisorErrorInfo(
            type: AdvisorErrorType.systemError,
            title: 'Storage Error',
            message: 'Unable to save data at this time. Please try again.',
            userFriendlyMessage: 'Unable to save your information right now.',
            canRetry: true,
            suggestedActions: ['Try again in a moment', 'Check your internet connection'],
          );
      }
    }
    
    // Handle other common exceptions
    if (error.toString().contains('network') || error.toString().contains('connection')) {
      return AdvisorErrorInfo(
        type: AdvisorErrorType.networkError,
        title: 'Connection Problem',
        message: 'Unable to connect to the server. Please check your internet connection.',
        userFriendlyMessage: 'Network connection issue - please check your internet.',
        canRetry: true,
        suggestedActions: ['Check your internet connection', 'Try again in a moment'],
      );
    }
    
    if (error.toString().contains('timeout')) {
      return AdvisorErrorInfo(
        type: AdvisorErrorType.timeout,
        title: 'Request Timeout',
        message: 'The request took too long to complete. This might be due to a slow connection.',
        userFriendlyMessage: 'Request timed out - please try again.',
        canRetry: true,
        suggestedActions: ['Try again with a better connection', 'Wait a moment before retrying'],
      );
    }
    
    // Generic error handling
    AppLogger.error('Unhandled advisor system error', error);
    return AdvisorErrorInfo(
      type: AdvisorErrorType.unknown,
      title: 'Unexpected Error',
      message: 'An unexpected error occurred. Our team has been notified.',
      userFriendlyMessage: 'Something went wrong. Please try again or contact support.',
      canRetry: true,
      suggestedActions: ['Try again', 'Contact support if the problem persists'],
    );
  }
  
  /// Show error dialog with appropriate styling and actions
  static Future<void> showErrorDialog({
    required BuildContext context,
    required AdvisorErrorInfo errorInfo,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(errorInfo.type),
              color: _getErrorColor(errorInfo.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorInfo.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _getErrorColor(errorInfo.type),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorInfo.userFriendlyMessage,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (errorInfo.suggestedActions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'What you can do:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...errorInfo.suggestedActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          action,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('Close'),
          ),
          if (errorInfo.canRetry && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Try Again'),
            ),
        ],
      ),
    );
  }
  
  /// Show error snackbar for less critical errors
  static void showErrorSnackBar({
    required BuildContext context,
    required AdvisorErrorInfo errorInfo,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(errorInfo.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(errorInfo.userFriendlyMessage),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(errorInfo.type),
        duration: const Duration(seconds: 6),
        action: errorInfo.canRetry && onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
  
  /// Show loading error state widget
  static Widget buildErrorStateWidget({
    required AdvisorErrorInfo errorInfo,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(errorInfo.type),
              size: 64,
              color: _getErrorColor(errorInfo.type),
            ),
            const SizedBox(height: 24),
            Text(
              errorInfo.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorInfo.userFriendlyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorInfo.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suggestions:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...errorInfo.suggestedActions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $action',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            if (errorInfo.canRetry && onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get appropriate icon for error type
  static IconData _getErrorIcon(AdvisorErrorType type) {
    switch (type) {
      case AdvisorErrorType.networkError:
        return Icons.wifi_off;
      case AdvisorErrorType.timeout:
        return Icons.schedule;
      case AdvisorErrorType.serviceError:
        return Icons.cloud_off;
      case AdvisorErrorType.systemError:
        return Icons.error_outline;
      case AdvisorErrorType.userError:
        return Icons.info_outline;
      case AdvisorErrorType.validationError:
        return Icons.warning;
      case AdvisorErrorType.notFound:
        return Icons.search_off;
      case AdvisorErrorType.expired:
        return Icons.schedule_send;
      case AdvisorErrorType.unknown:
        return Icons.help_outline;
    }
  }
  
  /// Get appropriate color for error type
  static Color _getErrorColor(AdvisorErrorType type) {
    switch (type) {
      case AdvisorErrorType.networkError:
      case AdvisorErrorType.timeout:
      case AdvisorErrorType.serviceError:
      case AdvisorErrorType.systemError:
        return AppTheme.errorRed;
      case AdvisorErrorType.userError:
      case AdvisorErrorType.notFound:
      case AdvisorErrorType.expired:
        return AppTheme.warningAmber;
      case AdvisorErrorType.validationError:
        return AppTheme.warningAmber;
      case AdvisorErrorType.unknown:
        return AppTheme.mutedText;
    }
  }
  
  /// Log error for monitoring and debugging
  static void logError({
    required String context,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final errorData = {
      'context': context,
      'error': error.toString(),
      'type': error.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'additional_data': additionalData,
    };
    
    AppLogger.error('Advisor system error in $context', error, stackTrace);
    AppLogger.info('Error data: $errorData');
  }
}

/// Information about an advisor system error
class AdvisorErrorInfo {
  final AdvisorErrorType type;
  final String title;
  final String message;
  final String userFriendlyMessage;
  final bool canRetry;
  final List<String> suggestedActions;
  
  const AdvisorErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    required this.userFriendlyMessage,
    required this.canRetry,
    this.suggestedActions = const [],
  });
}

/// Types of advisor system errors
enum AdvisorErrorType {
  networkError,
  timeout,
  serviceError,
  systemError,
  userError,
  validationError,
  notFound,
  expired,
  unknown,
}