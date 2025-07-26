import 'package:flutter/material.dart';
import 'advisor_response_form_screen.dart';

/// Router for handling advisor response URLs
/// Provides web-based access to advisor response forms via unique links
class AdvisorResponseRouter extends StatelessWidget {
  final String? invitationId;

  const AdvisorResponseRouter({
    super.key,
    this.invitationId,
  });

  /// Create router from URL path
  /// Expects URLs in format: /advisor-response/{invitationId}
  factory AdvisorResponseRouter.fromPath(String path) {
    final segments = path.split('/');
    String? invitationId;
    
    if (segments.length >= 3 && segments[1] == 'advisor-response') {
      invitationId = segments[2];
    }
    
    return AdvisorResponseRouter(invitationId: invitationId);
  }

  @override
  Widget build(BuildContext context) {
    if (invitationId == null || invitationId!.isEmpty) {
      return _buildInvalidLinkScreen();
    }

    return AdvisorResponseFormScreen(invitationId: invitationId!);
  }

  Widget _buildInvalidLinkScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.link_off,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Invalid Invitation Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This invitation link is invalid or may have expired. Please contact the person who sent you this link for a new one.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.teal,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Need Help?',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If you believe this is an error, please reach out to the person who invited you for assistance.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to help with URL parsing and route generation
extension AdvisorRouting on String {
  /// Check if this URL is an advisor response URL
  bool get isAdvisorResponseUrl {
    return startsWith('/advisor-response/') && split('/').length >= 3;
  }
  
  /// Extract invitation ID from advisor response URL
  String? get invitationIdFromUrl {
    if (!isAdvisorResponseUrl) return null;
    final segments = split('/');
    return segments.length >= 3 ? segments[2] : null;
  }
}

/// Helper class for generating advisor invitation URLs
class AdvisorUrlHelper {
  static const String baseUrl = 'https://wigu.career'; // Production URL
  static const String devBaseUrl = 'http://localhost:3000'; // Development URL
  
  /// Generate full advisor response URL
  static String generateResponseUrl(String invitationId, {bool isDevelopment = false}) {
    final base = isDevelopment ? devBaseUrl : baseUrl;
    return '$base/advisor-response/$invitationId';
  }
  
  /// Generate shareable link text
  static String generateShareableMessage(String invitationId, String advisorName, String userName) {
    final url = generateResponseUrl(invitationId);
    
    return '''Hi $advisorName,

I'm currently exploring my career direction and would really value your perspective on my professional strengths and potential.

Could you please take 10-15 minutes to provide some feedback using this secure link?

$url

Your insights will help me gain a clearer understanding of how others see my capabilities and where I might focus my career development.

Thank you so much for your time and honest feedback.

Best regards,
$userName

---
This link is secure and will expire in 30 days. Your responses will be kept confidential.''';
  }
  
  /// Validate invitation ID format
  static bool isValidInvitationId(String? invitationId) {
    if (invitationId == null || invitationId.isEmpty) return false;
    
    // Check format: invitation_{timestamp}
    final regex = RegExp(r'^invitation_\d{13}$');
    return regex.hasMatch(invitationId);
  }
}