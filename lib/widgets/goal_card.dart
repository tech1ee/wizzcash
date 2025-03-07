import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/financial_goal.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final Function()? onTap;
  
  const GoalCard({
    Key? key,
    required this.goal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate percentage completion (capped at 100%)
    double percentComplete = goal.progressPercentage / 100;
    if (percentComplete > 1.0) percentComplete = 1.0;
    
    // Determine color based on priority
    Color priorityColor;
    switch (goal.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppTheme.primaryColor;
        break;
      case 'medium':
        priorityColor = AppTheme.warningColor;
        break;
      case 'low':
        priorityColor = AppTheme.secondaryTextColor;
        break;
      default:
        priorityColor = AppTheme.primaryColor;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal title and icon
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppTheme.getCategoryIcon(goal.category),
                      color: priorityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: AppTheme.subheadingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Formatters.formatPriority(goal.priority),
                      style: AppTheme.captionStyle.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              LinearPercentIndicator(
                lineHeight: 10,
                percent: percentComplete,
                backgroundColor: AppTheme.borderColor,
                progressColor: priorityColor,
                barRadius: const Radius.circular(5),
                padding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 12),
              
              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${Formatters.formatCurrency(goal.currentAmount)} of ${Formatters.formatCurrency(goal.targetAmount)}',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(1)}%',
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: priorityColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Target date
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Target date: ${Formatters.formatMediumDate(goal.targetDate)}',
                    style: AppTheme.captionStyle,
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatTimeRemaining(goal.targetDate),
                    style: AppTheme.captionStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 