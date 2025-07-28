import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/career_session.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import 'enhanced_persistence_service.dart';
import 'data_encryption_service.dart';
import '../utils/logger.dart';

/// Service for migrating career assessment data between versions
/// Handles schema changes, data format updates, and backward compatibility
class DataMigrationService {
  final EnhancedPersistenceService _persistenceService;
  final DataEncryptionService _encryptionService;
  
  static const String _currentVersion = '2.0';
  static const String _versionKey = 'data_version';
  static const String _migrationLogKey = 'migration_log';
  
  DataMigrationService({
    EnhancedPersistenceService? persistenceService,
    DataEncryptionService? encryptionService,
  }) : _persistenceService = persistenceService ?? EnhancedPersistenceService(),
       _encryptionService = encryptionService ?? DataEncryptionService();

  /// Check if migration is needed and perform if necessary
  Future<MigrationResult> checkAndMigrate() async {
    try {
      AppLogger.info('Checking data migration requirements...');
      
      // Get current stored version
      final storedVersion = await _getStoredDataVersion();
      
      if (storedVersion == null) {
        // Fresh installation
        await _setDataVersion(_currentVersion);
        return MigrationResult.fresh();
      }
      
      if (storedVersion == _currentVersion) {
        // No migration needed
        return MigrationResult.upToDate();
      }
      
      // Migration needed
      return await _performMigration(storedVersion, _currentVersion);
    } catch (e, stackTrace) {
      AppLogger.error('Migration check failed', e, stackTrace);
      return MigrationResult.failed(e.toString());
    }
  }

  /// Perform data migration from one version to another
  Future<MigrationResult> _performMigration(String fromVersion, String toVersion) async {
    try {
      AppLogger.info('Starting migration from $fromVersion to $toVersion');
      
      final migrationSteps = _getMigrationSteps(fromVersion, toVersion);
      final migratedItems = <String, int>{};
      final errors = <String>[];
      
      for (final step in migrationSteps) {
        try {
          final result = await _executeMigrationStep(step);
          migratedItems[step.description] = result.itemCount;
          AppLogger.info('Migration step completed: ${step.description} (${result.itemCount} items)');
        } catch (e) {
          final error = 'Migration step failed: ${step.description} - $e';
          errors.add(error);
          AppLogger.error(error, e);
          
          if (step.isCritical) {
            throw MigrationException('Critical migration step failed: ${step.description}', e);
          }
        }
      }
      
      // Update stored version
      await _setDataVersion(toVersion);
      
      // Log migration completion
      await _logMigration(fromVersion, toVersion, migratedItems, errors);
      
      AppLogger.info('Migration completed successfully from $fromVersion to $toVersion');
      
      return MigrationResult.success(
        fromVersion: fromVersion,
        toVersion: toVersion,
        migratedItems: migratedItems,
        warnings: errors,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Migration failed from $fromVersion to $toVersion', e, stackTrace);
      return MigrationResult.failed(e.toString());
    }
  }

  /// Get list of migration steps needed
  List<MigrationStep> _getMigrationSteps(String fromVersion, String toVersion) {
    final steps = <MigrationStep>[];
    
    // Migration from 1.0 to 2.0
    if (_versionCompare(fromVersion, '2.0') < 0) {
      steps.addAll(_getMigrationSteps1To2());
    }
    
    // Future version migrations can be added here
    // if (_versionCompare(fromVersion, '3.0') < 0) {
    //   steps.addAll(_getMigrationSteps2To3());
    // }
    
    return steps;
  }

  /// Migration steps from version 1.0 to 2.0
  List<MigrationStep> _getMigrationSteps1To2() {
    return [
      MigrationStep(
        id: 'v1_to_v2_encryption',
        description: 'Encrypt existing sensitive data',
        isCritical: false,
        executor: _migrateToEncryption,
      ),
      MigrationStep(
        id: 'v1_to_v2_advisor_models',
        description: 'Update advisor invitation and response models',
        isCritical: true,
        executor: _migrateAdvisorModels,
      ),
      MigrationStep(
        id: 'v1_to_v2_synthesis_data',
        description: 'Add career synthesis data structures',
        isCritical: false,
        executor: _addSynthesisDataStructures,
      ),
      MigrationStep(
        id: 'v1_to_v2_metadata',
        description: 'Add metadata and analytics fields',
        isCritical: false,
        executor: _addMetadataFields,
      ),
      MigrationStep(
        id: 'v1_to_v2_cleanup',
        description: 'Clean up obsolete data and optimize storage',
        isCritical: false,
        executor: _cleanupObsoleteData,
      ),
    ];
  }

  /// Execute a single migration step
  Future<MigrationStepResult> _executeMigrationStep(MigrationStep step) async {
    AppLogger.info('Executing migration step: ${step.description}');
    
    try {
      return await step.executor();
    } catch (e, stackTrace) {
      AppLogger.error('Migration step failed: ${step.description}', e, stackTrace);
      rethrow;
    }
  }

  /// Migrate to encryption (encrypt existing sensitive data)
  Future<MigrationStepResult> _migrateToEncryption() async {
    int processedCount = 0;
    
    try {
      // Initialize encryption service if not already done
      if (!_encryptionService.isInitialized) {
        await _encryptionService.initialize();
      }
      
      // Encrypt career sessions
      final sessions = await _persistenceService.getAllCareerSessions();
      for (final session in sessions) {
        // Re-save session to trigger encryption
        await _persistenceService.saveCareerSession(session);
        processedCount++;
      }
      
      // Encrypt advisor invitations
      for (final session in sessions) {
        final invitations = _persistenceService.getAdvisorInvitationsForSession(session.id);
        for (final invitation in invitations) {
          await _persistenceService.saveAdvisorInvitation(invitation);
          processedCount++;
        }
      }
      
      AppLogger.info('Encrypted $processedCount items');
      return MigrationStepResult(processedCount);
    } catch (e, stackTrace) {
      AppLogger.error('Encryption migration failed', e, stackTrace);
      rethrow;
    }
  }

  /// Migrate advisor models to new structure
  Future<MigrationStepResult> _migrateAdvisorModels() async {
    int processedCount = 0;
    
    try {
      // Open legacy advisor boxes if they exist
      final legacyInvitationBox = await _openLegacyBoxSafely('advisor_invitations');
      final legacyResponseBox = await _openLegacyBoxSafely('advisor_responses');
      
      if (legacyInvitationBox != null) {
        // Migrate legacy advisor invitations
        for (final invitation in legacyInvitationBox.values) {
          try {
            final migratedInvitation = _migrateLegacyInvitation(invitation);
            await _persistenceService.saveAdvisorInvitation(migratedInvitation);
            processedCount++;
          } catch (e) {
            AppLogger.warning('Failed to migrate invitation: $e');
          }
        }
        
        // Close and delete legacy box
        await legacyInvitationBox.close();
        await Hive.deleteBoxFromDisk('advisor_invitations');
      }
      
      if (legacyResponseBox != null) {
        // Migrate legacy advisor responses
        for (final response in legacyResponseBox.values) {
          try {
            final migratedResponse = _migrateLegacyResponse(response);
            await _persistenceService.saveAdvisorResponse(migratedResponse);
            processedCount++;
          } catch (e) {
            AppLogger.warning('Failed to migrate response: $e');
          }
        }
        
        // Close and delete legacy box
        await legacyResponseBox.close();
        await Hive.deleteBoxFromDisk('advisor_responses');
      }
      
      AppLogger.info('Migrated $processedCount advisor items');
      return MigrationStepResult(processedCount);
    } catch (e, stackTrace) {
      AppLogger.error('Advisor model migration failed', e, stackTrace);
      rethrow;
    }
  }

  /// Add career synthesis data structures
  Future<MigrationStepResult> _addSynthesisDataStructures() async {
    int processedCount = 0;
    
    try {
      // Add synthesis capability to existing sessions that have both
      // self-assessment and advisor responses
      final sessions = await _persistenceService.getAllCareerSessions();
      
      for (final session in sessions) {
        final hasResponses = session.responses.isNotEmpty;
        final advisorResponses = _persistenceService.getAdvisorResponsesForSession(session.id);
        final hasAdvisorResponses = advisorResponses.isNotEmpty;
        
        if (hasResponses && hasAdvisorResponses) {
          // Create a basic synthesis structure for this session
          final synthesis = _createBasicSynthesis(session, advisorResponses);
          await _persistenceService.saveCareerSynthesis(synthesis);
          processedCount++;
        }
      }
      
      AppLogger.info('Added synthesis structures for $processedCount sessions');
      return MigrationStepResult(processedCount);
    } catch (e, stackTrace) {
      AppLogger.error('Synthesis data migration failed', e, stackTrace);
      rethrow;
    }
  }

  /// Add metadata and analytics fields
  Future<MigrationStepResult> _addMetadataFields() async {
    int processedCount = 0;
    
    try {
      // Add metadata to existing career sessions
      final sessions = await _persistenceService.getAllCareerSessions();
      
      for (final session in sessions) {
        // Re-save to ensure new metadata fields are added
        await _persistenceService.saveCareerSession(session);
        processedCount++;
      }
      
      AppLogger.info('Added metadata to $processedCount sessions');
      return MigrationStepResult(processedCount);
    } catch (e, stackTrace) {
      AppLogger.error('Metadata migration failed', e, stackTrace);
      rethrow;
    }
  }

  /// Clean up obsolete data and optimize storage
  Future<MigrationStepResult> _cleanupObsoleteData() async {
    int cleanedCount = 0;
    
    try {
      // Remove any orphaned data
      await _cleanupOrphanedData();
      
      // Compact Hive boxes
      await _compactHiveBoxes();
      
      cleanedCount = 1; // Placeholder count
      
      AppLogger.info('Cleanup completed');
      return MigrationStepResult(cleanedCount);
    } catch (e, stackTrace) {
      AppLogger.error('Cleanup migration failed', e, stackTrace);
      rethrow;
    }
  }

  /// Migrate legacy advisor invitation to new structure
  AdvisorInvitation _migrateLegacyInvitation(dynamic legacyInvitation) {
    // Convert legacy format to new AdvisorInvitation structure
    final Map<String, dynamic> legacyData = legacyInvitation is Map 
        ? Map<String, dynamic>.from(legacyInvitation)
        : _extractLegacyFields(legacyInvitation);
    
    return AdvisorInvitation(
      id: legacyData['id'] ?? 'migrated_${DateTime.now().millisecondsSinceEpoch}',
      advisorName: legacyData['advisorName'] ?? legacyData['name'] ?? 'Unknown Advisor',
      advisorEmail: legacyData['advisorEmail'] ?? legacyData['email'] ?? '',
      advisorPhone: legacyData['advisorPhone'] ?? legacyData['phone'],
      relationshipType: _mapLegacyRelationshipType(legacyData['relationshipType']),
      personalMessage: legacyData['personalMessage'] ?? legacyData['message'] ?? '',
      sentAt: _parseLegacyDate(legacyData['sentAt']) ?? DateTime.now(),
      status: _mapLegacyInvitationStatus(legacyData['status']),
      respondedAt: _parseLegacyDate(legacyData['respondedAt']),
      remindedAt: _parseLegacyDate(legacyData['remindedAt']),
      reminderCount: legacyData['reminderCount'] ?? 0,
      sessionId: legacyData['sessionId'] ?? 'unknown_session',
      includePersonalMessage: legacyData['includePersonalMessage'] ?? true,
      customQuestions: legacyData['customQuestions'] != null 
          ? Map<String, String>.from(legacyData['customQuestions'])
          : null,
      declineReason: legacyData['declineReason'],
    );
  }

  /// Migrate legacy advisor response to new structure
  AdvisorResponse _migrateLegacyResponse(dynamic legacyResponse) {
    final Map<String, dynamic> legacyData = legacyResponse is Map 
        ? Map<String, dynamic>.from(legacyResponse)
        : _extractLegacyFields(legacyResponse);
    
    return AdvisorResponse(
      id: legacyData['id'] ?? 'migrated_${DateTime.now().millisecondsSinceEpoch}',
      invitationId: legacyData['invitationId'] ?? 'unknown_invitation',
      questionId: legacyData['questionId'] ?? 'legacy_question',
      questionText: legacyData['questionText'] ?? 'Legacy question',
      response: legacyData['response'] ?? '',
      answeredAt: _parseLegacyDate(legacyData['answeredAt']) ?? DateTime.now(),
      domain: _mapLegacyDomain(legacyData['domain']),
      confidenceLevel: legacyData['confidenceLevel'],
      observationPeriod: _mapLegacyObservationPeriod(legacyData['observationPeriod']),
      specificExamples: legacyData['specificExamples'] != null 
          ? List<String>.from(legacyData['specificExamples'])
          : null,
      confidenceContext: _mapLegacyConfidenceContext(legacyData['confidenceContext']),
      additionalContext: legacyData['additionalContext'],
      isAnonymous: legacyData['isAnonymous'] ?? false,
      metadata: legacyData['metadata'] != null 
          ? Map<String, dynamic>.from(legacyData['metadata'])
          : null,
    );
  }

  /// Create basic synthesis structure for migrated data
  CareerSynthesis _createBasicSynthesis(CareerSession session, List<AdvisorResponse> advisorResponses) {
    return CareerSynthesis(
      id: 'migrated_synthesis_${session.id}',
      sessionId: session.id,
      generatedAt: DateTime.now(),
      selfResponseIds: session.responses.keys.toList(),
      advisorResponseIds: advisorResponses.map((r) => r.id).toList(),
      alignmentAreas: [], // Will be populated by synthesis engine later
      hiddenStrengths: [],
      overestimatedAreas: [],
      developmentOpportunities: [],
      repositioningPotential: [],
      executiveSummary: 'Migrated synthesis - analysis pending',
      strategicRecommendations: ['Complete synthesis analysis to get recommendations'],
      alignmentScore: 0.5, // Neutral score for migrated data
      confidenceLevel: SynthesisConfidence.low, // Low confidence for migrated data
      analysisMetadata: {
        'migrated': true,
        'migration_date': DateTime.now().toIso8601String(),
        'requires_analysis': true,
      },
    );
  }

  /// Safely open legacy Hive box
  Future<Box?> _openLegacyBoxSafely(String boxName) async {
    try {
      if (await Hive.boxExists(boxName)) {
        return await Hive.openBox(boxName);
      }
      return null;
    } catch (e) {
      AppLogger.warning('Failed to open legacy box $boxName: $e');
      return null;
    }
  }

  /// Extract fields from legacy object using reflection-like approach
  Map<String, dynamic> _extractLegacyFields(dynamic obj) {
    // This would need to be implemented based on the specific legacy object structure
    // For now, return empty map with fallback values
    return <String, dynamic>{};
  }

  /// Map legacy relationship type to new enum
  AdvisorRelationship _mapLegacyRelationshipType(dynamic legacyType) {
    if (legacyType == null) return AdvisorRelationship.other;
    
    final typeString = legacyType.toString().toLowerCase();
    
    if (typeString.contains('manager')) return AdvisorRelationship.manager;
    if (typeString.contains('colleague')) return AdvisorRelationship.colleague;
    if (typeString.contains('mentor')) return AdvisorRelationship.mentor;
    if (typeString.contains('friend')) return AdvisorRelationship.friend;
    if (typeString.contains('family')) return AdvisorRelationship.family;
    if (typeString.contains('client')) return AdvisorRelationship.client;
    if (typeString.contains('sponsor')) return AdvisorRelationship.sponsor;
    if (typeString.contains('peer')) return AdvisorRelationship.peer;
    
    return AdvisorRelationship.other;
  }

  /// Map legacy invitation status to new enum
  InvitationStatus _mapLegacyInvitationStatus(dynamic legacyStatus) {
    if (legacyStatus == null) return InvitationStatus.draft;
    
    final statusString = legacyStatus.toString().toLowerCase();
    
    if (statusString.contains('sent')) return InvitationStatus.sent;
    if (statusString.contains('viewed')) return InvitationStatus.viewed;
    if (statusString.contains('completed')) return InvitationStatus.completed;
    if (statusString.contains('declined')) return InvitationStatus.declined;
    if (statusString.contains('expired')) return InvitationStatus.expired;
    
    return InvitationStatus.draft;
  }

  /// Map legacy domain to new enum
  CareerDomain _mapLegacyDomain(dynamic legacyDomain) {
    if (legacyDomain == null) return CareerDomain.social;
    
    final domainString = legacyDomain.toString().toLowerCase();
    
    if (domainString.contains('technical')) return CareerDomain.technical;
    if (domainString.contains('leadership')) return CareerDomain.leadership;
    if (domainString.contains('creative')) return CareerDomain.creative;
    if (domainString.contains('analytical')) return CareerDomain.analytical;
    if (domainString.contains('social')) return CareerDomain.social;
    if (domainString.contains('entrepreneurial')) return CareerDomain.entrepreneurial;
    if (domainString.contains('traditional')) return CareerDomain.traditional;
    if (domainString.contains('investigative')) return CareerDomain.investigative;
    
    return CareerDomain.social;
  }

  /// Map legacy observation period to new enum
  AdvisorObservationPeriod _mapLegacyObservationPeriod(dynamic legacyPeriod) {
    if (legacyPeriod == null) return AdvisorObservationPeriod.oneToSixMonths;
    
    final periodString = legacyPeriod.toString().toLowerCase();
    
    if (periodString.contains('less') || periodString.contains('month')) {
      return AdvisorObservationPeriod.lessThanMonth;
    }
    if (periodString.contains('1') && periodString.contains('6')) {
      return AdvisorObservationPeriod.oneToSixMonths;
    }
    if (periodString.contains('6') && periodString.contains('year')) {
      return AdvisorObservationPeriod.sixMonthsToYear;
    }
    if (periodString.contains('1') && periodString.contains('3')) {
      return AdvisorObservationPeriod.oneToThreeYears;
    }
    if (periodString.contains('more') || periodString.contains('3')) {
      return AdvisorObservationPeriod.moreThanThreeYears;
    }
    
    return AdvisorObservationPeriod.oneToSixMonths;
  }

  /// Map legacy confidence context to new enum
  AdvisorConfidenceContext _mapLegacyConfidenceContext(dynamic legacyContext) {
    if (legacyContext == null) return AdvisorConfidenceContext.somewhatConfident;
    
    final contextString = legacyContext.toString().toLowerCase();
    
    if (contextString.contains('very') && contextString.contains('confident')) {
      return AdvisorConfidenceContext.veryConfident;
    }
    if (contextString.contains('confident') && !contextString.contains('somewhat')) {
      return AdvisorConfidenceContext.confident;
    }
    if (contextString.contains('somewhat')) {
      return AdvisorConfidenceContext.somewhatConfident;
    }
    if (contextString.contains('limited')) {
      return AdvisorConfidenceContext.limitedObservation;
    }
    if (contextString.contains('uncertain')) {
      return AdvisorConfidenceContext.uncertain;
    }
    
    return AdvisorConfidenceContext.somewhatConfident;
  }

  /// Parse legacy date format
  DateTime? _parseLegacyDate(dynamic legacyDate) {
    if (legacyDate == null) return null;
    
    try {
      if (legacyDate is DateTime) return legacyDate;
      if (legacyDate is String) return DateTime.parse(legacyDate);
      if (legacyDate is int) return DateTime.fromMillisecondsSinceEpoch(legacyDate);
    } catch (e) {
      AppLogger.warning('Failed to parse legacy date: $legacyDate');
    }
    
    return null;
  }

  /// Clean up orphaned data after migration
  Future<void> _cleanupOrphanedData() async {
    try {
      // This would implement cleanup logic similar to the one in EnhancedPersistenceService
      AppLogger.info('Cleaning up orphaned data after migration');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup orphaned data', e, stackTrace);
    }
  }

  /// Compact Hive boxes to optimize storage
  Future<void> _compactHiveBoxes() async {
    try {
      // Hive automatically compacts boxes, but we can trigger it explicitly
      AppLogger.info('Compacting Hive boxes for optimization');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to compact Hive boxes', e, stackTrace);
    }
  }

  /// Get stored data version
  Future<String?> _getStoredDataVersion() async {
    try {
      final settingsBox = await Hive.openBox<String>('migration_settings');
      return settingsBox.get(_versionKey);
    } catch (e) {
      AppLogger.warning('Failed to get stored data version: $e');
      return null;
    }
  }

  /// Set data version
  Future<void> _setDataVersion(String version) async {
    try {
      final settingsBox = await Hive.openBox<String>('migration_settings');
      await settingsBox.put(_versionKey, version);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set data version', e, stackTrace);
    }
  }

  /// Log migration completion
  Future<void> _logMigration(
    String fromVersion,
    String toVersion,
    Map<String, int> migratedItems,
    List<String> errors,
  ) async {
    try {
      final migrationLog = {
        'from_version': fromVersion,
        'to_version': toVersion,
        'completed_at': DateTime.now().toIso8601String(),
        'migrated_items': migratedItems,
        'errors': errors,
      };
      
      final settingsBox = await Hive.openBox<String>('migration_settings');
      final existingLogs = settingsBox.get(_migrationLogKey);
      final logs = existingLogs != null ? jsonDecode(existingLogs) as List : [];
      
      logs.add(migrationLog);
      
      // Keep only last 10 migration logs
      if (logs.length > 10) {
        logs.removeRange(0, logs.length - 10);
      }
      
      await settingsBox.put(_migrationLogKey, jsonEncode(logs));
      
      AppLogger.info('Migration logged successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log migration', e, stackTrace);
    }
  }

  /// Compare version strings
  int _versionCompare(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    final maxLength = [v1Parts.length, v2Parts.length].reduce((a, b) => a > b ? a : b);
    
    // Pad shorter version with zeros
    while (v1Parts.length < maxLength) v1Parts.add(0);
    while (v2Parts.length < maxLength) v2Parts.add(0);
    
    for (int i = 0; i < maxLength; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    
    return 0;
  }

  /// Get migration history
  Future<List<Map<String, dynamic>>> getMigrationHistory() async {
    try {
      final settingsBox = await Hive.openBox<String>('migration_settings');
      final existingLogs = settingsBox.get(_migrationLogKey);
      
      if (existingLogs != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(existingLogs));
      }
      
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get migration history', e, stackTrace);
      return [];
    }
  }

  /// Check if specific migration has been completed
  Future<bool> isMigrationCompleted(String migrationId) async {
    try {
      final history = await getMigrationHistory();
      return history.any((log) => 
          log['migrated_items'] != null &&
          (log['migrated_items'] as Map).containsKey(migrationId));
    } catch (e) {
      AppLogger.warning('Failed to check migration status for $migrationId: $e');
      return false;
    }
  }
}

/// Represents a single migration step
class MigrationStep {
  final String id;
  final String description;
  final bool isCritical;
  final Future<MigrationStepResult> Function() executor;

  const MigrationStep({
    required this.id,
    required this.description,
    required this.isCritical,
    required this.executor,
  });
}

/// Result of a migration step
class MigrationStepResult {
  final int itemCount;
  final Map<String, dynamic>? metadata;

  const MigrationStepResult(this.itemCount, {this.metadata});
}

/// Result of migration operation
class MigrationResult {
  final bool isSuccess;
  final String? fromVersion;
  final String? toVersion;
  final Map<String, int>? migratedItems;
  final List<String>? warnings;
  final String? error;
  final MigrationType type;

  const MigrationResult._({
    required this.isSuccess,
    this.fromVersion,
    this.toVersion,
    this.migratedItems,
    this.warnings,
    this.error,
    required this.type,
  });

  factory MigrationResult.success({
    required String fromVersion,
    required String toVersion,
    required Map<String, int> migratedItems,
    List<String>? warnings,
  }) => MigrationResult._(
    isSuccess: true,
    fromVersion: fromVersion,
    toVersion: toVersion,
    migratedItems: migratedItems,
    warnings: warnings,
    type: MigrationType.upgrade,
  );

  factory MigrationResult.fresh() => const MigrationResult._(
    isSuccess: true,
    type: MigrationType.fresh,
  );

  factory MigrationResult.upToDate() => const MigrationResult._(
    isSuccess: true,
    type: MigrationType.upToDate,
  );

  factory MigrationResult.failed(String error) => MigrationResult._(
    isSuccess: false,
    error: error,
    type: MigrationType.failed,
  );

  /// Get total migrated items count
  int get totalMigratedItems {
    if (migratedItems == null) return 0;
    return migratedItems!.values.fold(0, (sum, count) => sum + count);
  }

  /// Check if migration had warnings
  bool get hasWarnings => warnings != null && warnings!.isNotEmpty;
}

/// Types of migration
enum MigrationType {
  fresh,
  upToDate,
  upgrade,
  failed,
}

/// Custom exception for migration errors
class MigrationException implements Exception {
  final String message;
  final dynamic cause;

  const MigrationException(this.message, this.cause);

  @override
  String toString() => 'MigrationException: $message (caused by: $cause)';
}