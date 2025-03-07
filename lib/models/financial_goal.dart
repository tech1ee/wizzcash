class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String priority; // high, medium, low
  final String category;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.priority,
    required this.category,
  });

  double get progressPercentage => (currentAmount / targetAmount) * 100;

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      title: json['title'],
      targetAmount: json['target_amount'].toDouble(),
      currentAmount: json['current_amount'].toDouble(),
      targetDate: DateTime.parse(json['target_date']),
      priority: json['priority'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String().split('T').first,
      'priority': priority,
      'category': category,
    };
  }
} 