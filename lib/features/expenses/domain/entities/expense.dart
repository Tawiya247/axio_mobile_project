import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, description, category, date];

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toUtc().toIso8601String(),
    };
  }
}
