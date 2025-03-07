import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/recommendation_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinancialDataProvider>(context);
    final recommendations = provider.recommendations;
    final insights = provider.insights;
    final forecast = provider.forecast;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Financial Insights',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'AI-powered recommendations based on your financial data',
            style: AppTheme.captionStyle,
          ),
          const SizedBox(height: 24),
          
          // Monthly summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MONTHLY SUMMARY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Income vs Expenses
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Income',
                        insights['total_income'] ?? 0.0,
                        Icons.arrow_upward,
                        AppTheme.successColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Expenses',
                        insights['total_spend'] ?? 0.0,
                        Icons.arrow_downward,
                        AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Net cashflow
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Net Cashflow',
                        insights['net_cashflow'] ?? 0.0,
                        Icons.account_balance_wallet,
                        (insights['net_cashflow'] ?? 0.0) >= 0
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Top Expense',
                        insights['spending_by_category'] != null && 
                        insights['top_spending_category'] != null
                            ? insights['spending_by_category'][insights['top_spending_category']] ?? 0.0
                            : 0.0,
                        Icons.trending_up,
                        AppTheme.warningColor,
                        subtitle: insights['top_spending_category'] ?? 'None',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Forecast section
          const Text(
            'Monthly Forecast',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROJECTED SPENDING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Total forecast
                if (forecast.containsKey('Total'))
                  _buildForecastItem(
                    'Total Projected Spending',
                    forecast['Total']!,
                    Icons.show_chart,
                    AppTheme.primaryColor,
                  ),
                const SizedBox(height: 16),
                
                // Category forecasts
                ...forecast.entries
                    .where((entry) => entry.key != 'Total')
                    .take(3)
                    .map((entry) => _buildForecastItem(
                          entry.key,
                          entry.value,
                          AppTheme.getCategoryIcon(entry.key),
                          AppTheme.secondaryTextColor,
                        )),
                
                // Show more button if there are more categories
                if (forecast.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Show all forecast categories
                          _showAllForecastCategories(context, forecast);
                        },
                        child: const Text('Show All Categories'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Recommendations section
          const Text(
            'AI Recommendations',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          
          // Recommendations list
          if (recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: AppTheme.secondaryTextColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No recommendations yet',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add more transactions to get personalized recommendations',
                      style: AppTheme.captionStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...recommendations.map((recommendation) => RecommendationCard(
                  recommendation: recommendation,
                )),
        ],
      ),
    );
  }
  
  // Build a summary item widget
  Widget _buildSummaryItem(
    String title,
    double amount,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          Formatters.formatCurrency(amount),
          style: AppTheme.subheadingStyle.copyWith(
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.captionStyle,
          ),
        ],
      ],
    );
  }
  
  // Build a forecast item widget
  Widget _buildForecastItem(
    String category,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category,
              style: AppTheme.bodyStyle,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: AppTheme.subheadingStyle,
          ),
        ],
      ),
    );
  }
  
  // Show dialog with all forecast categories
  void _showAllForecastCategories(BuildContext context, Map<String, double> forecast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Forecast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total forecast
              if (forecast.containsKey('Total'))
                _buildForecastItem(
                  'Total Projected Spending',
                  forecast['Total']!,
                  Icons.show_chart,
                  AppTheme.primaryColor,
                ),
              const Divider(),
              
              // Category forecasts
              ...forecast.entries
                  .where((entry) => entry.key != 'Total')
                  .map((entry) => _buildForecastItem(
                        entry.key,
                        entry.value,
                        AppTheme.getCategoryIcon(entry.key),
                        AppTheme.secondaryTextColor,
                      )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 