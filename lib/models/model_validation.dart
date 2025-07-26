/// Validation utilities for career insight engine models
/// Provides comprehensive validation and error handling for all model types

import 'dart:convert';

class ModelValidation {
  static const int maxTextLength = 10000;
  static const int maxTitleLength = 200;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 20;
  static const int minPasswordLength = 8;
  static const int maxListSize = 100;

  /// Validate string fields
  static ValidationResult validateString(
    String? value, 
    String fieldName, {
    bool required = true,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    if (value == null || value.isEmpty) {
      if (required) {
        return ValidationResult.error('$fieldName is required and cannot be empty');
      }
      return ValidationResult.valid();
    }

    if (minLength != null && value.length < minLength) {
      return ValidationResult.error('$fieldName must be at least $minLength characters');
    }

    if (maxLength != null && value.length > maxLength) {
      return ValidationResult.error('$fieldName cannot exceed $maxLength characters');
    }

    if (pattern != null) {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return ValidationResult.error('$fieldName format is invalid');
      }
    }

    return ValidationResult.valid();
  }

  /// Validate email addresses
  static ValidationResult validateEmail(String? email, {bool required = true}) {
    if (email == null || email.isEmpty) {
      if (required) {
        return ValidationResult.error('Email address is required');
      }
      return ValidationResult.valid();
    }

    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailPattern);
    
    if (!regex.hasMatch(email)) {
      return ValidationResult.error('Please enter a valid email address');
    }

    if (email.length > maxEmailLength) {
      return ValidationResult.error('Email address is too long');
    }

    return ValidationResult.valid();
  }

  /// Validate Australian phone numbers
  static ValidationResult validateAustralianPhone(String? phone, {bool required = false}) {
    if (phone == null || phone.isEmpty) {
      if (required) {
        return ValidationResult.error('Phone number is required');
      }
      return ValidationResult.valid();
    }

    // Remove common formatting characters
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Australian phone number patterns
    final patterns = [
      r'^04\d{8}$', // Mobile: 04xxxxxxxx
      r'^614\d{8}$', // Mobile with country code: 614xxxxxxxx
      r'^0[2378]\d{8}$', // Landline: 0xxxxxxxxx
      r'^61[2378]\d{8}$', // Landline with country code: 61xxxxxxxxx
      r'^13\d{4}$', // 13xxxx numbers
      r'^1800\d{6}$', // 1800 numbers
      r'^1300\d{6}$', // 1300 numbers
    ];

    final isValid = patterns.any((pattern) => RegExp(pattern).hasMatch(cleanPhone));
    
    if (!isValid) {
      return ValidationResult.error('Please enter a valid Australian phone number');
    }

    return ValidationResult.valid();
  }

  /// Validate numeric ranges
  static ValidationResult validateRange(
    num? value, 
    String fieldName, {
    num? min,
    num? max,
    bool required = true,
  }) {
    if (value == null) {
      if (required) {
        return ValidationResult.error('$fieldName is required');
      }
      return ValidationResult.valid();
    }

    if (min != null && value < min) {
      return ValidationResult.error('$fieldName must be at least $min');
    }

    if (max != null && value > max) {
      return ValidationResult.error('$fieldName cannot exceed $max');
    }

    return ValidationResult.valid();
  }

  /// Validate scale ratings (1-5)
  static ValidationResult validateRating(int? rating, String fieldName, {bool required = true}) {
    return validateRange(rating, fieldName, min: 1, max: 5, required: required);
  }

  /// Validate confidence scores (0.0-1.0)
  static ValidationResult validateConfidence(double? confidence, {bool required = true}) {
    return validateRange(confidence, 'Confidence score', min: 0.0, max: 1.0, required: required);
  }

  /// Validate percentage values (0.0-1.0)
  static ValidationResult validatePercentage(double? percentage, String fieldName, {bool required = true}) {
    return validateRange(percentage, fieldName, min: 0.0, max: 1.0, required: required);
  }

  /// Validate lists
  static ValidationResult validateList<T>(
    List<T>? list, 
    String fieldName, {
    int? minSize,
    int? maxSize,
    bool required = false,
  }) {
    if (list == null || list.isEmpty) {
      if (required) {
        return ValidationResult.error('$fieldName is required and cannot be empty');
      }
      return ValidationResult.valid();
    }

    if (minSize != null && list.length < minSize) {
      return ValidationResult.error('$fieldName must have at least $minSize items');
    }

    if (maxSize != null && list.length > maxSize) {
      return ValidationResult.error('$fieldName cannot have more than $maxSize items');
    }

    return ValidationResult.valid();
  }

  /// Validate dates
  static ValidationResult validateDate(
    DateTime? date, 
    String fieldName, {
    DateTime? minDate,
    DateTime? maxDate,
    bool required = true,
  }) {
    if (date == null) {
      if (required) {
        return ValidationResult.error('$fieldName is required');
      }
      return ValidationResult.valid();
    }

    if (minDate != null && date.isBefore(minDate)) {
      return ValidationResult.error('$fieldName cannot be before ${_formatDate(minDate)}');
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return ValidationResult.error('$fieldName cannot be after ${_formatDate(maxDate)}');
    }

    return ValidationResult.valid();
  }

  /// Validate that a date is in the future
  static ValidationResult validateFutureDate(DateTime? date, String fieldName, {bool required = true}) {
    final result = validateDate(date, fieldName, required: required);
    if (!result.isValid) return result;

    if (date != null && date.isBefore(DateTime.now())) {
      return ValidationResult.error('$fieldName must be in the future');
    }

    return ValidationResult.valid();
  }

  /// Validate that a date is in the past
  static ValidationResult validatePastDate(DateTime? date, String fieldName, {bool required = true}) {
    final result = validateDate(date, fieldName, required: required);
    if (!result.isValid) return result;

    if (date != null && date.isAfter(DateTime.now())) {
      return ValidationResult.error('$fieldName must be in the past');
    }

    return ValidationResult.valid();
  }

  /// Validate enum values
  static ValidationResult validateEnum<T extends Enum>(
    T? value, 
    String fieldName, 
    List<T> validValues, {
    bool required = true,
  }) {
    if (value == null) {
      if (required) {
        return ValidationResult.error('$fieldName is required');
      }
      return ValidationResult.valid();
    }

    if (!validValues.contains(value)) {
      return ValidationResult.error('$fieldName has an invalid value');
    }

    return ValidationResult.valid();
  }

  /// Validate Australian Business Number (ABN)
  static ValidationResult validateABN(String? abn, {bool required = false}) {
    if (abn == null || abn.isEmpty) {
      if (required) {
        return ValidationResult.error('ABN is required');
      }
      return ValidationResult.valid();
    }

    // Remove spaces and format characters
    final cleanABN = abn.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Check length and numeric
    if (cleanABN.length != 11 || !RegExp(r'^\d{11}$').hasMatch(cleanABN)) {
      return ValidationResult.error('ABN must be 11 digits');
    }

    // Validate ABN checksum algorithm
    final digits = cleanABN.split('').map(int.parse).toList();
    final weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
    
    // Subtract 1 from first digit
    digits[0] -= 1;
    
    // Calculate weighted sum
    var sum = 0;
    for (int i = 0; i < 11; i++) {
      sum += digits[i] * weights[i];
    }
    
    if (sum % 89 != 0) {
      return ValidationResult.error('ABN checksum is invalid');
    }

    return ValidationResult.valid();
  }

  /// Validate URL format
  static ValidationResult validateUrl(String? url, {bool required = false}) {
    if (url == null || url.isEmpty) {
      if (required) {
        return ValidationResult.error('URL is required');
      }
      return ValidationResult.valid();
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return ValidationResult.error('Please enter a valid URL');
      }
      
      if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
        return ValidationResult.error('URL must use http or https protocol');
      }
      
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.error('Please enter a valid URL');
    }
  }

  /// Validate JSON structure
  static ValidationResult validateJson(String? jsonString, {bool required = false}) {
    if (jsonString == null || jsonString.isEmpty) {
      if (required) {
        return ValidationResult.error('JSON data is required');
      }
      return ValidationResult.valid();
    }

    try {
      // This will throw if invalid JSON
      // ignore: unused_local_variable
      final decoded = jsonDecode(jsonString);
      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.error('Invalid JSON format: ${e.toString()}');
    }
  }

  /// Validate Australian postcode
  static ValidationResult validateAustralianPostcode(String? postcode, {bool required = false}) {
    if (postcode == null || postcode.isEmpty) {
      if (required) {
        return ValidationResult.error('Postcode is required');
      }
      return ValidationResult.valid();
    }

    if (!RegExp(r'^\d{4}$').hasMatch(postcode)) {
      return ValidationResult.error('Australian postcode must be 4 digits');
    }

    // Basic range validation for Australian postcodes
    final code = int.parse(postcode);
    if (code < 1000 || code > 9999) {
      return ValidationResult.error('Invalid Australian postcode range');
    }

    return ValidationResult.valid();
  }

  /// Combine multiple validation results
  static ValidationResult combineResults(List<ValidationResult> results) {
    final errors = results
        .where((result) => !result.isValid)
        .map((result) => result.error!)
        .toList();

    if (errors.isEmpty) {
      return ValidationResult.valid();
    }

    return ValidationResult.error(errors.join('; '));
  }

  /// Helper method to format dates
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Result of a validation operation
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult._(this.isValid, this.error);

  factory ValidationResult.valid() => const ValidationResult._(true, null);
  
  factory ValidationResult.error(String error) => ValidationResult._(false, error);

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $error';
  }
}

/// Custom validation exceptions for models
class ModelValidationException implements Exception {
  final String message;
  final String? field;
  final dynamic value;

  const ModelValidationException(this.message, {this.field, this.value});

  @override
  String toString() {
    if (field != null) {
      return 'ModelValidationException: $field - $message';
    }
    return 'ModelValidationException: $message';
  }
}

/// Extension methods for easy validation in models
extension ModelValidationExtensions on String? {
  /// Validate as required string
  ValidationResult validateRequired(String fieldName) {
    return ModelValidation.validateString(this, fieldName, required: true);
  }

  /// Validate as optional string
  ValidationResult validateOptional(String fieldName, {int? maxLength}) {
    return ModelValidation.validateString(this, fieldName, required: false, maxLength: maxLength);
  }

  /// Validate as email
  ValidationResult validateEmail({bool required = true}) {
    return ModelValidation.validateEmail(this, required: required);
  }

  /// Validate as Australian phone
  ValidationResult validateAustralianPhone({bool required = false}) {
    return ModelValidation.validateAustralianPhone(this, required: required);
  }

  /// Validate as URL
  ValidationResult validateUrl({bool required = false}) {
    return ModelValidation.validateUrl(this, required: required);
  }
}

extension NumValidationExtensions on num? {
  /// Validate numeric range
  ValidationResult validateRange(String fieldName, {num? min, num? max, bool required = true}) {
    return ModelValidation.validateRange(this, fieldName, min: min, max: max, required: required);
  }
}

extension IntValidationExtensions on int? {
  /// Validate as rating (1-5)
  ValidationResult validateRating(String fieldName, {bool required = true}) {
    return ModelValidation.validateRating(this, fieldName, required: required);
  }
}

extension DoubleValidationExtensions on double? {
  /// Validate as confidence score (0.0-1.0)
  ValidationResult validateConfidence({bool required = true}) {
    return ModelValidation.validateConfidence(this, required: required);
  }

  /// Validate as percentage (0.0-1.0)
  ValidationResult validatePercentage(String fieldName, {bool required = true}) {
    return ModelValidation.validatePercentage(this, fieldName, required: required);
  }
}

extension ListValidationExtensions<T> on List<T>? {
  /// Validate list requirements
  ValidationResult validateList(String fieldName, {int? minSize, int? maxSize, bool required = false}) {
    return ModelValidation.validateList(this, fieldName, minSize: minSize, maxSize: maxSize, required: required);
  }
}

extension DateTimeValidationExtensions on DateTime? {
  /// Validate date requirements
  ValidationResult validateDate(String fieldName, {DateTime? minDate, DateTime? maxDate, bool required = true}) {
    return ModelValidation.validateDate(this, fieldName, minDate: minDate, maxDate: maxDate, required: required);
  }

  /// Validate as future date
  ValidationResult validateFutureDate(String fieldName, {bool required = true}) {
    return ModelValidation.validateFutureDate(this, fieldName, required: required);
  }

  /// Validate as past date
  ValidationResult validatePastDate(String fieldName, {bool required = true}) {
    return ModelValidation.validatePastDate(this, fieldName, required: required);
  }
}

/// Safe JSON decoding with validation
class SafeJsonDecoder {
  /// Safely decode JSON string
  static Map<String, dynamic>? decodeObject(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('Expected JSON object');
    } catch (e) {
      throw ModelValidationException('Invalid JSON: ${e.toString()}');
    }
  }

  /// Safely decode JSON array
  static List<dynamic>? decodeArray(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded;
      }
      throw const FormatException('Expected JSON array');
    } catch (e) {
      throw ModelValidationException('Invalid JSON array: ${e.toString()}');
    }
  }

  /// Get string value safely from JSON
  static String? getString(Map<String, dynamic> json, String key, {String? defaultValue}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Get integer value safely from JSON
  static int? getInt(Map<String, dynamic> json, String key, {int? defaultValue}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return defaultValue;
  }

  /// Get double value safely from JSON
  static double? getDouble(Map<String, dynamic> json, String key, {double? defaultValue}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return defaultValue;
  }

  /// Get boolean value safely from JSON
  static bool? getBool(Map<String, dynamic> json, String key, {bool? defaultValue}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return defaultValue;
  }

  /// Get DateTime value safely from JSON
  static DateTime? getDateTime(Map<String, dynamic> json, String key, {DateTime? defaultValue}) {
    final value = json[key];
    if (value == null) return defaultValue;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}