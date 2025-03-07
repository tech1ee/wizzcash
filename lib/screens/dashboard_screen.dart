import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/spending_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinancialDataProvider>(context);
    final insights = provider.insights;
    final transactions = provider.transactions;
    final goals = provider.financialGoals;
    final recommendations = provider.recommendations;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Hello, ${provider.userProfile?.name ?? 'there'}!',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your financial overview',
            style: AppTheme.captionStyle,
          ),
          const SizedBox(height: 24),
          
          // Financial summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.darkCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL BALANCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatCurrency(
                    insights['total_income'] ?? 0.0 - (insights['total_spend'] ?? 0.0),
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 12,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${insights['month_to_month_change'] != null ? insights['month_to_month_change'].toStringAsFixed(1) : '0.0'}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'from last month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Income and expenses summary
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(insights['total_income'] ?? 0.0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expenses',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(insights['total_spend'] ?? 0.0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Spending breakdown
          const Text(
            'Spending Breakdown',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: SpendingChart(
              spendingByCategory: Map<String, double>.from(
                insights['spending_by_category'] ?? {},
              ),
              totalSpending: insights['total_spend'] ?? 0.0,
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: AppTheme.subheadingStyle,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to transactions tab
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Text('No transactions yet'),
              ),
            )
          else
            ...transactions.take(3).map((transaction) => TransactionCard(
              transaction: transaction,
              onTap: () {
                // Navigate to transaction details
              },
            )),
          const SizedBox(height: 24),
          
          // Financial goals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Goals',
                style: AppTheme.subheadingStyle,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to goals tab
                  DefaultTabController.of(context)?.animateTo(2);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Text('No goals yet'),
              ),
            )
          else
            ...goals.take(2).map((goal) => GoalCard(
              goal: goal,
              onTap: () {
                // Navigate to goal details
              },
            )),
          const SizedBox(height: 24),
          
          // AI Recommendations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Recommendations',
                style: AppTheme.subheadingStyle,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to insights tab
                  DefaultTabController.of(context)?.animateTo(3);
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: const Center(
                child: Text('No recommendations yet'),
              ),
            )
          else
            ...recommendations.take(2).map((recommendation) => RecommendationCard(
              recommendation: recommendation,
              onTap: () {
                // Navigate to recommendation details
              },
            )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 