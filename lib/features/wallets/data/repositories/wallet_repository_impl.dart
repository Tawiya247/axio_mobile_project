import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:axio_mobile_project/core/error/failures.dart';
import 'package:axio_mobile_project/features/wallets/domain/entities/wallet.dart';
import 'package:axio_mobile_project/features/wallets/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  static const _storageKey = 'wallets';
  final SharedPreferences _prefs;

  WalletRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, List<Wallet>>> getWallets() async {
    try {
      final walletsJson = _prefs.getStringList(_storageKey) ?? [];
      final wallets = walletsJson
          .map(
            (json) => Wallet.fromJson(
              Map<String, dynamic>.from(jsonDecode(json) as Map),
            ),
          )
          .toList();
      return Right(wallets);
    } catch (e) {
      return Left(
        CacheFailure(
          'Impossible de charger les portefeuilles',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Wallet>> getWallet(String id) async {
    try {
      final result = await getWallets();
      return result.fold((failure) => Left(failure), (wallets) {
        try {
          final wallet = wallets.firstWhere((w) => w.id == id);
          return Right(wallet);
        } catch (e) {
          return Left(
            CacheFailure(
              'Portefeuille non trouvé',
              code: 'not_found',
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Impossible de charger le portefeuille',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Wallet>> createWallet(Wallet wallet) async {
    try {
      final result = await getWallets();
      return await result.fold((failure) => Left(failure), (wallets) async {
        if (wallets.any((w) => w.name == wallet.name)) {
          return Left(
            ValidationFailure(
              'Un portefeuille avec ce nom existe déjà',
              code: 'duplicate_name',
              stackTrace: StackTrace.current,
            ),
          );
        }

        final updatedWallets = List<Wallet>.from(wallets)..add(wallet);
        await _saveWallets(updatedWallets);
        return Right(wallet);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Échec de la création du portefeuille: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Wallet>> updateWallet(Wallet wallet) async {
    try {
      final result = await getWallets();
      return await result.fold((failure) => Left(failure), (wallets) async {
        final index = wallets.indexWhere((w) => w.id == wallet.id);
        if (index == -1) {
          return Left(
            CacheFailure(
              'Portefeuille non trouvé',
              code: 'not_found',
              stackTrace: StackTrace.current,
            ),
          );
        }

        // Vérifier si un autre portefeuille a le même nom
        if (wallets.any((w) => w.id != wallet.id && w.name == wallet.name)) {
          return Left(
            ValidationFailure(
              'Un autre portefeuille avec ce nom existe déjà',
              code: 'duplicate_name',
              stackTrace: StackTrace.current,
            ),
          );
        }

        final updatedWallets = List<Wallet>.from(wallets)
          ..[index] = wallet.copyWith(updatedAt: DateTime.now());
        await _saveWallets(updatedWallets);
        return Right(wallet);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Échec de la mise à jour du portefeuille: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String id) async {
    try {
      final result = await getWallets();
      return await result.fold((failure) => Left(failure), (wallets) async {
        final wallet = wallets.firstWhere(
          (w) => w.id == id,
          orElse: () => throw Exception('Portefeuille non trouvé'),
        );

        // Empêcher la suppression s'il reste de l'argent
        if (wallet.balance > 0) {
          return Left(
            ValidationFailure(
              'Impossible de supprimer un portefeuille avec un solde positif',
              code: 'non_empty_wallet',
              stackTrace: StackTrace.current,
            ),
          );
        }

        final updatedWallets = wallets.where((w) => w.id != id).toList();
        await _saveWallets(updatedWallets);
        return const Right(null);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Échec de la suppression du portefeuille: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
  }) async {
    try {
      if (amount <= 0) {
        return Left(
          ValidationFailure(
            'Le montant doit être supérieur à 0',
            code: 'invalid_amount',
            stackTrace: StackTrace.current,
          ),
        );
      }

      if (fromWalletId == toWalletId) {
        return Left(
          ValidationFailure(
            'Les portefeuilles source et destination doivent être différents',
            code: 'same_wallet',
            stackTrace: StackTrace.current,
          ),
        );
      }

      final result = await getWallets();
      return await result.fold((failure) => Left(failure), (wallets) async {
        final fromIndex = wallets.indexWhere((w) => w.id == fromWalletId);
        final toIndex = wallets.indexWhere((w) => w.id == toWalletId);

        if (fromIndex == -1 || toIndex == -1) {
          return Left(
            CacheFailure(
              'Un ou plusieurs portefeuilles sont introuvables',
              code: 'wallet_not_found',
              stackTrace: StackTrace.current,
            ),
          );
        }

        final fromWallet = wallets[fromIndex];
        final toWallet = wallets[toIndex];

        if (fromWallet.currency != toWallet.currency) {
          return Left(
            ValidationFailure(
              'Les portefeuilles doivent avoir la même devise',
              code: 'currency_mismatch',
              stackTrace: StackTrace.current,
            ),
          );
        }

        if (fromWallet.balance < amount) {
          return Left(
            ValidationFailure(
              'Solde insuffisant dans le portefeuille source',
              code: 'insufficient_funds',
              stackTrace: StackTrace.current,
            ),
          );
        }

        final now = DateTime.now();
        final updatedFrom = fromWallet.copyWith(
          balance: fromWallet.balance - amount,
          updatedAt: now,
        );

        final updatedTo = toWallet.copyWith(
          balance: toWallet.balance + amount,
          updatedAt: now,
        );

        final updatedWallets = List<Wallet>.from(wallets)
          ..[fromIndex] = updatedFrom
          ..[toIndex] = updatedTo;

        await _saveWallets(updatedWallets);
        return const Right(null);
      });
    } catch (e) {
      return Left(
        CacheFailure(
          'Échec du transfert: ${e.toString()}',
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  Future<void> _saveWallets(List<Wallet> wallets) async {
    try {
      final walletsJson = wallets.map((w) => jsonEncode(w.toJson())).toList();
      await _prefs.setStringList(_storageKey, walletsJson);
    } catch (e) {
      throw CacheFailure(
        'Erreur lors de la sauvegarde des portefeuilles: ${e.toString()}',
        stackTrace: StackTrace.current,
      );
    }
  }
}
