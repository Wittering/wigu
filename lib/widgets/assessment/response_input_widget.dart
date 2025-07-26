import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Widget for collecting thoughtful responses with validation and guidance
/// Features Australian English prompts and encouraging interaction
class ResponseInputWidget extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;
  final Color domainColor;
  final bool isMainQuestion;

  const ResponseInputWidget({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    required this.domainColor,
    required this.isMainQuestion,
  });

  @override
  State<ResponseInputWidget> createState() => _ResponseInputWidgetState();
}

class _ResponseInputWidgetState extends State<ResponseInputWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _hasText = false;
  bool _isFocused = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
      _validationMessage = null;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused 
                ? widget.domainColor.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextInput(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: widget.domainColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            color: widget.domainColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Share your thoughts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_hasText)
            Text(
              '${_controller.text.trim().split(' ').length} words',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 6,
            minLines: 3,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _handleSubmit(),
          ),
          
          // Validation message
          if (_validationMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationMessage!,
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Writing guidance
          _buildWritingGuidance(),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Clear button (if has text)
              if (_hasText && !widget.isLoading)
                OutlinedButton.icon(
                  onPressed: _handleClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              if (_hasText && !widget.isLoading) const SizedBox(width: 12),
              
              // Submit button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading || !_hasText ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.domainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.white.withOpacity(0.1),
                    disabledForegroundColor: Colors.white.withOpacity(0.3),
                  ),
                  icon: widget.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(
                    widget.isLoading 
                        ? 'Processing...' 
                        : widget.isMainQuestion 
                            ? 'Continue with Reflection'
                            : 'Submit Response',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWritingGuidance() {
    final tips = _getWritingTips();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
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
                Icons.tips_and_updates_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Writing tips',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tips,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    if (widget.isMainQuestion) {
      return 'Take your time to think through this question. Share specific examples, situations, or experiences that come to mind. The more detail you provide, the better insights we can offer...';
    } else {
      return 'This follow-up question helps us understand your experience more deeply. Feel free to expand on your previous response or explore new aspects...';
    }
  }

  String _getWritingTips() {
    if (widget.isMainQuestion) {
      return 'Share specific examples • Include how things made you feel • Mention what energised or drained you • There\'s no word limit - write as much as feels right';
    } else {
      return 'Build on your previous response • Add new examples if they come to mind • Be specific about situations and outcomes • Trust your instincts about what feels important';
    }
  }

  void _handleClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Clear your response?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will delete everything you\'ve written. You can always start fresh.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep Writing',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    
    // Validation
    if (text.isEmpty) {
      setState(() {
        _validationMessage = 'Please share your thoughts before continuing.';
      });
      return;
    }
    
    if (text.split(' ').length < 5) {
      setState(() {
        _validationMessage = 'Your response seems quite brief. Could you share a bit more detail?';
      });
      return;
    }
    
    // Clear validation and submit
    setState(() {
      _validationMessage = null;
    });
    
    widget.onSubmit(text);
    
    // Clear the field after submission
    _controller.clear();
  }
}