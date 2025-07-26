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
  
  /// The 5 top-line career exploration questions
  static const Map<String, Map<String, String>> topLineQuestions = {
    'joy_energy': {
      'id': 'joy_energy_main',
      'question': 'What activities or situations make you feel most energised and joyful at work? Think about times when you lose track of time because you\'re so engaged.',
      'domain': 'Personal Fulfillment',
      'probe_context': 'joy, energy, flow states, engagement, enthusiasm, passion',
    },
    'strengths': {
      'id': 'strengths_main', 
      'question': 'What are your natural strengths and talents that others consistently recognise in you? Include both technical skills and personal qualities.',
      'domain': 'Core Capabilities',
      'probe_context': 'strengths, talents, abilities, skills, competencies, natural gifts',
    },
    'sought_for': {
      'id': 'sought_for_main',
      'question': 'What do people typically come to you for help with? What problems do others trust you to solve or what advice do they seek from you?',
      'domain': 'Value to Others', 
      'probe_context': 'reputation, expertise, problem-solving, advice, consulting, helping others',
    },
    'values_impact': {
      'id': 'values_impact_main',
      'question': 'What kind of impact do you want to make in the world, and what values drive your desire to contribute? What legacy would you like to leave?',
      'domain': 'Purpose & Values',
      'probe_context': 'values, impact, purpose, contribution, legacy, meaning, difference',
    },
    'life_design': {
      'id': 'life_design_main',
      'question': 'How do you want to design your ideal working life? Consider work-life integration, location flexibility, team dynamics, and lifestyle preferences.',
      'domain': 'Lifestyle & Integration',
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

CAREER EXPLORATION REQUIREMENTS:
Assess if this response provides sufficient insight for meaningful career guidance. A comprehensive career response should include:
1. Specific examples or situations
2. Emotional/energy indicators (what feels energising vs draining)
3. Context about frequency, impact, or recognition
4. Personal reflections on why this matters to them
5. Concrete details rather than generalisations

If the response lacks depth in the career exploration context, generate 1-2 targeted follow-up questions that will:
- Uncover specific examples and situations
- Explore emotional and energy connections
- Clarify the significance and frequency of experiences
- Reveal underlying values and motivations
- Connect to practical career implications

Return JSON with this structure:
{
  "needsMoreDetail": true/false,
  "detailLevel": "surface/adequate/substantial/comprehensive",
  "questions": ["question1", "question2"],
  "reasoning": "brief explanation focused on career exploration depth"
}

Stop probing only when you have specific, emotionally-connected career insights that can guide career decisions.
''';
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
          'Can you describe a specific time recently when you felt completely energised at work? What exactly were you doing?',
          'What activities do you find yourself doing in your spare time that give you similar energy to your best work moments?',
        ];
      case 'strengths_main':
        return [
          'Can you share a specific example of when someone complimented your work or sought your expertise? What was the situation?',
          'What comes so naturally to you that you sometimes forget others find it difficult?',
        ];
      case 'sought_for_main':
        return [
          'Think about the last few times colleagues or friends asked for your help. What were the common themes in what they needed?',
          'What type of problems do people bring to you repeatedly, even if it\'s not officially part of your role?',
        ];
      case 'values_impact_main':
        return [
          'Can you describe a project or achievement that made you feel most proud? What about it was meaningful to you?',
          'What issues or causes do you find yourself talking about passionately with others?',
        ];
      case 'life_design_main':
        return [
          'Describe your ideal workday from start to finish. Where are you, who are you with, and what are you doing?',
          'What aspects of your current work setup energise you, and what aspects drain your energy?',
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