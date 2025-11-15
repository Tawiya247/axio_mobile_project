import 'package:dartz/dartz.dart';
import 'package:axio_mobile_project/core/error/failures.dart';
import 'package:axio_mobile_project/features/wallets/domain/entities/wallet.dart';

abstract class WalletRepository {
  // Récupérer tous les portefeuilles
  Future<Either<Failure, List<Wallet>>> getWallets();

  // Récupérer un portefeuille par son ID
  Future<Either<Failure, Wallet>> getWallet(String id);

  // Créer un nouveau portefeuille
  Future<Either<Failure, Wallet>> createWallet(Wallet wallet);

  // Mettre à jour un portefeuille existant
  Future<Either<Failure, Wallet>> updateWallet(Wallet wallet);

  // Supprimer un portefeuille
  Future<Either<Failure, void>> deleteWallet(String id);

  // Transférer de l'argent entre portefeuilles
  Future<Either<Failure, void>> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  });
}
