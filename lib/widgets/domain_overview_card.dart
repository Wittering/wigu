import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/career_session.dart';
import '../utils/theme.dart';

/// Card widget showing overview of a career domain
/// Displays domain information, completion status, and progress
class DomainOverviewCard extends StatelessWidget {
  final CareerDomain domain;
  final bool isCompleted;
  final int responseCount;
  final VoidCallback? onTap;

  const DomainOverviewCard({
    super.key,
    required this.domain,
    this.isCompleted = false,
    this.responseCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final domainColour = AppTheme.getCareerDomainColour(domain.name);
    
    return SizedBox(
      width: 100, // Further reduced to 100px
      height: 100, // Add explicit height constraint
      child: Card(
        elevation: 1, // Reduced elevation for more subtle look
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8), // Slightly smaller radius
          child: Container(
            padding: const EdgeInsets.all(8.0), // Further reduced padding to 8
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // Match the InkWell radius
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  domainColour.withOpacity(0.1),
                  domainColour.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: isCompleted 
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : domainColour.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, domainColour),
                const SizedBox(height: 3), // Further reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(context),
                      const SizedBox(height: 1), // Further reduced spacing
                      Flexible(child: _buildDescription(context)),
                      const Spacer(),
                      _buildProgressIndicator(context, domainColour),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color domainColour) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Domain icon
        Container(
          width: 20, // Further reduced to 20
          height: 20, // Further reduced to 20
          decoration: BoxDecoration(
            color: domainColour.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4), // Smaller radius
          ),
          child: Icon(
            _getDomainIcon(domain),
            size: 12, // Further reduced to 12
            color: domainColour,
          ),
        )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms)
            .then()
            .shimmer(
              duration: 2000.ms,
              colors: [
                domainColour.withOpacity(0.2),
                domainColour.withOpacity(0.05),
              ],
            ),
        
        // Completion status
        if (isCompleted)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), duration: 300.ms)
              .then()
              .shimmer(
                duration: 1500.ms,
                colors: [
                  AppTheme.successGreen,
                  AppTheme.successGreen.withOpacity(0.7),
                ],
              ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      domain.displayName,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppTheme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 10, // Further reduced for very compact cards
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      domain.description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.mutedText,
        fontSize: 8, // Further reduced for very compact cards
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressIndicator(BuildContext context, Color domainColour) {
    return Row(
      children: [
        Icon(
          Icons.edit_outlined,
          size: 12,
          color: AppTheme.mutedText,
        ),
        const SizedBox(width: 3), // Reduced spacing
        Text(
          '$responseCount',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 1), // Reduced spacing
        Text(
          responseCount == 1 ? 'response' : 'responses',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  IconData _getDomainIcon(CareerDomain domain) {
    switch (domain) {
      case CareerDomain.technical:
        return Icons.code_outlined;
      case CareerDomain.leadership:
        return Icons.groups_outlined;
      case CareerDomain.creative:
        return Icons.palette_outlined;
      case CareerDomain.analytical:
        return Icons.analytics_outlined;
      case CareerDomain.social:
        return Icons.people_outline;
      case CareerDomain.entrepreneurial:
        return Icons.rocket_launch_outlined;
      case CareerDomain.traditional:
        return Icons.business_outlined;
      case CareerDomain.investigative:
        return Icons.search_outlined;
    }
  }
}