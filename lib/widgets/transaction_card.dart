import 'package:flutter/material.dart';
import '../models/transaction.dart' as app_models;
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  final app_models.Transaction transaction;
  final Function()? onTap;
  
  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getTransactionColor(transaction.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppTheme.getCategoryIcon(transaction.category),
                  color: AppTheme.getTransactionColor(transaction.type),
                ),
              ),
              const SizedBox(width: 16),
              
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: AppTheme.subheadingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text(
                          Formatters.formatMediumDate(transaction.date),
                          style: AppTheme.captionStyle,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.borderColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.category,
                            style: AppTheme.captionStyle.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Amount - using a fixed width to ensure alignment
              SizedBox(
                width: 100,
                child: Text(
                  Formatters.formatTransactionAmount(
                    transaction.amount,
                    transaction.type,
                  ),
                  style: AppTheme.amountStyle.copyWith(
                    color: AppTheme.getTransactionColor(transaction.type),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 