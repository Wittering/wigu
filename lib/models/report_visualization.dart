import 'package:hive/hive.dart';
import 'career_insight.dart';

part 'report_visualization.g.dart';

/// Visualisation configuration and data for career reports
/// Defines charts, graphs, and visual elements to enhance report presentation
@HiveType(typeId: 80)
class ReportVisualization extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? subtitle;

  @HiveField(3)
  final VisualizationType type;

  @HiveField(4)
  final Map<String, dynamic> data;

  @HiveField(5)
  final VisualizationConfig config;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final List<String> insights; // Key insights from this visualisation

  @HiveField(8)
  final int orderIndex;

  @HiveField(9)
  final bool isInteractive;

  @HiveField(10)
  final String? reportSectionId;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final Map<String, String>? colorScheme;

  @HiveField(13)
  final VisualizationSize size;

  ReportVisualization({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.data,
    required this.config,
    this.description,
    required this.insights,
    required this.orderIndex,
    this.isInteractive = false,
    this.reportSectionId,
    required this.createdAt,
    this.colorScheme,
    required this.size,
  });

  ReportVisualization copyWith({
    String? id,
    String? title,
    String? subtitle,
    VisualizationType? type,
    Map<String, dynamic>? data,
    VisualizationConfig? config,
    String? description,
    List<String>? insights,
    int? orderIndex,
    bool? isInteractive,
    String? reportSectionId,
    DateTime? createdAt,
    Map<String, String>? colorScheme,
    VisualizationSize? size,
  }) {
    return ReportVisualization(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      data: data ?? this.data,
      config: config ?? this.config,
      description: description ?? this.description,
      insights: insights ?? this.insights,
      orderIndex: orderIndex ?? this.orderIndex,
      isInteractive: isInteractive ?? this.isInteractive,
      reportSectionId: reportSectionId ?? this.reportSectionId,
      createdAt: createdAt ?? this.createdAt,
      colorScheme: colorScheme ?? this.colorScheme,
      size: size ?? this.size,
    );
  }

  /// Check if this visualisation has sufficient data to render
  bool get hasValidData {
    return data.isNotEmpty && 
           data.values.any((value) => value != null);
  }

  /// Get the default color scheme for this visualisation type
  Map<String, String> get defaultColorScheme {
    switch (type) {
      case VisualizationType.strengthsRadar:
        return {
          'primary': '#2E7D32',
          'secondary': '#66BB6A',
          'accent': '#A5D6A7',
          'background': '#F1F8E9',
        };
      case VisualizationType.insightDistribution:
        return {
          'primary': '#1976D2',
          'secondary': '#42A5F5',
          'accent': '#90CAF9',
          'background': '#E3F2FD',
        };
      case VisualizationType.progressTracking:
        return {
          'primary': '#7B1FA2',
          'secondary': '#AB47BC',
          'accent': '#CE93D8',
          'background': '#F3E5F5',
        };
      case VisualizationType.themeNetwork:
        return {
          'primary': '#F57C00',
          'secondary': '#FF9800',
          'accent': '#FFB74D',
          'background': '#FFF3E0',
        };
      case VisualizationType.timelineDevelopment:
        return {
          'primary': '#388E3C',
          'secondary': '#4CAF50',
          'accent': '#81C784',
          'background': '#E8F5E8',
        };
      case VisualizationType.competencyMatrix:
        return {
          'primary': '#D32F2F',
          'secondary': '#F44336',
          'accent': '#EF5350',
          'background': '#FFEBEE',
        };
      case VisualizationType.valueAlignment:
        return {
          'primary': '#512DA8',
          'secondary': '#673AB7',
          'accent': '#9575CD',
          'background': '#EDE7F6',
        };
      case VisualizationType.experimentResults:
        return {
          'primary': '#00796B',
          'secondary': '#009688',
          'accent': '#4DB6AC',
          'background': '#E0F2F1',
        };
    }
  }

  /// Generate chart configuration for fl_chart
  Map<String, dynamic> generateChartConfig() {
    final colors = colorScheme ?? defaultColorScheme;
    
    return {
      'type': type.name,
      'data': data,
      'colors': colors,
      'size': {
        'width': size.width,
        'height': size.height,
      },
      'config': config.toJson(),
      'interactive': isInteractive,
      'responsive': config.isResponsive,
    };
  }

  /// Generate description with insights
  String generateFullDescription() {
    final buffer = StringBuffer();
    
    if (description != null && description!.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln('');
    }
    
    if (insights.isNotEmpty) {
      buffer.writeln('Key Insights:');
      for (final insight in insights) {
        buffer.writeln('• $insight');
      }
    }
    
    return buffer.toString().trim();
  }

  /// Export visualisation data to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'data': data,
      'config': config.toJson(),
      'description': description,
      'insights': insights,
      'orderIndex': orderIndex,
      'isInteractive': isInteractive,
      'reportSectionId': reportSectionId,
      'createdAt': createdAt.toIso8601String(),
      'colorScheme': colorScheme ?? defaultColorScheme,
      'size': size.toJson(),
      'hasValidData': hasValidData,
      'chartConfig': generateChartConfig(),
    };
  }

  /// Create a strengths radar chart
  static ReportVisualization createStrengthsRadar({
    required String title,
    required Map<String, double> strengthsData,
    required List<String> insights,
    String? subtitle,
    String? description,
    int orderIndex = 0,
    String? reportSectionId,
  }) {
    return ReportVisualization(
      id: 'viz_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      type: VisualizationType.strengthsRadar,
      data: {
        'strengths': strengthsData,
        'maxValue': strengthsData.values.isNotEmpty 
            ? strengthsData.values.reduce((a, b) => a > b ? a : b) 
            : 5.0,
      },
      config: VisualizationConfig(
        showLegend: true,
        showGridLines: true,
        isResponsive: true,
        customSettings: {
          'radarType': 'filled',
          'strokeWidth': 2.0,
          'fillOpacity': 0.3,
        },
      ),
      description: description,
      insights: insights,
      orderIndex: orderIndex,
      isInteractive: true,
      reportSectionId: reportSectionId,
      createdAt: DateTime.now(),
      size: VisualizationSize.medium,
    );
  }

  /// Create an insight distribution pie chart
  static ReportVisualization createInsightDistribution({
    required String title,
    required Map<String, int> distributionData,
    required List<String> insights,
    String? subtitle,
    String? description,
    int orderIndex = 0,
    String? reportSectionId,
  }) {
    return ReportVisualization(
      id: 'viz_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      type: VisualizationType.insightDistribution,
      data: {
        'distribution': distributionData,
        'total': distributionData.values.fold(0, (a, b) => a + b),
      },
      config: VisualizationConfig(
        showLegend: true,
        showLabels: true,
        isResponsive: true,
        customSettings: {
          'chartType': 'donut',
          'innerRadius': 0.6,
          'showPercentages': true,
        },
      ),
      description: description,
      insights: insights,
      orderIndex: orderIndex,
      reportSectionId: reportSectionId,
      createdAt: DateTime.now(),
      size: VisualizationSize.medium,
    );
  }

  /// Create a progress tracking line chart
  static ReportVisualization createProgressTracking({
    required String title,
    required Map<String, List<double>> progressData,
    required List<String> timeLabels,
    required List<String> insights,
    String? subtitle,
    String? description,
    int orderIndex = 0,
    String? reportSectionId,
  }) {
    return ReportVisualization(
      id: 'viz_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      type: VisualizationType.progressTracking,
      data: {
        'progress': progressData,
        'timeLabels': timeLabels,
        'dataPoints': progressData.values.isNotEmpty 
            ? progressData.values.first.length 
            : 0,
      },
      config: VisualizationConfig(
        showLegend: true,
        showGridLines: true,
        showLabels: true,
        isResponsive: true,
        customSettings: {
          'lineType': 'smooth',
          'strokeWidth': 3.0,
          'showDataPoints': true,
          'pointRadius': 4.0,
        },
      ),
      description: description,
      insights: insights,
      orderIndex: orderIndex,
      isInteractive: true,
      reportSectionId: reportSectionId,
      createdAt: DateTime.now(),
      size: VisualizationSize.large,
    );
  }

  @override
  String toString() {
    return 'ReportVisualization{id: $id, title: $title, type: ${type.name}, '
           'order: $orderIndex, hasData: $hasValidData}';
  }
}

/// Configuration for visualisations
@HiveType(typeId: 81)
class VisualizationConfig extends HiveObject {
  @HiveField(0)
  final bool showLegend;

  @HiveField(1)
  final bool showGridLines;

  @HiveField(2)
  final bool showLabels;

  @HiveField(3)
  final bool isResponsive;

  @HiveField(4)
  final Map<String, dynamic>? customSettings;

  @HiveField(5)
  final bool showTooltips;

  @HiveField(6)
  final bool enableAnimation;

  @HiveField(7)
  final int? animationDuration;

  VisualizationConfig({
    this.showLegend = true,
    this.showGridLines = false,
    this.showLabels = true,
    this.isResponsive = true,
    this.customSettings,
    this.showTooltips = true,
    this.enableAnimation = true,
    this.animationDuration = 1000,
  });

  Map<String, dynamic> toJson() {
    return {
      'showLegend': showLegend,
      'showGridLines': showGridLines,
      'showLabels': showLabels,
      'isResponsive': isResponsive,
      'customSettings': customSettings,
      'showTooltips': showTooltips,
      'enableAnimation': enableAnimation,
      'animationDuration': animationDuration,
    };
  }

  @override
  String toString() {
    return 'VisualizationConfig{legend: $showLegend, responsive: $isResponsive, animation: $enableAnimation}';
  }
}

/// Size configuration for visualisations
@HiveType(typeId: 82)
class VisualizationSize extends HiveObject {
  @HiveField(0)
  final double width;

  @HiveField(1)
  final double height;

  @HiveField(2)
  final SizePreset preset;

  VisualizationSize({
    required this.width,
    required this.height,
    required this.preset,
  });

  static final VisualizationSize small = VisualizationSize(
    width: 300,
    height: 200,
    preset: SizePreset.small,
  );

  static final VisualizationSize medium = VisualizationSize(
    width: 500,
    height: 350,
    preset: SizePreset.medium,
  );

  static final VisualizationSize large = VisualizationSize(
    width: 800,
    height: 500,
    preset: SizePreset.large,
  );

  static final VisualizationSize fullWidth = VisualizationSize(
    width: 1000,
    height: 400,
    preset: SizePreset.fullWidth,
  );

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'preset': preset.name,
    };
  }

  @override
  String toString() {
    return 'VisualizationSize{${width}x$height, preset: ${preset.name}}';
  }
}

/// Types of visualisations available for reports
@HiveType(typeId: 83)
enum VisualizationType {
  @HiveField(0)
  strengthsRadar('Strengths Radar', 'Radar chart showing strength levels across domains'),
  
  @HiveField(1)
  insightDistribution('Insight Distribution', 'Pie chart showing distribution of insight types'),
  
  @HiveField(2)
  progressTracking('Progress Tracking', 'Line chart showing progress over time'),
  
  @HiveField(3)
  themeNetwork('Theme Network', 'Network diagram showing theme relationships'),
  
  @HiveField(4)
  timelineDevelopment('Development Timeline', 'Timeline showing career development milestones'),
  
  @HiveField(5)
  competencyMatrix('Competency Matrix', 'Matrix showing competency levels vs importance'),
  
  @HiveField(6)
  valueAlignment('Value Alignment', 'Bar chart showing alignment with personal values'),
  
  @HiveField(7)
  experimentResults('Experiment Results', 'Chart showing experiment outcomes and success rates');

  const VisualizationType(this.displayName, this.description);
  
  final String displayName;
  final String description;
}

/// Predefined size presets
@HiveType(typeId: 84)
enum SizePreset {
  @HiveField(0)
  small('Small', 'Compact visualisation for inline use'),
  
  @HiveField(1)
  medium('Medium', 'Standard size for most visualisations'),
  
  @HiveField(2)
  large('Large', 'Large visualisation for detailed analysis'),
  
  @HiveField(3)
  fullWidth('Full Width', 'Full width visualisation for impact');

  const SizePreset(this.displayName, this.description);
  
  final String displayName;
  final String description;
}