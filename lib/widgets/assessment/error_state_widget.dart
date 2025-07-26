import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Widget for displaying error states in the career assessment flow
/// Provides user-friendly error messages with Australian English
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onGoBack,
    this.icon = Icons.error_outline,
  });

  /// Factory constructor for common AI service errors
  factory ErrorStateWidget.aiServiceError({
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return ErrorStateWidget(
      title: 'AI Service Unavailable',
      message: 'We\'re having trouble connecting to our AI service. Your responses are still being saved, but you might not receive follow-up questions right away.',
      icon: Icons.cloud_off_outlined,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }

  /// Factory constructor for session loading errors
  factory ErrorStateWidget.sessionError({
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return ErrorStateWidget(
      title: 'Session Error',
      message: 'There was a problem loading your assessment session. Your progress has been saved, but you might need to restart.',
      icon: Icons.folder_off_outlined,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }

  /// Factory constructor for network errors
  factory ErrorStateWidget.networkError({
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return ErrorStateWidget(
      title: 'Connection Issues',
      message: 'We\'re having trouble connecting to the internet. Your responses are being saved locally and will sync when you\'re back online.',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }

  /// Factory constructor for validation errors
  factory ErrorStateWidget.validationError({
    String? customMessage,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return ErrorStateWidget(
      title: 'Input Validation',
      message: customMessage ?? 'Please check your response and try again. We need a bit more detail to provide meaningful insights.',
      icon: Icons.edit_off_outlined,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CareerTheme.statusError.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CareerTheme.statusError.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CareerTheme.statusError.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: CareerTheme.statusError,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Error message
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                if (onGoBack != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onGoBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.7),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (onRetry != null) const SizedBox(width: 12),
                ],
                
                if (onRetry != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CareerTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Additional help text
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your progress is automatically saved. You can continue your assessment at any time.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}