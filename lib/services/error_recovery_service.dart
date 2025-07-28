import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
// Removed connectivity_plus dependency for local-only operation
import '../utils/logger.dart';

/// Comprehensive error handling and retry logic service
/// Provides intelligent error recovery, retry strategies, and resilience patterns
class ErrorRecoveryService {
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const int _maxRetryAttempts = 5;
  static const Duration _circuitBreakerThreshold = Duration(minutes: 5);
  static const int _circuitBreakerFailureThreshold = 10;
  
  final Map<String, RetryContext> _retryContexts = {};
  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final StreamController<ErrorEvent> _errorEventController = StreamController<ErrorEvent>.broadcast();
  final Connectivity _connectivity = Connectivity();
  
  /// Execute operation with comprehensive error handling and retry logic
  Future<T> executeWithRetry<T>(
    String operationId,
    Future<T> Function() operation, {
    RetryStrategy strategy = RetryStrategy.exponentialBackoff,
    int? maxAttempts,
    Duration? baseDelay,
    List<Type>? retryableExceptions,
    List<Type>? nonRetryableExceptions,
    bool useCircuitBreaker = true,
    Duration? timeout,
  }) async {
    final context = _getOrCreateRetryContext(
      operationId,
      maxAttempts ?? _maxRetryAttempts,
      baseDelay ?? _baseRetryDelay,
      strategy,
    );
    
    final circuitBreaker = useCircuitBreaker ? _getOrCreateCircuitBreaker(operationId) : null;
    
    // Check circuit breaker
    if (circuitBreaker != null && circuitBreaker.isOpen) {
      throw CircuitBreakerOpenException('Circuit breaker is open for operation: $operationId');
    }
    
    for (int attempt = 1; attempt <= context.maxAttempts; attempt++) {
      try {
        context.currentAttempt = attempt;
        
        AppLogger.debug('Executing operation $operationId (attempt $attempt/${context.maxAttempts})');
        
        // Execute with timeout if specified
        final T result = timeout != null 
            ? await operation().timeout(timeout)
            : await operation();
        
        // Success - reset retry context and close circuit breaker
        _resetRetryContext(operationId);
        circuitBreaker?.recordSuccess();
        
        AppLogger.debug('Operation $operationId completed successfully');
        return result;
        
      } catch (e, stackTrace) {
        final errorEvent = ErrorEvent(
          operationId: operationId,
          attempt: attempt,
          maxAttempts: context.maxAttempts,
          error: e,
          stackTrace: stackTrace,
          timestamp: DateTime.now(),
        );
        
        _errorEventController.add(errorEvent);
        AppLogger.warning('Operation $operationId failed (attempt $attempt): $e');
        
        // Check if error is retryable
        if (!_isRetryableError(e, retryableExceptions, nonRetryableExceptions)) {
          circuitBreaker?.recordFailure();
          throw NonRetryableException('Non-retryable error in operation $operationId', e);
        }
        
        // Check if this is the last attempt
        if (attempt >= context.maxAttempts) {
          circuitBreaker?.recordFailure();
          throw MaxRetriesExceededException(
            'Operation $operationId failed after $attempt attempts',
            e,
            attempt,
          );
        }
        
        // Calculate delay and wait
        final delay = _calculateDelay(context, attempt);
        AppLogger.debug('Retrying operation $operationId in ${delay.inMilliseconds}ms');
        
        await Future.delayed(delay);
        
        // Check if we should continue retrying (e.g., network connectivity)
        if (!await _shouldContinueRetrying(e)) {
          circuitBreaker?.recordFailure();
          throw RetryAbortedException('Retry aborted for operation $operationId', e);
        }
      }
    }
    
    // This should never be reached, but included for completeness
    throw MaxRetriesExceededException(
      'Operation $operationId failed after ${context.maxAttempts} attempts',
      null,
      context.maxAttempts,
    );
  }

  /// Execute operation with deadline and automatic cancellation
  Future<T> executeWithDeadline<T>(
    String operationId,
    Future<T> Function() operation,
    Duration deadline, {
    VoidCallback? onTimeout,
  }) async {
    try {
      return await operation().timeout(deadline);
    } on TimeoutException catch (e) {
      AppLogger.error('Operation $operationId timed out after ${deadline.inMilliseconds}ms', e);
      onTimeout?.call();
      
      _errorEventController.add(ErrorEvent(
        operationId: operationId,
        attempt: 1,
        maxAttempts: 1,
        error: e,
        stackTrace: StackTrace.current,
        timestamp: DateTime.now(),
      ));
      
      throw OperationTimeoutException('Operation $operationId timed out', deadline);
    }
  }

  /// Execute operation with fallback
  Future<T> executeWithFallback<T>(
    String operationId,
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation, {
    List<Type>? fallbackTriggers,
  }) async {
    try {
      return await primaryOperation();
    } catch (e, stackTrace) {
      AppLogger.warning('Primary operation $operationId failed, trying fallback: $e');
      
      // Check if this error should trigger fallback
      if (fallbackTriggers != null && !fallbackTriggers.any((type) => e.runtimeType == type)) {
        rethrow;
      }
      
      try {
        final result = await fallbackOperation();
        
        _errorEventController.add(ErrorEvent(
          operationId: operationId,
          attempt: 1,
          maxAttempts: 1,
          error: e,
          stackTrace: stackTrace,
          timestamp: DateTime.now(),
          recoveredWithFallback: true,
        ));
        
        AppLogger.info('Operation $operationId recovered using fallback');
        return result;
      } catch (fallbackError, fallbackStackTrace) {
        AppLogger.error('Fallback operation also failed for $operationId', fallbackError, fallbackStackTrace);
        
        _errorEventController.add(ErrorEvent(
          operationId: operationId,
          attempt: 1,
          maxAttempts: 1,
          error: FallbackFailedException('Both primary and fallback operations failed', e, fallbackError),
          stackTrace: fallbackStackTrace,
          timestamp: DateTime.now(),
        ));
        
        throw FallbackFailedException('Both primary and fallback operations failed for $operationId', e, fallbackError);
      }
    }
  }

  /// Execute batch operation with partial failure handling
  Future<BatchResult<T>> executeBatchWithRecovery<T>(
    String operationId,
    List<Future<T> Function()> operations, {
    int? maxConcurrency,
    bool continueOnError = true,
    RetryStrategy retryStrategy = RetryStrategy.exponentialBackoff,
  }) async {
    final concurrency = maxConcurrency ?? min(operations.length, 10);
    final results = <T>[];
    final errors = <BatchError>[];
    final semaphore = Semaphore(concurrency);
    
    Future<void> executeOperation(int index, Future<T> Function() operation) async {
      await semaphore.acquire();
      
      try {
        final result = await executeWithRetry(
          '${operationId}_batch_$index',
          operation,
          strategy: retryStrategy,
        );
        results.add(result);
      } catch (e, stackTrace) {
        final batchError = BatchError(
          index: index,
          error: e,
          stackTrace: stackTrace,
        );
        errors.add(batchError);
        
        if (!continueOnError) {
          throw batchError;
        }
      } finally {
        semaphore.release();
      }
    }
    
    // Execute all operations
    final futures = operations.asMap().entries.map((entry) => 
        executeOperation(entry.key, entry.value));
    
    await Future.wait(futures, eagerError: !continueOnError);
    
    return BatchResult<T>(
      successes: results,
      errors: errors,
      successCount: results.length,
      errorCount: errors.length,
      totalCount: operations.length,
    );
  }

  /// Execute operation with health check
  Future<T> executeWithHealthCheck<T>(
    String operationId,
    Future<T> Function() operation,
    Future<bool> Function() healthCheck, {
    Duration healthCheckInterval = const Duration(seconds: 30),
    int maxHealthCheckFailures = 3,
  }) async {
    var healthCheckFailures = 0;
    Timer? healthCheckTimer;
    
    try {
      // Start health check monitoring
      healthCheckTimer = Timer.periodic(healthCheckInterval, (timer) async {
        try {
          final isHealthy = await healthCheck();
          if (!isHealthy) {
            healthCheckFailures++;
            AppLogger.warning('Health check failed for $operationId ($healthCheckFailures/$maxHealthCheckFailures)');
            
            if (healthCheckFailures >= maxHealthCheckFailures) {
              timer.cancel();
              throw HealthCheckFailedException('Health check failed $healthCheckFailures times for $operationId');
            }
          } else {
            healthCheckFailures = 0; // Reset on success
          }
        } catch (e) {
          healthCheckFailures++;
          AppLogger.error('Health check error for $operationId', e);
        }
      });
      
      return await operation();
    } finally {
      healthCheckTimer?.cancel();
    }
  }

  /// Get or create retry context
  RetryContext _getOrCreateRetryContext(
    String operationId,
    int maxAttempts,
    Duration baseDelay,
    RetryStrategy strategy,
  ) {
    return _retryContexts.putIfAbsent(
      operationId,
      () => RetryContext(
        operationId: operationId,
        maxAttempts: maxAttempts,
        baseDelay: baseDelay,
        strategy: strategy,
      ),
    );
  }

  /// Get or create circuit breaker
  CircuitBreaker _getOrCreateCircuitBreaker(String operationId) {
    return _circuitBreakers.putIfAbsent(
      operationId,
      () => CircuitBreaker(
        operationId: operationId,
        failureThreshold: _circuitBreakerFailureThreshold,
        timeout: _circuitBreakerThreshold,
      ),
    );
  }

  /// Reset retry context after successful operation
  void _resetRetryContext(String operationId) {
    _retryContexts.remove(operationId);
  }

  /// Calculate delay based on retry strategy
  Duration _calculateDelay(RetryContext context, int attempt) {
    switch (context.strategy) {
      case RetryStrategy.fixed:
        return context.baseDelay;
        
      case RetryStrategy.linear:
        return context.baseDelay * attempt;
        
      case RetryStrategy.exponentialBackoff:
        final delayMs = context.baseDelay.inMilliseconds * pow(2, attempt - 1);
        return Duration(milliseconds: min(delayMs.toInt(), 30000)); // Cap at 30 seconds
        
      case RetryStrategy.exponentialBackoffWithJitter:
        final baseDelayMs = context.baseDelay.inMilliseconds * pow(2, attempt - 1);
        final jitter = Random().nextDouble() * 0.1; // ±10% jitter
        final jitteredDelayMs = baseDelayMs * (1 + jitter);
        return Duration(milliseconds: min(jitteredDelayMs.toInt(), 30000));
    }
  }

  /// Check if error is retryable
  bool _isRetryableError(
    dynamic error,
    List<Type>? retryableExceptions,
    List<Type>? nonRetryableExceptions,
  ) {
    // Check non-retryable exceptions first
    if (nonRetryableExceptions != null) {
      if (nonRetryableExceptions.any((type) => error.runtimeType == type)) {
        return false;
      }
    }
    
    // Check explicit retryable exceptions
    if (retryableExceptions != null) {
      return retryableExceptions.any((type) => error.runtimeType == type);
    }
    
    // Default retryable error types
    return error is SocketException ||
           error is TimeoutException ||
           error is HttpException ||
           (error is Exception && error.toString().toLowerCase().contains('network')) ||
           (error is Exception && error.toString().toLowerCase().contains('connection'));
  }

  /// Check if we should continue retrying based on system state
  Future<bool> _shouldContinueRetrying(dynamic error) async {
    // Check network connectivity for network-related errors
    if (error is SocketException || error is TimeoutException) {
      try {
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          AppLogger.info('No network connectivity - aborting retry');
          return false;
        }
      } catch (e) {
        AppLogger.warning('Failed to check connectivity: $e');
      }
    }
    
    return true;
  }

  /// Get error statistics for monitoring
  ErrorStatistics getErrorStatistics({Duration? period}) {
    final cutoff = period != null ? DateTime.now().subtract(period) : null;
    
    final events = cutoff != null 
        ? _errorEventController.stream.where((event) => event.timestamp.isAfter(cutoff))
        : _errorEventController.stream;
    
    // Note: This is a simplified version. In production, you'd want to store 
    // error events and calculate statistics from stored data.
    
    return ErrorStatistics(
      totalErrors: 0, // Would be calculated from stored events
      retrySuccessRate: 0.0,
      circuitBreakerTrips: _circuitBreakers.values.where((cb) => cb.isOpen).length,
      commonErrors: {},
      averageRetryAttempts: 0.0,
    );
  }

  /// Reset circuit breaker for operation
  void resetCircuitBreaker(String operationId) {
    final circuitBreaker = _circuitBreakers[operationId];
    if (circuitBreaker != null) {
      circuitBreaker.reset();
      AppLogger.info('Circuit breaker reset for operation: $operationId');
    }
  }

  /// Get circuit breaker status
  CircuitBreakerStatus? getCircuitBreakerStatus(String operationId) {
    final circuitBreaker = _circuitBreakers[operationId];
    return circuitBreaker?.status;
  }

  /// Stream of error events for monitoring
  Stream<ErrorEvent> get errorEventStream => _errorEventController.stream;

  /// Close the service and clean up resources
  void close() {
    _errorEventController.close();
    _retryContexts.clear();
    _circuitBreakers.clear();
  }
}

/// Retry context for tracking retry state
class RetryContext {
  final String operationId;
  final int maxAttempts;
  final Duration baseDelay;
  final RetryStrategy strategy;
  int currentAttempt = 0;

  RetryContext({
    required this.operationId,
    required this.maxAttempts,
    required this.baseDelay,
    required this.strategy,
  });
}

/// Circuit breaker implementation
class CircuitBreaker {
  final String operationId;
  final int failureThreshold;
  final Duration timeout;
  
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  CircuitBreakerState _state = CircuitBreakerState.closed;

  CircuitBreaker({
    required this.operationId,
    required this.failureThreshold,
    required this.timeout,
  });

  bool get isOpen => _state == CircuitBreakerState.open;
  bool get isHalfOpen => _state == CircuitBreakerState.halfOpen;
  bool get isClosed => _state == CircuitBreakerState.closed;

  void recordSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
  }

  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    
    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      AppLogger.warning('Circuit breaker opened for operation: $operationId');
    }
  }

  void reset() {
    _failureCount = 0;
    _lastFailureTime = null;
    _state = CircuitBreakerState.closed;
  }

  CircuitBreakerStatus get status {
    // Check if we should transition from open to half-open
    if (_state == CircuitBreakerState.open && 
        _lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) > timeout) {
      _state = CircuitBreakerState.halfOpen;
    }

    return CircuitBreakerStatus(
      operationId: operationId,
      state: _state,
      failureCount: _failureCount,
      lastFailureTime: _lastFailureTime,
    );
  }
}

/// Semaphore for controlling concurrency
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

/// Error event for monitoring and analytics
class ErrorEvent {
  final String operationId;
  final int attempt;
  final int maxAttempts;
  final dynamic error;
  final StackTrace stackTrace;
  final DateTime timestamp;
  final bool recoveredWithFallback;

  const ErrorEvent({
    required this.operationId,
    required this.attempt,
    required this.maxAttempts,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    this.recoveredWithFallback = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'attempt': attempt,
      'maxAttempts': maxAttempts,
      'error': error.toString(),
      'timestamp': timestamp.toIso8601String(),
      'recoveredWithFallback': recoveredWithFallback,
    };
  }
}

/// Batch operation result
class BatchResult<T> {
  final List<T> successes;
  final List<BatchError> errors;
  final int successCount;
  final int errorCount;
  final int totalCount;

  const BatchResult({
    required this.successes,
    required this.errors,
    required this.successCount,
    required this.errorCount,
    required this.totalCount,
  });

  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
  bool get hasErrors => errors.isNotEmpty;
  bool get isComplete => successCount + errorCount == totalCount;
}

/// Batch operation error
class BatchError {
  final int index;
  final dynamic error;
  final StackTrace stackTrace;

  const BatchError({
    required this.index,
    required this.error,
    required this.stackTrace,
  });
}

/// Error statistics for monitoring
class ErrorStatistics {
  final int totalErrors;
  final double retrySuccessRate;
  final int circuitBreakerTrips;
  final Map<String, int> commonErrors;
  final double averageRetryAttempts;

  const ErrorStatistics({
    required this.totalErrors,
    required this.retrySuccessRate,
    required this.circuitBreakerTrips,
    required this.commonErrors,
    required this.averageRetryAttempts,
  });
}

/// Circuit breaker status
class CircuitBreakerStatus {
  final String operationId;
  final CircuitBreakerState state;
  final int failureCount;
  final DateTime? lastFailureTime;

  const CircuitBreakerStatus({
    required this.operationId,
    required this.state,
    required this.failureCount,
    this.lastFailureTime,
  });
}

/// Retry strategies
enum RetryStrategy {
  fixed,
  linear,
  exponentialBackoff,
  exponentialBackoffWithJitter,
}

/// Circuit breaker states
enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

/// Custom exceptions for error handling

class NonRetryableException implements Exception {
  final String message;
  final dynamic cause;

  const NonRetryableException(this.message, this.cause);

  @override
  String toString() => 'NonRetryableException: $message';
}

class MaxRetriesExceededException implements Exception {
  final String message;
  final dynamic cause;
  final int attempts;

  const MaxRetriesExceededException(this.message, this.cause, this.attempts);

  @override
  String toString() => 'MaxRetriesExceededException: $message (after $attempts attempts)';
}

class RetryAbortedException implements Exception {
  final String message;
  final dynamic cause;

  const RetryAbortedException(this.message, this.cause);

  @override
  String toString() => 'RetryAbortedException: $message';
}

class CircuitBreakerOpenException implements Exception {
  final String message;

  const CircuitBreakerOpenException(this.message);

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

class OperationTimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const OperationTimeoutException(this.message, this.timeout);

  @override
  String toString() => 'OperationTimeoutException: $message (timeout: ${timeout.inMilliseconds}ms)';
}

class FallbackFailedException implements Exception {
  final String message;
  final dynamic primaryError;
  final dynamic fallbackError;

  const FallbackFailedException(this.message, this.primaryError, this.fallbackError);

  @override
  String toString() => 'FallbackFailedException: $message';
}

class HealthCheckFailedException implements Exception {
  final String message;

  const HealthCheckFailedException(this.message);

  @override
  String toString() => 'HealthCheckFailedException: $message';
}