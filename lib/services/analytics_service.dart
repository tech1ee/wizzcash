import 'dart:math';
import '../models/transaction.dart' as app_models;
import '../models/recommendation.dart';
import '../models/user_profile.dart';

class AnalyticsService {
  // Generate spending insights based on transaction history
  Map<String, dynamic> generateSpendingInsights(List<app_models.Transaction> transactions) {
    Map<String, dynamic> insights = {};
    
    if (transactions.isEmpty) {
      return {
        'total_spend': 0.0,
        'total_income': 0.0,
        'net_cashflow': 0.0,
        'spending_by_category': {},
        'income_by_category': {},
        'top_spending_category': null,
        'month_to_month_change': 0.0,
      };
    }
    
    // Calculate total spend and income
    double totalSpend = 0;
    double totalIncome = 0;
    
    // Spending by category
    Map<String, double> spendingByCategory = {};
    Map<String, double> incomeByCategory = {};
    
    // Process all transactions
    for (var transaction in transactions) {
      if (transaction.type == 'debit') {
        totalSpend += transaction.amount;
        
        // Add to category spending
        if (spendingByCategory.containsKey(transaction.category)) {
          spendingByCategory[transaction.category] = 
              spendingByCategory[transaction.category]! + transaction.amount;
        } else {
          spendingByCategory[transaction.category] = transaction.amount;
        }
      } else {
        totalIncome += transaction.amount;
        
        // Add to category income
        if (incomeByCategory.containsKey(transaction.category)) {
          incomeByCategory[transaction.category] = 
              incomeByCategory[transaction.category]! + transaction.amount;
        } else {
          incomeByCategory[transaction.category] = transaction.amount;
        }
      }
    }
    
    // Find top spending category
    String? topSpendingCategory;
    double maxSpending = 0;
    
    spendingByCategory.forEach((category, amount) {
      if (amount > maxSpending) {
        maxSpending = amount;
        topSpendingCategory = category;
      }
    });
    
    // Calculate month-to-month change (mocked value for now)
    double monthToMonthChange = (Random().nextDouble() * 20) - 10; // -10% to +10%
    
    // Populate insights
    insights['total_spend'] = totalSpend;
    insights['total_income'] = totalIncome;
    insights['net_cashflow'] = totalIncome - totalSpend;
    insights['spending_by_category'] = spendingByCategory;
    insights['income_by_category'] = incomeByCategory;
    insights['top_spending_category'] = topSpendingCategory;
    insights['month_to_month_change'] = monthToMonthChange;
    
    return insights;
  }
  
  // Generate personalized recommendations based on transaction history and user profile
  List<Recommendation> generateRecommendations(
      List<app_models.Transaction> transactions, UserProfile userProfile) {
    List<Recommendation> recommendations = [];
    
    if (transactions.isEmpty) {
      return recommendations;
    }
    
    Map<String, dynamic> insights = generateSpendingInsights(transactions);
    Map<String, double> spendingByCategory = insights['spending_by_category'];
    
    // Check budget limits and create recommendations
    spendingByCategory.forEach((category, amount) {
      if (userProfile.budgetLimits.containsKey(category)) {
        double budgetLimit = userProfile.budgetLimits[category]!;
        
        // If spending exceeds 90% of the budget, create a recommendation
        if (amount > budgetLimit * 0.9) {
          double overBudgetPercent = ((amount / budgetLimit) - 1) * 100;
          String priority = overBudgetPercent > 20 ? 'high' : 'medium';
          
          recommendations.add(
            Recommendation(
              id: 'rec_budget_${category.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Reduce $category Spending',
              description: 'You\'ve spent ${overBudgetPercent.toStringAsFixed(1)}% more than your budget for $category. Consider finding ways to reduce these expenses next month.',
              category: 'Budgeting',
              potentialSavings: amount - budgetLimit > 0 ? amount - budgetLimit : 0,
              priority: priority,
            )
          );
        }
      }
    });
    
    // If income is less than spending, suggest expense reduction
    if (insights['total_income'] < insights['total_spend']) {
      recommendations.add(
        Recommendation(
          id: 'rec_income_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Income Below Expenses',
          description: 'Your spending exceeds your income by \$${(insights['total_spend'] - insights['total_income']).toStringAsFixed(2)}. Review your expenses to find areas to cut back or look for ways to increase your income.',
          category: 'Income Planning',
          potentialSavings: insights['total_spend'] - insights['total_income'],
          priority: 'high',
        )
      );
    }
    
    // Add a savings recommendation if net cashflow is positive
    if (insights['net_cashflow'] > 0) {
      double savingsAmount = insights['net_cashflow'] * 0.5; // Suggest saving 50% of positive cashflow
      
      recommendations.add(
        Recommendation(
          id: 'rec_savings_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Increase Your Savings',
          description: 'You have a positive cashflow of \$${insights['net_cashflow'].toStringAsFixed(2)}. Consider setting aside \$${savingsAmount.toStringAsFixed(2)} into savings or investments.',
          category: 'Saving Strategy',
          potentialSavings: 0, // Not applicable for this recommendation
          priority: 'medium',
        )
      );
    }
    
    // Add additional mock recommendations to ensure we have a diverse set
    _addMockRecommendations(recommendations, insights);
    
    return recommendations;
  }
  
  // Add some additional mock recommendations
  void _addMockRecommendations(List<Recommendation> recommendations, Map<String, dynamic> insights) {
    final random = Random();
    
    // Only add if we have fewer than 5 recommendations so far
    if (recommendations.length < 5) {
      // Potential mock recommendations
      List<Map<String, dynamic>> mockRecs = [
        {
          'title': 'Review Subscription Services',
          'description': 'You have multiple subscription payments. Consider reviewing which ones you actively use and cancel any that are unnecessary.',
          'category': 'Expense Reduction',
          'potential_savings': 15.0 * (random.nextInt(5) + 1),
          'priority': 'low',
        },
        {
          'title': 'Shop for Better Insurance Rates',
          'description': 'Many people save by comparing insurance providers. Take some time to shop around for better rates on your policies.',
          'category': 'Expense Reduction',
          'potential_savings': 50.0 * (random.nextInt(5) + 1),
          'priority': 'medium',
        },
        {
          'title': 'Consider Refinancing Loans',
          'description': 'Current interest rates may allow you to refinance existing loans at better terms, potentially saving you money over time.',
          'category': 'Debt Management',
          'potential_savings': 100.0 * (random.nextInt(5) + 1),
          'priority': 'medium',
        },
        {
          'title': 'Build an Emergency Fund',
          'description': 'Aim to save 3-6 months of expenses as an emergency fund to protect against unexpected financial challenges.',
          'category': 'Financial Security',
          'potential_savings': 0.0,
          'priority': 'high',
        },
        {
          'title': 'Meal Planning to Reduce Food Expenses',
          'description': 'Planning meals in advance and cooking at home can significantly reduce your food expenses.',
          'category': 'Expense Reduction',
          'potential_savings': 50.0 * (random.nextInt(3) + 1),
          'priority': 'low',
        },
      ];
      
      // Shuffle the list
      mockRecs.shuffle();
      
      // Add recommendations until we reach 5 or run out of mock recommendations
      for (var mockRec in mockRecs) {
        if (recommendations.length >= 5) break;
        
        recommendations.add(
          Recommendation(
            id: 'rec_mock_${DateTime.now().millisecondsSinceEpoch}_${recommendations.length}',
            title: mockRec['title'],
            description: mockRec['description'],
            category: mockRec['category'],
            potentialSavings: mockRec['potential_savings'],
            priority: mockRec['priority'],
          )
        );
      }
    }
  }
  
  // Generate monthly spending forecast
  Map<String, double> generateMonthlyForecast(List<app_models.Transaction> transactions) {
    Map<String, double> forecast = {};
    
    // If no transactions, return empty forecast
    if (transactions.isEmpty) {
      return forecast;
    }
    
    // Get insights from existing transactions
    Map<String, dynamic> insights = generateSpendingInsights(transactions);
    
    // Calculate average daily spend
    double totalSpend = insights['total_spend'];
    
    // Get unique days in the transaction set
    Set<String> uniqueDays = {};
    
    for (var transaction in transactions) {
      if (transaction.type == 'debit') {
        String dateKey = '${transaction.date.year}-${transaction.date.month}-${transaction.date.day}';
        uniqueDays.add(dateKey);
      }
    }
    
    // Average daily spend (if we have days)
    double averageDailySpend = uniqueDays.isNotEmpty ? totalSpend / uniqueDays.length : 0;
    
    // Forecast categories based on past transactions
    Map<String, double> spendingByCategory = insights['spending_by_category'];
    
    // Project for next 30 days with some randomness
    final random = Random();
    
    // Project each category
    spendingByCategory.forEach((category, amount) {
      // Calculate daily average for this category
      double dailyCategoryAverage = uniqueDays.isNotEmpty ? amount / uniqueDays.length : 0;
      
      // Add some randomness to the projection (±20%)
      double randomFactor = 0.8 + (random.nextDouble() * 0.4); // 0.8 to 1.2
      
      // Project for 30 days
      forecast[category] = dailyCategoryAverage * 30 * randomFactor;
    });
    
    // Add a total projection
    forecast['Total'] = averageDailySpend * 30 * (0.9 + (random.nextDouble() * 0.2)); // 0.9 to 1.1
    
    return forecast;
  }
} 