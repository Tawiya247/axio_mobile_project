import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axio_mobile_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:axio_mobile_project/features/expenses/domain/entities/expense.dart';
import 'package:axio_mobile_project/features/expenses/domain/repositories/expense_repository.dart';
import 'package:axio_mobile_project/features/settings/domain/entities/user_settings.dart';
import 'package:axio_mobile_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:axio_mobile_project/features/settings/presentation/screens/settings_screen.dart';
import 'package:axio_mobile_project/injection.dart';
import 'package:axio_mobile_project/features/expenses/domain/entities/scanned_ticket.dart';
import 'package:axio_mobile_project/features/expenses/presentation/widgets/ticket_scanner/ticket_scanner_screen.dart';
import 'package:axio_mobile_project/features/home/presentation/widgets/category_chart.dart';
import 'package:axio_mobile_project/features/home/presentation/widgets/budget_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _currentIndex = 0; // Index de l'onglet actif

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  late final ExpenseRepository _expenseRepository;
  late final AuthRepository _authRepository;
  late final SettingsRepository _settingsRepository;
  List<Expense> _expenses = [];
  UserSettings _settings = const UserSettings(
    monthlyBudget: 2000.0,
    categoryBudgets: {
      'food': 500.0,
      'transport': 300.0,
      'shopping': 400.0,
      'bills': 800.0,
      'other': 200.0,
    },
  );

  @override
  @override
  void initState() {
    super.initState();
    _expenseRepository = getIt<ExpenseRepository>();
    _authRepository = getIt<AuthRepository>();
    _settingsRepository = getIt<SettingsRepository>();
    _loadSettings();
    _loadExpenses();
  }

  Future<void> _loadSettings() async {
    final result = await _settingsRepository.loadSettings();
    result.fold(
      (failure) => _showError('Erreur lors du chargement des paramètres'),
      (settings) {
        if (mounted) {
          setState(() => _settings = settings);
        }
      },
    );
  }

  Future<void> _loadExpenses() async {
    try {
      final result = await _expenseRepository.getExpenses();
      result.fold(
        (failure) => _showError('Erreur lors du chargement des dépenses'),
        (expenses) => setState(() => _expenses = expenses),
      );
    } catch (e) {
      _showError('Une erreur est survenue');
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await _authRepository.signOut();
      result.fold(
        (failure) => _showError('Erreur lors de la déconnexion'),
        (_) => context.go('/login'),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _scanTicket() async {
    await Navigator.push<ScannedTicket>(
      context,
      MaterialPageRoute(
        builder: (context) => TicketScannerScreen(
          onTicketScanned: (ticket) {
            // Remplir automatiquement les champs avec les données scannées
            if (ticket.totalAmount != null) {
              _amountController.text = ticket.totalAmount!.toStringAsFixed(2);
            }
            if (ticket.merchantName != null) {
              _descriptionController.text = ticket.merchantName!;
            }
            if (ticket.date != null) {
              setState(() => _selectedDate = ticket.date!);
            }
          },
        ),
      ),
    );
  }

  void _addExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          category: _selectedCategory ?? 'other',
          date: _selectedDate,
        );

        final result = await _expenseRepository.addExpense(expense);

        await result.fold(
          (failure) => throw Exception(
            'Échec de l\'ajout de la dépense: ${failure.toString()}',
          ),
          (_) async {
            // Recharger les dépenses après l'ajout
            await _loadExpenses();
          },
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dépense ajoutée avec succès'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Réinitialisation du formulaire
          _amountController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedCategory = null;
            _selectedDate = DateTime.now();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Map<String, double> _calculateCategoryAmounts() {
    final Map<String, double> categoryAmounts = {};

    for (final expense in _expenses) {
      final category = expense.category.toLowerCase();
      categoryAmounts.update(
        category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryAmounts;
  }

  List<Widget> _buildRecentExpenses() {
    if (_expenses.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Aucune dépense récente'),
        ),
      ];
    }

    final sortedExpenses = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final recentExpenses = sortedExpenses.take(5).toList();

    return [
      ...recentExpenses.map(
        (expense) => ListTile(
          leading: _getCategoryIcon(expense.category),
          title: Text(expense.description),
          subtitle: Text(
            '${expense.date.day}/${expense.date.month}/${expense.date.year}',
          ),
          trailing: Text(
            '${expense.amount.toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    ];
  }

  Widget _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Icon(Icons.restaurant);
      case 'transport':
        return const Icon(Icons.directions_car);
      case 'shopping':
        return const Icon(Icons.shopping_cart);
      case 'bills':
        return const Icon(Icons.receipt);
      default:
        return const Icon(Icons.money);
    }
  }

  List<Widget> _buildCategoryBudgets() {
    final now = DateTime.now();
    final categorySpending = <String, double>{};

    // Calculer les dépenses par catégorie pour le mois en cours
    for (final expense in _expenses.where(
      (e) => e.date.month == now.month && e.date.year == now.year,
    )) {
      categorySpending.update(
        expense.category.toLowerCase(),
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return _settings.categoryBudgets.entries.map((entry) {
      final category = entry.key;
      final budget = entry.value;
      final spent = categorySpending[category] ?? 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: BudgetProgressBar(
          currentAmount: spent,
          maxAmount: budget,
          label: _getCategoryName(category),
        ),
      );
    }).toList();
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'food':
        return 'Nourriture';
      case 'transport':
        return 'Transport';
      case 'shopping':
        return 'Shopping';
      case 'bills':
        return 'Factures';
      default:
        return 'Autre';
    }
  }

  double get _currentMonthSpent {
    final now = DateTime.now();
    final spent = _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (total, expense) => total + expense.amount);

    return spent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              if (result == true) {
                // Recharger les paramètres si des modifications ont été apportées
                await _loadSettings();
                // Recharger les dépenses pour mettre à jour les graphiques
                await _loadExpenses();
              }
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tableau de Bord',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (_expenses.isNotEmpty) ...[
              // Graphique des catégories
              CategoryChart(categoryAmounts: _calculateCategoryAmounts()),
              // Barre de progression du budget mensuel
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: BudgetProgressBar(
                  currentAmount: _currentMonthSpent,
                  maxAmount: _settings.monthlyBudget,
                  label: 'Budget du mois',
                ),
              ),
              // Budgets par catégorie
              ..._buildCategoryBudgets(),
              // Dernières dépenses
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dépenses récentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildRecentExpenses(),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Ajoutez votre première dépense pour commencer',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Nouvelle dépense',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Montant',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sélection de catégorie
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'food',
                            child: Text('Nourriture'),
                          ),
                          DropdownMenuItem(
                            value: 'transport',
                            child: Text('Transport'),
                          ),
                          DropdownMenuItem(
                            value: 'shopping',
                            child: Text('Shopping'),
                          ),
                          DropdownMenuItem(
                            value: 'bills',
                            child: Text('Factures'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Autre'),
                          ),
                        ],
                        initialValue: _selectedCategory,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Bouton de scan de ticket
                      FilledButton.icon(
                        onPressed: _scanTicket,
                        icon: const Icon(Icons.receipt),
                        label: const Text('Scanner un ticket'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sélection de date
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _addExpense,
                        child: const Text('Enregistrer'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une dépense'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);

          // Gestion de la navigation en fonction de l'onglet sélectionné
          switch (index) {
            case 0: // Accueil
              // Déjà sur la page d'accueil
              break;
            case 1: // Statistiques
              GoRouter.of(context).pushNamed('statistics');
              // Réinitialiser l'index à 0 après la navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _currentIndex = 0);
                }
              });
              break;
            case 2: // Portefeuilles
              GoRouter.of(context).pushNamed('wallets');
              // Réinitialiser l'index à 0 après la navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _currentIndex = 0);
                }
              });
              break;
            case 3: // Paramètres
              GoRouter.of(context).pushNamed('settings');
              // Réinitialiser l'index à 0 après la navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _currentIndex = 0);
                }
              });
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistiques',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Portefeuilles',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
