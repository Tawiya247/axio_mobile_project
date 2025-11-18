import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:axio_mobile_project/core/theme/app_colors.dart';
import 'package:axio_mobile_project/features/wallets/domain/entities/wallet.dart';
import 'package:axio_mobile_project/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:axio_mobile_project/features/wallets/presentation/widgets/wallet_list_item.dart';
import 'package:axio_mobile_project/injection.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  @override
  WalletsScreenState createState() => WalletsScreenState();
}

class WalletsScreenState extends State<WalletsScreen> {
  final WalletRepository _walletRepository = getIt<WalletRepository>();
  List<Wallet> _wallets = [];
  bool _isLoading = true;
  String? _error;
  Wallet? _selectedWallet;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _walletRepository.getWallets();

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (wallets) {
          setState(() {
            _wallets = wallets;
            _isLoading = false;
          });
        },
      );

      // Données factices pour le moment
      final dummyWallets = [
        Wallet(
          id: '1',
          name: 'Compte Courant',
          balance: 1250.50,
          currency: 'EUR',
          description: 'Compte principal',
        ),
        Wallet(
          id: '2',
          name: 'Épargne',
          balance: 5000.00,
          currency: 'EUR',
          description: 'Fonds d\'urgence',
        ),
        Wallet(
          id: '3',
          name: 'Espèces',
          balance: 150.75,
          currency: 'EUR',
          description: 'Portefeuille physique',
        ),
      ];

      setState(() {
        _wallets = dummyWallets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des portefeuilles';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Portefeuilles'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Effectuer un transfert',
            onPressed: () {
              GoRouter.of(context).pushNamed('wallet-transfer');
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un portefeuille',
            onPressed: () {
              GoRouter.of(context).pushNamed('wallet-form');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedWallet != null) {
            if (!mounted) return;
            Navigator.pushNamed(
              context,
              '/wallets/transfer',
              arguments: _selectedWallet,
            ).then(
              (_) => _loadWallets(),
            ); // Recharger la liste après le transfert
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.swap_horiz, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    if (_wallets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun portefeuille trouvé',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (!mounted) return;
                Navigator.pushNamed(context, '/wallets/form/new').then(
                  (_) => _loadWallets(),
                ); // Recharger la liste après création
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un portefeuille'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWallets,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Espace pour le FAB
        itemCount: _wallets.length,
        itemBuilder: (context, index) {
          final wallet = _wallets[index];
          return WalletListItem(
            wallet: wallet,
            onTap: () {
              if (!mounted) return;
              Navigator.pushNamed(
                context,
                '/wallets/form/${wallet.id}',
                arguments: wallet,
              ).then((result) {
                if (result == 'deleted') {
                  _loadWallets(); // Recharger la liste après suppression
                } else if (result != null) {
                  _loadWallets(); // Recharger la liste après modification
                }
              });
            },
            onLongPress: () {
              _showWalletOptions(wallet);
            },
          );
        },
      ),
    );
  }

  void _showWalletOptions(Wallet wallet) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).pushNamed('wallet-form', extra: wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteWallet(wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.green),
              title: const Text('Effectuer un transfert'),
              onTap: () {
                Navigator.pop(context);
                _selectedWallet = wallet;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteWallet(Wallet wallet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le portefeuille'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le portefeuille "${wallet.name}" ?',
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
      try {
        final result = await _walletRepository.deleteWallet(wallet.id);

        if (!mounted) return;

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            setState(() {
              _wallets.removeWhere((w) => w.id == wallet.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Portefeuille supprimé avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression du portefeuille'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
