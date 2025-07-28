import 'package:hive/hive.dart';
import 'career_session.dart';
import 'career_insight.dart';
import 'career_synthesis.dart';
import 'experiment_result.dart';

part 'career_report.g.dart';

/// Comprehensive career report combining insights, synthesis, and recommendations
/// Generates professional documents for career development planning
@HiveType(typeId: 70)
class CareerReport extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final ReportType type;

  @HiveField(4)
  final DateTime generatedAt;

  @HiveField(5)
  final List<String> includedInsightIds;

  @HiveField(6)
  final String? synthesisId;

  @HiveField(7)
  final List<String>? experimentResultIds;

  @HiveField(8)
  final ReportFormat format;

  @HiveField(9)
  final String executiveSummary;

  @HiveField(10)
  final List<ReportSection> sections;

  @HiveField(11)
  final List<String> keyFindings;

  @HiveField(12)
  final List<String> strategicRecommendations;

  @HiveField(13)
  final List<String> nextSteps;

  @HiveField(14)
  final Map<String, dynamic>? visualisationData;

  @HiveField(15)
  final ReportConfidence confidence;

  @HiveField(16)
  final String? customBranding;

  @HiveField(17)
  final Map<String, String>? metadata;

  @HiveField(18)
  final DateTime? lastUpdated;

  @HiveField(19)
  final bool isShareable;

  @HiveField(20)
  final String? sharingToken;

  CareerReport({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.type,
    required this.generatedAt,
    required this.includedInsightIds,
    this.synthesisId,
    this.experimentResultIds,
    required this.format,
    required this.executiveSummary,
    required this.sections,
    required this.keyFindings,
    required this.strategicRecommendations,
    required this.nextSteps,
    this.visualisationData,
    required this.confidence,
    this.customBranding,
    this.metadata,
    this.lastUpdated,
    this.isShareable = false,
    this.sharingToken,
  });

  CareerReport copyWith({
    String? id,
    String? sessionId,
    String? title,
    ReportType? type,
    DateTime? generatedAt,
    List<String>? includedInsightIds,
    String? synthesisId,
    List<String>? experimentResultIds,
    ReportFormat? format,
    String? executiveSummary,
    List<ReportSection>? sections,
    List<String>? keyFindings,
    List<String>? strategicRecommendations,
    List<String>? nextSteps,
    Map<String, dynamic>? visualisationData,
    ReportConfidence? confidence,
    String? customBranding,
    Map<String, String>? metadata,
    DateTime? lastUpdated,
    bool? isShareable,
    String? sharingToken,
  }) {
    return CareerReport(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      type: type ?? this.type,
      generatedAt: generatedAt ?? this.generatedAt,
      includedInsightIds: includedInsightIds ?? this.includedInsightIds,
      synthesisId: synthesisId ?? this.synthesisId,
      experimentResultIds: experimentResultIds ?? this.experimentResultIds,
      format: format ?? this.format,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      sections: sections ?? this.sections,
      keyFindings: keyFindings ?? this.keyFindings,
      strategicRecommendations: strategicRecommendations ?? this.strategicRecommendations,
      nextSteps: nextSteps ?? this.nextSteps,
      visualisationData: visualisationData ?? this.visualisationData,
      confidence: confidence ?? this.confidence,
      customBranding: customBranding ?? this.customBranding,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isShareable: isShareable ?? this.isShareable,
      sharingToken: sharingToken ?? this.sharingToken,
    );
  }

  /// Get the estimated reading time in minutes
  int get estimatedReadingTime {
    int totalWords = 0;
    
    // Executive summary
    totalWords += executiveSummary.split(' ').length;
    
    // Sections
    for (final section in sections) {
      totalWords += section.content.split(' ').length;
    }
    
    // Key findings and recommendations
    totalWords += keyFindings.join(' ').split(' ').length;
    totalWords += strategicRecommendations.join(' ').split(' ').length;
    totalWords += nextSteps.join(' ').split(' ').length;
    
    // Average reading speed is 200-250 words per minute
    return (totalWords / 225).ceil();
  }

  /// Get the report quality score based on various factors
  double get qualityScore {
    double score = 0.0;
    
    // Base score from content completeness
    if (executiveSummary.length > 100) score += 0.2;
    if (keyFindings.length >= 3) score += 0.2;
    if (strategicRecommendations.length >= 5) score += 0.2;
    if (nextSteps.length >= 3) score += 0.1;
    
    // Section quality
    if (sections.length >= 3) score += 0.1;
    final avgSectionLength = sections.isEmpty ? 0 : 
        sections.map((s) => s.content.length).reduce((a, b) => a + b) / sections.length;
    if (avgSectionLength > 200) score += 0.1;
    
    // Confidence factor
    switch (confidence) {
      case ReportConfidence.high:
        score += 0.1;
        break;
      case ReportConfidence.medium:
        score += 0.05;
        break;
      case ReportConfidence.low:
        break;
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Check if the report is comprehensive
  bool get isComprehensive {
    return sections.length >= 4 && 
           keyFindings.length >= 5 &&
           strategicRecommendations.length >= 7 &&
           qualityScore >= 0.8;
  }

  /// Generate sharing URL if report is shareable
  String? generateSharingUrl({String baseUrl = 'https://wigu.career'}) {
    if (!isShareable || sharingToken == null) return null;
    return '$baseUrl/shared-report/$sharingToken';
  }

  /// Generate document header
  String generateHeader() {
    final buffer = StringBuffer();
    
    buffer.writeln('Career Development Report');
    buffer.writeln(title);
    buffer.writeln('');
    buffer.writeln('Generated: ${generatedAt.toIso8601String().split('T')[0]}');
    buffer.writeln('Type: ${type.displayName}');
    buffer.writeln('Confidence: ${confidence.displayName}');
    buffer.writeln('Reading Time: $estimatedReadingTime minutes');
    
    if (customBranding != null) {
      buffer.writeln('');
      buffer.writeln(customBranding);
    }
    
    buffer.writeln('');
    buffer.writeln('=' * 50);
    
    return buffer.toString();
  }

  /// Generate table of contents
  String generateTableOfContents() {
    final buffer = StringBuffer();
    
    buffer.writeln('Table of Contents');
    buffer.writeln('================');
    buffer.writeln('');
    buffer.writeln('1. Executive Summary');
    
    int sectionNumber = 2;
    for (final section in sections) {
      buffer.writeln('$sectionNumber. ${section.title}');
      sectionNumber++;
    }
    
    buffer.writeln('$sectionNumber. Key Findings');
    buffer.writeln('${sectionNumber + 1}. Strategic Recommendations');
    buffer.writeln('${sectionNumber + 2}. Next Steps');
    
    if (visualisationData != null && visualisationData!.isNotEmpty) {
      buffer.writeln('${sectionNumber + 3}. Visualisations & Charts');
    }
    
    buffer.writeln('');
    return buffer.toString();
  }

  /// Generate the full report content as markdown
  String generateMarkdownContent() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('# $title');
    buffer.writeln('');
    buffer.writeln('**Generated:** ${generatedAt.toIso8601String().split('T')[0]}');
    buffer.writeln('**Type:** ${type.displayName}');
    buffer.writeln('**Confidence:** ${confidence.displayName}');
    buffer.writeln('**Reading Time:** $estimatedReadingTime minutes');
    buffer.writeln('');
    
    // Executive Summary
    buffer.writeln('## Executive Summary');
    buffer.writeln('');
    buffer.writeln(executiveSummary);
    buffer.writeln('');
    
    // Sections
    for (final section in sections) {
      buffer.writeln('## ${section.title}');
      buffer.writeln('');
      if (section.subtitle != null) {
        buffer.writeln('*${section.subtitle}*');
        buffer.writeln('');
      }
      buffer.writeln(section.content);
      buffer.writeln('');
      
      if (section.keyPoints.isNotEmpty) {
        buffer.writeln('**Key Points:**');
        for (final point in section.keyPoints) {
          buffer.writeln('- $point');
        }
        buffer.writeln('');
      }
    }
    
    // Key Findings
    if (keyFindings.isNotEmpty) {
      buffer.writeln('## Key Findings');
      buffer.writeln('');
      for (int i = 0; i < keyFindings.length; i++) {
        buffer.writeln('${i + 1}. ${keyFindings[i]}');
      }
      buffer.writeln('');
    }
    
    // Strategic Recommendations
    if (strategicRecommendations.isNotEmpty) {
      buffer.writeln('## Strategic Recommendations');
      buffer.writeln('');
      for (int i = 0; i < strategicRecommendations.length; i++) {
        buffer.writeln('${i + 1}. ${strategicRecommendations[i]}');
      }
      buffer.writeln('');
    }
    
    // Next Steps
    if (nextSteps.isNotEmpty) {
      buffer.writeln('## Next Steps');
      buffer.writeln('');
      for (int i = 0; i < nextSteps.length; i++) {
        buffer.writeln('${i + 1}. ${nextSteps[i]}');
      }
      buffer.writeln('');
    }
    
    // Footer
    buffer.writeln('---');
    buffer.writeln('');
    buffer.writeln('*This report was generated by the "When I grow up..." Career Insight Engine.*');
    
    if (isShareable && sharingToken != null) {
      final shareUrl = generateSharingUrl();
      buffer.writeln('*Report ID: $id*');
      if (shareUrl != null) {
        buffer.writeln('*Shareable Link: $shareUrl*');
      }
    }
    
    return buffer.toString();
  }

  /// Generate action plan from recommendations and next steps
  List<String> generateActionPlan() {
    final actions = <String>[];
    
    // Prioritise next steps
    actions.addAll(nextSteps.take(5));
    
    // Add top strategic recommendations as actions
    actions.addAll(strategicRecommendations.take(3).map(
      (rec) => 'Strategic focus: $rec'
    ));
    
    return actions.take(8).toList();
  }

  /// Export report data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'title': title,
      'type': type.name,
      'generatedAt': generatedAt.toIso8601String(),
      'includedInsightIds': includedInsightIds,
      'synthesisId': synthesisId,
      'experimentResultIds': experimentResultIds,
      'format': format.name,
      'executiveSummary': executiveSummary,
      'sections': sections.map((s) => s.toJson()).toList(),
      'keyFindings': keyFindings,
      'strategicRecommendations': strategicRecommendations,
      'nextSteps': nextSteps,
      'visualisationData': visualisationData,
      'confidence': confidence.name,
      'customBranding': customBranding,
      'metadata': metadata,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isShareable': isShareable,
      'sharingToken': sharingToken,
      'analysis': {
        'estimatedReadingTime': estimatedReadingTime,
        'qualityScore': qualityScore,
        'isComprehensive': isComprehensive,
        'sharingUrl': generateSharingUrl(),
      },
    };
  }

  /// Create a new career report
  static CareerReport create({
    required String sessionId,
    required String title,
    required ReportType type,
    required List<String> includedInsightIds,
    String? synthesisId,
    List<String>? experimentResultIds,
    required ReportFormat format,
    required String executiveSummary,
    required List<ReportSection> sections,
    required List<String> keyFindings,
    required List<String> strategicRecommendations,
    required List<String> nextSteps,
    Map<String, dynamic>? visualisationData,
    required ReportConfidence confidence,
    String? customBranding,
    Map<String, String>? metadata,
    bool isShareable = false,
  }) {
    return CareerReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      title: title,
      type: type,
      generatedAt: DateTime.now(),
      includedInsightIds: includedInsightIds,
      synthesisId: synthesisId,
      experimentResultIds: experimentResultIds,
      format: format,
      executiveSummary: executiveSummary,
      sections: sections,
      keyFindings: keyFindings,
      strategicRecommendations: strategicRecommendations,
      nextSteps: nextSteps,
      visualisationData: visualisationData,
      confidence: confidence,
      customBranding: customBranding,
      metadata: metadata,
      isShareable: isShareable,
      sharingToken: isShareable ? 'share_${DateTime.now().millisecondsSinceEpoch}' : null,
    );
  }

  @override
  String toString() {
    return 'CareerReport{id: $id, title: $title, type: ${type.name}, '
           'quality: ${qualityScore.toStringAsFixed(2)}, '
           'readingTime: ${estimatedReadingTime}min}';
  }
}

/// Individual section within a career report
@HiveType(typeId: 71)
class ReportSection extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? subtitle;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final SectionType type;

  @HiveField(5)
  final List<String> keyPoints;

  @HiveField(6)
  final int orderIndex;

  @HiveField(7)
  final Map<String, dynamic>? sectionData;

  @HiveField(8)
  final bool includeVisualisations;

  ReportSection({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    required this.type,
    required this.keyPoints,
    required this.orderIndex,
    this.sectionData,
    this.includeVisualisations = false,
  });

  ReportSection copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    SectionType? type,
    List<String>? keyPoints,
    int? orderIndex,
    Map<String, dynamic>? sectionData,
    bool? includeVisualisations,
  }) {
    return ReportSection(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      type: type ?? this.type,
      keyPoints: keyPoints ?? this.keyPoints,
      orderIndex: orderIndex ?? this.orderIndex,
      sectionData: sectionData ?? this.sectionData,
      includeVisualisations: includeVisualisations ?? this.includeVisualisations,
    );
  }

  /// Get the word count of this section
  int get wordCount {
    return content.split(' ').length + 
           keyPoints.join(' ').split(' ').length;
  }

  /// Check if this section is substantial
  bool get isSubstantial {
    return content.length > 200 || keyPoints.length >= 3;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'type': type.name,
      'keyPoints': keyPoints,
      'orderIndex': orderIndex,
      'sectionData': sectionData,
      'includeVisualisations': includeVisualisations,
      'wordCount': wordCount,
      'isSubstantial': isSubstantial,
    };
  }

  @override
  String toString() {
    return 'ReportSection{title: $title, type: ${type.name}, '
           'wordCount: $wordCount, order: $orderIndex}';
  }
}

/// Types of career reports
@HiveType(typeId: 72)
enum ReportType {
  @HiveField(0)
  comprehensive('Comprehensive Career Analysis', 'Complete analysis with all insights and recommendations'),
  
  @HiveField(1)
  strengthsFocus('Strengths-Focused Report', 'Emphasis on identifying and leveraging strengths'),
  
  @HiveField(2)
  developmentPlan('Development Plan', 'Focus on growth areas and development opportunities'),
  
  @HiveField(3)
  synthesisReport('Self vs External Synthesis', 'Comparison of self-perception with external feedback'),
  
  @HiveField(4)
  experimentSummary('Experiment Results Summary', 'Summary of completed career experiments'),
  
  @HiveField(5)
  executiveBrief('Executive Brief', 'Concise summary for senior stakeholders'),
  
  @HiveField(6)
  coachingReport('Coaching Report', 'Detailed analysis for career coaching sessions');

  const ReportType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Format of the report output
@HiveType(typeId: 73)
enum ReportFormat {
  @HiveField(0)
  markdown('Markdown', 'Markdown format for web display'),
  
  @HiveField(1)
  pdf('PDF', 'Professional PDF document'),
  
  @HiveField(2)
  word('Word Document', 'Microsoft Word document'),
  
  @HiveField(3)
  html('HTML', 'Web page format'),
  
  @HiveField(4)
  json('JSON', 'Structured data format');

  const ReportFormat(this.displayName, this.description);
  
  final String displayName;
  final String description;
  
  String get fileExtension {
    switch (this) {
      case ReportFormat.markdown:
        return '.md';
      case ReportFormat.pdf:
        return '.pdf';
      case ReportFormat.word:
        return '.docx';
      case ReportFormat.html:
        return '.html';
      case ReportFormat.json:
        return '.json';
    }
  }
}

/// Types of report sections
@HiveType(typeId: 74)
enum SectionType {
  @HiveField(0)
  overview('Overview', 'General overview and introduction'),
  
  @HiveField(1)
  insights('Insights', 'Career insights and findings'),
  
  @HiveField(2)
  strengths('Strengths', 'Identified strengths and capabilities'),
  
  @HiveField(3)
  development('Development', 'Areas for growth and development'),
  
  @HiveField(4)
  synthesis('Synthesis', 'Comparison and synthesis of perspectives'),
  
  @HiveField(5)
  experiments('Experiments', 'Results from career experiments'),
  
  @HiveField(6)
  recommendations('Recommendations', 'Strategic recommendations'),
  
  @HiveField(7)
  action('Action Plan', 'Specific actions and next steps'),
  
  @HiveField(8)
  appendix('Appendix', 'Supporting information and details');

  const SectionType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Confidence level in the report
@HiveType(typeId: 75)
enum ReportConfidence {
  @HiveField(0)
  high('High', 'High confidence based on substantial data'),
  
  @HiveField(1)
  medium('Medium', 'Medium confidence with some limitations'),
  
  @HiveField(2)
  low('Low', 'Lower confidence due to limited data or analysis');

  const ReportConfidence(this.displayName, this.description);
  
  final String displayName;
  final String description;
}