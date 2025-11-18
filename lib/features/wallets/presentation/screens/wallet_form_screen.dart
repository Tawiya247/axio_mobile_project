import 'package:flutter/material.dart';
import 'package:axio_mobile_project/core/theme/app_colors.dart';
import 'package:axio_mobile_project/features/wallets/domain/entities/wallet.dart';
import 'package:axio_mobile_project/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:axio_mobile_project/injection.dart';

class WalletFormScreen extends StatefulWidget {
  final Wallet? wallet;

  const WalletFormScreen({super.key, this.wallet});

  @override
  @override
  WalletFormScreenState createState() => WalletFormScreenState();
}

class WalletFormScreenState extends State<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final WalletRepository _walletRepository = getIt<WalletRepository>();
  late final bool _isEditMode;
  String _selectedCurrency = 'EUR';
  final List<String> _availableCurrencies = ['EUR', 'USD', 'GBP', 'JPY', 'CHF'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.wallet != null) {
      _nameController.text = widget.wallet!.name;
      _descriptionController.text = widget.wallet?.description ?? '';
      _initialBalanceController.text = widget.wallet!.balance.toStringAsFixed(
        2,
      );
      _selectedCurrency = widget.wallet!.currency;
    } else {
      _initialBalanceController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final wallet = Wallet(
        id:
            widget.wallet?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        balance: double.parse(_initialBalanceController.text),
        currency: _selectedCurrency,
      );

      await _saveWallet(wallet);

      if (mounted) {
        Navigator.of(context).pop(wallet);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveWallet(Wallet wallet) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newWallet = wallet.copyWith(updatedAt: DateTime.now());

      final result = await (wallet.id.isEmpty
          ? _walletRepository.createWallet(newWallet)
          : _walletRepository.updateWallet(newWallet));

      if (!mounted) return;

      await result.fold(
        (failure) async {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) async {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portefeuille enregistré avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Modifier le portefeuille' : 'Nouveau portefeuille',
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: _buildForm(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ Nom
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du portefeuille',
                hintText: 'Ex: Compte Courant, Épargne...',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Champ Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Description du portefeuille',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Champs Solde initial et Devise
            Row(
              children: [
                // Champ Solde initial
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _initialBalanceController,
                    decoration: const InputDecoration(
                      labelText: 'Solde initial',
                      prefixIcon: Icon(Icons.euro_symbol),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Montant invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Sélecteur de devise
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: const InputDecoration(labelText: 'Devise'),
                    items: _availableCurrencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedCurrency = value);
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton d'enregistrement
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.primary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Mettre à jour' : 'Créer le portefeuille',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _isLoading ? null : _submitForm,
      backgroundColor: AppColors.primary,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.check),
    );
  }

  Future<void> _deleteWallet() async {
    if (widget.wallet?.id == null) return;

    try {
      final result = await _walletRepository.deleteWallet(widget.wallet!.id);

      if (!mounted) return;

      await result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Portefeuille supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop('deleted');
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue lors de la suppression'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (widget.wallet == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le portefeuille'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement ce portefeuille ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await _deleteWallet();
    }
  }
}
