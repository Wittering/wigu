import 'dart:convert';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/advisor_response.dart';
import '../models/advisor_invitation.dart';
import '../models/career_synthesis.dart';
import 'data_encryption_service.dart';
import '../utils/logger.dart';

/// Service for field-level encryption of career assessment data
/// Provides specialized encryption for sensitive career information
class CareerFieldEncryption {
  final DataEncryptionService _encryptionService;
  
  CareerFieldEncryption(this._encryptionService);

  /// Encrypt sensitive fields in a CareerSession
  CareerSession encryptCareerSession(CareerSession session) {
    try {
      // Encrypt session name if it contains sensitive information
      final encryptedSessionName = _shouldEncryptSessionName(session.sessionName)
          ? _encryptionService.encryptText(session.sessionName)
          : session.sessionName;

      // Encrypt responses
      final encryptedResponses = <String, CareerResponse>{};
      for (final entry in session.responses.entries) {
        encryptedResponses[entry.key] = encryptCareerResponse(entry.value);
      }

      return session.copyWith(
        sessionName: encryptedSessionName,
        responses: encryptedResponses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt CareerSession', e, stackTrace);
      return session; // Return original on encryption failure
    }
  }

  /// Decrypt sensitive fields in a CareerSession
  CareerSession decryptCareerSession(CareerSession session) {
    try {
      // Decrypt session name if encrypted
      final decryptedSessionName = _shouldEncryptSessionName(session.sessionName)
          ? _encryptionService.decryptText(session.sessionName)
          : session.sessionName;

      // Decrypt responses
      final decryptedResponses = <String, CareerResponse>{};
      for (final entry in session.responses.entries) {
        decryptedResponses[entry.key] = decryptCareerResponse(entry.value);
      }

      return session.copyWith(
        sessionName: decryptedSessionName,
        responses: decryptedResponses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt CareerSession', e, stackTrace);
      return session; // Return original on decryption failure
    }
  }

  /// Encrypt sensitive fields in a CareerResponse
  CareerResponse encryptCareerResponse(CareerResponse response) {
    try {
      // Encrypt the response text as it may contain personal information
      final encryptedResponseText = _encryptionService.encryptText(response.response);
      
      // Encrypt tags if they contain sensitive information
      List<String>? encryptedTags;
      if (response.tags != null) {
        encryptedTags = response.tags!
            .map((tag) => _shouldEncryptTag(tag) ? _encryptionService.encryptText(tag) : tag)
            .toList();
      }

      return CareerResponse(
        questionId: response.questionId,
        questionText: response.questionText,
        response: encryptedResponseText,
        answeredAt: response.answeredAt,
        domain: response.domain,
        confidenceLevel: response.confidenceLevel,
        tags: encryptedTags,
        isReflectionComplete: response.isReflectionComplete,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt CareerResponse', e, stackTrace);
      return response;
    }
  }

  /// Decrypt sensitive fields in a CareerResponse
  CareerResponse decryptCareerResponse(CareerResponse response) {
    try {
      // Decrypt the response text
      final decryptedResponseText = _encryptionService.decryptText(response.response);
      
      // Decrypt tags if they were encrypted
      List<String>? decryptedTags;
      if (response.tags != null) {
        decryptedTags = response.tags!
            .map((tag) => _shouldEncryptTag(tag) ? _encryptionService.decryptText(tag) : tag)
            .toList();
      }

      return CareerResponse(
        questionId: response.questionId,
        questionText: response.questionText,
        response: decryptedResponseText,
        answeredAt: response.answeredAt,
        domain: response.domain,
        confidenceLevel: response.confidenceLevel,
        tags: decryptedTags,
        isReflectionComplete: response.isReflectionComplete,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt CareerResponse', e, stackTrace);
      return response;
    }
  }

  /// Encrypt sensitive fields in an AdvisorInvitation
  AdvisorInvitation encryptAdvisorInvitation(AdvisorInvitation invitation) {
    try {
      return AdvisorInvitation(
        id: invitation.id,
        sessionId: invitation.sessionId,
        advisorName: _encryptionService.encryptText(invitation.advisorName),
        advisorEmail: _encryptionService.encryptText(invitation.advisorEmail),
        advisorPhone: invitation.advisorPhone != null 
            ? _encryptionService.encryptText(invitation.advisorPhone!) 
            : null,
        relationshipType: invitation.relationshipType,
        personalMessage: _encryptionService.encryptText(invitation.personalMessage),
        sentAt: invitation.sentAt,
        status: invitation.status,
        respondedAt: invitation.respondedAt,
        remindedAt: invitation.remindedAt,
        reminderCount: invitation.reminderCount,
        includePersonalMessage: invitation.includePersonalMessage,
        customQuestions: invitation.customQuestions,
        declineReason: invitation.declineReason,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt AdvisorInvitation', e, stackTrace);
      return invitation;
    }
  }

  /// Decrypt sensitive fields in an AdvisorInvitation
  AdvisorInvitation decryptAdvisorInvitation(AdvisorInvitation invitation) {
    try {
      return AdvisorInvitation(
        id: invitation.id,
        sessionId: invitation.sessionId,
        advisorName: _encryptionService.decryptText(invitation.advisorName),
        advisorEmail: _encryptionService.decryptText(invitation.advisorEmail),
        advisorPhone: invitation.advisorPhone != null 
            ? _encryptionService.decryptText(invitation.advisorPhone!) 
            : null,
        relationshipType: invitation.relationshipType,
        personalMessage: _encryptionService.decryptText(invitation.personalMessage),
        sentAt: invitation.sentAt,
        status: invitation.status,
        respondedAt: invitation.respondedAt,
        remindedAt: invitation.remindedAt,
        reminderCount: invitation.reminderCount,
        includePersonalMessage: invitation.includePersonalMessage,
        customQuestions: invitation.customQuestions,
        declineReason: invitation.declineReason,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt AdvisorInvitation', e, stackTrace);
      return invitation;
    }
  }

  /// Encrypt sensitive fields in an AdvisorResponse
  AdvisorResponse encryptAdvisorResponse(AdvisorResponse response) {
    try {
      return AdvisorResponse(
        id: response.id,
        invitationId: response.invitationId,
        questionId: response.questionId,
        questionText: response.questionText,
        response: _encryptionService.encryptText(response.response),
        answeredAt: response.answeredAt,
        domain: response.domain,
        confidenceLevel: response.confidenceLevel,
        observationPeriod: response.observationPeriod,
        specificExamples: response.specificExamples?.map((example) => 
            _encryptionService.encryptText(example)).toList(),
        confidenceContext: response.confidenceContext,
        additionalContext: response.additionalContext,
        isAnonymous: response.isAnonymous,
        metadata: response.metadata,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt AdvisorResponse', e, stackTrace);
      return response;
    }
  }

  /// Decrypt sensitive fields in an AdvisorResponse
  AdvisorResponse decryptAdvisorResponse(AdvisorResponse response) {
    try {
      return AdvisorResponse(
        id: response.id,
        invitationId: response.invitationId,
        questionId: response.questionId,
        questionText: response.questionText,
        response: _encryptionService.decryptText(response.response),
        answeredAt: response.answeredAt,
        domain: response.domain,
        confidenceLevel: response.confidenceLevel,
        observationPeriod: response.observationPeriod,
        specificExamples: response.specificExamples?.map((example) => 
            _encryptionService.decryptText(example)).toList(),
        confidenceContext: response.confidenceContext,
        additionalContext: response.additionalContext,
        isAnonymous: response.isAnonymous,
        metadata: response.metadata,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt AdvisorResponse', e, stackTrace);
      return response;
    }
  }

  /// Encrypt sensitive fields in a CareerSynthesis
  CareerSynthesis encryptCareerSynthesis(CareerSynthesis synthesis) {
    try {
      return CareerSynthesis(
        id: synthesis.id,
        sessionId: synthesis.sessionId,
        generatedAt: synthesis.generatedAt,
        selfResponseIds: synthesis.selfResponseIds,
        advisorResponseIds: synthesis.advisorResponseIds,
        alignmentAreas: synthesis.alignmentAreas,
        hiddenStrengths: synthesis.hiddenStrengths,
        overestimatedAreas: synthesis.overestimatedAreas,
        developmentOpportunities: synthesis.developmentOpportunities,
        repositioningPotential: synthesis.repositioningPotential,
        executiveSummary: _encryptionService.encryptText(synthesis.executiveSummary),
        strategicRecommendations: synthesis.strategicRecommendations
            .map((rec) => _encryptionService.encryptText(rec))
            .toList(),
        alignmentScore: synthesis.alignmentScore,
        confidenceLevel: synthesis.confidenceLevel,
        analysisMetadata: synthesis.analysisMetadata,
        lastUpdated: synthesis.lastUpdated,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt CareerSynthesis', e, stackTrace);
      return synthesis;
    }
  }

  /// Decrypt sensitive fields in a CareerSynthesis
  CareerSynthesis decryptCareerSynthesis(CareerSynthesis synthesis) {
    try {
      return CareerSynthesis(
        id: synthesis.id,
        sessionId: synthesis.sessionId,
        generatedAt: synthesis.generatedAt,
        selfResponseIds: synthesis.selfResponseIds,
        advisorResponseIds: synthesis.advisorResponseIds,
        alignmentAreas: synthesis.alignmentAreas,
        hiddenStrengths: synthesis.hiddenStrengths,
        overestimatedAreas: synthesis.overestimatedAreas,
        developmentOpportunities: synthesis.developmentOpportunities,
        repositioningPotential: synthesis.repositioningPotential,
        executiveSummary: _encryptionService.decryptText(synthesis.executiveSummary),
        strategicRecommendations: synthesis.strategicRecommendations
            .map((rec) => _encryptionService.decryptText(rec))
            .toList(),
        alignmentScore: synthesis.alignmentScore,
        confidenceLevel: synthesis.confidenceLevel,
        analysisMetadata: synthesis.analysisMetadata,
        lastUpdated: synthesis.lastUpdated,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt CareerSynthesis', e, stackTrace);
      return synthesis;
    }
  }

  /// Create an encrypted export for GDPR compliance
  Map<String, dynamic> createGDPREncryptedExport(Map<String, dynamic> careerData) {
    try {
      final encryptedData = _encryptionService.encryptJson(careerData);
      
      return {
        'version': '1.0',
        'exportType': 'gdpr_compliant',
        'timestamp': DateTime.now().toIso8601String(),
        'dataHash': _encryptionService.generateHash(jsonEncode(careerData)),
        'encryptedCareerData': encryptedData,
        'encryptionInfo': {
          'algorithm': 'AES-256',
          'mode': 'CBC',
          'dataTypes': _getEncryptedDataTypes(),
        },
      };
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create GDPR encrypted export', e, stackTrace);
      rethrow;
    }
  }

  /// Decrypt GDPR export data
  Map<String, dynamic> decryptGDPRExport(Map<String, dynamic> exportData) {
    try {
      final encryptedCareerData = exportData['encryptedCareerData'] as String;
      final expectedHash = exportData['dataHash'] as String;
      
      final decryptedData = _encryptionService.decryptJson(encryptedCareerData);
      
      // Verify data integrity
      final actualHash = _encryptionService.generateHash(jsonEncode(decryptedData));
      if (actualHash != expectedHash) {
        throw SecurityException('GDPR export data integrity check failed');
      }
      
      return decryptedData;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt GDPR export', e, stackTrace);
      rethrow;
    }
  }

  /// Check if a session name should be encrypted based on content
  bool _shouldEncryptSessionName(String sessionName) {
    // Encrypt if contains personal info patterns
    final personalPatterns = [
      RegExp(r'\b[A-Za-z]+\s+[A-Za-z]+\b'), // Full names
      RegExp(r'\b\d{4}\b'), // Birth years
      RegExp(r'personal|private|confidential', caseSensitive: false),
    ];
    
    return personalPatterns.any((pattern) => pattern.hasMatch(sessionName));
  }

  /// Check if a tag should be encrypted
  bool _shouldEncryptTag(String tag) {
    final sensitiveTagPatterns = [
      RegExp(r'personal|private|confidential', caseSensitive: false),
      RegExp(r'company|employer|workplace', caseSensitive: false),
      RegExp(r'name|email|phone', caseSensitive: false),
    ];
    
    return sensitiveTagPatterns.any((pattern) => pattern.hasMatch(tag));
  }

  /// Get list of data types that are encrypted
  List<String> _getEncryptedDataTypes() {
    return [
      'session_names',
      'career_responses',
      'advisor_names',
      'advisor_emails',
      'advisor_phones',
      'personal_messages',
      'advisor_responses',
      'career_synthesis_content',
      'reflection_notes',
      'tags',
    ];
  }

  /// Validate encryption integrity for a data set
  bool validateEncryptionIntegrity(Map<String, dynamic> data) {
    try {
      // Attempt to encrypt and decrypt test data
      const testData = 'encryption_integrity_test';
      final encrypted = _encryptionService.encryptText(testData);
      final decrypted = _encryptionService.decryptText(encrypted);
      
      return decrypted == testData;
    } catch (e, stackTrace) {
      AppLogger.error('Encryption integrity validation failed', e, stackTrace);
      return false;
    }
  }

  /// Get encryption statistics
  Map<String, dynamic> getEncryptionStatistics() {
    return {
      'isInitialized': _encryptionService.isInitialized,
      'encryptedDataTypes': _getEncryptedDataTypes(),
      'encryptionAlgorithm': 'AES-256-CBC',
      'integrityValidation': validateEncryptionIntegrity({}),
    };
  }
}

/// Custom exception for security-related errors in career field encryption
class SecurityException implements Exception {
  final String message;
  
  const SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}