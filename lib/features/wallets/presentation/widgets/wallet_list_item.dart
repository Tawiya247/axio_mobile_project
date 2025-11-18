import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wallet.dart';

class WalletListItem extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WalletListItem({
    super.key,
    required this.wallet,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: wallet.currency == 'EUR' ? '€' : wallet.currency,
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26), // ~10% d'opacité
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getWalletIcon(),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (wallet.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          wallet.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(wallet.balance),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: wallet.balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWalletIcon() {
    switch (wallet.name.toLowerCase()) {
      case 'compte courant':
        return Icons.account_balance_wallet;
      case 'épargne':
        return Icons.savings;
      case 'espèces':
        return Icons.money;
      case 'carte de crédit':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
