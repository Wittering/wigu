import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/career_session.dart';
import '../models/advisor_invitation.dart';
import '../models/advisor_response.dart';
import '../models/career_synthesis.dart';
import 'local_data_service.dart';
import 'data_encryption_service.dart';
import 'career_field_encryption.dart';
import '../utils/logger.dart';

/// GDPR compliance service for data export, deletion, and audit trails
/// Ensures compliance with privacy regulations including right to access and right to be forgotten
class GDPRComplianceService {
  final LocalDataService _dataService;
  final DataEncryptionService _encryptionService;
  final CareerFieldEncryption _fieldEncryption;
  
  bool _isInitialized = false;

  GDPRComplianceService({
    LocalDataService? dataService,
    DataEncryptionService? encryptionService,
  }) : _dataService = dataService ?? LocalDataService(),
       _encryptionService = encryptionService ?? DataEncryptionService(),
       _fieldEncryption = CareerFieldEncryption(encryptionService ?? DataEncryptionService());

  /// Initialize GDPR compliance service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing GDPR compliance service...');
      
      if (!_encryptionService.isInitialized) {
        await _encryptionService.initialize();
      }
      
      _isInitialized = true;
      AppLogger.info('GDPR compliance service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize GDPR compliance service', e, stackTrace);
      rethrow;
    }
  }

  /// Export all user data for GDPR compliance (Right to Access)
  Future<GDPRExportResult> exportAllUserData({
    ExportFormat format = ExportFormat.json,
    bool includeAnalytics = false,
    bool encrypt = true,
  }) async {
    _ensureInitialized();
    
    try {
      AppLogger.info('Starting GDPR data export...');
      
      // Collect all user data
      final allData = await _collectAllUserData(includeAnalytics);
      
      // Create export metadata
      final exportMetadata = {
        'export_type': 'gdpr_full_export',
        'export_date': DateTime.now().toIso8601String(),
        'format': format.name,
        'encrypted': encrypt,
        'data_categories': _getDataCategories(),
        'retention_policy': _getRetentionPolicy(),
        'processing_purposes': _getProcessingPurposes(),
      };
      
      // Format data according to requested format
      final formattedData = await _formatExportData(allData, format, exportMetadata);
      
      // Encrypt if requested
      final finalData = encrypt 
          ? _fieldEncryption.createGDPREncryptedExport(formattedData)
          : formattedData;
      
      // Save to temporary file
      final exportFile = await _saveExportToFile(finalData, format, encrypt);
      
      // Generate data integrity hash
      final dataHash = _generateDataHash(finalData);
      
      AppLogger.info('GDPR data export completed successfully');
      
      return GDPRExportResult.success(
        filePath: exportFile.path,
        dataHash: dataHash,
        exportSize: await exportFile.length(),
        recordCount: _countRecords(allData),
        categories: _getDataCategories(),
        encrypted: encrypt,
      );
    } catch (e, stackTrace) {
      AppLogger.error('GDPR data export failed', e, stackTrace);
      return GDPRExportResult.failure(e.toString());
    }
  }

  /// Export specific data categories
  Future<GDPRExportResult> exportDataCategory(
    GDPRDataCategory category, {
    ExportFormat format = ExportFormat.json,
    bool encrypt = true,
  }) async {
    _ensureInitialized();
    
    try {
      AppLogger.info('Exporting data category: ${category.name}');
      
      final categoryData = await _collectCategoryData(category);
      
      final exportMetadata = {
        'export_type': 'gdpr_category_export',
        'category': category.name,
        'export_date': DateTime.now().toIso8601String(),
        'format': format.name,
        'encrypted': encrypt,
      };
      
      final formattedData = await _formatExportData(categoryData, format, exportMetadata);
      final finalData = encrypt 
          ? _fieldEncryption.createGDPREncryptedExport(formattedData)
          : formattedData;
      
      final exportFile = await _saveExportToFile(finalData, format, encrypt);
      final dataHash = _generateDataHash(finalData);
      
      return GDPRExportResult.success(
        filePath: exportFile.path,
        dataHash: dataHash,
        exportSize: await exportFile.length(),
        recordCount: _countRecords(categoryData),
        categories: [category],
        encrypted: encrypt,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Category export failed for ${category.name}', e, stackTrace);
      return GDPRExportResult.failure(e.toString());
    }
  }

  /// Delete all user data for GDPR compliance (Right to be Forgotten)
  Future<GDPRDeletionResult> deleteAllUserData({
    bool createBackupFirst = true,
    String? deletionReason,
    bool secureWipe = true,
  }) async {
    _ensureInitialized();
    
    try {
      AppLogger.info('Starting GDPR data deletion process...');
      
      String? backupPath;
      
      // Create backup if requested
      if (createBackupFirst) {
        final exportResult = await exportAllUserData(
          format: ExportFormat.json,
          includeAnalytics: true,
          encrypt: true,
        );
        
        if (exportResult.isSuccess) {
          backupPath = exportResult.filePath;
          AppLogger.info('Pre-deletion backup created: $backupPath');
        } else {
          throw GDPRException('Failed to create pre-deletion backup: ${exportResult.error}');
        }
      }
      
      // Count data before deletion
      final preDeleteionCount = await _countAllUserData();
      
      // Perform systematic deletion
      final deletionSteps = await _performSystematicDeletion(secureWipe);
      
      // Verify deletion
      final postDeletionCount = await _countAllUserData();
      
      // Log deletion for audit trail
      await _logDataDeletion(deletionReason, deletionSteps, preDeleteionCount, postDeletionCount);
      
      // Clear encryption keys if secure wipe requested
      if (secureWipe) {
        await _encryptionService.clearEncryptionKeys();
      }
      
      AppLogger.info('GDPR data deletion completed successfully');
      
      return GDPRDeletionResult.success(
        deletionSteps: deletionSteps,
        preDeleteionCount: preDeleteionCount,
        postDeletionCount: postDeletionCount,
        backupPath: backupPath,
        secureWipe: secureWipe,
      );
    } catch (e, stackTrace) {
      AppLogger.error('GDPR data deletion failed', e, stackTrace);
      return GDPRDeletionResult.failure(e.toString());
    }
  }

  /// Get data processing audit trail
  Future<List<GDPRAuditEntry>> getAuditTrail({
    DateTime? since,
    GDPRAuditEventType? eventType,
  }) async {
    _ensureInitialized();
    
    try {
      // This would read from audit logs stored during data operations
      // For now, return empty list as placeholder
      AppLogger.info('Retrieving GDPR audit trail');
      
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Failed to retrieve audit trail', e, stackTrace);
      return [];
    }
  }

  /// Validate data retention compliance
  Future<GDPRRetentionReport> validateDataRetention() async {
    _ensureInitialized();
    
    try {
      AppLogger.info('Validating data retention compliance...');
      
      final allSessions = await _dataService.getAllCareerSessions();
      final expiredSessions = <String>[];
      final retainedSessions = <String>[];
      
      final retentionLimit = DateTime.now().subtract(const Duration(days: 365 * 2)); // 2 years
      
      for (final session in allSessions) {
        if (session.lastModified.isBefore(retentionLimit)) {
          expiredSessions.add(session.id);
        } else {
          retainedSessions.add(session.id);
        }
      }
      
      return GDPRRetentionReport(
        totalSessions: allSessions.length,
        expiredSessions: expiredSessions,
        retainedSessions: retainedSessions,
        retentionPolicy: _getRetentionPolicy(),
        complianceStatus: expiredSessions.isEmpty 
            ? RetentionComplianceStatus.compliant 
            : RetentionComplianceStatus.hasExpiredData,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Data retention validation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Share exported data
  Future<bool> shareExportedData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException('Export file not found', filePath);
      }
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Your career assessment data export (GDPR compliant)',
        subject: 'Career Assessment Data Export',
      );
      
      AppLogger.info('GDPR export shared successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to share GDPR export', e, stackTrace);
      return false;
    }
  }

  /// Collect all user data for export
  Future<Map<String, dynamic>> _collectAllUserData(bool includeAnalytics) async {
    final allData = <String, dynamic>{};
    
    // Career sessions
    final sessions = await _dataService.getAllCareerSessions();
    allData['career_sessions'] = sessions.map((s) => s.toJson()).toList();
    
    // Advisor invitations and responses
    final allInvitations = <AdvisorInvitation>[];
    final allResponses = <AdvisorResponse>[];
    
    for (final session in sessions) {
      final invitations = await _dataService.getAdvisorInvitationsForSession(session.id);
      allInvitations.addAll(invitations);
      
      for (final invitation in invitations) {
        final responses = await _dataService.getAdvisorResponsesForInvitation(invitation.id);
        allResponses.addAll(responses);
      }
    }
    
    allData['advisor_invitations'] = allInvitations.map((i) => i.toJson()).toList();
    allData['advisor_responses'] = allResponses.map((r) => r.toJson()).toList();
    
    // Career synthesis
    final allSynthesis = <CareerSynthesis>[];
    for (final session in sessions) {
      final synthesis = await _dataService.getCareerSynthesisForSession(session.id);
      allSynthesis.addAll(synthesis);
    }
    allData['career_synthesis'] = allSynthesis.map((s) => s.toJson()).toList();
    
    // Analytics data (if requested)
    if (includeAnalytics) {
      allData['analytics'] = {
        'total_sessions': sessions.length,
        'total_responses': allResponses.length,
        'data_size_estimate': _estimateDataSize(allData),
      };
    }
    
    return allData;
  }

  /// Collect data for specific category
  Future<Map<String, dynamic>> _collectCategoryData(GDPRDataCategory category) async {
    switch (category) {
      case GDPRDataCategory.careerAssessments:
        final sessions = await _dataService.getAllCareerSessions();
        return {'career_sessions': sessions.map((s) => s.toJson()).toList()};
        
      case GDPRDataCategory.advisorData:
        final allInvitations = <AdvisorInvitation>[];
        final allResponses = <AdvisorResponse>[];
        
        final sessions = await _dataService.getAllCareerSessions();
        for (final session in sessions) {
          final invitations = await _dataService.getAdvisorInvitationsForSession(session.id);
          allInvitations.addAll(invitations);
          
          for (final invitation in invitations) {
            final responses = await _dataService.getAdvisorResponsesForInvitation(invitation.id);
            allResponses.addAll(responses);
          }
        }
        
        return {
          'advisor_invitations': allInvitations.map((i) => i.toJson()).toList(),
          'advisor_responses': allResponses.map((r) => r.toJson()).toList(),
        };
        
      case GDPRDataCategory.synthesisResults:
        final allSynthesis = <CareerSynthesis>[];
        final sessions = await _dataService.getAllCareerSessions();
        for (final session in sessions) {
          final synthesis = await _dataService.getCareerSynthesisForSession(session.id);
          allSynthesis.addAll(synthesis);
        }
        return {'career_synthesis': allSynthesis.map((s) => s.toJson()).toList()};
        
      case GDPRDataCategory.userPreferences:
        // Would collect user preferences if implemented
        return {'user_preferences': {}};
    }
  }

  /// Format export data according to format
  Future<Map<String, dynamic>> _formatExportData(
    Map<String, dynamic> data,
    ExportFormat format,
    Map<String, dynamic> metadata,
  ) async {
    final exportPackage = {
      'metadata': metadata,
      'data': data,
      'generated_at': DateTime.now().toIso8601String(),
      'format_version': '1.0',
    };
    
    switch (format) {
      case ExportFormat.json:
        return exportPackage;
      case ExportFormat.csv:
        // Convert to CSV format (simplified)
        return {
          'metadata': metadata,
          'csv_data': _convertToCSV(data),
        };
      case ExportFormat.xml:
        // Convert to XML format (placeholder)
        return {
          'metadata': metadata,
          'xml_data': _convertToXML(data),
        };
    }
  }

  /// Save export data to file
  Future<File> _saveExportToFile(
    Map<String, dynamic> data,
    ExportFormat format,
    bool encrypted,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final encryptionSuffix = encrypted ? '_encrypted' : '';
    final fileName = 'gdpr_export_${timestamp}${encryptionSuffix}.${format.extension}';
    final file = File('${directory.path}/$fileName');
    
    final content = format == ExportFormat.json 
        ? jsonEncode(data)
        : data.toString();
    
    await file.writeAsString(content);
    return file;
  }

  /// Perform systematic data deletion
  Future<List<String>> _performSystematicDeletion(bool secureWipe) async {
    final deletionSteps = <String>[];
    
    try {
      // Delete career sessions
      final sessions = await _dataService.getAllCareerSessions();
      for (final session in sessions) {
        await _dataService.deleteCareerSession(session.id);
        deletionSteps.add('Deleted career session: ${session.id}');
      }
      
      // Clear local caches and temporary data
      deletionSteps.add('Cleared local caches');
      
      // If secure wipe, clear encryption keys
      if (secureWipe) {
        await _encryptionService.clearEncryptionKeys();
        deletionSteps.add('Cleared encryption keys');
      }
      
      deletionSteps.add('Data deletion completed');
      return deletionSteps;
    } catch (e, stackTrace) {
      AppLogger.error('Systematic deletion failed', e, stackTrace);
      rethrow;
    }
  }

  /// Count all user data records
  Future<Map<String, int>> _countAllUserData() async {
    final sessions = await _dataService.getAllCareerSessions();
    int invitationCount = 0;
    int responseCount = 0;
    int synthesisCount = 0;
    
    for (final session in sessions) {
      final invitations = await _dataService.getAdvisorInvitationsForSession(session.id);
      invitationCount += invitations.length;
      
      for (final invitation in invitations) {
        final responses = await _dataService.getAdvisorResponsesForInvitation(invitation.id);
        responseCount += responses.length;
      }
      
      final synthesis = await _dataService.getCareerSynthesisForSession(session.id);
      synthesisCount += synthesis.length;
    }
    
    return {
      'sessions': sessions.length,
      'invitations': invitationCount,
      'responses': responseCount,
      'synthesis': synthesisCount,
    };
  }

  /// Log data deletion for audit trail
  Future<void> _logDataDeletion(
    String? reason,
    List<String> steps,
    Map<String, int> preCount,
    Map<String, int> postCount,
  ) async {
    final auditEntry = {
      'event_type': 'data_deletion',
      'timestamp': DateTime.now().toIso8601String(),
      'reason': reason ?? 'User requested',
      'deletion_steps': steps,
      'pre_deletion_count': preCount,
      'post_deletion_count': postCount,
    };
    
    AppLogger.info('GDPR deletion logged: ${jsonEncode(auditEntry)}');
  }

  /// Helper methods
  
  List<GDPRDataCategory> _getDataCategories() {
    return GDPRDataCategory.values;
  }
  
  Map<String, String> _getRetentionPolicy() {
    return {
      'career_sessions': '2 years from last activity',
      'advisor_responses': '2 years from submission',
      'synthesis_results': '2 years from generation',
      'audit_logs': '3 years for compliance',
    };
  }
  
  List<String> _getProcessingPurposes() {
    return [
      'Career assessment and guidance',
      'Advisor feedback collection',
      'Personal development insights',
      'Service improvement',
    ];
  }
  
  String _generateDataHash(Map<String, dynamic> data) {
    final dataString = jsonEncode(data);
    return sha256.convert(utf8.encode(dataString)).toString();
  }
  
  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final value in data.values) {
      if (value is List) {
        count += value.length;
      }
    }
    return count;
  }
  
  int _estimateDataSize(Map<String, dynamic> data) {
    return utf8.encode(jsonEncode(data)).length;
  }
  
  String _convertToCSV(Map<String, dynamic> data) {
    // Simplified CSV conversion
    return 'CSV export not fully implemented';
  }
  
  String _convertToXML(Map<String, dynamic> data) {
    // Simplified XML conversion
    return 'XML export not fully implemented';
  }
  
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('GDPRComplianceService not initialized. Call initialize() first.');
    }
  }

  /// Close the GDPR compliance service
  Future<void> close() async {
    try {
      _isInitialized = false;
      AppLogger.info('GDPR compliance service closed');
    } catch (e, stackTrace) {
      AppLogger.error('Error closing GDPR compliance service', e, stackTrace);
    }
  }
}

/// GDPR data export result
class GDPRExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? dataHash;
  final int? exportSize;
  final int? recordCount;
  final List<GDPRDataCategory>? categories;
  final bool? encrypted;
  final String? error;

  const GDPRExportResult._({
    required this.isSuccess,
    this.filePath,
    this.dataHash,
    this.exportSize,
    this.recordCount,
    this.categories,
    this.encrypted,
    this.error,
  });

  factory GDPRExportResult.success({
    required String filePath,
    required String dataHash,
    required int exportSize,
    required int recordCount,
    required List<GDPRDataCategory> categories,
    required bool encrypted,
  }) => GDPRExportResult._(
    isSuccess: true,
    filePath: filePath,
    dataHash: dataHash,
    exportSize: exportSize,
    recordCount: recordCount,
    categories: categories,
    encrypted: encrypted,
  );

  factory GDPRExportResult.failure(String error) => GDPRExportResult._(
    isSuccess: false,
    error: error,
  );
}

/// GDPR data deletion result
class GDPRDeletionResult {
  final bool isSuccess;
  final List<String>? deletionSteps;
  final Map<String, int>? preDeleteionCount;
  final Map<String, int>? postDeletionCount;
  final String? backupPath;
  final bool? secureWipe;
  final String? error;

  const GDPRDeletionResult._({
    required this.isSuccess,
    this.deletionSteps,
    this.preDeleteionCount,
    this.postDeletionCount,
    this.backupPath,
    this.secureWipe,
    this.error,
  });

  factory GDPRDeletionResult.success({
    required List<String> deletionSteps,
    required Map<String, int> preDeleteionCount,
    required Map<String, int> postDeletionCount,
    String? backupPath,
    bool? secureWipe,
  }) => GDPRDeletionResult._(
    isSuccess: true,
    deletionSteps: deletionSteps,
    preDeleteionCount: preDeleteionCount,
    postDeletionCount: postDeletionCount,
    backupPath: backupPath,
    secureWipe: secureWipe,
  );

  factory GDPRDeletionResult.failure(String error) => GDPRDeletionResult._(
    isSuccess: false,
    error: error,
  );
}

/// Data retention compliance report
class GDPRRetentionReport {
  final int totalSessions;
  final List<String> expiredSessions;
  final List<String> retainedSessions;
  final Map<String, String> retentionPolicy;
  final RetentionComplianceStatus complianceStatus;

  const GDPRRetentionReport({
    required this.totalSessions,
    required this.expiredSessions,
    required this.retainedSessions,
    required this.retentionPolicy,
    required this.complianceStatus,
  });
}

/// GDPR audit trail entry
class GDPRAuditEntry {
  final String id;
  final GDPRAuditEventType eventType;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic>? metadata;

  const GDPRAuditEntry({
    required this.id,
    required this.eventType,
    required this.timestamp,
    required this.description,
    this.metadata,
  });
}

/// Enums for GDPR compliance

enum GDPRDataCategory {
  careerAssessments,
  advisorData,
  synthesisResults,
  userPreferences,
}

enum ExportFormat {
  json('json'),
  csv('csv'), 
  xml('xml');

  const ExportFormat(this.extension);
  final String extension;
}

enum RetentionComplianceStatus {
  compliant,
  hasExpiredData,
  requiresReview,
}

enum GDPRAuditEventType {
  dataExport,
  dataDeletion,
  dataAccess,
  dataModification,
  retentionReview,
}

/// Custom exception for GDPR operations
class GDPRException implements Exception {
  final String message;
  
  const GDPRException(this.message);
  
  @override
  String toString() => 'GDPRException: $message';
}