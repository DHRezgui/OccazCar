import 'package:flutter/material.dart';

class AppColors {
  // Couleur principale - Corail/Saumon
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8E8E);
  static const Color primaryDark = Color(0xFFE85555);
  
  // Couleur secondaire - Gris foncé
  static const Color secondary = Color(0xFF2D3436);
  static const Color secondaryLight = Color(0xFF636E72);
  
  // Arrière-plans
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Textes
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFF95A5A6);
  
  // États
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDAA5D);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF0984E3);
  
  // Bordures
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);
  
  // Étoiles rating
  static const Color starFilled = Color(0xFFFFB800);
  static const Color starEmpty = Color(0xFFE0E0E0);
  
  // Gradient pour les boutons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Ombres
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withAlpha((0.08 * 255).round()),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withAlpha((0.3 * 255).round()),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}
