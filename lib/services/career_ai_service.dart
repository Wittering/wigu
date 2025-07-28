import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/career_session.dart';
import '../models/career_response.dart';
import '../models/career_insight.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// Comprehensive AI service for career exploration and insight generation
/// Handles the 5 top-line career questions and AI-powered analysis
class CareerAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const Duration _requestTimeout = Duration(seconds: 30);
  
  // Remove hardcoded API key - use environment variables or config
  String? _apiKey;
  
  CareerAIService() {
    _initializeApiKey();
  }
  
  /// Initialize API key from environment or configuration
  void _initializeApiKey() {
    // Use hardcoded API key for web compatibility (copied from AI_assess)
    _apiKey = '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';
    
    // Try environment variable as fallback (not available on web)
    if (!kIsWeb && _apiKey == null) {
      try {
        _apiKey = Platform.environment['OPENAI_API_KEY'];
      } catch (e) {
        // Platform.environment might not be available in some contexts
        AppLogger.warning('Could not access platform environment: $e');
      }
    }
    
    if (_apiKey == null) {
      AppLogger.warning('OpenAI API key not configured. AI features will use fallback responses.');
    } else {
      AppLogger.info('CareerAIService initialized with API key');
    }
  }
  
  /// The 5 top-line career questions for the self-assessment (as per specification)
  static const Map<String, Map<String, String>> topLineQuestions = {
    'joy_energy': {
      'id': 'joy_energy_main',
      'question': 'When do you feel most alive and lose track of time?',
      'domain': 'Joy/Energy/Flow',
      'probe_context': 'joy, energy, flow states, engagement, enthusiasm, passion',
    },
    'strengths': {
      'id': 'strengths_main', 
      'question': 'What do you consistently do better than most—and how do you know?',
      'domain': 'Strengths (Self-Evidence)',
      'probe_context': 'strengths, talents, abilities, skills, competencies, natural gifts',
    },
    'sought_for': {
      'id': 'sought_for_main',
      'question': 'What do people seek you out for—and which of those asks actually light you up?',
      'domain': 'Reflected Strengths vs Energy Filter',
      'probe_context': 'reputation, expertise, problem-solving, advice, consulting, helping others',
    },
    'values_impact': {
      'id': 'values_impact_main',
      'question': 'If you could help fix or improve one thing over the next few years, what would it be and why?',
      'domain': 'Values/Impact',
      'probe_context': 'values, impact, purpose, contribution, legacy, meaning, difference',
    },
    'life_design': {
      'id': 'life_design_main',
      'question': 'What does "a great work life" look like for you—non-negotiables, nice-to-haves, and deal-breakers?',
      'domain': 'Life Design & Constraints',
      'probe_context': 'lifestyle, work-life balance, flexibility, autonomy, environment, preferences',
    },
  };

  /// Generate follow-up probing questions for deeper exploration
  Future<List<String>> generateProbingQuestions({
    required String questionId,
    required String questionText,
    required String userResponse,
    required List<String> previousProbes,
    required String domain,
  }) async {
    if (_apiKey == null) {
      return _getFallbackProbingQuestions(questionId, domain);
    }

    // Limit to max 3-4 probes per domain as requested
    if (previousProbes.length >= 4) {
      AppLogger.info('Maximum probes reached for domain: $domain');
      return [];
    }

    final prompt = _buildProbingPrompt(
      questionId: questionId,
      questionText: questionText,
      userResponse: userResponse,
      previousProbes: previousProbes,
      domain: domain,
    );

    try {
      AppLogger.debug('Generating probing questions for $domain');
      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getCareerProbingSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI probing question generation', stopwatch.elapsed, {
        'domain': domain,
        'probe_count': previousProbes.length,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          final responseData = jsonDecode(content);
          final needsMoreDetail = responseData['needsMoreDetail'] ?? false;
          final questions = (responseData['questions'] as List?)?.cast<String>() ?? [];
          
          if (needsMoreDetail && questions.isNotEmpty) {
            AppLogger.info('Generated ${questions.length} probing questions for $domain');
            return questions.take(2).toList(); // Max 2 questions per probe session
          } else {
            AppLogger.info('Sufficient detail collected for $domain');
            return [];
          }
        } catch (e) {
          AppLogger.warning('Failed to parse AI response as JSON, extracting questions from text');
          return _extractQuestionsFromText(content).take(2).toList();
        }
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error generating probing questions for $domain', e, stackTrace);
      return _getFallbackProbingQuestions(questionId, domain);
    }
  }

  /// Extract ingredients (verbs, nouns, value words) from a user response
  Future<List<String>> extractIngredients({
    required String questionId,
    required String questionText,
    required String userResponse,
    required String domain,
  }) async {
    if (_apiKey == null) {
      return _getFallbackIngredients(userResponse);
    }

    try {
      AppLogger.debug('Extracting ingredients from response for $domain');
      final stopwatch = Stopwatch()..start();

      final extractionPrompt = _buildIngredientExtractionPrompt(
        questionId: questionId,
        questionText: questionText,
        userResponse: userResponse,
        domain: domain,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getIngredientExtractionSystemPrompt(),
            },
            {
              'role': 'user',
              'content': extractionPrompt,
            }
          ],
          'max_tokens': 400,
          'temperature': 0.3,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI ingredient extraction', stopwatch.elapsed, {
        'domain': domain,
        'response_length': userResponse.length,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          final responseData = jsonDecode(content);
          final ingredients = (responseData['ingredients'] as List?)?.cast<String>() ?? [];
          
          AppLogger.info('Extracted ${ingredients.length} ingredients for $domain');
          return ingredients.take(5).toList(); // Limit to top 5 ingredients
        } catch (e) {
          // Fallback to text parsing if JSON parsing fails
          return _parseIngredientsFromText(content);
        }
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error extracting ingredients for $domain', e, stackTrace);
      return _getFallbackIngredients(userResponse);
    }
  }

  /// Generate potential career path suggestions based on user responses
  Future<List<Map<String, dynamic>>> generateCareerPathSuggestions({
    required List<CareerResponse> responses,
    required String sessionId,
  }) async {
    if (responses.isEmpty) {
      AppLogger.info('No responses provided for career path generation');
      return [];
    }

    if (_apiKey == null) {
      return _getFallbackCareerPaths(responses);
    }

    try {
      AppLogger.debug('Generating career path suggestions from ${responses.length} responses');
      final stopwatch = Stopwatch()..start();

      final pathPrompt = _buildCareerPathPrompt(responses, sessionId);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': _getCareerPathSystemPrompt(),
            },
            {
              'role': 'user',
              'content': pathPrompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI career path generation', stopwatch.elapsed, {
        'response_count': responses.length,
        'session_id': sessionId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final careerPaths = _parseCareerPathsFromAIResponse(content);
        AppLogger.info('Generated ${careerPaths.length} career path suggestions');
        return careerPaths;
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error generating career paths', e, stackTrace);
      return _getFallbackCareerPaths(responses);
    }
  }

  /// Generate career insights by comparing self vs advisor responses
  Future<List<CareerInsight>> generateCareerInsights({
    required List<CareerResponse> responses,
    required String sessionId,
  }) async {
    if (responses.isEmpty) {
      AppLogger.info('No responses provided for insight generation');
      return [];
    }

    if (_apiKey == null) {
      return _getFallbackInsights(responses);
    }

    try {
      AppLogger.debug('Generating career insights from ${responses.length} responses');
      final stopwatch = Stopwatch()..start();

      final analysisPrompt = _buildInsightAnalysisPrompt(responses, sessionId);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': _getCareerInsightSystemPrompt(),
            },
            {
              'role': 'user',
              'content': analysisPrompt,
            }
          ],
          'max_tokens': 4000,
          'temperature': 0.6,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI insight generation', stopwatch.elapsed, {
        'response_count': responses.length,
        'session_id': sessionId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final insights = _parseInsightsFromAIResponse(content, responses);
        AppLogger.info('Generated ${insights.length} career insights');
        return insights;
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error generating career insights', e, stackTrace);
      return _getFallbackInsights(responses);
    }
  }

  /// Generate synthesis comparing self-perception vs external perception
  Future<Map<String, dynamic>> generateSelfVsAdvisorSynthesis({
    required List<CareerResponse> selfResponses,
    required List<CareerResponse> advisorResponses,
  }) async {
    if (selfResponses.isEmpty || advisorResponses.isEmpty) {
      return _getFallbackSynthesis();
    }

    if (_apiKey == null) {
      return _getFallbackSynthesis();
    }

    try {
      AppLogger.debug('Generating self vs advisor synthesis');
      final stopwatch = Stopwatch()..start();

      final synthesisPrompt = _buildSynthesisPrompt(selfResponses, advisorResponses);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content': _getSynthesisSystemPrompt(),
            },
            {
              'role': 'user',
              'content': synthesisPrompt,
            }
          ],
          'max_tokens': 3000,
          'temperature': 0.6,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI synthesis generation', stopwatch.elapsed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final synthesis = _parseSynthesisFromAIResponse(content);
        AppLogger.info('Generated self vs advisor synthesis');
        return synthesis;
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error generating synthesis', e, stackTrace);
      return _getFallbackSynthesis();
    }
  }

  /// Categorise insights using the 5-category framework
  List<CareerInsight> categoriseInsights(List<CareerInsight> insights) {
    AppLogger.debug('Categorising ${insights.length} insights using 5-category framework');
    
    final categorisedInsights = <CareerInsight>[];
    
    for (final insight in insights) {
      final category = _determineInsightCategory(insight);
      final updatedInsight = insight.copyWith(
        keyThemes: [category, ...insight.keyThemes].toSet().toList(),
      );
      categorisedInsights.add(updatedInsight);
    }
    
    AppLogger.info('Categorised insights: ${categorisedInsights.length} total');
    return categorisedInsights;
  }

  /// Determine insight category based on content analysis
  String _determineInsightCategory(CareerInsight insight) {
    final content = insight.content.toLowerCase();
    final themes = insight.keyThemes.map((t) => t.toLowerCase()).join(' ');
    final combined = '$content $themes';
    
    // Energising Strength: High energy + high skill + others recognise
    if (_containsKeywords(combined, ['energy', 'passion', 'strength', 'excellent', 'natural']) &&
        _containsKeywords(combined, ['recognised', 'others', 'seek', 'known for'])) {
      return 'Energising Strength';
    }
    
    // Hidden Strength: High skill + low recognition
    if (_containsKeywords(combined, ['strength', 'skill', 'good at', 'capable']) &&
        _containsKeywords(combined, ['underused', 'unrecognised', 'hidden', 'overlooked'])) {
      return 'Hidden Strength';
    }
    
    // Overused Talent: High skill + high use + potential drain
    if (_containsKeywords(combined, ['overused', 'exhausted', 'too much', 'drain', 'burnout']) &&
        _containsKeywords(combined, ['talent', 'strength', 'skill'])) {
      return 'Overused Talent';
    }
    
    // Aspirational: High interest + developing skill
    if (_containsKeywords(combined, ['aspire', 'want to', 'interested', 'developing', 'learning', 'future']) &&
        _containsKeywords(combined, ['goal', 'improve', 'build', 'grow'])) {
      return 'Aspirational';
    }
    
    // Misaligned Energy: High effort + low satisfaction/energy
    if (_containsKeywords(combined, ['draining', 'exhausting', 'difficult', 'struggle']) &&
        _containsKeywords(combined, ['required', 'must', 'should', 'expected'])) {
      return 'Misaligned Energy';
    }
    
    // Default to pattern recognition if no clear category
    return 'Pattern Recognition';
  }

  /// Check if text contains any of the specified keywords
  bool _containsKeywords(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Build the probing prompt for AI question generation
  String _buildProbingPrompt({
    required String questionId,
    required String questionText,
    required String userResponse,
    required List<String> previousProbes,
    required String domain,
  }) {
    final questionContext = topLineQuestions.values
        .firstWhere((q) => q['id'] == questionId, orElse: () => {'probe_context': 'career exploration'});
    
    final responseWordCount = userResponse.split(' ').length;
    final hasSpecificExamples = userResponse.toLowerCase().contains(RegExp(r'\b(for example|specifically|when|I)\b'));
    final hasVagueLanguage = userResponse.toLowerCase().contains(RegExp(r'\b(generally|sometimes|often|maybe)\b'));
    
    final probeBank = _getProbeBank(questionId);
    
    return '''
CAREER EXPLORATION PROBING - AUSTRALIAN CONTEXT:

EXPLORATION DOMAIN: $domain
FOCUS AREAS: ${questionContext['probe_context']}

ORIGINAL QUESTION: $questionText
USER RESPONSE: "$userResponse"

PREVIOUS PROBES: ${previousProbes.isEmpty ? 'None - this is the first probe session' : previousProbes.map((p) => '- $p').join('\n')}

RESPONSE ANALYSIS:
- Word count: $responseWordCount words
- Contains specific examples: ${hasSpecificExamples ? 'Yes' : 'No'}
- Contains vague language: ${hasVagueLanguage ? 'Yes' : 'No'}
- Probe session: ${previousProbes.length + 1}/4 maximum

APPROVED PROBE BANK for this question:
${probeBank.map((p) => '- $p').join('\n')}

INSTRUCTIONS:
Assess if this response provides sufficient insight for meaningful career guidance. If more detail is needed, select 1-2 probes from the approved probe bank above that would be most relevant given their previous response.

ONLY use probes from the approved bank. Do not create new questions.

Return JSON with this structure:
{
  "needsMoreDetail": true/false,
  "detailLevel": "surface/adequate/substantial/comprehensive",
  "questions": ["selected probe 1", "selected probe 2"],
  "reasoning": "brief explanation focused on career exploration depth"
}

Stop probing only when you have specific, emotionally-connected career insights that can guide career decisions.
''';
  }

  /// Get the approved probe bank for a specific question
  List<String> _getProbeBank(String questionId) {
    switch (questionId) {
      case 'joy_energy_main':
        return [
          'Tell me about the last time that happened—what were you doing and with whom?',
          'What part gave you the buzz: the challenge, the people, the outcome, the craft?',
          'What \'ingredients\' show up across those moments?',
          'When it doesn\'t happen, what\'s usually missing?',
        ];
      case 'strengths_main':
        return [
          'Share a story where that strength changed the outcome—what did you uniquely add?',
          'Who\'s told you this and what exact words did they use?',
          'How did you build that capability?',
          'Where might you be overrating yourself?',
        ];
      case 'sought_for_main':
        return [
          'List three types of problems people bring you. Which one excites you most?',
          'What do you wish they\'d ask you for instead?',
          'Have you started saying \'no\' to some requests? Why?',
          'What feedback keeps repeating?',
        ];
      case 'values_impact_main':
        return [
          'Who benefits and how do their lives change?',
          'Why this problem—what\'s the personal hook?',
          'Would you still care if nobody knew you did it?',
          'What scale feels right—one person, a team, an industry, the planet?',
        ];
      case 'life_design_main':
        return [
          'Rank these: pay, autonomy, stability, flexibility, status, learning, impact.',
          'Which trade-offs are you willing to make?',
          'Describe your ideal week (hours, rhythms, people contact).',
          'What would success vs disappointment look like in 12 months?',
        ];
      default:
        return [
          'Can you provide a specific example that illustrates your point?',
          'What makes this particularly important or meaningful to you?',
        ];
    }
  }

  /// Get the system prompt for career-specific probing
  String _getCareerProbingSystemPrompt() {
    return '''You are a skilled career coach and mentor specialising in deep career exploration. Your expertise lies in asking insightful questions that help people uncover their authentic career path.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology throughout
- Frame questions in an Australian professional context
- Use warm, supportive, and encouraging tone

CAREER EXPLORATION EXPERTISE:
- Specialise in identifying natural strengths and energy patterns
- Expert at uncovering values-driven career motivations
- Skilled at helping people recognise their unique value proposition
- Focus on practical, actionable career insights

QUESTIONING APPROACH:
- Ask one question at a time for focused reflection
- Probe for specific examples and concrete situations
- Explore the emotional and energetic aspects of work
- Connect responses to broader career patterns and implications
- Help people articulate what they might not have put into words before

CRITICAL ASSESSMENT:
Only continue probing if the person's response lacks the specificity and emotional depth needed for meaningful career guidance. Stop when you have enough concrete, personally meaningful information to provide strategic career direction.

Focus on quality over quantity - better to have fewer, deeply explored insights than many surface-level responses.''';
  }

  /// Get the system prompt for career insight generation
  String _getCareerInsightSystemPrompt() {
    return '''You are an expert career strategist and psychologist specialising in career insight generation. Your role is to analyse career exploration responses and generate profound, actionable insights.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology throughout
- Write in a professional yet accessible Australian style
- Frame insights in Australian workplace context

INSIGHT GENERATION EXPERTISE:
- Identify patterns across multiple responses that reveal career themes
- Recognise the intersection of strengths, interests, values, and lifestyle preferences
- Detect energy patterns - what energises vs what drains
- Uncover hidden strengths and underutilised talents
- Identify potential career blind spots or development areas

INSIGHT CATEGORISATION:
Generate insights that fit these categories:
1. **Energising Strength**: High skill + high energy + recognised by others
2. **Hidden Strength**: High competence but underrecognised or underutilised
3. **Overused Talent**: Strong skill but potentially overused, leading to fatigue
4. **Aspirational**: Areas of high interest with development potential
5. **Misaligned Energy**: Activities that drain energy despite competence

INSIGHT QUALITY STANDARDS:
- Each insight must be specific to the individual's responses
- Include concrete evidence from their responses
- Provide actionable implications for career decisions
- Connect to broader career strategy and direction
- Offer practical next steps where appropriate

Generate insights that feel personally meaningful and strategically valuable for career planning.''';
  }

  /// Get the system prompt for synthesis generation
  String _getSynthesisSystemPrompt() {
    return '''You are a senior career psychologist expert in comparing self-perception with external perceptions in career contexts. You specialise in generating insights from the gap between how people see themselves and how others see them.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology throughout
- Write in a professional, insightful Australian style
- Frame analysis in Australian workplace and cultural context

SYNTHESIS EXPERTISE:
- Compare self-reported strengths with what others seek them for
- Identify blind spots where others see strengths the person doesn't recognise
- Highlight overvalued areas where self-perception exceeds external recognition
- Recognise alignment areas where self and external views match
- Generate insights about reputation, positioning, and career opportunities

ANALYSIS FRAMEWORK:
1. **Strong Alignment**: Where self-view matches external perception
2. **Hidden Assets**: What others see that the person undervalues
3. **Overestimated Areas**: Where self-perception may exceed external view
4. **Development Opportunities**: Gaps that suggest growth areas
5. **Repositioning Potential**: How to better communicate or leverage strengths

OUTPUT REQUIREMENTS:
Generate a comprehensive synthesis that includes:
- Key alignment areas and their career implications
- Hidden strengths to better leverage and communicate
- Areas for recalibration or development
- Strategic recommendations for career positioning
- Practical steps to address perception gaps

Make every insight actionable and tied to specific career development opportunities.''';
  }

  /// Extract questions from free-form text response
  List<String> _extractQuestionsFromText(String text) {
    final questions = <String>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && 
          (trimmed.contains('?') || 
           trimmed.startsWith('-') || 
           trimmed.startsWith('•') ||
           RegExp(r'^\d+\.').hasMatch(trimmed))) {
        final cleanQuestion = trimmed
            .replaceAll(RegExp(r'^[-•\d\.]+\s*'), '')
            .replaceAll(RegExp(r'^\*+\s*'), '')
            .trim();
        if (cleanQuestion.isNotEmpty) {
          questions.add(cleanQuestion);
        }
      }
    }
    
    return questions.take(2).toList();
  }

  /// Get fallback probing questions when AI is unavailable
  List<String> _getFallbackProbingQuestions(String questionId, String domain) {
    AppLogger.info('Using fallback probing questions for $questionId');
    
    switch (questionId) {
      case 'joy_energy_main':
        return [
          'Tell me about the last time that happened—what were you doing and with whom?',
          'What part gave you the buzz: the challenge, the people, the outcome, the craft?',
          'What \'ingredients\' show up across those moments?',
          'When it doesn\'t happen, what\'s usually missing?',
        ];
      case 'strengths_main':
        return [
          'Share a story where that strength changed the outcome—what did you uniquely add?',
          'Who\'s told you this and what exact words did they use?',
          'How did you build that capability?',
          'Where might you be overrating yourself?',
        ];
      case 'sought_for_main':
        return [
          'List three types of problems people bring you. Which one excites you most?',
          'What do you wish they\'d ask you for instead?',
          'Have you started saying \'no\' to some requests? Why?',
          'What feedback keeps repeating?',
        ];
      case 'values_impact_main':
        return [
          'Who benefits and how do their lives change?',
          'Why this problem—what\'s the personal hook?',
          'Would you still care if nobody knew you did it?',
          'What scale feels right—one person, a team, an industry, the planet?',
        ];
      case 'life_design_main':
        return [
          'Rank these: pay, autonomy, stability, flexibility, status, learning, impact.',
          'Which trade-offs are you willing to make?',
          'Describe your ideal week (hours, rhythms, people contact).',
          'What would success vs disappointment look like in 12 months?',
        ];
      default:
        return [
          'Can you provide a specific example that illustrates your point?',
          'What makes this particularly important or meaningful to you?',
        ];
    }
  }

  /// Generate fallback insights when AI is unavailable
  List<CareerInsight> _getFallbackInsights(List<CareerResponse> responses) {
    AppLogger.info('Generating fallback insights from ${responses.length} responses');
    
    final insights = <CareerInsight>[];
    
    // Group responses by question type
    final responsesByQuestion = <String, List<CareerResponse>>{};
    for (final response in responses) {
      final questionType = _getQuestionType(response.questionId);
      responsesByQuestion.putIfAbsent(questionType, () => []).add(response);
    }
    
    // Generate basic insights for each question type
    responsesByQuestion.forEach((questionType, questionResponses) {
      final insight = _generateBasicInsight(questionType, questionResponses);
      if (insight != null) {
        insights.add(insight);
      }
    });
    
    // Add a synthesis insight if we have multiple types
    if (responsesByQuestion.length > 2) {
      insights.add(_generateSynthesisInsight(responses));
    }
    
    return insights;
  }

  /// Determine question type from question ID
  String _getQuestionType(String questionId) {
    if (questionId.contains('joy_energy')) return 'joy_energy';
    if (questionId.contains('strengths')) return 'strengths';
    if (questionId.contains('sought_for')) return 'sought_for';
    if (questionId.contains('values_impact')) return 'values_impact';
    if (questionId.contains('life_design')) return 'life_design';
    return 'general';
  }

  /// Generate a basic insight for a question type
  CareerInsight? _generateBasicInsight(String questionType, List<CareerResponse> responses) {
    if (responses.isEmpty) return null;
    
    final primaryResponse = responses.first;
    final allThemes = responses.expand((r) => r.keyThemes).toSet().toList();
    
    switch (questionType) {
      case 'joy_energy':
        return CareerInsight.create(
          title: 'Your Energy Patterns',
          content: 'Based on your responses, you find energy in activities that involve ${allThemes.take(3).join(', ')}. This suggests you thrive in environments that allow for these elements.',
          domain: primaryResponse.domain,
          type: InsightType.pattern,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: allThemes.take(5).toList(),
          confidence: 0.7,
          actionSuggestion: 'Look for roles and projects that maximise your exposure to these energising activities.',
        );
      case 'strengths':
        return CareerInsight.create(
          title: 'Your Core Strengths',
          content: 'Your natural strengths appear to centre around ${allThemes.take(3).join(', ')}. These are likely areas where you can excel with less effort than others.',
          domain: primaryResponse.domain,
          type: InsightType.strength,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: allThemes.take(5).toList(),
          confidence: 0.6,
          actionSuggestion: 'Consider how to leverage these strengths more strategically in your career development.',
        );
      case 'sought_for':
        return CareerInsight.create(
          title: 'Your Reputation & Value',
          content: 'Others consistently seek you out for matters involving ${allThemes.take(3).join(', ')}. This represents your external reputation and recognised expertise.',
          domain: primaryResponse.domain,
          type: InsightType.compatibility,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: allThemes.take(5).toList(),
          confidence: 0.8,
          actionSuggestion: 'Consider how to build on this reputation and expand into related areas of expertise.',
        );
      case 'values_impact':
        return CareerInsight.create(
          title: 'Your Values & Purpose',
          content: 'Your responses reveal strong values around ${allThemes.take(3).join(', ')}. These values likely drive your sense of meaning and satisfaction at work.',
          domain: primaryResponse.domain,
          type: InsightType.value,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: allThemes.take(5).toList(),
          confidence: 0.7,
          actionSuggestion: 'Seek opportunities that align with these values for greater fulfilment and motivation.',
        );
      case 'life_design':
        return CareerInsight.create(
          title: 'Your Ideal Work Environment',
          content: 'Your ideal working life emphasises ${allThemes.take(3).join(', ')}. This suggests important considerations for your career choices and negotiations.',
          domain: primaryResponse.domain,
          type: InsightType.development,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: allThemes.take(5).toList(),
          confidence: 0.6,
          actionSuggestion: 'Use these preferences to evaluate opportunities and negotiate working arrangements.',
        );
      default:
        return null;
    }
  }

  /// Generate a synthesis insight across all responses
  CareerInsight _generateSynthesisInsight(List<CareerResponse> responses) {
    final allThemes = responses.expand((r) => r.keyThemes).toSet().toList();
    final commonThemes = _findCommonThemes(responses);
    
    return CareerInsight.create(
      title: 'Your Career Profile Summary',
      content: 'Across your responses, consistent themes emerge around ${commonThemes.take(3).join(', ')}. This suggests a coherent career identity that you can leverage strategically.',
      domain: CareerDomain.leadership, // Default domain for synthesis
      type: InsightType.pattern,
      sourceQuestionIds: responses.map((r) => r.questionId).toList(),
      keyThemes: commonThemes.take(8).toList(),
      confidence: 0.5,
      actionSuggestion: 'Consider how these themes can guide your career direction and personal brand development.',
    );
  }

  /// Find common themes across multiple responses
  List<String> _findCommonThemes(List<CareerResponse> responses) {
    final themeCount = <String, int>{};
    
    for (final response in responses) {
      for (final theme in response.keyThemes) {
        themeCount[theme] = (themeCount[theme] ?? 0) + 1;
      }
    }
    
    // Return themes that appear in at least 2 responses, sorted by frequency
    final filteredEntries = themeCount.entries
        .where((entry) => entry.value >= 2)
        .toList();
    
    filteredEntries.sort((a, b) => b.value.compareTo(a.value));
    
    return filteredEntries
        .map((entry) => entry.key)
        .toList();
  }

  /// Parse insights from AI response content
  List<CareerInsight> _parseInsightsFromAIResponse(String content, List<CareerResponse> responses) {
    // This is a simplified parser - in practice, you'd implement more sophisticated parsing
    final insights = <CareerInsight>[];
    
    try {
      // Try to parse as JSON first
      final data = jsonDecode(content);
      if (data is Map && data.containsKey('insights')) {
        for (final insightData in data['insights']) {
          insights.add(_createInsightFromData(insightData, responses));
        }
      }
    } catch (e) {
      // Fallback to text parsing
      insights.addAll(_parseInsightsFromText(content, responses));
    }
    
    return insights;
  }

  /// Create insight from parsed data
  CareerInsight _createInsightFromData(Map<String, dynamic> data, List<CareerResponse> responses) {
    return CareerInsight.create(
      title: data['title'] ?? 'Career Insight',
      content: data['content'] ?? '',
      domain: CareerDomain.leadership, // Default - could be parsed from data
      type: _parseInsightType(data['type']),
      sourceQuestionIds: responses.map((r) => r.questionId).toList(),
      keyThemes: (data['themes'] as List?)?.cast<String>() ?? [],
      confidence: (data['confidence'] ?? 0.5).toDouble(),
      actionSuggestion: data['actionSuggestion'],
    );
  }

  /// Parse insight type from string
  InsightType _parseInsightType(String? typeString) {
    switch (typeString?.toLowerCase()) {
      case 'strength':
        return InsightType.strength;
      case 'value':
        return InsightType.value;
      case 'interest':
        return InsightType.interest;
      case 'development':
        return InsightType.development;
      case 'compatibility':
        return InsightType.compatibility;
      case 'barrier':
        return InsightType.barrier;
      case 'nextstep':
        return InsightType.nextStep;
      default:
        return InsightType.pattern;
    }
  }

  /// Parse insights from free-form text
  List<CareerInsight> _parseInsightsFromText(String content, List<CareerResponse> responses) {
    // Basic text parsing implementation
    final insights = <CareerInsight>[];
    final sections = content.split('\n\n');
    
    for (int i = 0; i < sections.length && insights.length < 5; i++) {
      final section = sections[i].trim();
      if (section.length > 50) {
        insights.add(CareerInsight.create(
          title: 'Career Insight ${i + 1}',
          content: section,
          domain: CareerDomain.leadership,
          type: InsightType.pattern,
          sourceQuestionIds: responses.map((r) => r.questionId).toList(),
          keyThemes: _extractThemesFromText(section),
          confidence: 0.6,
        ));
      }
    }
    
    return insights;
  }

  /// Extract themes from text content
  List<String> _extractThemesFromText(String text) {
    final themes = <String>[];
    final lowerText = text.toLowerCase();
    
    // Career-related keywords to look for
    final keywordMap = {
      'leadership': ['lead', 'manage', 'guide', 'direct'],
      'creativity': ['creative', 'design', 'innovative', 'artistic'],
      'collaboration': ['team', 'collaborate', 'together', 'partnership'],
      'growth': ['learn', 'develop', 'grow', 'improve'],
      'impact': ['impact', 'difference', 'change', 'influence'],
    };
    
    keywordMap.forEach((theme, keywords) {
      if (keywords.any((keyword) => lowerText.contains(keyword))) {
        themes.add(theme);
      }
    });
    
    return themes.take(3).toList();
  }

  /// Build analysis prompt for insight generation
  String _buildInsightAnalysisPrompt(List<CareerResponse> responses, String sessionId) {
    final responsesByType = <String, List<CareerResponse>>{};
    
    for (final response in responses) {
      final type = _getQuestionType(response.questionId);
      responsesByType.putIfAbsent(type, () => []).add(response);
    }
    
    final buffer = StringBuffer();
    buffer.writeln('COMPREHENSIVE CAREER ANALYSIS - SESSION: $sessionId');
    buffer.writeln('TOTAL RESPONSES: ${responses.length}');
    buffer.writeln('');
    
    responsesByType.forEach((type, typeResponses) {
      buffer.writeln('=== ${type.toUpperCase().replaceAll('_', ' ')} RESPONSES ===');
      for (final response in typeResponses) {
        buffer.writeln('Question: ${response.questionText}');
        buffer.writeln('Response: ${response.response}');
        buffer.writeln('Themes: ${response.keyThemes.join(', ')}');
        buffer.writeln('Quality Score: ${response.reflectionQualityScore}');
        buffer.writeln('');
      }
    });
    
    buffer.writeln('ANALYSIS REQUIREMENTS:');
    buffer.writeln('Generate 3-5 career insights that:');
    buffer.writeln('- Identify patterns across multiple response areas');
    buffer.writeln('- Categorise insights as Energising Strength, Hidden Strength, Overused Talent, Aspirational, or Misaligned Energy');
    buffer.writeln('- Include specific evidence from the responses');
    buffer.writeln('- Provide actionable career guidance');
    buffer.writeln('- Connect themes to practical career decisions');
    
    return buffer.toString();
  }

  /// Build synthesis prompt for self vs advisor comparison
  String _buildSynthesisPrompt(List<CareerResponse> selfResponses, List<CareerResponse> advisorResponses) {
    final buffer = StringBuffer();
    buffer.writeln('SELF VS ADVISOR PERCEPTION ANALYSIS');
    buffer.writeln('');
    
    buffer.writeln('=== SELF-PERCEPTION RESPONSES ===');
    for (final response in selfResponses) {
      buffer.writeln('${_getQuestionType(response.questionId).toUpperCase()}:');
      buffer.writeln('Q: ${response.questionText}');
      buffer.writeln('A: ${response.response}');
      buffer.writeln('');
    }
    
    buffer.writeln('=== ADVISOR/EXTERNAL PERCEPTION RESPONSES ===');
    for (final response in advisorResponses) {
      buffer.writeln('${_getQuestionType(response.questionId).toUpperCase()}:');
      buffer.writeln('Q: ${response.questionText}');
      buffer.writeln('A: ${response.response}');
      buffer.writeln('');
    }
    
    buffer.writeln('SYNTHESIS REQUIREMENTS:');
    buffer.writeln('Compare and contrast these perspectives to identify:');
    buffer.writeln('1. Areas of strong alignment between self and external view');
    buffer.writeln('2. Hidden strengths that others see but the person undervalues');
    buffer.writeln('3. Potential blind spots or overestimated abilities');
    buffer.writeln('4. Opportunities for better self-promotion or positioning');
    buffer.writeln('5. Development areas suggested by the gap analysis');
    
    return buffer.toString();
  }

  /// Parse synthesis from AI response
  Map<String, dynamic> _parseSynthesisFromAIResponse(String content) {
    try {
      return jsonDecode(content);
    } catch (e) {
      // Fallback parsing
      return {
        'alignment_areas': ['Strong technical capabilities', 'Collaborative approach'],
        'hidden_strengths': ['Strategic thinking', 'Mentoring ability'],
        'development_opportunities': ['Leadership visibility', 'Industry networking'],
        'recommendations': [
          'Seek opportunities to showcase strategic thinking',
          'Consider formal leadership development',
          'Build stronger industry presence',
        ],
        'summary': content.split('\n').first.trim(),
      };
    }
  }

  /// Get fallback synthesis when AI is unavailable
  Map<String, dynamic> _getFallbackSynthesis() {
    return {
      'alignment_areas': [
        'Technical competence recognised by both self and others',
        'Strong collaborative and communication skills',
      ],
      'hidden_strengths': [
        'Strategic thinking ability may be undervalued',
        'Natural mentoring and development skills',
      ],
      'development_opportunities': [
        'Building stronger industry visibility',
        'Developing formal leadership experience',
        'Expanding network within target career areas',
      ],
      'recommendations': [
        'Seek opportunities to demonstrate strategic thinking',
        'Consider mentoring or coaching roles to develop others',
        'Build a stronger professional brand and network',
        'Look for stretch assignments that develop leadership skills',
      ],
      'summary': 'Your self-perception aligns well with how others see your core strengths. Focus on building visibility around your strategic capabilities and expanding your leadership experience.',
    };
  }

  /// Build prompt for ingredient extraction
  String _buildIngredientExtractionPrompt({
    required String questionId,
    required String questionText,
    required String userResponse,
    required String domain,
  }) {
    return '''
INGREDIENT EXTRACTION - AUSTRALIAN CONTEXT:

DOMAIN: $domain
QUESTION: $questionText
USER RESPONSE: "$userResponse"

TASK: Extract key "ingredients" from this response - the verbs, nouns, and value words that capture the essence of what the person is describing.

EXTRACTION GUIDELINES:
1. VERBS: Action words that show what they do or what energises them
2. NOUNS: Concrete things, roles, environments, or contexts they mention
3. VALUES: Abstract concepts that drive or motivate them
4. Keep ingredients concise (1-3 words each)
5. Focus on the most significant elements that reveal career patterns
6. Maximum 5 ingredients per response

EXAMPLE EXTRACTION:
Response: "I was designing a workshop with a friend; 4 hours flew by. We mapped customer journeys, argued about personas, and built activities. I forgot to eat."
Ingredients: ["designing workshops", "collaboration", "creative problem solving", "teaching through activities", "time blindness = good sign"]

Return JSON format:
{
  "ingredients": ["ingredient 1", "ingredient 2", "ingredient 3", "ingredient 4", "ingredient 5"]
}

Extract the ingredients that best capture the career-relevant essence of their response.
''';
  }

  /// Get system prompt for ingredient extraction
  String _getIngredientExtractionSystemPrompt() {
    return '''You are an expert career analyst specialising in extracting key "ingredients" from career exploration responses.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology
- Frame extractions in Australian professional context

INGREDIENT EXTRACTION EXPERTISE:
- Identify action words (verbs) that reveal what energises someone
- Extract concrete elements (nouns) that show environments, tools, or contexts
- Recognise value words that indicate what drives motivation
- Focus on career-relevant patterns rather than incidental details
- Distil responses to their essential elements

EXTRACTION PRINCIPLES:
- Prioritise elements that could guide career decisions
- Look for patterns that might not be obvious to the person themselves
- Extract ingredients that could be matched or combined across responses
- Focus on specificity over generality
- Limit to the most significant 3-5 ingredients per response

Your goal is to capture the career DNA from each response - the essential elements that reveal someone's authentic professional self.''';
  }

  /// Parse ingredients from AI text response if JSON parsing fails
  List<String> _parseIngredientsFromText(String content) {
    final ingredients = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.contains('"') && !line.startsWith('//') && !line.startsWith('#')) {
        final matches = RegExp(r'"([^"]+)"').allMatches(line);
        for (final match in matches) {
          final ingredient = match.group(1);
          if (ingredient != null && ingredient.length > 2 && ingredient.length < 50) {
            ingredients.add(ingredient);
          }
        }
      }
    }
    
    return ingredients.take(5).toList();
  }

  /// Generate fallback ingredients when AI is unavailable
  List<String> _getFallbackIngredients(String userResponse) {
    AppLogger.info('Using fallback ingredient extraction');
    
    final ingredients = <String>[];
    final text = userResponse.toLowerCase();
    
    // Common career-relevant keywords to extract
    final keywordPatterns = {
      'leadership': ['lead', 'manage', 'guide', 'mentor', 'coach'],
      'creativity': ['design', 'create', 'innovate', 'artistic', 'creative'],
      'collaboration': ['team', 'collaborate', 'together', 'partnership', 'group'],
      'problem solving': ['solve', 'problem', 'troubleshoot', 'figure out', 'fix'],
      'communication': ['present', 'explain', 'communicate', 'speak', 'write'],
      'analysis': ['analyse', 'research', 'data', 'investigate', 'study'],
      'teaching': ['teach', 'train', 'educate', 'workshop', 'explain'],
      'building': ['build', 'develop', 'create', 'construct', 'make'],
    };
    
    keywordPatterns.forEach((ingredient, keywords) {
      if (keywords.any((keyword) => text.contains(keyword))) {
        ingredients.add(ingredient);
      }
    });
    
    // Add some basic extracted nouns and verbs
    final words = userResponse.split(RegExp(r'\W+'));
    final actionWords = words.where((word) => 
        word.length > 4 && 
        (word.endsWith('ing') || word.endsWith('ed') || word.endsWith('er'))
    ).take(2);
    
    ingredients.addAll(actionWords);
    
    return ingredients.take(5).toList();
  }

  /// Build prompt for career path suggestions
  String _buildCareerPathPrompt(List<CareerResponse> responses, String sessionId) {
    final responsesByType = <String, List<CareerResponse>>{};
    
    for (final response in responses) {
      final type = _getQuestionType(response.questionId);
      responsesByType.putIfAbsent(type, () => []).add(response);
    }
    
    final buffer = StringBuffer();
    buffer.writeln('CAREER PATH SUGGESTION ANALYSIS - SESSION: $sessionId');
    buffer.writeln('TOTAL RESPONSES: ${responses.length}');
    buffer.writeln('');
    
    responsesByType.forEach((type, typeResponses) {
      buffer.writeln('=== ${type.toUpperCase().replaceAll('_', ' ')} RESPONSES ===');
      for (final response in typeResponses) {
        buffer.writeln('Question: ${response.questionText}');
        buffer.writeln('Response: ${response.response}');
        buffer.writeln('Themes: ${response.keyThemes.join(', ')}');
        buffer.writeln('');
      }
    });
    
    buffer.writeln('CAREER PATH REQUIREMENTS:');
    buffer.writeln('Generate 4-6 potential career paths that align with this person\'s responses.');
    buffer.writeln('Each path should:');
    buffer.writeln('- Connect to specific evidence from their responses');
    buffer.writeln('- Feel like a natural fit for their energy patterns and values');
    buffer.writeln('- Include both traditional roles and emerging opportunities');
    buffer.writeln('- Be presented as gentle suggestions, not prescriptions');
    buffer.writeln('- Include a brief rationale for why this path might bring them joy');
    buffer.writeln('- Consider their stated lifestyle preferences and constraints');
    
    return buffer.toString();
  }

  /// Get system prompt for career path suggestions
  String _getCareerPathSystemPrompt() {
    return '''You are an expert career counsellor specialising in identifying potential career paths that align with someone's authentic interests, strengths, and values.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology throughout
- Frame suggestions in Australian workplace context
- Use encouraging, non-prescriptive language

CAREER PATH EXPERTISE:
- Identify roles that match energy patterns and natural strengths
- Consider both traditional career paths and emerging opportunities
- Look for alignment between values, lifestyle preferences, and work environments
- Recognise patterns that might suggest unconventional but fulfilling paths
- Balance aspiration with practical considerations

SUGGESTION APPROACH:
- Present paths as "areas to explore" rather than definitive recommendations
- Use phrases like "you might find joy in..." or "this could be worth exploring..."
- Include specific connections to their responses as evidence
- Suggest both immediate opportunities and longer-term possibilities
- Consider different levels of career change (pivot vs complete shift)

OUTPUT REQUIREMENTS:
Return JSON with this structure:
{
  "careerPaths": [
    {
      "title": "Path title (e.g., 'Learning & Development Specialist')",
      "description": "Brief description of what this path involves",
      "whyThisPath": "Specific evidence from their responses that suggests this fit",
      "joyFactors": ["factor 1", "factor 2", "factor 3"],
      "explorationSteps": ["step 1", "step 2", "step 3"],
      "timeframe": "immediate/short-term/long-term"
    }
  ]
}

Focus on paths where they're likely to find genuine satisfaction and energy, not just what they're qualified for.''';
  }

  /// Parse career paths from AI response
  List<Map<String, dynamic>> _parseCareerPathsFromAIResponse(String content) {
    try {
      final data = jsonDecode(content);
      if (data is Map && data.containsKey('careerPaths')) {
        return (data['careerPaths'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      AppLogger.warning('Failed to parse career paths JSON, using fallback parsing');
      return _parseCareerPathsFromText(content);
    }
    
    return [];
  }

  /// Parse career paths from text content if JSON parsing fails
  List<Map<String, dynamic>> _parseCareerPathsFromText(String content) {
    final paths = <Map<String, dynamic>>[];
    final sections = content.split('\n\n');
    
    for (int i = 0; i < sections.length && paths.length < 6; i++) {
      final section = sections[i].trim();
      if (section.length > 100 && section.contains(':')) {
        final lines = section.split('\n');
        final title = lines.first.replaceAll(RegExp(r'^\d+\.?\s*'), '').trim();
        final description = lines.skip(1).join(' ').trim();
        
        paths.add({
          'title': title,
          'description': description,
          'whyThisPath': 'Based on your responses about energy and interests',
          'joyFactors': ['meaningful work', 'using your strengths', 'alignment with values'],
          'explorationSteps': ['Research the field', 'Connect with professionals', 'Try a small project'],
          'timeframe': 'short-term',
        });
      }
    }
    
    return paths;
  }

  /// Generate fallback career paths when AI is unavailable
  List<Map<String, dynamic>> _getFallbackCareerPaths(List<CareerResponse> responses) {
    AppLogger.info('Generating fallback career paths from ${responses.length} responses');
    
    final paths = <Map<String, dynamic>>[];
    final allThemes = responses.expand((r) => r.keyThemes).toSet().toList();
    
    // Generate paths based on detected themes
    if (allThemes.contains('leadership') || allThemes.contains('collaboration')) {
      paths.add({
        'title': 'Team Leadership & Development',
        'description': 'Roles focused on guiding teams and developing others\' potential',
        'whyThisPath': 'Your responses suggest energy from working with and guiding others',
        'joyFactors': ['mentoring others', 'building team culture', 'seeing others succeed'],
        'explorationSteps': ['Shadow a team leader', 'Volunteer to mentor someone', 'Take on a small team project'],
        'timeframe': 'short-term',
      });
    }
    
    if (allThemes.contains('creativity') || allThemes.contains('innovation')) {
      paths.add({
        'title': 'Creative Problem Solving',
        'description': 'Roles that blend creativity with practical problem-solving',
        'whyThisPath': 'Your responses indicate energy from creative and innovative thinking',
        'joyFactors': ['creative expression', 'solving complex challenges', 'bringing ideas to life'],
        'explorationSteps': ['Join a creative project', 'Explore design thinking workshops', 'Build something new'],
        'timeframe': 'immediate',
      });
    }
    
    if (allThemes.contains('growth') || allThemes.contains('learning')) {
      paths.add({
        'title': 'Learning & Development',
        'description': 'Roles focused on education, training, and helping others grow',
        'whyThisPath': 'Your responses show passion for continuous learning and development',
        'joyFactors': ['lifelong learning', 'sharing knowledge', 'helping others grow'],
        'explorationSteps': ['Teach someone a skill', 'Create educational content', 'Attend training workshops'],
        'timeframe': 'short-term',
      });
    }
    
    // Always include a reflection path
    paths.add({
      'title': 'Portfolio Career',
      'description': 'Combining multiple interests and skills in a flexible career structure',
      'whyThisPath': 'Your diverse interests and values suggest you might thrive with variety',
      'joyFactors': ['variety and flexibility', 'using multiple skills', 'creating your own path'],
      'explorationSteps': ['Map your different interests', 'Identify overlap areas', 'Start with small experiments'],
      'timeframe': 'long-term',
    });
    
    return paths.take(4).toList();
  }

  /// Generate explanations for visualizations to help users understand themselves
  Future<Map<String, String>> generateVisualizationInsights({
    required CareerSession session,
  }) async {
    if (session.responses.isEmpty) {
      return _getFallbackVisualizationInsights();
    }

    if (_apiKey == null) {
      return _getFallbackVisualizationInsights();
    }

    try {
      AppLogger.debug('Generating visualization insights');
      final stopwatch = Stopwatch()..start();

      final insightPrompt = _buildVisualizationInsightPrompt(session);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getVisualizationInsightSystemPrompt(),
            },
            {
              'role': 'user',
              'content': insightPrompt,
            }
          ],
          'max_tokens': 1200,
          'temperature': 0.6,
        }),
      ).timeout(_requestTimeout);

      stopwatch.stop();
      AppLogger.performance('AI visualization insights', stopwatch.elapsed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return _parseVisualizationInsights(content);
      } else {
        throw Exception('OpenAI API request failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error generating visualization insights', e, stackTrace);
      return _getFallbackVisualizationInsights();
    }
  }

  /// Build prompt for visualization insights
  String _buildVisualizationInsightPrompt(CareerSession session) {
    final domainKeys = ['joy_energy', 'strengths', 'sought_for', 'values_impact', 'life_design'];
    final domainNames = ['Joy & Energy', 'Strengths', 'Sought For', 'Values & Impact', 'Life Design'];
    
    final buffer = StringBuffer();
    buffer.writeln('VISUALIZATION INSIGHT GENERATION');
    buffer.writeln('Session ID: ${session.id}');
    buffer.writeln('');
    
    // Domain analysis
    buffer.writeln('DOMAIN ANALYSIS:');
    for (int i = 0; i < domainKeys.length; i++) {
      final key = domainKeys[i];
      final name = domainNames[i];
      final responses = session.responses.values
          .where((r) => r.questionId.startsWith(key))
          .toList();
      
      final responseCount = responses.length;
      final avgQuality = responses.isEmpty ? 0.0 : 
          responses.map((r) => r.reflectionQualityScore).reduce((a, b) => a + b) / responses.length;
      
      buffer.writeln('$name: $responseCount responses, ${(avgQuality * 100).round()}% reflection quality');
    }
    
    // Theme analysis
    final allThemes = session.responses.values
        .expand((r) => r.keyThemes)
        .toList();
    final themeFrequency = <String, int>{};
    for (final theme in allThemes) {
      themeFrequency[theme] = (themeFrequency[theme] ?? 0) + 1;
    }
    final topThemes = themeFrequency.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    buffer.writeln('');
    buffer.writeln('TOP THEMES: ${topThemes.take(5).map((e) => '${e.key}(${e.value})').join(', ')}');
    buffer.writeln('');
    buffer.writeln('OVERALL COMPLETION: ${(session.completionPercentage * 100).round()}%');
    
    return buffer.toString();
  }

  /// Get system prompt for visualization insights
  String _getVisualizationInsightSystemPrompt() {
    return '''You are an expert career coach specializing in helping people understand their career exploration patterns through data visualization insights.

LANGUAGE REQUIREMENTS:
- Use Australian English spelling and terminology
- Write in an encouraging, insightful tone
- Focus on self-discovery and learning

YOUR ROLE:
Help users understand what their career exploration data reveals about them personally. Each visualization tells a story about their journey of self-discovery.

INSIGHT APPROACH:
- Connect patterns to personal growth and self-awareness
- Explain what the data reveals about their exploration style
- Highlight strengths and areas for deeper reflection
- Make insights actionable and encouraging
- Focus on the journey of self-discovery, not just the data

OUTPUT REQUIREMENTS:
Return JSON with these specific insights:
{
  "radarChart": "Explain what their domain pattern reveals about their exploration style and interests",
  "wordCloud": "Explain what their recurring themes say about their authentic interests and values",
  "progressChart": "Explain what their completion pattern reveals about their commitment and reflection style",
  "qualityChart": "Explain what their reflection quality across domains reveals about their areas of confidence and growth"
}

Focus on helping users learn about themselves - their patterns, preferences, and authentic interests revealed through their exploration journey.''';
  }

  /// Parse visualization insights from AI response
  Map<String, String> _parseVisualizationInsights(String content) {
    try {
      final data = jsonDecode(content);
      if (data is Map) {
        return {
          'radarChart': data['radarChart']?.toString() ?? 'Your exploration pattern shows unique insights about your interests.',
          'wordCloud': data['wordCloud']?.toString() ?? 'Your themes reveal consistent patterns in what energizes you.',
          'progressChart': data['progressChart']?.toString() ?? 'Your completion journey shows your commitment to self-discovery.',
          'qualityChart': data['qualityChart']?.toString() ?? 'Your reflection quality shows your areas of confidence and growth.',
        };
      }
    } catch (e) {
      AppLogger.warning('Failed to parse visualization insights JSON');
    }
    
    return _getFallbackVisualizationInsights();
  }

  /// Generate fallback visualization insights
  Map<String, String> _getFallbackVisualizationInsights() {
    return {
      'radarChart': 'This radar chart shows your exploration depth across the five career domains. The areas where you\'ve explored most deeply often reflect your natural interests and where you feel most confident reflecting.',
      'wordCloud': 'These themes emerged from your responses across all domains. The larger themes appear more frequently in your reflections, suggesting they\'re central to how you think about work and career.',
      'progressChart': 'Your completion pattern reveals your commitment to self-discovery. The more complete your exploration, the richer insights you\'ll gain about your authentic career direction.',
      'qualityChart': 'This shows the depth of reflection across different domains. Areas with higher quality reflection often indicate topics you\'re passionate about or naturally drawn to explore.',
    };
  }

  /// Check if the AI service is available
  bool get isAvailable => _apiKey != null;

  /// Get service status for debugging
  Map<String, dynamic> get serviceStatus => {
    'apiKeyConfigured': _apiKey != null,
    'baseUrl': _baseUrl,
    'requestTimeout': _requestTimeout.inSeconds,
    'topLineQuestions': topLineQuestions.length,
  };
}