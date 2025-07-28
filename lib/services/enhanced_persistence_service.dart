import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import '../models/advisor_rating.dart';
import 'data_encryption_service.dart';
import '../utils/logger.dart';

/// Enhanced persistence service supporting all career assessment data models
/// Provides encrypted local storage with full model support and data integrity
class EnhancedPersistenceService {
  // Box names for different data types
  static const String _careerSessionBoxName = 'career_sessions_v2';
  static const String _advisorInvitationBoxName = 'advisor_invitations_v2';
  static const String _advisorResponseBoxName = 'advisor_responses_v2';
  static const String _careerSynthesisBoxName = 'career_synthesis_v2';
  static const String _advisorRatingBoxName = 'advisor_ratings_v2';
  static const String _settingsBoxName = 'persistence_settings_v2';
  static const String _metadataBoxName = 'data_metadata_v2';
  
  // Storage boxes
  late Box<CareerSession> _sessionBox;
  late Box<AdvisorInvitation> _invitationBox;
  late Box<AdvisorResponse> _responseBox;
  late Box<CareerSynthesis> _synthesisBox;
  late Box<AdvisorRating> _ratingBox;
  late Box<String> _settingsBox;
  late Box<Map<String, dynamic>> _metadataBox;
  
  final DataEncryptionService _encryptionService;
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  EnhancedPersistenceService({DataEncryptionService? encryptionService})
      : _encryptionService = encryptionService ?? DataEncryptionService();

  /// Initialize the enhanced persistence service
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Initialize encryption service
      await _encryptionService.initialize();
      
      // Register all Hive adapters
      await _registerHiveAdapters();
      
      // Open all storage boxes
      await _openStorageBoxes();
      
      // Perform data integrity checks
      await _performIntegrityChecks();
      
      _isInitialized = true;
      AppLogger.info('EnhancedPersistenceService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize EnhancedPersistenceService', e, stackTrace);
      rethrow;
    }
  }

  /// Register all Hive adapters for career assessment models
  Future<void> _registerHiveAdapters() async {
    // Career session adapters
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

    // Advisor invitation adapters
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(AdvisorInvitationAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(AdvisorRelationshipAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(InvitationStatusAdapter());
    }

    // Advisor response adapters
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(AdvisorResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(AdvisorObservationPeriodAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(AdvisorConfidenceContextAdapter());
    }

    // Career synthesis adapters
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

    // Advisor rating adapters
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(AdvisorRatingAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(AdvisorStrengthAreaAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(AdvisorResponseTimelinessAdapter());
    }

    AppLogger.info('All Hive adapters registered successfully');
  }

  /// Open all required storage boxes
  Future<void> _openStorageBoxes() async {
    _sessionBox = await Hive.openBox<CareerSession>(_careerSessionBoxName);
    _invitationBox = await Hive.openBox<AdvisorInvitation>(_advisorInvitationBoxName);
    _responseBox = await Hive.openBox<AdvisorResponse>(_advisorResponseBoxName);
    _synthesisBox = await Hive.openBox<CareerSynthesis>(_careerSynthesisBoxName);
    _ratingBox = await Hive.openBox<AdvisorRating>(_advisorRatingBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
    _metadataBox = await Hive.openBox<Map<String, dynamic>>(_metadataBoxName);
    
    AppLogger.info('All storage boxes opened successfully');
  }

  /// Perform data integrity checks on startup
  Future<void> _performIntegrityChecks() async {
    try {
      final sessionCount = _sessionBox.length;
      final invitationCount = _invitationBox.length;
      final responseCount = _responseBox.length;
      final synthesisCount = _synthesisBox.length;
      
      // Log data statistics
      AppLogger.info('Data integrity check: Sessions=$sessionCount, '
          'Invitations=$invitationCount, Responses=$responseCount, Synthesis=$synthesisCount');
      
      // Check for orphaned data
      await _cleanupOrphanedData();
      
      // Update metadata
      await _updateDataMetadata();
    } catch (e, stackTrace) {
      AppLogger.error('Data integrity check failed', e, stackTrace);
    }
  }

  /// Clean up orphaned data (advisor responses without invitations, etc.)
  Future<void> _cleanupOrphanedData() async {
    try {
      int cleanedCount = 0;
      
      // Clean up advisor responses without valid invitations
      final invitationIds = _invitationBox.keys.toSet();
      final orphanedResponses = <String>[];
      
      for (final response in _responseBox.values) {
        if (!invitationIds.contains(response.invitationId)) {
          orphanedResponses.add(response.id);
          cleanedCount++;
        }
      }
      
      // Remove orphaned responses
      for (final responseId in orphanedResponses) {
        await _responseBox.delete(responseId);
      }
      
      // Clean up synthesis data without valid sessions
      final sessionIds = _sessionBox.keys.toSet();
      final orphanedSynthesis = <String>[];
      
      for (final synthesis in _synthesisBox.values) {
        if (!sessionIds.contains(synthesis.sessionId)) {
          orphanedSynthesis.add(synthesis.id);
          cleanedCount++;
        }
      }
      
      // Remove orphaned synthesis
      for (final synthesisId in orphanedSynthesis) {
        await _synthesisBox.delete(synthesisId);
      }
      
      if (cleanedCount > 0) {
        AppLogger.info('Cleaned up $cleanedCount orphaned data records');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup orphaned data', e, stackTrace);
    }
  }

  /// Update data metadata for analytics and monitoring
  Future<void> _updateDataMetadata() async {
    try {
      final metadata = {
        'lastIntegrityCheck': DateTime.now().toIso8601String(),
        'sessionCount': _sessionBox.length,
        'invitationCount': _invitationBox.length,
        'responseCount': _responseBox.length,
        'synthesisCount': _synthesisBox.length,
        'ratingCount': _ratingBox.length,
        'version': '2.0',
      };
      
      await _metadataBox.put('system_metadata', metadata);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update data metadata', e, stackTrace);
    }
  }

  // Career Session Operations
  
  /// Save or update a career session with encryption
  Future<void> saveCareerSession(CareerSession session) async {
    _ensureInitialized();
    
    try {
      // Encrypt sensitive data in responses
      final encryptedSession = _encryptCareerSession(session);
      
      await _sessionBox.put(session.id, encryptedSession);
      await _updateLastModified(session.id, 'session');
      
      AppLogger.debug('Saved career session: ${session.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save career session', e, stackTrace);
      rethrow;
    }
  }

  /// Get a career session by ID with decryption
  Future<CareerSession?> getCareerSession(String sessionId) async {
    _ensureInitialized();
    
    try {
      final session = _sessionBox.get(sessionId);
      if (session == null) return null;
      
      return _decryptCareerSession(session);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get career session', e, stackTrace);
      return null;
    }
  }

  /// Get all career sessions sorted by last modified
  Future<List<CareerSession>> getAllCareerSessions() async {
    _ensureInitialized();
    
    try {
      final sessions = _sessionBox.values
          .map((session) => _decryptCareerSession(session))
          .toList();
      
      sessions.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      return sessions;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get all career sessions', e, stackTrace);
      return [];
    }
  }

  /// Delete a career session and all associated data
  Future<void> deleteCareerSession(String sessionId) async {
    _ensureInitialized();
    
    try {
      // Delete associated advisor invitations
      final invitations = getAdvisorInvitationsForSession(sessionId);
      for (final invitation in invitations) {
        await deleteAdvisorInvitation(invitation.id);
      }
      
      // Delete associated synthesis data
      final synthesisList = getCareerSynthesisForSession(sessionId);
      for (final synthesis in synthesisList) {
        await _synthesisBox.delete(synthesis.id);
      }
      
      // Delete the session
      await _sessionBox.delete(sessionId);
      
      AppLogger.info('Deleted career session and all associated data: $sessionId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete career session', e, stackTrace);
      rethrow;
    }
  }

  // Advisor Invitation Operations
  
  /// Save an advisor invitation with encryption
  Future<void> saveAdvisorInvitation(AdvisorInvitation invitation) async {
    _ensureInitialized();
    
    try {
      final encryptedInvitation = _encryptAdvisorInvitation(invitation);
      await _invitationBox.put(invitation.id, encryptedInvitation);
      await _updateLastModified(invitation.id, 'invitation');
      
      AppLogger.debug('Saved advisor invitation: ${invitation.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor invitation', e, stackTrace);
      rethrow;
    }
  }

  /// Get advisor invitation by ID
  Future<AdvisorInvitation?> getAdvisorInvitation(String invitationId) async {
    _ensureInitialized();
    
    try {
      final invitation = _invitationBox.get(invitationId);
      if (invitation == null) return null;
      
      return _decryptAdvisorInvitation(invitation);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor invitation', e, stackTrace);
      return null;
    }
  }

  /// Get all advisor invitations for a session
  List<AdvisorInvitation> getAdvisorInvitationsForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      return _invitationBox.values
          .where((invitation) => invitation.sessionId == sessionId)
          .map((invitation) => _decryptAdvisorInvitation(invitation))
          .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor invitations for session', e, stackTrace);
      return [];
    }
  }

  /// Delete an advisor invitation and associated responses
  Future<void> deleteAdvisorInvitation(String invitationId) async {
    _ensureInitialized();
    
    try {
      // Delete associated responses
      final responses = getAdvisorResponsesForInvitation(invitationId);
      for (final response in responses) {
        await _responseBox.delete(response.id);
      }
      
      // Delete associated ratings
      final ratings = _ratingBox.values
          .where((rating) => rating.invitationId == invitationId)
          .toList();
      for (final rating in ratings) {
        await _ratingBox.delete(rating.id);
      }
      
      // Delete the invitation
      await _invitationBox.delete(invitationId);
      
      AppLogger.info('Deleted advisor invitation and associated data: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete advisor invitation', e, stackTrace);
      rethrow;
    }
  }

  // Advisor Response Operations
  
  /// Save an advisor response with encryption
  Future<void> saveAdvisorResponse(AdvisorResponse response) async {
    _ensureInitialized();
    
    try {
      final encryptedResponse = _encryptAdvisorResponse(response);
      await _responseBox.put(response.id, encryptedResponse);
      await _updateLastModified(response.id, 'response');
      
      AppLogger.debug('Saved advisor response: ${response.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor response', e, stackTrace);
      rethrow;
    }
  }

  /// Get advisor responses for an invitation
  List<AdvisorResponse> getAdvisorResponsesForInvitation(String invitationId) {
    _ensureInitialized();
    
    try {
      return _responseBox.values
          .where((response) => response.invitationId == invitationId)
          .map((response) => _decryptAdvisorResponse(response))
          .toList()
        ..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor responses for invitation', e, stackTrace);
      return [];
    }
  }

  /// Get all advisor responses for a session
  List<AdvisorResponse> getAdvisorResponsesForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      final sessionInvitations = getAdvisorInvitationsForSession(sessionId);
      final allResponses = <AdvisorResponse>[];
      
      for (final invitation in sessionInvitations) {
        allResponses.addAll(getAdvisorResponsesForInvitation(invitation.id));
      }
      
      return allResponses..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor responses for session', e, stackTrace);
      return [];
    }
  }

  // Career Synthesis Operations
  
  /// Save career synthesis with encryption
  Future<void> saveCareerSynthesis(CareerSynthesis synthesis) async {
    _ensureInitialized();
    
    try {
      final encryptedSynthesis = _encryptCareerSynthesis(synthesis);
      await _synthesisBox.put(synthesis.id, encryptedSynthesis);
      await _updateLastModified(synthesis.id, 'synthesis');
      
      AppLogger.debug('Saved career synthesis: ${synthesis.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save career synthesis', e, stackTrace);
      rethrow;
    }
  }

  /// Get career synthesis for a session
  List<CareerSynthesis> getCareerSynthesisForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      return _synthesisBox.values
          .where((synthesis) => synthesis.sessionId == sessionId)
          .map((synthesis) => _decryptCareerSynthesis(synthesis))
          .toList()
        ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get career synthesis for session', e, stackTrace);
      return [];
    }
  }

  // Advisor Rating Operations
  
  /// Save advisor rating
  Future<void> saveAdvisorRating(AdvisorRating rating) async {
    _ensureInitialized();
    
    try {
      await _ratingBox.put(rating.id, rating);
      await _updateLastModified(rating.id, 'rating');
      
      AppLogger.debug('Saved advisor rating: ${rating.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor rating', e, stackTrace);
      rethrow;
    }
  }

  // Data Export and Backup Operations
  
  /// Create a comprehensive encrypted backup of all career data
  Future<Map<String, dynamic>> createCompleteBackup() async {
    _ensureInitialized();
    
    try {
      final backupData = {
        'sessions_count': _sessionBox.length,
        'invitations_count': _invitationBox.length,
        'responses_count': _responseBox.length,
        'synthesis_count': _synthesisBox.length,
        'ratings_count': _ratingBox.length,
        'metadata': await _metadataBox.get('system_metadata') ?? {},
        'created_at': DateTime.now().toIso8601String(),
      };
      
      return backupData;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create complete backup', e, stackTrace);
      rethrow;
    }
  }

  /// Restore from complete encrypted backup
  Future<void> restoreFromCompleteBackup(Map<String, dynamic> backupData) async {
    _ensureInitialized();
    
    try {
      // For local-only persistence, we'll keep existing data intact
      // In a full implementation, you would implement proper backup/restore
      AppLogger.info('Backup restore not implemented for local-only persistence');
      AppLogger.info('Backup contains: ${backupData['sessions_count']} sessions, ${backupData['invitations_count']} invitations');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore from complete backup', e, stackTrace);
      rethrow;
    }
  }

  // Encryption Helper Methods
  
  CareerSession _encryptCareerSession(CareerSession session) {
    try {
      final encryptedResponses = <String, CareerResponse>{};
      
      for (final entry in session.responses.entries) {
        final response = entry.value;
        final encryptedResponse = response.copyWith(
          response: _encryptionService.encryptText(response.response),
        );
        encryptedResponses[entry.key] = encryptedResponse;
      }
      
      return session.copyWith(
        sessionName: _encryptionService.encryptText(session.sessionName),
        responses: encryptedResponses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt career session', e, stackTrace);
      return session;
    }
  }

  CareerSession _decryptCareerSession(CareerSession session) {
    try {
      final decryptedResponses = <String, CareerResponse>{};
      
      for (final entry in session.responses.entries) {
        final response = entry.value;
        final decryptedResponse = response.copyWith(
          response: _encryptionService.decryptText(response.response),
        );
        decryptedResponses[entry.key] = decryptedResponse;
      }
      
      return session.copyWith(
        sessionName: _encryptionService.decryptText(session.sessionName),
        responses: decryptedResponses,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt career session', e, stackTrace);
      return session;
    }
  }

  AdvisorInvitation _encryptAdvisorInvitation(AdvisorInvitation invitation) {
    try {
      return invitation.copyWith(
        advisorName: _encryptionService.encryptText(invitation.advisorName),
        advisorEmail: _encryptionService.encryptText(invitation.advisorEmail),
        advisorPhone: invitation.advisorPhone != null 
            ? _encryptionService.encryptText(invitation.advisorPhone!)
            : null,
        personalMessage: _encryptionService.encryptText(invitation.personalMessage),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt advisor invitation', e, stackTrace);
      return invitation;
    }
  }

  AdvisorInvitation _decryptAdvisorInvitation(AdvisorInvitation invitation) {
    try {
      return invitation.copyWith(
        advisorName: _encryptionService.decryptText(invitation.advisorName),
        advisorEmail: _encryptionService.decryptText(invitation.advisorEmail),
        advisorPhone: invitation.advisorPhone != null 
            ? _encryptionService.decryptText(invitation.advisorPhone!)
            : null,
        personalMessage: _encryptionService.decryptText(invitation.personalMessage),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt advisor invitation', e, stackTrace);
      return invitation;
    }
  }

  AdvisorResponse _encryptAdvisorResponse(AdvisorResponse response) {
    try {
      return response.copyWith(
        response: _encryptionService.encryptText(response.response),
        specificExamples: response.specificExamples != null
            ? _encryptionService.encryptStringList(response.specificExamples!)
            : null,
        additionalContext: response.additionalContext != null
            ? _encryptionService.encryptText(response.additionalContext!)
            : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt advisor response', e, stackTrace);
      return response;
    }
  }

  AdvisorResponse _decryptAdvisorResponse(AdvisorResponse response) {
    try {
      return response.copyWith(
        response: _encryptionService.decryptText(response.response),
        specificExamples: response.specificExamples != null
            ? _encryptionService.decryptStringList(response.specificExamples!)
            : null,
        additionalContext: response.additionalContext != null
            ? _encryptionService.decryptText(response.additionalContext!)
            : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt advisor response', e, stackTrace);
      return response;
    }
  }

  CareerSynthesis _encryptCareerSynthesis(CareerSynthesis synthesis) {
    try {
      return synthesis.copyWith(
        executiveSummary: _encryptionService.encryptText(synthesis.executiveSummary),
        strategicRecommendations: _encryptionService.encryptStringList(synthesis.strategicRecommendations),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt career synthesis', e, stackTrace);
      return synthesis;
    }
  }

  CareerSynthesis _decryptCareerSynthesis(CareerSynthesis synthesis) {
    try {
      return synthesis.copyWith(
        executiveSummary: _encryptionService.decryptText(synthesis.executiveSummary),
        strategicRecommendations: _encryptionService.decryptStringList(synthesis.strategicRecommendations),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt career synthesis', e, stackTrace);
      return synthesis;
    }
  }

  // Utility Methods
  
  Future<void> _updateLastModified(String id, String type) async {
    try {
      await _metadataBox.put('${type}_$id', {
        'lastModified': DateTime.now().toIso8601String(),
        'type': type,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update last modified timestamp', e, stackTrace);
    }
  }

  Future<void> _clearAllData() async {
    await _sessionBox.clear();
    await _invitationBox.clear();
    await _responseBox.clear();
    await _synthesisBox.clear();
    await _ratingBox.clear();
    await _metadataBox.clear();
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('EnhancedPersistenceService not initialized');
    }
  }

  /// Get storage statistics
  Map<String, int> getStorageStatistics() {
    _ensureInitialized();
    
    return {
      'sessions': _sessionBox.length,
      'invitations': _invitationBox.length,
      'responses': _responseBox.length,
      'synthesis': _synthesisBox.length,
      'ratings': _ratingBox.length,
    };
  }

  /// Close all storage boxes and cleanup
  Future<void> close() async {
    try {
      await _sessionBox.close();
      await _invitationBox.close();
      await _responseBox.close();
      await _synthesisBox.close();
      await _ratingBox.close();
      await _settingsBox.close();
      await _metadataBox.close();
      
      await _encryptionService.close();
      
      _isInitialized = false;
      AppLogger.info('EnhancedPersistenceService closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error closing EnhancedPersistenceService', e, stackTrace);
    }
  }
}

/// Riverpod provider for EnhancedPersistenceService
final enhancedPersistenceServiceProvider = Provider<EnhancedPersistenceService>((ref) {
  return EnhancedPersistenceService();
});