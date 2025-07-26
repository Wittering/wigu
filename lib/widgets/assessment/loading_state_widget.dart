import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Widget for displaying loading states in the career assessment flow
/// Provides engaging loading animations with Australian English messages
class LoadingStateWidget extends StatefulWidget {
  final String? message;
  final LoadingType type;
  final Color? color;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.type = LoadingType.general,
    this.color,
  });

  /// Factory constructor for AI thinking state
  factory LoadingStateWidget.aiThinking({String? customMessage}) {
    return LoadingStateWidget(
      message: customMessage ?? 'AI is analysing your response and preparing follow-up questions...',
      type: LoadingType.aiThinking,
      color: CareerTheme.accentYellow,
    );
  }

  /// Factory constructor for session loading
  factory LoadingStateWidget.sessionLoading({String? customMessage}) {
    return LoadingStateWidget(
      message: customMessage ?? 'Loading your assessment session...',
      type: LoadingType.sessionLoading,
      color: CareerTheme.primaryBlue,
    );
  }

  /// Factory constructor for response processing
  factory LoadingStateWidget.processingResponse({String? customMessage}) {
    return LoadingStateWidget(
      message: customMessage ?? 'Processing your thoughtful response...',
      type: LoadingType.processing,
      color: CareerTheme.primaryGreen,
    );
  }

  /// Factory constructor for generating insights
  factory LoadingStateWidget.generatingInsights({String? customMessage}) {
    return LoadingStateWidget(
      message: customMessage ?? 'Generating personalised career insights from your responses...',
      type: LoadingType.insights,
      color: CareerTheme.accentPurple,
    );
  }

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    if (widget.type == LoadingType.aiThinking) {
      _rotationController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? CareerTheme.primaryBlue;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            _buildLoadingIndicator(color),
            const SizedBox(height: 24),
            
            // Loading message
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
            // Progress dots for longer operations
            if (widget.type == LoadingType.insights || widget.type == LoadingType.aiThinking)
              _buildProgressDots(color),
            
            // Encouraging message
            const SizedBox(height: 16),
            _buildEncouragingMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.type) {
      case LoadingType.aiThinking:
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.psychology_outlined,
                        color: color,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      
      case LoadingType.processing:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: color,
                  size: 32,
                ),
              ),
            );
          },
        );
      
      case LoadingType.insights:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: color,
                  size: 32,
                ),
              ),
            );
          },
        );
      
      default:
        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
        );
    }
  }

  Widget _buildProgressDots(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.3;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final opacity = (animationValue < 0.5) 
                ? animationValue * 2 
                : (1.0 - animationValue) * 2;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEncouragingMessage() {
    String message;
    switch (widget.type) {
      case LoadingType.aiThinking:
        message = 'Take a moment to pause and reflect while AI prepares thoughtful follow-up questions.';
        break;
      case LoadingType.processing:
        message = 'Your thoughtful response is being carefully processed for insights.';
        break;
      case LoadingType.insights:
        message = 'Analysing patterns across your responses to generate personalised career insights.';
        break;
      case LoadingType.sessionLoading:
        message = 'Preparing your personalised career exploration environment.';
        break;
      default:
        message = 'Processing your request...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.eco_outlined,
            color: Colors.white.withOpacity(0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum LoadingType {
  general,
  aiThinking,
  processing,
  insights,
  sessionLoading,
}