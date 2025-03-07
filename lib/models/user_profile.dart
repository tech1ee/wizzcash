class UserProfile {
  String id;
  String name;
  double monthlyIncome;
  Map<String, double> budgetLimits; // Category-based budget limits
  bool hasCompletedOnboarding;

  UserProfile({
    required this.id,
    required this.name,
    required this.monthlyIncome,
    required this.budgetLimits,
    this.hasCompletedOnboarding = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> budgetMap = json['budget_limits'];
    Map<String, double> typedBudgetMap = {};
    
    budgetMap.forEach((key, value) {
      typedBudgetMap[key] = value.toDouble();
    });

    return UserProfile(
      id: json['id'],
      name: json['name'],
      monthlyIncome: json['monthly_income'].toDouble(),
      budgetLimits: typedBudgetMap,
      hasCompletedOnboarding: json['has_completed_onboarding'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthly_income': monthlyIncome,
      'budget_limits': budgetLimits,
      'has_completed_onboarding': hasCompletedOnboarding,
    };
  }

  factory UserProfile.createDefault() {
    return UserProfile(
      id: 'user_default',
      name: 'New User',
      monthlyIncome: 0,
      budgetLimits: {
        'Food': 500.0,
        'Transportation': 200.0,
        'Entertainment': 150.0,
        'Housing': 1500.0,
        'Utilities': 300.0,
        'Shopping': 200.0,
        'Health': 200.0,
        'Insurance': 200.0,
      },
      hasCompletedOnboarding: false,
    );
  }
} 