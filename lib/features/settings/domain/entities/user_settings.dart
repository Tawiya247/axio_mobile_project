import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final double monthlyBudget;
  final Map<String, double> categoryBudgets;

  const UserSettings({
    required this.monthlyBudget,
    required this.categoryBudgets,
  });

  UserSettings copyWith({
    double? monthlyBudget,
    Map<String, double>? categoryBudgets,
  }) {
    return UserSettings(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  @override
  List<Object?> get props => [monthlyBudget, categoryBudgets];
}
