import 'package:axio_mobile_project/core/error/exceptions.dart';
import 'package:axio_mobile_project/core/network/dio_client.dart';
import 'package:axio_mobile_project/features/expenses/domain/entities/expense.dart';
import 'package:axio_mobile_project/features/expenses/domain/repositories/expense_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DioClient _dioClient;

  ExpenseRepositoryImpl(this._dioClient);

  @override
  Future<Either<Exception, void>> addExpense(Expense expense) async {
    try {
      await _dioClient.dio.post(
        '/expenses',
        data: {
          'amount': expense.amount,
          'description': expense.description,
          'category': expense.category,
          'date': expense.date.toIso8601String(),
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerException(
          message: e.message ?? 'Erreur inconnue',
          statusCode: e.response?.statusCode ?? 500,
        ),
      );
    } catch (e) {
      return Left(ServerException(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Future<Either<Exception, List<Expense>>> getExpenses() async {
    try {
      final response = await _dioClient.dio.get('/expenses');
      final List<dynamic> data = response.data as List<dynamic>;

      final expenses = data
          .map((expense) => Expense.fromJson(expense))
          .toList();
      return Right(expenses);
    } on DioException catch (e) {
      return Left(
        ServerException(
          message: e.message ?? 'Erreur lors de la récupération des dépenses',
          statusCode: e.response?.statusCode ?? 500,
        ),
      );
    } catch (e) {
      return Left(
        ServerException(
          message: 'Erreur inattendue: ${e.toString()}',
          statusCode: 500,
        ),
      );
    }
  }
}
