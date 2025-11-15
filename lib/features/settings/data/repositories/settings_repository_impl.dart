import 'package:shared_preferences/shared_preferences.dart';
import 'package:axio_mobile_project/features/settings/domain/entities/user_settings.dart';
import 'package:axio_mobile_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _monthlyBudgetKey = 'monthly_budget';
  static const _categoryBudgetsKey = 'category_budgets';

  @override
  Future<Either<Exception, UserSettings>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger le budget mensuel
      final monthlyBudget = prefs.getDouble(_monthlyBudgetKey) ?? 2000.0;

      // Charger les budgets par catégorie
      final categoryBudgets = <String, double>{};
      final categoriesJson = prefs.getString(_categoryBudgetsKey);

      if (categoriesJson != null) {
        final Map<String, dynamic> categoriesMap = Map<String, dynamic>.from(
          categoriesJson as Map,
        );
        categoriesMap.forEach((key, value) {
          categoryBudgets[key] = value.toDouble();
        });
      } else {
        // Valeurs par défaut
        categoryBudgets.addAll({
          'food': 500.0,
          'transport': 300.0,
          'shopping': 400.0,
          'bills': 800.0,
          'other': 200.0,
        });
      }

      return Right(
        UserSettings(
          monthlyBudget: monthlyBudget,
          categoryBudgets: categoryBudgets,
        ),
      );
    } catch (e) {
      return Left(Exception('Erreur lors du chargement des paramètres'));
    }
  }

  @override
  Future<Either<Exception, void>> saveSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder le budget mensuel
      await prefs.setDouble(_monthlyBudgetKey, settings.monthlyBudget);

      // Sauvegarder les budgets par catégorie
      final categoriesMap = <String, dynamic>{};
      settings.categoryBudgets.forEach((key, value) {
        categoriesMap[key] = value;
      });

      await prefs.setString(_categoryBudgetsKey, categoriesMap.toString());

      return const Right(null);
    } catch (e) {
      return Left(Exception('Erreur lors de la sauvegarde des paramètres'));
    }
  }
}
