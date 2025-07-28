import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_session.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import '../models/advisor_rating.dart';
import 'enhanced_persistence_service.dart';
import 'data_encryption_service.dart';
import '../utils/logger.dart';

/// Local-only data service for career assessment data
/// Provides simple, secure local persistence without cloud synchronization
class LocalDataService {
  final EnhancedPersistenceService _localService;
  final DataEncryptionService _encryptionService;
  
  bool _isInitialized = false;
  
  LocalDataService({
    EnhancedPersistenceService? localService,
    DataEncryptionService? encryptionService,
  }) : _localService = localService ?? EnhancedPersistenceService(),
       _encryptionService = encryptionService ?? DataEncryptionService();

  /// Initialize the local data service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing LocalDataService...');
      
      // Initialize encryption service
      await _encryptionService.initialize();
      
      // Initialize local persistence
      await _localService.initialize();
      
      _isInitialized = true;
      AppLogger.info('LocalDataService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize LocalDataService', e, stackTrace);
      rethrow;
    }
  }

  // Career Session Operations

  /// Save career session
  Future<void> saveCareerSession(CareerSession session) async {
    _ensureInitialized();
    
    try {
      await _localService.saveCareerSession(session);
      AppLogger.debug('Career session saved: ${session.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save career session', e, stackTrace);
      rethrow;
    }
  }

  /// Get career session by ID
  Future<CareerSession?> getCareerSession(String sessionId) async {
    _ensureInitialized();
    
    try {
      return await _localService.getCareerSession(sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get career session', e, stackTrace);
      return null;
    }
  }

  /// Get all career sessions
  Future<List<CareerSession>> getAllCareerSessions() async {
    _ensureInitialized();
    
    try {
      return await _localService.getAllCareerSessions();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get all career sessions', e, stackTrace);
      return [];
    }
  }

  /// Delete career session
  Future<void> deleteCareerSession(String sessionId) async {
    _ensureInitialized();
    
    try {
      await _localService.deleteCareerSession(sessionId);
      AppLogger.info('Career session deleted: $sessionId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete career session', e, stackTrace);
      rethrow;
    }
  }

  // Advisor Invitation Operations

  /// Save advisor invitation
  Future<void> saveAdvisorInvitation(AdvisorInvitation invitation) async {
    _ensureInitialized();
    
    try {
      await _localService.saveAdvisorInvitation(invitation);
      AppLogger.debug('Advisor invitation saved: ${invitation.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor invitation', e, stackTrace);
      rethrow;
    }
  }

  /// Get advisor invitation by ID
  Future<AdvisorInvitation?> getAdvisorInvitation(String invitationId) async {
    _ensureInitialized();
    
    try {
      return await _localService.getAdvisorInvitation(invitationId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor invitation', e, stackTrace);
      return null;
    }
  }

  /// Get advisor invitations for session
  List<AdvisorInvitation> getAdvisorInvitationsForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      return _localService.getAdvisorInvitationsForSession(sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor invitations for session', e, stackTrace);
      return [];
    }
  }

  /// Delete advisor invitation
  Future<void> deleteAdvisorInvitation(String invitationId) async {
    _ensureInitialized();
    
    try {
      await _localService.deleteAdvisorInvitation(invitationId);
      AppLogger.info('Advisor invitation deleted: $invitationId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete advisor invitation', e, stackTrace);
      rethrow;
    }
  }

  // Advisor Response Operations

  /// Save advisor response
  Future<void> saveAdvisorResponse(AdvisorResponse response) async {
    _ensureInitialized();
    
    try {
      await _localService.saveAdvisorResponse(response);
      AppLogger.debug('Advisor response saved: ${response.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor response', e, stackTrace);
      rethrow;
    }
  }

  /// Get advisor responses for invitation
  List<AdvisorResponse> getAdvisorResponsesForInvitation(String invitationId) {
    _ensureInitialized();
    
    try {
      return _localService.getAdvisorResponsesForInvitation(invitationId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor responses for invitation', e, stackTrace);
      return [];
    }
  }

  /// Get advisor responses for session
  List<AdvisorResponse> getAdvisorResponsesForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      return _localService.getAdvisorResponsesForSession(sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get advisor responses for session', e, stackTrace);
      return [];
    }
  }

  // Career Synthesis Operations

  /// Save career synthesis
  Future<void> saveCareerSynthesis(CareerSynthesis synthesis) async {
    _ensureInitialized();
    
    try {
      await _localService.saveCareerSynthesis(synthesis);
      AppLogger.debug('Career synthesis saved: ${synthesis.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save career synthesis', e, stackTrace);
      rethrow;
    }
  }

  /// Get career synthesis for session
  List<CareerSynthesis> getCareerSynthesisForSession(String sessionId) {
    _ensureInitialized();
    
    try {
      return _localService.getCareerSynthesisForSession(sessionId);
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
      await _localService.saveAdvisorRating(rating);
      AppLogger.debug('Advisor rating saved: ${rating.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save advisor rating', e, stackTrace);
      rethrow;
    }
  }

  // Data Export and Backup Operations

  /// Create comprehensive encrypted backup
  Future<Map<String, dynamic>> createCompleteBackup() async {
    _ensureInitialized();
    
    try {
      return await _localService.createCompleteBackup();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create complete backup', e, stackTrace);
      rethrow;
    }
  }

  /// Restore from encrypted backup
  Future<void> restoreFromBackup(Map<String, dynamic> backupData) async {
    _ensureInitialized();
    
    try {
      await _localService.restoreFromCompleteBackup(backupData);
      AppLogger.info('Successfully restored from backup');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore from backup', e, stackTrace);
      rethrow;
    }
  }

  /// Export all career data for GDPR compliance
  Future<Map<String, dynamic>> exportAllUserData() async {
    _ensureInitialized();
    
    try {
      final sessions = await getAllCareerSessions();
      final allData = <String, dynamic>{};
      
      // Export sessions
      allData['career_sessions'] = sessions.map((s) => s.toJson()).toList();
      
      // Export all invitations and responses
      final allInvitations = <Map<String, dynamic>>[];
      final allResponses = <Map<String, dynamic>>[];
      final allSyntheses = <Map<String, dynamic>>[];
      
      for (final session in sessions) {
        final invitations = getAdvisorInvitationsForSession(session.id);
        allInvitations.addAll(invitations.map((i) => i.toJson()));
        
        final responses = getAdvisorResponsesForSession(session.id);
        allResponses.addAll(responses.map((r) => r.toJson()));
        
        final syntheses = getCareerSynthesisForSession(session.id);
        allSyntheses.addAll(syntheses.map((s) => s.toJson()));
      }
      
      allData['advisor_invitations'] = allInvitations;
      allData['advisor_responses'] = allResponses;
      allData['career_syntheses'] = allSyntheses;
      
      // Add metadata
      allData['exported_at'] = DateTime.now().toIso8601String();
      allData['version'] = '2.0';
      allData['stats'] = storageStatistics;
      
      AppLogger.info('Exported all user data for GDPR compliance');
      return allData;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export user data', e, stackTrace);
      rethrow;
    }
  }

  /// Delete all user data for GDPR compliance
  Future<void> deleteAllUserData() async {
    _ensureInitialized();
    
    try {
      // Delete all sessions and associated data
      final sessions = await getAllCareerSessions();
      for (final session in sessions) {
        await deleteCareerSession(session.id);
      }
      
      // Clear encryption keys
      await _encryptionService.clearEncryptionKeys();
      
      AppLogger.info('All user data deleted for GDPR compliance');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete all user data', e, stackTrace);
      rethrow;
    }
  }

  // Utility Methods

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('LocalDataService not initialized');
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get storage statistics
  Map<String, int> get storageStatistics => _localService.getStorageStatistics();

  /// Close the service
  Future<void> close() async {
    try {
      await _localService.close();
      await _encryptionService.close();
      
      _isInitialized = false;
      AppLogger.info('LocalDataService closed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error closing LocalDataService', e, stackTrace);
    }
  }
}

/// Riverpod providers for dependency injection
final localDataServiceProvider = Provider<LocalDataService>((ref) {
  return LocalDataService();
});

final dataServiceProvider = FutureProvider<LocalDataService>((ref) async {
  final service = ref.read(localDataServiceProvider);
  await service.initialize();
  return service;
});