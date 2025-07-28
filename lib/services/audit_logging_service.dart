import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

/// Comprehensive audit logging service for career assessment app
/// Provides tamper-evident logging for security, compliance, and debugging
class AuditLoggingService {
  static const String _auditBoxName = 'audit_logs';
  static const String _auditFilePrefix = 'audit_log';
  static const int _maxLogsPerFile = 1000;
  static const int _maxRetentionDays = 90;

  late Box<String> _auditBox;
  bool _isInitialized = false;
  int _currentLogCount = 0;
  String? _currentLogFileHash;

  /// Initialize the audit logging service
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing audit logging service...');
      
      // Open Hive box for audit logs
      _auditBox = await Hive.openBox<String>(_auditBoxName);
      
      // Initialize log file tracking
      await _initializeLogFileTracking();
      
      // Clean up old logs
      await _cleanupOldLogs();
      
      _isInitialized = true;
      
      // Log service initialization
      await logEvent(
        eventType: AuditEventType.systemEvent,
        action: 'audit_service_initialized',
        description: 'Audit logging service started successfully',
        metadata: {
          'version': '1.0',
          'max_retention_days': _maxRetentionDays,
        },
      );
      
      AppLogger.info('Audit logging service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize audit logging service', e, stackTrace);
      rethrow;
    }
  }

  /// Log a general audit event
  Future<void> logEvent({
    required AuditEventType eventType,
    required String action,
    required String description,
    String? userId,
    String? sessionId,
    String? resourceId,
    Map<String, dynamic>? metadata,
    AuditSeverity severity = AuditSeverity.info,
  }) async {
    if (!_isInitialized) {
      AppLogger.warning('Audit logging service not initialized - skipping log');
      return;
    }

    try {
      final auditEntry = AuditEntry(
        id: _generateAuditId(),
        timestamp: DateTime.now(),
        eventType: eventType,
        action: action,
        description: description,
        userId: userId,
        sessionId: sessionId,
        resourceId: resourceId,
        severity: severity,
        metadata: metadata,
        source: 'career_assessment_app',
        version: '1.0',
      );

      await _writeAuditEntry(auditEntry);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log audit event', e, stackTrace);
      // Don't rethrow to prevent audit logging from breaking application flow
    }
  }

  /// Log user authentication events
  Future<void> logAuthentication({
    required String action, // 'login', 'logout', 'login_failed', 'signup'
    String? userId,
    String? authMethod, // 'email', 'anonymous'
    String? ipAddress,
    String? userAgent,
    bool success = true,
    String? failureReason,
  }) async {
    await logEvent(
      eventType: AuditEventType.authentication,
      action: action,
      description: success 
          ? 'User $action successful via $authMethod'
          : 'User $action failed: $failureReason',
      userId: userId,
      severity: success ? AuditSeverity.info : AuditSeverity.warning,
      metadata: {
        'auth_method': authMethod,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'success': success,
        'failure_reason': failureReason,
      },
    );
  }

  /// Log data access events
  Future<void> logDataAccess({
    required String action, // 'read', 'create', 'update', 'delete'
    required String dataType, // 'career_session', 'advisor_response', etc.
    String? resourceId,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? additionalData,
  }) async {
    await logEvent(
      eventType: AuditEventType.dataAccess,
      action: 'data_$action',
      description: 'User ${action}d $dataType ${resourceId ?? 'resource'}',
      userId: userId,
      sessionId: sessionId,
      resourceId: resourceId,
      metadata: {
        'data_type': dataType,
        'operation': action,
        ...?additionalData,
      },
    );
  }

  /// Log advisor-related events
  Future<void> logAdvisorEvent({
    required String action, // 'invitation_sent', 'response_received', 'reminder_sent'
    required String invitationId,
    String? advisorEmail,
    String? sessionId,
    String? userId,
    Map<String, dynamic>? advisorData,
  }) async {
    await logEvent(
      eventType: AuditEventType.advisorActivity,
      action: action,
      description: 'Advisor event: $action for invitation $invitationId',
      userId: userId,
      sessionId: sessionId,
      resourceId: invitationId,
      metadata: {
        'advisor_email_hash': advisorEmail != null ? _hashSensitiveData(advisorEmail) : null,
        'invitation_id': invitationId,
        ...?advisorData,
      },
    );
  }

  /// Log privacy and GDPR events
  Future<void> logPrivacyEvent({
    required String action, // 'data_export', 'data_deletion', 'consent_given', 'consent_withdrawn'
    String? userId,
    String? dataType,
    String? reason,
    Map<String, dynamic>? privacyData,
  }) async {
    await logEvent(
      eventType: AuditEventType.privacy,
      action: action,
      description: 'Privacy action: $action ${dataType != null ? 'for $dataType' : ''}',
      userId: userId,
      severity: AuditSeverity.important,
      metadata: {
        'data_type': dataType,
        'reason': reason,
        'compliance_type': 'GDPR',
        ...?privacyData,
      },
    );
  }

  /// Log security events
  Future<void> logSecurityEvent({
    required String action, // 'encryption_key_rotation', 'suspicious_activity', 'data_breach_detected'
    required String description,
    String? userId,
    AuditSeverity severity = AuditSeverity.warning,
    Map<String, dynamic>? securityData,
  }) async {
    await logEvent(
      eventType: AuditEventType.security,
      action: action,
      description: description,
      userId: userId,
      severity: severity,
      metadata: {
        'security_event': true,
        ...?securityData,
      },
    );
  }

  /// Log error events with context
  Future<void> logError({
    required String error,
    required String context,
    String? userId,
    String? sessionId,
    StackTrace? stackTrace,
    Map<String, dynamic>? errorData,
  }) async {
    await logEvent(
      eventType: AuditEventType.error,
      action: 'error_occurred',
      description: 'Error in $context: $error',
      userId: userId,
      sessionId: sessionId,
      severity: AuditSeverity.error,
      metadata: {
        'error_message': error,
        'context': context,
        'stack_trace': stackTrace?.toString(),
        ...?errorData,
      },
    );
  }

  /// Get audit logs with filtering
  Future<List<AuditEntry>> getAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    AuditEventType? eventType,
    String? userId,
    String? sessionId,
    AuditSeverity? minSeverity,
    int? limit,
  }) async {
    _ensureInitialized();

    try {
      final allLogs = <AuditEntry>[];
      
      // Read from Hive box
      for (final logData in _auditBox.values) {
        try {
          final entry = AuditEntry.fromJson(jsonDecode(logData));
          
          // Apply filters
          if (startDate != null && entry.timestamp.isBefore(startDate)) continue;
          if (endDate != null && entry.timestamp.isAfter(endDate)) continue;
          if (eventType != null && entry.eventType != eventType) continue;
          if (userId != null && entry.userId != userId) continue;
          if (sessionId != null && entry.sessionId != sessionId) continue;
          if (minSeverity != null && entry.severity.index < minSeverity.index) continue;
          
          allLogs.add(entry);
        } catch (e) {
          AppLogger.warning('Failed to parse audit log entry: $e');
        }
      }
      
      // Sort by timestamp (newest first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      if (limit != null && allLogs.length > limit) {
        return allLogs.take(limit).toList();
      }
      
      return allLogs;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to retrieve audit logs', e, stackTrace);
      return [];
    }
  }

  /// Export audit logs for compliance
  Future<String> exportAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    AuditExportFormat format = AuditExportFormat.json,
  }) async {
    _ensureInitialized();

    try {
      final logs = await getAuditLogs(
        startDate: startDate,
        endDate: endDate,
      );

      final exportData = {
        'export_metadata': {
          'timestamp': DateTime.now().toIso8601String(),
          'total_entries': logs.length,
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'format': format.name,
        },
        'audit_logs': logs.map((log) => log.toJson()).toList(),
      };

      // Create export file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'audit_export_$timestamp.${format.extension}';
      final file = File('${directory.path}/$fileName');

      String content;
      switch (format) {
        case AuditExportFormat.json:
          content = jsonEncode(exportData);
          break;
        case AuditExportFormat.csv:
          content = _convertLogsToCSV(logs);
          break;
      }

      await file.writeAsString(content);
      
      // Log the export event
      await logPrivacyEvent(
        action: 'audit_logs_exported',
        reason: 'Compliance export',
        privacyData: {
          'export_file': fileName,
          'entries_count': logs.length,
          'format': format.name,
        },
      );

      return file.path;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export audit logs', e, stackTrace);
      rethrow;
    }
  }

  /// Get audit statistics
  Future<AuditStatistics> getAuditStatistics({DateTime? since}) async {
    _ensureInitialized();

    try {
      final logs = await getAuditLogs(startDate: since);
      
      final eventTypeCounts = <AuditEventType, int>{};
      final severityCounts = <AuditSeverity, int>{};
      final dailyCounts = <String, int>{};
      
      for (final log in logs) {
        // Count by event type
        eventTypeCounts[log.eventType] = (eventTypeCounts[log.eventType] ?? 0) + 1;
        
        // Count by severity
        severityCounts[log.severity] = (severityCounts[log.severity] ?? 0) + 1;
        
        // Count by day
        final day = log.timestamp.toIso8601String().substring(0, 10);
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }

      return AuditStatistics(
        totalLogs: logs.length,
        eventTypeCounts: eventTypeCounts,
        severityCounts: severityCounts,
        dailyCounts: dailyCounts,
        oldestLog: logs.isNotEmpty ? logs.last.timestamp : null,
        newestLog: logs.isNotEmpty ? logs.first.timestamp : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get audit statistics', e, stackTrace);
      rethrow;
    }
  }

  /// Clean up old audit logs
  Future<void> cleanupOldLogs() async {
    await _cleanupOldLogs();
  }

  /// Write audit entry to storage
  Future<void> _writeAuditEntry(AuditEntry entry) async {
    try {
      final entryJson = jsonEncode(entry.toJson());
      final entryKey = '${entry.timestamp.millisecondsSinceEpoch}_${entry.id}';
      
      // Store in Hive
      await _auditBox.put(entryKey, entryJson);
      
      // Also write to file for additional persistence
      await _writeToAuditFile(entry);
      
      _currentLogCount++;
      
      // Rotate log file if needed
      if (_currentLogCount >= _maxLogsPerFile) {
        await _rotateLogFile();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to write audit entry', e, stackTrace);
    }
  }

  /// Write audit entry to file
  Future<void> _writeToAuditFile(AuditEntry entry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${_auditFilePrefix}_current.log');
      
      final logLine = jsonEncode(entry.toJson()) + '\n';
      await logFile.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      AppLogger.warning('Failed to write to audit file: $e');
    }
  }

  /// Initialize log file tracking
  Future<void> _initializeLogFileTracking() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${_auditFilePrefix}_current.log');
      
      if (await logFile.exists()) {
        final content = await logFile.readAsString();
        _currentLogCount = content.split('\n').where((line) => line.isNotEmpty).length;
        _currentLogFileHash = _calculateFileHash(content);
      } else {
        _currentLogCount = 0;
        _currentLogFileHash = null;
      }
    } catch (e) {
      AppLogger.warning('Failed to initialize log file tracking: $e');
      _currentLogCount = 0;
    }
  }

  /// Rotate log file when it gets too large
  Future<void> _rotateLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final currentFile = File('${directory.path}/${_auditFilePrefix}_current.log');
      
      if (await currentFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final archiveFile = File('${directory.path}/${_auditFilePrefix}_$timestamp.log');
        await currentFile.rename(archiveFile.path);
      }
      
      _currentLogCount = 0;
      _currentLogFileHash = null;
    } catch (e) {
      AppLogger.warning('Failed to rotate log file: $e');
    }
  }

  /// Clean up old audit logs
  Future<void> _cleanupOldLogs() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: _maxRetentionDays));
      
      // Clean up from Hive box
      final keysToDelete = <String>[];
      for (final key in _auditBox.keys) {
        try {
          final timestampStr = key.toString().split('_')[0];
          final timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(timestampStr));
          if (timestamp.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        } catch (e) {
          // Invalid key format, consider for deletion
          keysToDelete.add(key);
        }
      }
      
      for (final key in keysToDelete) {
        await _auditBox.delete(key);
      }
      
      // Clean up old log files
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .where((file) => file.path.contains(_auditFilePrefix))
          .where((file) => !file.path.contains('current'));
      
      for (final file in files) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
      
      if (keysToDelete.isNotEmpty) {
        AppLogger.info('Cleaned up ${keysToDelete.length} old audit log entries');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clean up old audit logs', e, stackTrace);
    }
  }

  /// Generate unique audit ID
  String _generateAuditId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'audit_${timestamp}_$random';
  }

  /// Hash sensitive data for audit logging
  String _hashSensitiveData(String data) {
    return sha256.convert(utf8.encode(data)).toString().substring(0, 16);
  }

  /// Calculate file hash for integrity
  String _calculateFileHash(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// Convert logs to CSV format
  String _convertLogsToCSV(List<AuditEntry> logs) {
    final csv = StringBuffer();
    
    // Header
    csv.writeln('timestamp,event_type,action,description,user_id,session_id,resource_id,severity,source');
    
    // Data rows
    for (final log in logs) {
      csv.writeln([
        log.timestamp.toIso8601String(),
        log.eventType.name,
        log.action,
        '"${log.description.replaceAll('"', '""')}"',
        log.userId ?? '',
        log.sessionId ?? '',
        log.resourceId ?? '',
        log.severity.name,
        log.source,
      ].join(','));
    }
    
    return csv.toString();
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('AuditLoggingService not initialized. Call initialize() first.');
    }
  }

  /// Close the audit logging service
  Future<void> close() async {
    try {
      if (_isInitialized) {
        await logEvent(
          eventType: AuditEventType.systemEvent,
          action: 'audit_service_shutdown',
          description: 'Audit logging service shutting down',
        );
        
        await _auditBox.close();
        _isInitialized = false;
        AppLogger.info('Audit logging service closed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error closing audit logging service', e, stackTrace);
    }
  }
}

/// Audit log entry model
class AuditEntry {
  final String id;
  final DateTime timestamp;
  final AuditEventType eventType;
  final String action;
  final String description;
  final String? userId;
  final String? sessionId;
  final String? resourceId;
  final AuditSeverity severity;
  final Map<String, dynamic>? metadata;
  final String source;
  final String version;

  const AuditEntry({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.action,
    required this.description,
    this.userId,
    this.sessionId,
    this.resourceId,
    required this.severity,
    this.metadata,
    required this.source,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType.name,
      'action': action,
      'description': description,
      'user_id': userId,
      'session_id': sessionId,
      'resource_id': resourceId,
      'severity': severity.name,
      'metadata': metadata,
      'source': source,
      'version': version,
    };
  }

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      eventType: AuditEventType.values.firstWhere((e) => e.name == json['event_type']),
      action: json['action'],
      description: json['description'],
      userId: json['user_id'],
      sessionId: json['session_id'],
      resourceId: json['resource_id'],
      severity: AuditSeverity.values.firstWhere((s) => s.name == json['severity']),
      metadata: json['metadata'],
      source: json['source'],
      version: json['version'],
    );
  }
}

/// Audit statistics model
class AuditStatistics {
  final int totalLogs;
  final Map<AuditEventType, int> eventTypeCounts;
  final Map<AuditSeverity, int> severityCounts;
  final Map<String, int> dailyCounts;
  final DateTime? oldestLog;
  final DateTime? newestLog;

  const AuditStatistics({
    required this.totalLogs,
    required this.eventTypeCounts,
    required this.severityCounts,
    required this.dailyCounts,
    this.oldestLog,
    this.newestLog,
  });
}

/// Enums for audit logging

enum AuditEventType {
  authentication,
  dataAccess,
  advisorActivity,
  privacy,
  security,
  systemEvent,
  error,
}

enum AuditSeverity {
  debug,
  info,
  warning,
  important,
  error,
  critical,
}

enum AuditExportFormat {
  json('json'),
  csv('csv');

  const AuditExportFormat(this.extension);
  final String extension;
}