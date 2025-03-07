class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type; // credit or debit
  final String category;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T').first,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
    };
  }
} 