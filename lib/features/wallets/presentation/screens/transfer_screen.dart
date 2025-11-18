import 'package:flutter/material.dart';
import 'package:axio_mobile_project/core/theme/app_colors.dart';
import 'package:axio_mobile_project/core/error/failures.dart';
import 'package:axio_mobile_project/features/wallets/domain/entities/wallet.dart';
import 'package:axio_mobile_project/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:axio_mobile_project/injection.dart';

class TransferScreen extends StatefulWidget {
  final Wallet? sourceWallet;

  const TransferScreen({super.key, this.sourceWallet});

  @override
  @override
  TransferScreenState createState() => TransferScreenState();
}

class TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _walletRepository = getIt<WalletRepository>();

  Wallet? _sourceWallet;
  Wallet? _targetWallet;
  List<Wallet> _wallets = [];
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _sourceWallet = widget.sourceWallet;
    _loadWallets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _walletRepository.getWallets();
      result.fold(
        (failure) => setState(() {
          _error = 'Erreur lors du chargement des portefeuilles';
          _isLoading = false;
        }),
        (wallets) => setState(() {
          _wallets = wallets;
          if (_sourceWallet == null && _wallets.isNotEmpty) {
            _sourceWallet = _wallets.first;
          }
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = 'Une erreur inattendue est survenue';
        _isLoading = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceWallet == null || _targetWallet == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le transfert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous vraiment effectuer ce transfert ?'),
            const SizedBox(height: 16),
            Text(
              'De: ${_sourceWallet!.name} (${_sourceWallet!.balance} ${_sourceWallet!.currency})',
            ),
            Text(
              'Vers: ${_targetWallet!.name} (${_targetWallet!.balance} ${_targetWallet!.currency})',
            ),
            const SizedBox(height: 8),
            Text(
              'Montant: $amount ${_sourceWallet!.currency}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitTransfer(amount);
    }
  }

  Future<void> _submitTransfer(double amount) async {
    if (_sourceWallet == null || _targetWallet == null) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _walletRepository.transfer(
        fromWalletId: _sourceWallet!.id,
        toWalletId: _targetWallet!.id,
        amount: amount,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          String errorMessage = 'Erreur lors du transfert';

          if (failure is ValidationFailure) {
            errorMessage = failure.message;
          } else if (failure is CacheFailure) {
            errorMessage = 'Erreur de stockage: ${failure.message}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transfert effectué avec succès'),
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
          content: Text('Une erreur inattendue est survenue'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effectuer un transfert'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWallets,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Portefeuille source
                    const Text(
                      'Depuis le portefeuille',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wallet>(
                      initialValue: _sourceWallet,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: _wallets
                          .where(
                            (wallet) =>
                                _targetWallet == null ||
                                wallet.id != _targetWallet!.id,
                          )
                          .map(
                            (wallet) => DropdownMenuItem(
                              value: wallet,
                              child: Text(wallet.name),
                            ),
                          )
                          .toList(),
                      onChanged: (wallet) {
                        if (wallet != null) {
                          setState(() => _sourceWallet = wallet);
                        }
                      },
                      validator: (value) => value == null
                          ? 'Sélectionnez un portefeuille source'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Portefeuille cible
                    const Text(
                      'Vers le portefeuille',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Wallet>(
                      initialValue: _targetWallet,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      items: _wallets
                          .where(
                            (wallet) =>
                                _sourceWallet == null ||
                                wallet.id != _sourceWallet!.id,
                          )
                          .map(
                            (wallet) => DropdownMenuItem(
                              value: wallet,
                              child: Text(wallet.name),
                            ),
                          )
                          .toList(),
                      onChanged: (wallet) {
                        if (wallet != null) {
                          setState(() => _targetWallet = wallet);
                        }
                      },
                      validator: (value) => value == null
                          ? 'Sélectionnez un portefeuille cible'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Montant
                    const Text(
                      'Montant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixText: '€ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un montant';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Montant invalide';
                        }
                        if (_sourceWallet != null &&
                            amount > _sourceWallet!.balance) {
                          return 'Solde insuffisant';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Bouton de confirmation
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirmer le transfert',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
