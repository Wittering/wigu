import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../utils/theme.dart';
import '../../models/career_session.dart';
import '../../models/career_response.dart';

/// Advanced visualization widgets for career insights
/// Includes radar charts, word clouds, progress charts, and more
class CareerVisualizations {
  
  /// Build a radar chart showing career insight dimensions based on response content
  static Widget buildCareerInsightRadarChart({
    required CareerSession session,
    required double width,
    required double height,
  }) {
    // More meaningful career dimensions based on content analysis
    final dimensions = [
      'People Focus',
      'Creativity', 
      'Leadership',
      'Analysis',
      'Impact Drive',
      'Autonomy',
    ];
    
    // Calculate scores based on content analysis of all responses
    final allResponses = session.responses.values.toList();
    final scores = _analyzeCareerDimensions(allResponses);
    
    return Container(
      width: width,
      height: height,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppTheme.accentTeal.withOpacity(0.1),
              borderColor: AppTheme.accentTeal,
              entryRadius: 3,
              dataEntries: scores.map((score) => RadarEntry(value: score)).toList(),
            ),
          ],
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          gridBorderData: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          tickBorderData: BorderSide(color: Colors.transparent),
          getTitle: (index, angle) {
            if (index < dimensions.length) {
              return RadarChartTitle(
                text: dimensions[index],
                angle: angle,
                positionPercentageOffset: 0.1,
              );
            }
            return const RadarChartTitle(text: '');
          },
          titleTextStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          tickCount: 5,
          radarBackgroundColor: Colors.transparent,
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  /// Build a word cloud visualization from response themes
  static Widget buildThemeWordCloud({
    required CareerSession session,
    required double width,
    required double height,
  }) {
    // Extract all themes from responses
    final themeFrequency = <String, int>{};
    
    for (final response in session.responses.values) {
      for (final theme in response.keyThemes) {
        themeFrequency[theme] = (themeFrequency[theme] ?? 0) + 1;
      }
    }
    
    // Sort themes by frequency
    final sortedThemes = themeFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      width: width,
      height: height,
      child: _WordCloudWidget(
        themes: sortedThemes.take(20).toList(),
        width: width,
        height: height,
      ),
    );
  }

  /// Build a reflection depth chart showing quality of responses
  static Widget buildReflectionDepthChart({
    required CareerSession session,
    required double size,
  }) {
    // Calculate average reflection depth across all responses
    final responses = session.responses.values.toList();
    final avgDepth = responses.isNotEmpty 
        ? responses.map((r) => r.reflectionQualityScore).reduce((a, b) => a + b) / responses.length
        : 0.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: avgDepth * 100,
              color: AppTheme.accentTeal,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              value: (1 - avgDepth) * 100,
              color: Colors.white.withOpacity(0.1),
              radius: 20,
              showTitle: false,
            ),
          ],
          centerSpaceRadius: size / 3,
          sectionsSpace: 2,
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  /// Build a horizontal bar chart showing response quality by domain
  static Widget buildQualityBarChart({
    required CareerSession session,
    required double width,
    required double height,
  }) {
    final domainKeys = ['joy_energy', 'strengths', 'sought_for', 'values_impact', 'life_design'];
    final domainNames = ['Joy & Energy', 'Strengths', 'Sought For', 'Values & Impact', 'Life Design'];
    
    final qualityScores = domainKeys.map((key) {
      final responses = session.responses.values
          .where((r) => r.questionId.startsWith(key))
          .toList();
      
      if (responses.isEmpty) return 0.0;
      
      return responses
          .map((r) => r.reflectionQualityScore)
          .reduce((a, b) => a + b) / responses.length;
    }).toList();
    
    return Container(
      width: width,
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < domainNames.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        domainNames[index].split(' ').first, // Just first word
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 0.2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          barGroups: qualityScores.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: _getDomainColor(entry.key),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  /// Get color for domain by index
  static Color _getDomainColor(int index) {
    final colors = [
      AppTheme.warningAmber,
      AppTheme.accentTeal,
      AppTheme.warningAmber,
      AppTheme.successGreen,
      AppTheme.mutedTone1,
    ];
    return colors[index % colors.length];
  }
}

/// Custom word cloud widget
class _WordCloudWidget extends StatelessWidget {
  final List<MapEntry<String, int>> themes;
  final double width;
  final double height;

  const _WordCloudWidget({
    required this.themes,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) {
      return Center(
        child: Text(
          'No themes found',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    final maxFrequency = themes.first.value;
    final minFrequency = themes.last.value;
    final frequencyRange = maxFrequency - minFrequency;

    return Container(
      width: width,
      height: height,
      child: Stack(
        children: themes.asMap().entries.map((entry) {
          final index = entry.key;
          final theme = entry.value;
          
          // Calculate font size based on frequency
          final normalizedFreq = frequencyRange > 0 
              ? (theme.value - minFrequency) / frequencyRange 
              : 0.5;
          final fontSize = 12 + (normalizedFreq * 16); // 12-28px range
          
          // Position words in a scattered but readable way
          final angle = (index * 137.5) % 360; // Golden angle for distribution
          final radius = (index % 3 + 1) * (min(width, height) * 0.15);
          final x = (width / 2) + cos(angle * pi / 180) * radius;
          final y = (height / 2) + sin(angle * pi / 180) * radius;
          
          return Positioned(
            left: x - (theme.key.length * fontSize * 0.3),
            top: y - fontSize / 2,
            child: Text(
              theme.key,
              style: TextStyle(
                color: _getThemeColor(index),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getThemeColor(int index) {
    final colors = [
      AppTheme.accentTeal,
      AppTheme.successGreen,
      AppTheme.warningAmber,
      AppTheme.mutedTone1,
      Colors.white.withOpacity(0.8),
    ];
    return colors[index % colors.length];
  }

}

/// Analyze career dimensions from response content
List<double> _analyzeCareerDimensions(List<CareerResponse> responses) {
  if (responses.isEmpty) {
    return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]; // 6 dimensions
  }

  // Combine all response text for analysis
  final allText = responses.map((r) => r.response.toLowerCase()).join(' ');
  
  // Define keyword patterns for each dimension
  final peopleFocusKeywords = ['team', 'people', 'collaborate', 'mentor', 'help', 'guide', 'support', 'community', 'relationship', 'together', 'others', 'coaching', 'teaching'];
  final creativityKeywords = ['creative', 'design', 'innovative', 'idea', 'imagination', 'artistic', 'visual', 'original', 'unique', 'invent', 'brainstorm', 'aesthetic'];
  final leadershipKeywords = ['lead', 'manage', 'direct', 'influence', 'inspire', 'motivate', 'decision', 'strategy', 'vision', 'organize', 'coordinate', 'responsibility'];
  final analysisKeywords = ['analyze', 'data', 'research', 'investigate', 'logic', 'systematic', 'detail', 'pattern', 'solve', 'technical', 'method', 'evidence'];
  final impactKeywords = ['impact', 'change', 'improve', 'difference', 'meaningful', 'purpose', 'mission', 'contribute', 'legacy', 'transform', 'benefit'];
  final autonomyKeywords = ['independent', 'freedom', 'flexible', 'own', 'control', 'choice', 'autonomy', 'self-directed', 'pace', 'decide'];

  // Calculate scores based on keyword frequency and context
  final peopleFocus = _calculateDimensionScore(allText, peopleFocusKeywords);
  final creativity = _calculateDimensionScore(allText, creativityKeywords);
  final leadership = _calculateDimensionScore(allText, leadershipKeywords);
  final analysis = _calculateDimensionScore(allText, analysisKeywords);
  final impact = _calculateDimensionScore(allText, impactKeywords);
  final autonomy = _calculateDimensionScore(allText, autonomyKeywords);

  return [peopleFocus, creativity, leadership, analysis, impact, autonomy];
}

/// Calculate dimension score based on keyword frequency and weighting
double _calculateDimensionScore(String text, List<String> keywords) {
  var score = 0.0;
  
  for (final keyword in keywords) {
    // Count occurrences of each keyword
    final regex = RegExp(r'\b' + keyword + r'\b');
    final matches = regex.allMatches(text).length;
    
    // Weight longer, more specific keywords higher
    final weight = keyword.length > 6 ? 1.5 : 1.0;
    score += matches * weight;
  }
  
  // Normalize to 0-5 scale based on text length and keyword density
  final textWords = text.split(' ').length;
  final normalizedScore = (score / (textWords / 100)) * 2; // Adjust multiplier as needed
  
  return normalizedScore.clamp(0.0, 5.0);
}