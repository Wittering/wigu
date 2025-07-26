import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Card displaying overview of a career domain with status and actions
/// Shows completion status, provides entry point to domain exploration
class DomainOverviewCard extends StatefulWidget {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback? onReset;

  const DomainOverviewCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLoading,
    required this.onTap,
    this.onReset,
  });

  @override
  State<DomainOverviewCard> createState() => _DomainOverviewCardState();
}

class _DomainOverviewCardState extends State<DomainOverviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered && !widget.isLoading) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.isLoading ? null : widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Base shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    // Glow effect when hovered or current
                    if (_isHovered || widget.isCurrent)
                      BoxShadow(
                        color: widget.color.withOpacity(_glowAnimation.value),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2A2A2A).withOpacity(0.8),
                        ],
                      ),
                      border: Border.all(
                        color: widget.isCurrent 
                            ? widget.color
                            : widget.isCompleted
                                ? CareerTheme.statusSuccess.withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                        width: widget.isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon and status
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: widget.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.color.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildStatusIndicator(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Title
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Description
                              Expanded(
                                child: Text(
                                  widget.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Action button
                              _buildActionButton(),
                            ],
                          ),
                        ),
                        
                        // Loading overlay
                        if (widget.isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.color,
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CareerTheme.statusSuccess.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CareerTheme.statusSuccess.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: CareerTheme.statusSuccess,
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              'Complete',
              style: TextStyle(
                color: CareerTheme.statusSuccess,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Current',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: const Text(
        'Pending',
        style: TextStyle(
          color: CareerTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: CareerTheme.statusSuccess,
                side: const BorderSide(color: CareerTheme.statusSuccess),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text(
                'Review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (widget.onReset != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onReset,
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red.withOpacity(0.8),
                padding: const EdgeInsets.all(8),
              ),
              icon: const Icon(Icons.restart_alt, size: 16),
              tooltip: 'Reset this domain',
            ),
          ],
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        icon: Icon(
          widget.isCurrent ? Icons.play_arrow : Icons.start,
          size: 18,
        ),
        label: Text(
          widget.isCurrent ? 'Continue' : 'Start Exploring',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}