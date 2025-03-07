class Recommendation {
  final String id;
  final String title;
  final String description;
  final String category;
  final double potentialSavings;
  final String priority; // high, medium, low

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.potentialSavings,
    required this.priority,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      potentialSavings: json['potential_savings'].toDouble(),
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'potential_savings': potentialSavings,
      'priority': priority,
    };
  }
} 