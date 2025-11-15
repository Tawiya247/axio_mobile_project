import 'package:axio_mobile_project/features/expenses/domain/entities/expense.dart';
import 'package:dartz/dartz.dart';

abstract class ExpenseRepository {
  Future<Either<Exception, void>> addExpense(Expense expense);
  Future<Either<Exception, List<Expense>>> getExpenses();
  // Ajoutez d'autres méthodes selon vos besoins (updateExpense, deleteExpense, etc.)
}
