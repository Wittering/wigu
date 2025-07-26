import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Card displaying a career exploration question with calm, reflective design
/// Features Australian English and thoughtful visual presentation
class QuestionCard extends StatefulWidget {
  final String question;
  final bool isMainQuestion;
  final Color domainColor;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isMainQuestion,
    required this.domainColor,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 300,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2A2A2A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.domainColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: widget.domainColor.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.5,
                          colors: [
                            widget.domainColor.withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Simple question type indicator
                        _buildSimpleIndicator(),
                        const SizedBox(height: 32),
                        
                        // Clean question text
                        Expanded(
                          child: _buildCleanQuestionText(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimpleIndicator() {
    return Row(
      children: [
        if (widget.totalQuestions > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              '${widget.questionNumber}/${widget.totalQuestions}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCleanQuestionText() {
    return Center(
      child: SelectableText(
        widget.question,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildReflectionPrompt() {
    final prompts = widget.isMainQuestion 
        ? _getMainQuestionPrompts()
        : _getFollowUpPrompts();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: widget.domainColor.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Take your time to reflect',
                style: TextStyle(
                  color: widget.domainColor.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...prompts.map((prompt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    prompt,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<String> _getMainQuestionPrompts() {
    return [
      'There are no right or wrong answers - just your authentic experience',
      'Think of specific examples and situations that come to mind',
      'Consider both recent experiences and patterns over time',
      'Share as much detail as feels comfortable - the more context, the better insights we can provide',
    ];
  }

  List<String> _getFollowUpPrompts() {
    return [
      'This follow-up question aims to deepen your reflection',
      'Feel free to build on your previous response or explore new angles',
      'Specific examples and stories are particularly valuable',
      'Take a moment to really consider what resonates with you',
    ];
  }
}