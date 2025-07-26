import 'dart:math';
import 'dart:convert';
import '../models/advisor_invitation.dart';
import '../utils/logger.dart';

/// Security utilities for advisor invitation system
/// Provides rate limiting, validation, and protection against abuse
class AdvisorSecurity {
  static const int _maxInvitationsPerHour = 10;
  static const int _maxInvitationsPerDay = 20;
  static const int _maxResponseAttemptsPerHour = 5;
  static const Duration _invitationExpiry = Duration(days: 30);
  static const Duration _rateLimitWindow = Duration(hours: 1);
  
  // Rate limiting storage (in production, use Redis or database)
  static final Map<String, List<DateTime>> _invitationAttempts = {};
  static final Map<String, List<DateTime>> _responseAttempts = {};
  
  /// Validate invitation creation request
  static SecurityValidationResult validateInvitationCreation({
    required String sessionId,
    required String advisorEmail,
    required String userIpAddress,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Rate limiting by IP address
    final rateLimitResult = checkInvitationRateLimit(userIpAddress);
    if (!rateLimitResult.allowed) {
      errors.add('Too many invitation attempts. Please wait before sending more invitations.');
      return SecurityValidationResult(
        isValid: false,
        errors: errors,
        warnings: warnings,
      );
    }
    
    // Email validation
    if (!_isValidEmail(advisorEmail)) {
      errors.add('Invalid email address format');
    }
    
    // Check for suspicious patterns
    final suspiciousResult = _checkSuspiciousPatterns(advisorEmail, userIpAddress);
    warnings.addAll(suspiciousResult.warnings);
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Check rate limits for invitation creation
  static RateLimitResult checkInvitationRateLimit(String ipAddress) {
    final now = DateTime.now();
    final attempts = _invitationAttempts[ipAddress] ?? [];
    
    // Clean old attempts
    attempts.removeWhere((attempt) => now.difference(attempt) > _rateLimitWindow);
    
    // Check hourly limit
    if (attempts.length >= _maxInvitationsPerHour) {
      return RateLimitResult(
        allowed: false,
        remainingAttempts: 0,
        resetTime: attempts.first.add(_rateLimitWindow),
      );
    }
    
    // Record this attempt
    attempts.add(now);
    _invitationAttempts[ipAddress] = attempts;
    
    return RateLimitResult(
      allowed: true,
      remainingAttempts: _maxInvitationsPerHour - attempts.length,
      resetTime: now.add(_rateLimitWindow),
    );
  }
  
  /// Check rate limits for response submission
  static RateLimitResult checkResponseRateLimit(String ipAddress) {
    final now = DateTime.now();
    final attempts = _responseAttempts[ipAddress] ?? [];
    
    // Clean old attempts
    attempts.removeWhere((attempt) => now.difference(attempt) > _rateLimitWindow);
    
    // Check hourly limit
    if (attempts.length >= _maxResponseAttemptsPerHour) {
      return RateLimitResult(
        allowed: false,
        remainingAttempts: 0,
        resetTime: attempts.first.add(_rateLimitWindow),
      );
    }
    
    // Record this attempt
    attempts.add(now);
    _responseAttempts[ipAddress] = attempts;
    
    return RateLimitResult(
      allowed: true,
      remainingAttempts: _maxResponseAttemptsPerHour - attempts.length,
      resetTime: now.add(_rateLimitWindow),
    );
  }
  
  /// Validate advisor response access
  static SecurityValidationResult validateResponseAccess({
    required String invitationId,
    required String? userAgent,
    required String ipAddress,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validate invitation ID format
    if (!_isValidInvitationId(invitationId)) {
      errors.add('Invalid invitation link format');
      AppLogger.warning('Invalid invitation ID attempted: $invitationId from IP: $ipAddress');
    }
    
    // Check for bot access
    if (_isPotentialBot(userAgent)) {
      warnings.add('Potential automated access detected');
      AppLogger.warning('Potential bot access to invitation $invitationId from IP: $ipAddress');
    }
    
    // Rate limiting
    final rateLimitResult = checkResponseRateLimit(ipAddress);
    if (!rateLimitResult.allowed) {
      errors.add('Too many response attempts. Please wait before trying again.');
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Validate advisor response content
  static SecurityValidationResult validateResponseContent({
    required Map<String, String> responses,
    required String ipAddress,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Check for spam patterns
    for (final entry in responses.entries) {
      final response = entry.value;
      
      if (_containsSpamPatterns(response)) {
        warnings.add('Response contains potential spam patterns');
        AppLogger.warning('Spam patterns detected in response from IP: $ipAddress');
      }
      
      if (_isLikelyGenerated(response)) {
        warnings.add('Response may be AI-generated');
        AppLogger.warning('Potentially AI-generated response from IP: $ipAddress');
      }
      
      if (response.length > 2000) {
        warnings.add('Response is unusually long');
      }
    }
    
    return SecurityValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Generate secure invitation token
  static String generateSecureToken() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = <int>[];
    
    for (int i = 0; i < 16; i++) {
      randomBytes.add(random.nextInt(256));
    }
    
    final tokenData = '$timestamp-${base64Encode(randomBytes)}';
    // Use a simple hash instead of SHA256 to avoid crypto dependency
    final hashCode = tokenData.hashCode.abs().toString().padLeft(16, '0').substring(0, 16);
    
    return 'invitation_${timestamp}_$hashCode';
  }
  
  /// Validate invitation hasn't expired
  static bool isInvitationValid(AdvisorInvitation invitation) {
    final now = DateTime.now();
    final expiryDate = invitation.sentAt.add(_invitationExpiry);
    
    return now.isBefore(expiryDate) && 
           invitation.status != InvitationStatus.expired &&
           invitation.status != InvitationStatus.declined;
  }
  
  /// Sanitise user input
  static String sanitiseInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s\.,!?@-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' '); // Normalise whitespace
  }
  
  /// Check for suspicious patterns
  static SecurityValidationResult _checkSuspiciousPatterns(String email, String ipAddress) {
    final warnings = <String>[];
    
    // Check for disposable email domains
    final disposableDomains = [
      'tempmail.org', '10minutemail.com', 'guerrillamail.com',
      'mailinator.com', 'throwaway.email', 'temp-mail.org'
    ];
    
    final emailDomain = email.split('@').last.toLowerCase();
    if (disposableDomains.contains(emailDomain)) {
      warnings.add('Disposable email domain detected');
      AppLogger.warning('Disposable email domain used: $emailDomain from IP: $ipAddress');
    }
    
    // Check for suspicious email patterns
    if (RegExp(r'^[a-z]+\d+@').hasMatch(email.toLowerCase())) {
      warnings.add('Potentially automated email pattern');
    }
    
    return SecurityValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }
  
  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }
  
  /// Validate invitation ID format
  static bool _isValidInvitationId(String invitationId) {
    final regex = RegExp(r'^invitation_\d{13}_[a-f0-9]{16}$');
    return regex.hasMatch(invitationId);
  }
  
  /// Check if user agent suggests a bot
  static bool _isPotentialBot(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) return true;
    
    final botPatterns = [
      'bot', 'crawler', 'spider', 'scraper', 'curl', 'wget',
      'python-requests', 'urllib', 'axios', 'postman'
    ];
    
    final lowerUserAgent = userAgent.toLowerCase();
    return botPatterns.any((pattern) => lowerUserAgent.contains(pattern));
  }
  
  /// Check for spam patterns in text
  static bool _containsSpamPatterns(String text) {
    final spamPatterns = [
      RegExp(r'https?://\S+'), // URLs
      RegExp(r'\b(?:viagra|cialis|pharmacy|casino|bitcoin|crypto)\b', caseSensitive: false),
      RegExp(r'\b(?:click here|visit now|buy now|free money)\b', caseSensitive: false),
      RegExp(r'(.)\1{10,}'), // Repeated characters
    ];
    
    return spamPatterns.any((pattern) => pattern.hasMatch(text));
  }
  
  /// Check if text is likely AI-generated
  static bool _isLikelyGenerated(String text) {
    final aiPatterns = [
      'as an ai', 'i am an artificial', 'as a language model',
      'i cannot provide', 'i apologize, but i cannot',
      'generated response', 'artificial intelligence',
    ];
    
    final lowerText = text.toLowerCase();
    return aiPatterns.any((pattern) => lowerText.contains(pattern));
  }
  
  /// Log security event
  static void logSecurityEvent({
    required String eventType,
    required String description,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'event_type': eventType,
      'description': description,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'metadata': metadata,
    };
    
    AppLogger.warning('SECURITY_EVENT: ${jsonEncode(logData)}');
  }
}

/// Result of security validation
class SecurityValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const SecurityValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Result of rate limiting check
class RateLimitResult {
  final bool allowed;
  final int remainingAttempts;
  final DateTime resetTime;
  
  const RateLimitResult({
    required this.allowed,
    required this.remainingAttempts,
    required this.resetTime,
  });
  
  Duration get timeUntilReset => resetTime.difference(DateTime.now());
}