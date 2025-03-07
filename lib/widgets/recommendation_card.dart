import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final Function()? onTap;
  
  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors based on priority
    Color getPriorityColor() {
      switch (recommendation.priority.toLowerCase()) {
        case 'high':
          return AppTheme.errorColor;
        case 'medium':
          return AppTheme.warningColor;
        case 'low':
          return AppTheme.successColor;
        default:
          return AppTheme.primaryColor;
      }
    }
    
    // Get category icon
    IconData getCategoryIcon() {
      switch (recommendation.category.toLowerCase()) {
        case 'expense reduction':
          return Icons.trending_down;
        case 'saving strategy':
          return Icons.savings;
        case 'debt management':
          return Icons.money_off;
        case 'retirement planning':
          return Icons.beach_access;
        case 'budgeting':
          return Icons.account_balance_wallet;
        case 'financial security':
          return Icons.security;
        case 'income planning':
          return Icons.trending_up;
        default:
          return Icons.lightbulb_outline;
      }
    }
    
    Color priorityColor = getPriorityColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppTheme.cardDecoration.copyWith(
          border: Border.all(
            color: priorityColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with priority indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    getCategoryIcon(),
                    color: priorityColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.category,
                      style: AppTheme.bodyStyle.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatPriority(recommendation.priority),
                          style: AppTheme.captionStyle.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recommendation.description,
                    style: AppTheme.bodyStyle,
                  ),
                  
                  // Only show potential savings if greater than 0
                  if (recommendation.potentialSavings > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Potential savings: ${Formatters.formatCurrency(recommendation.potentialSavings)}',
                            style: AppTheme.bodyStyle.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 