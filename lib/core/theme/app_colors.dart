import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF6C63FF); // Violet
  static const Color secondary = Color(0xFF4A45B1); // Violet foncé
  static const Color accent = Color(0xFF00BFA6); // Turquoise

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2D3748); // Gris très foncé
  static const Color textSecondary = Color(0xFF718096); // Gris
  static const Color textLight = Color(0xFFFFFFFF); // Blanc

  // Couleurs d'arrière-plan
  static const Color background = Color(0xFFF7FAFC); // Gris très clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc

  // Couleurs d'états
  static const Color success = Color(0xFF48BB78); // Vert
  static const Color error = Color(0xFFF56565); // Rouge
  static const Color warning = Color(0xFFED8936); // Orange
  static const Color info = Color(0xFF4299E1); // Bleu

  // Couleurs de cartes et éléments d'interface
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
  );

  // Couleurs spécifiques aux catégories
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFF48BB78), // Vert
    'transport': Color(0xFF4299E1), // Bleu
    'shopping': Color(0xFF9F7AEA), // Violet
    'bills': Color(0xFFED8936), // Orange
    'entertainment': Color(0xFFED64A6), // Rose
    'health': Color(0xFFF56565), // Rouge
    'other': Color(0xFF718096), // Gris
  };

  // Couleurs des portefeuilles
  static const List<Color> walletColors = [
    Color(0xFF6C63FF), // Violet
    Color(0xFF4FD1C5), // Turquoise
    Color(0xFFF6AD55), // Orange clair
    Color(0xFFF687B3), // Rose
    Color(0xFF68D391), // Vert clair
    Color(0xFFF6E05E), // Jaune
    Color(0xFFB794F4), // Violet clair
  ];

  // Méthode pour obtenir une couleur de catégorie
  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryColors['other']!;
  }

  // Méthode pour obtenir une couleur de portefeuille en fonction de l'index
  static Color getWalletColor(int index) {
    return walletColors[index % walletColors.length];
  }
}
