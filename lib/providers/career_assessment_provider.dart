import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';
import '../services/career_ai_service.dart';
import '../services/career_persistence_service.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// Provider for managing career self-assessment flow
/// Handles the 5 top-line questions, AI probing, and session management
class CareerAssessmentProvider extends ChangeNotifier {
  final CareerAIService _aiService;
  final CareerPersistenceService _persistenceService;
  
  // Current session state
  CareerSession? _currentSession;
  String? _currentDomain;
  String? _currentQuestionId;
  List<String> _currentProbes = [];
  
  // UI state
  bool _isLoading = false;
  bool _isAiThinking = false;
  String? _errorMessage;
  
  // Assessment flow state
  Map<String, List<String>> _domainProbes = {};
  Map<String, int> _probeCount = {};
  Set<String> _completedDomains = {};
  
  CareerAssessmentProvider({
    CareerAIService? aiService,
    CareerPersistenceService? persistenceService,
  }) : _aiService = aiService ?? CareerAIService(),
        _persistenceService = persistenceService ?? CareerPersistenceService() {
    _initialize();
  }
  
  // Getters
  CareerSession? get currentSession => _currentSession;
  String? get currentDomain => _currentDomain;
  String? get currentQuestionId => _currentQuestionId;
  List<String> get currentProbes => List.unmodifiable(_currentProbes);
  bool get isLoading => _isLoading;
  bool get isAiThinking => _isAiThinking;
  String? get errorMessage => _errorMessage;
  Set<String> get completedDomains => Set.unmodifiable(_completedDomains);
  
  /// Get the 5 top-line career questions
  Map<String, Map<String, String>> get topLineQuestions => CareerAIService.topLineQuestions;
  
  /// Get current question details
  Map<String, String>? get currentQuestion {
    if (_currentQuestionId == null) return null;
    return topLineQuestions[_currentQuestionId];
  }
  
  /// Get current probe count for domain
  int getCurrentProbeCount(String domain) {
    return _probeCount[domain] ?? 0;
  }
  
  /// Check if domain is completed
  bool isDomainCompleted(String domain) {
    return _completedDomains.contains(domain);
  }
  
  /// Get overall progress (0.0 to 1.0)
  double get overallProgress {
    final totalDomains = topLineQuestions.length;
    return totalDomains > 0 ? _completedDomains.length / totalDomains : 0.0;
  }
  
  /// Initialize the provider
  Future<void> _initialize() async {
    try {
      AppLogger.info('Initializing CareerAssessmentProvider');
      await _loadExistingSession();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize CareerAssessmentProvider', e, stackTrace);
      _setError('Failed to load previous session');
    }
  }
  
  /// Load existing session if available
  Future<void> _loadExistingSession() async {
    try {
      final sessions = await _persistenceService.getAllSessions();
      if (sessions.isNotEmpty) {
        // Get the most recent session
        final session = sessions.reduce((a, b) => 
          a.lastModified.isAfter(b.lastModified) ? a : b);
        
        _currentSession = session;
        _syncStateFromSession();
        AppLogger.info('Loaded existing session: ${session.id}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load existing session', e, stackTrace);
    }
  }
  
  /// Sync provider state from loaded session
  void _syncStateFromSession() {
    if (_currentSession == null) return;
    
    _completedDomains = Set.from(_currentSession!.completedDomains.map((d) => d.name));
    
    // Restore probe counts and questions
    for (final response in _currentSession!.responses.values) {
      final questionType = _getQuestionType(response.questionId);
      if (questionType != null) {
        _probeCount[questionType] = (_probeCount[questionType] ?? 0) + 1;
      }
    }
  }
  
  /// Start a new assessment session
  Future<void> startNewSession({
    required String sessionName,
    required ExplorationType explorationType,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final session = CareerSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        responses: {},
        insights: [],
        sessionName: sessionName,
        completedDomains: [],
        preferredExplorationType: explorationType,
      );
      
      await _persistenceService.saveSession(session);
      _currentSession = session;
      
      // Reset state
      _completedDomains.clear();
      _domainProbes.clear();
      _probeCount.clear();
      _currentDomain = null;
      _currentQuestionId = null;
      _currentProbes.clear();
      
      AppLogger.info('Started new assessment session: ${session.id}');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start new session', e, stackTrace);
      _setError('Failed to start new session');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Resume existing session
  Future<void> resumeSession(String sessionId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final session = await _persistenceService.getSession(sessionId);
      if (session != null) {
        _currentSession = session;
        _syncStateFromSession();
        AppLogger.info('Resumed session: $sessionId');
      } else {
        throw Exception('Session not found: $sessionId');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to resume session', e, stackTrace);
      _setError('Failed to resume session');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }
  
  /// Start exploring a specific domain
  Future<void> startDomainExploration(String domainKey) async {
    if (_currentSession == null) {
      _setError('No active session. Please start a new session first.');
      return;
    }
    
    try {
      _clearError();
      _currentDomain = domainKey;
      _currentQuestionId = domainKey;
      _currentProbes.clear();
      
      AppLogger.info('Started exploring domain: $domainKey');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start domain exploration', e, stackTrace);
      _setError('Failed to start domain exploration');
    }
  }
  
  /// Submit response to current question
  Future<void> submitResponse(String response) async {
    if (_currentSession == null || _currentQuestionId == null) {
      _setError('No active question to respond to');
      return;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      final questionData = topLineQuestions[_currentQuestionId!];
      if (questionData == null) {
        throw Exception('Question not found: $_currentQuestionId');
      }
      
      // Create response record
      final careerResponse = CareerResponse.create(
        questionId: questionData['id']!,
        questionText: questionData['question']!,
        response: response,
        domain: _getDomainFromQuestionId(_currentQuestionId!),
      );
      
      // Save response to session
      final updatedResponses = Map<String, CareerResponse>.from(_currentSession!.responses);
      updatedResponses[careerResponse.questionId] = careerResponse;
      
      _currentSession = _currentSession!.copyWith(
        responses: updatedResponses,
        lastModified: DateTime.now(),
      );
      
      await _persistenceService.saveSession(_currentSession!);
      
      AppLogger.info('Submitted response for question: $_currentQuestionId');
      
      // Generate AI probes if needed
      await _generateProbesIfNeeded(careerResponse);
      
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit response', e, stackTrace);
      _setError('Failed to save response');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Generate AI probes if needed - let user control when to stop
  Future<void> _generateProbesIfNeeded(CareerResponse response) async {
    if (_currentQuestionId == null) return;
    
    // Remove arbitrary probe limits - let the user decide when they're done exploring
    
    try {
      _setAiThinking(true);
      
      final questionData = topLineQuestions[_currentQuestionId!];
      if (questionData == null) return;
      
      final probes = await _aiService.generateProbingQuestions(
        questionId: questionData['id']!,
        questionText: questionData['question']!,
        userResponse: response.response,
        previousProbes: _currentProbes,
        domain: questionData['domain']!,
      );
      
      if (probes.isNotEmpty) {
        _currentProbes.addAll(probes);
        _probeCount[_currentQuestionId!] = (_probeCount[_currentQuestionId!] ?? 0) + 1;
        AppLogger.info('Generated ${probes.length} probes for $_currentQuestionId');
      } else {
        // AI couldn't generate more probes, but don't auto-complete - let user decide
        AppLogger.info('No additional probes generated for $_currentQuestionId - user can continue or finish');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate probes', e, stackTrace);
      // Even if AI fails, don't auto-complete - let user continue their exploration
      AppLogger.info('AI probe generation failed, but continuing with user-driven exploration');
    } finally {
      _setAiThinking(false);
    }
  }
  
  /// Submit response to a probe question
  Future<void> submitProbeResponse(String probeQuestion, String response) async {
    if (_currentSession == null || _currentQuestionId == null) {
      _setError('No active probe question');
      return;
    }
    
    try {
      _setLoading(true);
      _clearError();
      
      // Create response record for probe
      final probeId = '${_currentQuestionId}_probe_${DateTime.now().millisecondsSinceEpoch}';
      final careerResponse = CareerResponse.create(
        questionId: probeId,
        questionText: probeQuestion,
        response: response,
        domain: _getDomainFromQuestionId(_currentQuestionId!),
      );
      
      // Save probe response to session
      final updatedResponses = Map<String, CareerResponse>.from(_currentSession!.responses);
      updatedResponses[probeId] = careerResponse;
      
      _currentSession = _currentSession!.copyWith(
        responses: updatedResponses,
        lastModified: DateTime.now(),
      );
      
      await _persistenceService.saveSession(_currentSession!);
      
      AppLogger.info('Submitted probe response for: $_currentQuestionId');
      
      // Generate more probes if needed
      await _generateProbesIfNeeded(careerResponse);
      
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit probe response', e, stackTrace);
      _setError('Failed to save probe response');
    } finally {
      _setLoading(false);
    }
  }
  
  /// User manually completes a domain when they're satisfied with their exploration
  Future<void> completeDomainByUser(String domainKey) async {
    await _completeDomain(domainKey);
  }
  
  /// Complete a domain (internal method)
  Future<void> _completeDomain(String domainKey) async {
    try {
      _completedDomains.add(domainKey);
      
      final domain = _getDomainFromQuestionId(domainKey);
      final updatedCompletedDomains = List<CareerDomain>.from(_currentSession!.completedDomains);
      if (!updatedCompletedDomains.contains(domain)) {
        updatedCompletedDomains.add(domain);
      }
      
      _currentSession = _currentSession!.copyWith(
        completedDomains: updatedCompletedDomains,
        lastModified: DateTime.now(),
      );
      
      await _persistenceService.saveSession(_currentSession!);
      
      AppLogger.info('Completed domain: $domainKey');
      
      // Generate insights if this was the last domain
      if (_completedDomains.length >= topLineQuestions.length) {
        await _generateFinalInsights();
      }
      
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to complete domain', e, stackTrace);
      _setError('Failed to complete domain');
    }
  }
  
  /// Generate final insights when assessment is complete
  Future<void> _generateFinalInsights() async {
    if (_currentSession == null) return;
    
    try {
      _setAiThinking(true);
      
      final insights = await _aiService.generateCareerInsights(
        responses: _currentSession!.responses.values.toList(),
        sessionId: _currentSession!.id,
      );
      
      _currentSession = _currentSession!.copyWith(
        insights: insights,
        lastModified: DateTime.now(),
      );
      
      await _persistenceService.saveSession(_currentSession!);
      
      AppLogger.info('Generated ${insights.length} final insights');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate final insights', e, stackTrace);
    } finally {
      _setAiThinking(false);
    }
  }
  
  /// Get next recommended domain
  String? getNextRecommendedDomain() {
    final remaining = topLineQuestions.keys.where((key) => !_completedDomains.contains(key)).toList();
    if (remaining.isEmpty) return null;
    
    // Return first remaining domain (could be enhanced with AI recommendations)
    return remaining.first;
  }
  
  /// Reset current domain exploration
  Future<void> resetCurrentDomain() async {
    if (_currentQuestionId == null) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      // Remove responses for current domain
      final updatedResponses = Map<String, CareerResponse>.from(_currentSession!.responses);
      updatedResponses.removeWhere((key, value) => 
        key.startsWith(_currentQuestionId!) || 
        value.questionId.startsWith(_currentQuestionId!));
      
      // Remove from completed domains
      _completedDomains.remove(_currentQuestionId!);
      _probeCount.remove(_currentQuestionId!);
      _currentProbes.clear();
      
      final domain = _getDomainFromQuestionId(_currentQuestionId!);
      final updatedCompletedDomains = _currentSession!.completedDomains.where((d) => d != domain).toList();
      
      _currentSession = _currentSession!.copyWith(
        responses: updatedResponses,
        completedDomains: updatedCompletedDomains,
        lastModified: DateTime.now(),
      );
      
      await _persistenceService.saveSession(_currentSession!);
      
      AppLogger.info('Reset domain: $_currentQuestionId');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reset domain', e, stackTrace);
      _setError('Failed to reset domain');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Delete current session
  Future<void> deleteCurrentSession() async {
    if (_currentSession == null) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      await _persistenceService.deleteSession(_currentSession!.id);
      
      _currentSession = null;
      _currentDomain = null;
      _currentQuestionId = null;
      _currentProbes.clear();
      _completedDomains.clear();
      _domainProbes.clear();
      _probeCount.clear();
      
      AppLogger.info('Deleted current session');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete session', e, stackTrace);
      _setError('Failed to delete session');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Utility methods
  String? _getQuestionType(String questionId) {
    if (questionId.contains('joy_energy')) return 'joy_energy';
    if (questionId.contains('strengths')) return 'strengths';
    if (questionId.contains('sought_for')) return 'sought_for';
    if (questionId.contains('values_impact')) return 'values_impact';
    if (questionId.contains('life_design')) return 'life_design';
    return null;
  }
  
  CareerDomain _getDomainFromQuestionId(String questionId) {
    switch (questionId) {
      case 'joy_energy':
        return CareerDomain.social;
      case 'strengths':
        return CareerDomain.analytical;
      case 'sought_for':
        return CareerDomain.social;
      case 'values_impact':
        return CareerDomain.leadership;
      case 'life_design':
        return CareerDomain.creative;
      default:
        return CareerDomain.social;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setAiThinking(bool thinking) {
    _isAiThinking = thinking;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    if (error != null) {
      AppLogger.warning('CareerAssessmentProvider error: $error');
    }
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  @override
  void dispose() {
    AppLogger.debug('Disposing CareerAssessmentProvider');
    super.dispose();
  }
}

// Riverpod provider for CareerAssessmentProvider
final careerAssessmentProvider = ChangeNotifierProvider<CareerAssessmentProvider>((ref) {
  final persistenceService = ref.read(careerPersistenceServiceProvider);
  return CareerAssessmentProvider(persistenceService: persistenceService);
});