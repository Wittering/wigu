import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advisor_invitation.dart';
import '../../services/advisor_service.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../../widgets/assessment/loading_state_widget.dart';
import '../../widgets/assessment/error_state_widget.dart';

/// Screen for inviting advisors to provide career insight feedback
/// Follows Australian English conventions and calm, reflective design
class AdvisorInvitationScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AdvisorInvitationScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<AdvisorInvitationScreen> createState() => _AdvisorInvitationScreenState();
}

class _AdvisorInvitationScreenState extends ConsumerState<AdvisorInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advisorService = AdvisorService();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _personalMessageController = TextEditingController();
  
  // Form state
  AdvisorRelationship? _selectedRelationship;
  bool _includePersonalMessage = true;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initialiseService();
    _setupDefaultMessage();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _personalMessageController.dispose();
    super.dispose();
  }
  
  Future<void> _initialiseService() async {
    try {
      await _advisorService.initialise();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialise advisor service: ${e.toString()}';
      });
    }
  }
  
  void _setupDefaultMessage() {
    // Set a thoughtful default personal message in Australian English
    _personalMessageController.text = '''I'm currently exploring my career direction and would really value your perspective on my professional strengths and potential. 

Your insights will help me gain a clearer understanding of how others see my capabilities and where I might focus my career development. I'd be grateful for about 10-15 minutes of your time to share your observations.''';
  }
  
  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your relationship with this advisor'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Create the invitation
      final invitation = await _advisorService.createInvitation(
        sessionId: widget.sessionId,
        advisorName: _nameController.text.trim(),
        advisorEmail: _emailController.text.trim().toLowerCase(),
        advisorPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        relationshipType: _selectedRelationship!,
        personalMessage: _personalMessageController.text.trim(),
        includePersonalMessage: _includePersonalMessage,
      );
      
      // Send the invitation email
      await _advisorService.sendInvitationEmail(
        invitationId: invitation.id,
        userName: 'Career Explorer', // In production, get from user session
      );
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${invitation.advisorName}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        
        // Return to previous screen with success indicator
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      AppLogger.error('Failed to send advisor invitation', e);
      setState(() {
        _error = _getErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is AdvisorServiceException) {
      switch (error.type) {
        case AdvisorServiceErrorType.advisorLimitExceeded:
          return 'You\'ve already invited the maximum number of advisors (4) for this session.';
        case AdvisorServiceErrorType.duplicateAdvisor:
          return 'You\'ve already invited someone with this email address.';
        default:
          return error.message;
      }
    }
    return 'Failed to send invitation. Please try again.';
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invite Advisor')),
        body: const LoadingStateWidget(message: 'Sending invitation...'),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invite Advisor')),
        body: ErrorStateWidget(
          title: 'Error', 
          message: _error!,
          onRetry: () {
            setState(() {
              _error = null;
            });
          },
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Advisor'),
        actions: [
          TextButton(
            onPressed: _sendInvitation,
            child: const Text('Send Invitation'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildAdvisorDetailsSection(),
              const SizedBox(height: 24),
              _buildRelationshipSection(),
              const SizedBox(height: 24),
              _buildPersonalMessageSection(),
              const SizedBox(height: 32),
              _buildSendButton(),
              const SizedBox(height: 16),
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_add,
                  size: 28,
                  color: AppTheme.accentTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invite an Advisor',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get external perspective on your career strengths and potential',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Choose someone who knows your work well and can provide honest, constructive feedback about your professional capabilities.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdvisorDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advisor Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter advisor\'s full name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the advisor\'s name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'advisor@example.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the advisor\'s email address';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                hintText: '+61 4XX XXX XXX',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  // Basic Australian phone number validation
                  final phoneRegex = RegExp(r'^(\+61|0)[2-9]\d{8}$|^(\+61|0)4\d{8}$');
                  final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (!phoneRegex.hasMatch(cleanNumber)) {
                    return 'Please enter a valid Australian phone number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRelationshipSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relationship Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'How do you know this person?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...AdvisorRelationship.values.map((relationship) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<AdvisorRelationship>(
                value: relationship,
                groupValue: _selectedRelationship,
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                },
                title: Text(
                  relationship.displayName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  relationship.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalMessageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Personal Message',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Switch(
                  value: _includePersonalMessage,
                  onChanged: (value) {
                    setState(() {
                      _includePersonalMessage = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Add a personal touch to your invitation',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_includePersonalMessage) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _personalMessageController,
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  hintText: 'Add a personal note to your invitation...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: _includePersonalMessage ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a personal message or turn off this option';
                  }
                  if (value.trim().length < 20) {
                    return 'Please write a more detailed message (at least 20 characters)';
                  }
                  return null;
                } : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Explain why their perspective matters to you and what you hope to learn',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'A standard professional invitation will be sent',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _sendInvitation,
        icon: const Icon(Icons.send),
        label: const Text('Send Invitation'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
  
  Widget _buildHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: AppTheme.accentTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'What happens next?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              '1.',
              'Your advisor will receive an email invitation with a secure link',
            ),
            _buildHelpItem(
              '2.',
              'They\'ll answer 5 thoughtful questions about your professional strengths',
            ),
            _buildHelpItem(
              '3.',
              'Their responses will be compiled into insights for your career exploration',
            ),
            _buildHelpItem(
              '4.',
              'You can track invitation status and view responses in your advisor dashboard',
            ),
            const SizedBox(height: 8),
            Text(
              'The process takes about 10-15 minutes for your advisor to complete.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHelpItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}