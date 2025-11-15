import 'package:flutter/material.dart';
import 'package:axio_mobile_project/features/settings/domain/entities/user_settings.dart';
import 'package:axio_mobile_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsRepository _settingsRepository;
  late UserSettings _settings;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settingsRepository = GetIt.I<SettingsRepository>();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final result = await _settingsRepository.loadSettings();
    result.fold(
      (failure) => _showError('Erreur lors du chargement des paramètres'),
      (settings) => setState(() => _settings = settings),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = await _settingsRepository.saveSettings(_settings);
    result.fold(
      (failure) => _showError('Erreur lors de la sauvegarde'),
      (_) => _showSuccess('Paramètres enregistrés avec succès'),
    );

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du budget'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Enregistrer'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Mensuel Global',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _settings.monthlyBudget.toStringAsFixed(2),
                      decoration: const InputDecoration(
                        labelText: 'Montant (€)',
                        border: OutlineInputBorder(),
                        prefixText: '€ ',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final amount = double.tryParse(value) ?? 0;
                        setState(() {
                          _settings = _settings.copyWith(
                            monthlyBudget: amount > 0 ? amount : 0,
                          );
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Budgets par Catégorie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildCategoryBudgetFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryBudgetFields() {
    final categories = _settings.categoryBudgets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return categories.map((entry) {
      final category = entry.key;
      final budget = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryDisplayName(category),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: budget.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Budget (€)',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final amount = double.tryParse(value) ?? 0;
                  setState(() {
                    final newBudgets = Map<String, double>.from(
                      _settings.categoryBudgets,
                    );
                    newBudgets[category] = amount > 0 ? amount : 0;
                    _settings = _settings.copyWith(categoryBudgets: newBudgets);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'food':
        return '🍽️ Nourriture';
      case 'transport':
        return '🚗 Transport';
      case 'shopping':
        return '🛍️ Shopping';
      case 'bills':
        return '📋 Factures';
      case 'other':
        return '📌 Autres';
      default:
        return category;
    }
  }
}
