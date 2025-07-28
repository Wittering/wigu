import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

/// Service for encrypting and decrypting sensitive career assessment data
/// Provides field-level encryption for privacy-sensitive information
class DataEncryptionService {
  static const String _keyBoxName = 'encryption_keys';
  static const String _masterKeyName = 'master_key';
  static const String _saltKeyName = 'encryption_salt';
  
  late Box<String> _keyBox;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  bool _isInitialized = false;

  /// Initialize the encryption service
  Future<void> initialize() async {
    try {
      // Open secure key storage
      _keyBox = await Hive.openBox<String>(_keyBoxName);
      
      // Initialize encryption
      await _initializeEncryption();
      
      _isInitialized = true;
      AppLogger.info('DataEncryptionService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize DataEncryptionService', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize encryption keys and ciphers
  Future<void> _initializeEncryption() async {
    // Get or create master key
    String? masterKey = _keyBox.get(_masterKeyName);
    String? salt = _keyBox.get(_saltKeyName);

    if (masterKey == null || salt == null) {
      // Generate new master key and salt
      final key = encrypt.Key.fromSecureRandom(32);
      final newSalt = encrypt.IV.fromSecureRandom(16);
      
      masterKey = key.base64;
      salt = newSalt.base64;
      
      await _keyBox.put(_masterKeyName, masterKey);
      await _keyBox.put(_saltKeyName, salt);
      
      AppLogger.info('Generated new encryption keys');
    }

    // Initialize encrypter with AES-256
    final key = encrypt.Key.fromBase64(masterKey);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _iv = encrypt.IV.fromBase64(salt);
  }

  /// Encrypt sensitive text data
  String encryptText(String plainText) {
    if (!_isInitialized) {
      throw StateError('DataEncryptionService not initialized');
    }
    
    if (plainText.isEmpty) return plainText;
    
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt text', e, stackTrace);
      // Return original text in debug mode, empty in production
      return kDebugMode ? plainText : '';
    }
  }

  /// Decrypt sensitive text data
  String decryptText(String encryptedText) {
    if (!_isInitialized) {
      throw StateError('DataEncryptionService not initialized');
    }
    
    if (encryptedText.isEmpty) return encryptedText;
    
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt text', e, stackTrace);
      // Return encrypted text in debug mode to avoid data loss
      return kDebugMode ? encryptedText : '';
    }
  }

  /// Encrypt JSON data
  String encryptJson(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      return encryptText(jsonString);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to encrypt JSON data', e, stackTrace);
      rethrow;
    }
  }

  /// Decrypt JSON data
  Map<String, dynamic> decryptJson(String encryptedData) {
    try {
      final decryptedString = decryptText(encryptedData);
      if (decryptedString.isEmpty) return {};
      return jsonDecode(decryptedString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decrypt JSON data', e, stackTrace);
      return {};
    }
  }

  /// Encrypt a list of strings
  List<String> encryptStringList(List<String> strings) {
    return strings.map((str) => encryptText(str)).toList();
  }

  /// Decrypt a list of strings
  List<String> decryptStringList(List<String> encryptedStrings) {
    return encryptedStrings.map((str) => decryptText(str)).toList();
  }

  /// Generate a secure hash for data integrity verification
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity using hash
  bool verifyHash(String data, String expectedHash) {
    final actualHash = generateHash(data);
    return actualHash == expectedHash;
  }

  /// Create an encrypted backup of career data
  Future<Map<String, dynamic>> createEncryptedBackup(Map<String, dynamic> careerData) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final dataHash = generateHash(jsonEncode(careerData));
      
      final backupData = {
        'version': '1.0',
        'timestamp': timestamp,
        'dataHash': dataHash,
        'encryptedData': encryptJson(careerData),
      };
      
      AppLogger.info('Created encrypted backup at $timestamp');
      return backupData;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create encrypted backup', e, stackTrace);
      rethrow;
    }
  }

  /// Restore data from encrypted backup
  Future<Map<String, dynamic>> restoreFromEncryptedBackup(Map<String, dynamic> backupData) async {
    try {
      final version = backupData['version'] as String?;
      final timestamp = backupData['timestamp'] as String?;
      final expectedHash = backupData['dataHash'] as String?;
      final encryptedData = backupData['encryptedData'] as String?;
      
      if (version == null || encryptedData == null || expectedHash == null) {
        throw FormatException('Invalid backup format');
      }
      
      final decryptedData = decryptJson(encryptedData);
      final actualHash = generateHash(jsonEncode(decryptedData));
      
      if (!verifyHash(jsonEncode(decryptedData), expectedHash)) {
        throw SecurityException('Backup data integrity check failed');
      }
      
      AppLogger.info('Successfully restored encrypted backup from $timestamp');
      return decryptedData;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to restore from encrypted backup', e, stackTrace);
      rethrow;
    }
  }

  /// Encrypt personally identifiable information (PII)
  Map<String, String> encryptPII(Map<String, String> piiData) {
    final encryptedPII = <String, String>{};
    
    for (final entry in piiData.entries) {
      if (_isPIIField(entry.key)) {
        encryptedPII[entry.key] = encryptText(entry.value);
      } else {
        encryptedPII[entry.key] = entry.value;
      }
    }
    
    return encryptedPII;
  }

  /// Decrypt personally identifiable information (PII)
  Map<String, String> decryptPII(Map<String, String> encryptedPII) {
    final decryptedPII = <String, String>{};
    
    for (final entry in encryptedPII.entries) {
      if (_isPIIField(entry.key)) {
        decryptedPII[entry.key] = decryptText(entry.value);
      } else {
        decryptedPII[entry.key] = entry.value;
      }
    }
    
    return decryptedPII;
  }

  /// Check if a field contains personally identifiable information
  bool _isPIIField(String fieldName) {
    const piiFields = {
      'advisorName',
      'advisorEmail',
      'advisorPhone',
      'personalMessage',
      'additionalContext',
      'response',
      'specificExamples',
      'sessionName',
    };
    
    return piiFields.contains(fieldName) || 
           fieldName.toLowerCase().contains('name') ||
           fieldName.toLowerCase().contains('email') ||
           fieldName.toLowerCase().contains('phone') ||
           fieldName.toLowerCase().contains('personal');
  }

  /// Generate a secure session token for advisor responses
  String generateSecureToken() {
    final randomBytes = encrypt.IV.fromSecureRandom(32);
    return randomBytes.base64;
  }

  /// Rotate encryption keys (for enhanced security)
  Future<void> rotateEncryptionKeys() async {
    try {
      // Generate new keys
      final newKey = encrypt.Key.fromSecureRandom(32);
      final newSalt = encrypt.IV.fromSecureRandom(16);
      
      // Store new keys
      await _keyBox.put(_masterKeyName, newKey.base64);
      await _keyBox.put(_saltKeyName, newSalt.base64);
      
      // Re-initialize encryption
      await _initializeEncryption();
      
      AppLogger.info('Encryption keys rotated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to rotate encryption keys', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all encryption keys (for data deletion compliance)
  Future<void> clearEncryptionKeys() async {
    try {
      await _keyBox.clear();
      _isInitialized = false;
      AppLogger.info('Encryption keys cleared for GDPR compliance');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear encryption keys', e, stackTrace);
      rethrow;
    }
  }

  /// Check if encryption service is ready
  bool get isInitialized => _isInitialized;

  /// Close the encryption service
  Future<void> close() async {
    try {
      await _keyBox.close();
      _isInitialized = false;
      AppLogger.info('DataEncryptionService closed');
    } catch (e, stackTrace) {
      AppLogger.error('Error closing DataEncryptionService', e, stackTrace);
    }
  }
}

/// Custom exception for security-related errors
class SecurityException implements Exception {
  final String message;
  
  const SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}