import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/advisor_invitation.dart';
import '../utils/logger.dart';
import '../screens/advisor/advisor_response_router.dart';

/// Service for handling advisor email invitations
/// Integrates with email providers and generates Australian English content
class AdvisorEmailService {
  static const String _sendGridApiKey = ''; // Add your SendGrid API key
  static const String _fromEmail = 'noreply@wigu.career';
  static const String _fromName = 'Career Insight Platform';
  
  /// Send advisor invitation email
  Future<bool> sendInvitationEmail({
    required AdvisorInvitation invitation,
    required String userName,
    String? userTitle,
    String? companyName,
  }) async {
    try {
      final emailContent = _generateEmailContent(
        invitation: invitation,
        userName: userName,
        userTitle: userTitle,
        companyName: companyName,
      );
      
      final subject = _generateSubject(invitation, userName);
      
      // In production, use actual email service
      if (_sendGridApiKey.isNotEmpty) {
        return await _sendViaSendGrid(
          to: invitation.advisorEmail,
          toName: invitation.advisorName,
          subject: subject,
          htmlContent: emailContent.html,
          textContent: emailContent.text,
        );
      } else {
        // For development/testing, log the email content
        AppLogger.info('EMAIL WOULD BE SENT TO: ${invitation.advisorEmail}');
        AppLogger.info('SUBJECT: $subject');
        AppLogger.info('CONTENT:\n${emailContent.text}');
        return true;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send invitation email', e, stackTrace);
      return false;
    }
  }
  
  /// Generate email subject line
  String _generateSubject(AdvisorInvitation invitation, String userName) {
    switch (invitation.relationshipType) {
      case AdvisorRelationship.manager:
        return 'Career insight request from $userName';
      case AdvisorRelationship.colleague:
        return '$userName has requested your professional perspective';
      case AdvisorRelationship.mentor:
        return 'Career guidance request from $userName';
      case AdvisorRelationship.friend:
        return '$userName would value your career insights';
      case AdvisorRelationship.family:
        return '$userName is exploring career options - your input needed';
      case AdvisorRelationship.client:
        return 'Professional feedback request from $userName';
      case AdvisorRelationship.sponsor:
        return 'Career development input requested by $userName';
      case AdvisorRelationship.peer:
        return 'Peer feedback request from $userName';
      case AdvisorRelationship.other:
        return 'Career insight request from $userName';
    }
  }
  
  /// Generate email content in both HTML and text formats
  EmailContent _generateEmailContent({
    required AdvisorInvitation invitation,
    required String userName,
    String? userTitle,
    String? companyName,
  }) {
    final invitationUrl = AdvisorUrlHelper.generateResponseUrl(invitation.id);
    final greeting = _getGreeting(invitation.relationshipType);
    final relationshipContext = _getRelationshipContext(invitation.relationshipType, userName);
    
    // Generate text content
    final textContent = '''
$greeting ${invitation.advisorName},

$relationshipContext

I'm currently undertaking some career exploration and reflection, and your perspective would be incredibly valuable to me. I've been working through a comprehensive career insight process, and I'd love to understand how you see my strengths, capabilities, and potential career directions.

${invitation.includePersonalMessage && invitation.personalMessage.isNotEmpty ? '${invitation.personalMessage}\n\n' : ''}The process involves answering five thoughtful questions about what you've observed in my work and capabilities. It should take about 10-15 minutes, and your honest insights will help me gain a clearer picture of how others perceive my professional strengths and potential.

You can access the questions here: $invitationUrl

Your input will be kept confidential and used solely to help me better understand my career direction. Thank you so much for taking the time to help me with this important reflection.

With appreciation,
$userName${userTitle != null ? ', $userTitle' : ''}${companyName != null ? '\n$companyName' : ''}

P.S. If you have any questions about this process, please don't hesitate to reach out to me directly.

---

About this invitation:
• This is a secure, confidential feedback process
• Your responses will only be seen by $userName
• The link expires in 30 days
• You can decline the invitation if you're unable to participate

If you cannot access the link above, please contact $userName directly.
''';

    // Generate HTML content
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Career Insight Request</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #4FD1C7, #38B2AC); color: white; padding: 32px 24px; text-align: center; }
        .header h1 { margin: 0; font-size: 24px; font-weight: 600; }
        .header p { margin: 8px 0 0; opacity: 0.9; }
        .content { padding: 32px 24px; }
        .greeting { font-size: 18px; font-weight: 500; color: #2D3748; margin-bottom: 16px; }
        .message { margin-bottom: 24px; }
        .personal-message { background: #EDF2F7; border-left: 4px solid #4FD1C7; padding: 16px; margin: 24px 0; border-radius: 4px; font-style: italic; }
        .cta-button { display: inline-block; background: #4FD1C7; color: white; text-decoration: none; padding: 16px 32px; border-radius: 6px; font-weight: 600; margin: 24px 0; }
        .cta-button:hover { background: #38B2AC; }
        .info-box { background: #F0FFF4; border: 1px solid #68D391; border-radius: 6px; padding: 16px; margin: 24px 0; }
        .info-box h3 { margin: 0 0 12px; color: #2F855A; font-size: 16px; }
        .info-box ul { margin: 8px 0; padding-left: 20px; }
        .info-box li { margin-bottom: 4px; }
        .footer { background: #F7FAFC; padding: 24px; border-top: 1px solid #E2E8F0; font-size: 14px; color: #718096; text-align: center; }
        .signature { margin-top: 32px; padding-top: 16px; border-top: 1px solid #E2E8F0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Career Insight Request</h1>
            <p>Your perspective matters</p>
        </div>
        
        <div class="content">
            <div class="greeting">$greeting ${invitation.advisorName},</div>
            
            <div class="message">
                <p>$relationshipContext</p>
                
                <p>I'm currently undertaking some career exploration and reflection, and your perspective would be incredibly valuable to me. I've been working through a comprehensive career insight process, and I'd love to understand how you see my strengths, capabilities, and potential career directions.</p>
            </div>
            
            ${invitation.includePersonalMessage && invitation.personalMessage.isNotEmpty ? '<div class="personal-message">${invitation.personalMessage.replaceAll('\n', '<br>').replaceAll(RegExp(r'<br>\s*<br>'), '</p><p>')}</div>' : ''}
            
            <div class="message">
                <p>The process involves answering five thoughtful questions about what you've observed in my work and capabilities. It should take about 10-15 minutes, and your honest insights will help me gain a clearer picture of how others perceive my professional strengths and potential.</p>
            </div>
            
            <div style="text-align: center;">
                <a href="$invitationUrl" class="cta-button">Provide Your Insights</a>
            </div>
            
            <div class="info-box">
                <h3>What to expect:</h3>
                <ul>
                    <li><strong>5 thoughtful questions</strong> about my professional capabilities</li>
                    <li><strong>10-15 minutes</strong> to complete at your convenience</li>
                    <li><strong>Secure and confidential</strong> - only I will see your responses</li>
                    <li><strong>Optional anonymity</strong> - you can choose to make your responses anonymous</li>
                </ul>
            </div>
            
            <p>Your input will be kept confidential and used solely to help me better understand my career direction. Thank you so much for taking the time to help me with this important reflection.</p>
            
            <div class="signature">
                <p><strong>With appreciation,</strong><br>
                $userName${userTitle != null ? '<br><em>$userTitle</em>' : ''}${companyName != null ? '<br>$companyName' : ''}</p>
                
                <p><small>P.S. If you have any questions about this process, please don't hesitate to reach out to me directly.</small></p>
            </div>
        </div>
        
        <div class="footer">
            <p><strong>About this invitation:</strong></p>
            <p>This is a secure, confidential feedback process. Your responses will only be seen by $userName. The link expires in 30 days, and you can decline if you're unable to participate.</p>
            <p>If you cannot access the link above, please contact $userName directly.</p>
            <p style="margin-top: 16px; font-size: 12px; opacity: 0.7;">
                Powered by Career Insight Platform • 
                <a href="$invitationUrl" style="color: #4FD1C7;">View Invitation</a>
            </p>
        </div>
    </div>
</body>
</html>
''';

    return EmailContent(
      text: textContent,
      html: htmlContent,
    );
  }
  
  /// Get appropriate greeting based on relationship
  String _getGreeting(AdvisorRelationship relationship) {
    switch (relationship) {
      case AdvisorRelationship.manager:
        return 'Hi';
      case AdvisorRelationship.colleague:
        return 'Hi';
      case AdvisorRelationship.mentor:
        return 'Dear';
      case AdvisorRelationship.friend:
        return 'Hi';
      case AdvisorRelationship.family:
        return 'Hi';
      case AdvisorRelationship.client:
        return 'Dear';
      case AdvisorRelationship.sponsor:
        return 'Dear';
      case AdvisorRelationship.peer:
        return 'Hi';
      case AdvisorRelationship.other:
        return 'Hi';
    }
  }
  
  /// Get relationship context for the invitation
  String _getRelationshipContext(AdvisorRelationship relationship, String userName) {
    switch (relationship) {
      case AdvisorRelationship.manager:
        return 'As my manager, you\'ve had great insight into my work style, strengths, and professional development.';
      case AdvisorRelationship.colleague:
        return 'As a colleague, you\'ve worked alongside me and seen my contributions firsthand.';
      case AdvisorRelationship.mentor:
        return 'You\'ve been such a valuable mentor to me, and your guidance has been instrumental in my professional growth.';
      case AdvisorRelationship.friend:
        return 'You know me well both personally and professionally, which gives you a unique perspective on my capabilities.';
      case AdvisorRelationship.family:
        return 'As someone who knows me so well, you have insights into my natural talents and what motivates me.';
      case AdvisorRelationship.client:
        return 'Working with you as a client has given you visibility into my professional capabilities and approach.';
      case AdvisorRelationship.sponsor:
        return 'Your sponsorship and support of my career has given you valuable insights into my potential and areas for growth.';
      case AdvisorRelationship.peer:
        return 'As a peer in our field, you understand the industry context and have observed my professional contributions.';
      case AdvisorRelationship.other:
        return 'Your perspective on my professional capabilities would be incredibly valuable.';
    }
  }
  
  /// Send email via SendGrid
  Future<bool> _sendViaSendGrid({
    required String to,
    required String toName,
    required String subject,
    required String htmlContent,
    required String textContent,
  }) async {
    final url = 'https://api.sendgrid.com/v3/mail/send';
    
    final payload = {
      'personalizations': [
        {
          'to': [
            {'email': to, 'name': toName}
          ],
          'subject': subject,
        }
      ],
      'from': {'email': _fromEmail, 'name': _fromName},
      'content': [
        {'type': 'text/html', 'value': htmlContent},
        {'type': 'text/plain', 'value': textContent},
      ],
      'tracking_settings': {
        'click_tracking': {'enable': true},
        'open_tracking': {'enable': true},
      },
    };
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 202) {
        AppLogger.info('Email sent successfully to $to');
        return true;
      } else {
        AppLogger.error('Failed to send email: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error sending email via SendGrid', e, stackTrace);
      return false;
    }
  }
  
  /// Send reminder email
  Future<bool> sendReminderEmail({
    required AdvisorInvitation invitation,
    required String userName,
    int reminderNumber = 1,
  }) async {
    final invitationUrl = AdvisorUrlHelper.generateResponseUrl(invitation.id);
    final greeting = _getGreeting(invitation.relationshipType);
    
    final subject = reminderNumber == 1 
        ? 'Gentle reminder: Career insight request from $userName'
        : 'Final reminder: Career insight request from $userName';
    
    final textContent = '''
$greeting ${invitation.advisorName},

I hope this message finds you well. I'm following up on my career insight request from ${invitation.daysSinceSent} days ago.

I completely understand that you're busy, and I don't want to be a bother. However, your perspective would be incredibly valuable to me as I explore my career direction.

If you have just 10-15 minutes in the coming days, I'd be so grateful for your insights:

$invitationUrl

${reminderNumber >= 2 ? 'This will be my final reminder about this request. ' : ''}If you're unable to participate or would prefer not to, that's completely fine too - just let me know and I won't send any more reminders.

Thank you for considering this request.

With appreciation,
$userName
''';

    // For development/testing, log the reminder email
    AppLogger.info('REMINDER EMAIL WOULD BE SENT TO: ${invitation.advisorEmail}');
    AppLogger.info('SUBJECT: $subject');
    AppLogger.info('CONTENT:\n$textContent');
    
    return true; // In production, send via actual email service
  }
}

/// Email content container
class EmailContent {
  final String text;
  final String html;
  
  const EmailContent({
    required this.text,
    required this.html,
  });
}