import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../providers/career_assessment_provider.dart';

/// Simple exploration widget for the "What do you want to be when you grow up?" flow
/// Provides a conversational, approachable entry point to career exploration
class SimpleExplorationWidget extends ConsumerStatefulWidget {
  const SimpleExplorationWidget({super.key});

  @override
  ConsumerState<SimpleExplorationWidget> createState() => _SimpleExplorationWidgetState();
}

class _SimpleExplorationWidgetState extends ConsumerState<SimpleExplorationWidget> {
  final TextEditingController _responseController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ConversationMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeConversation() {
    // Add the initial welcome message
    _messages.add(ConversationMessage(
      text: "G'day! I'm here to help you explore what you might want to be when you grow up. 🌟\n\nLet's start with something simple - what's one thing you really enjoy doing? It could be anything at all!",
      isFromUser: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildConversation(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentTeal.withOpacity(0.1),
            AppTheme.accentTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentTeal.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '🌱',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'What Do You Want To Be\nWhen You Grow Up?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A simple conversation to explore your possibilities',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildConversation() {
    if (_messages.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentTeal,
          strokeWidth: 2,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mutedTone2.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message, int index) {
    final isUser = message.isFromUser;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentTeal.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 18,
                color: AppTheme.accentTeal,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppTheme.accentTeal.withOpacity(0.1)
                    : AppTheme.mutedTone1.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser 
                      ? AppTheme.accentTeal.withOpacity(0.2)
                      : AppTheme.mutedTone2.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryText,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.mutedTone2.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mutedTone2.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                size: 18,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.mutedTone1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mutedTone2.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _responseController,
              enabled: !_isLoading,
              maxLines: null,
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _isLoading ? null : (_) => _handleSubmit(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isLoading 
                  ? AppTheme.mutedTone2.withOpacity(0.3)
                  : AppTheme.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isLoading 
                    ? AppTheme.mutedTone2.withOpacity(0.3)
                    : AppTheme.accentTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _handleSubmit,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.mutedText,
                      ),
                    )
                  : Icon(
                      Icons.send_outlined,
                      color: AppTheme.accentTeal,
                      size: 20,
                    ),
              tooltip: 'Send message',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final text = _responseController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ConversationMessage(text: text, isFromUser: true));
      _isLoading = true;
    });
    
    _responseController.clear();
    _scrollToBottom();

    try {
      // Get AI response (using simple conversation logic for now)
      final response = await _generateSimpleResponse(text, _messages.length);
      
      setState(() {
        _messages.add(ConversationMessage(text: response, isFromUser: false));
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ConversationMessage(
          text: "Sorry, I'm having trouble right now. Could you try again?",
          isFromUser: false,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _generateSimpleResponse(String userInput, int messageCount) async {
    // Simple conversation flow - in a real implementation, this would use AI
    await Future.delayed(const Duration(seconds: 1)); // Simulate AI thinking
    
    final responses = [
      "That's interesting! What is it about that activity that makes you enjoy it so much?",
      "I can see why you'd find that engaging! Have you ever thought about careers that involve similar activities?",
      "That sounds like something you're naturally drawn to. What would your ideal day look like if you could do more of this?",
      "Brilliant! It sounds like you've got some natural interests there. Would you like to explore some career paths that might align with what you enjoy?",
      "You're building a nice picture of what energises you! Ready to dive deeper with our detailed assessment, or would you like to explore more possibilities first?",
    ];
    
    if (messageCount < responses.length * 2) {
      return responses[(messageCount ~/ 2) % responses.length];
    } else {
      return "You've shared some wonderful insights! Would you like to continue with our detailed career assessment to get personalised recommendations?";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ConversationMessage {
  final String text;
  final bool isFromUser;
  
  ConversationMessage({
    required this.text,
    required this.isFromUser,
  });
}