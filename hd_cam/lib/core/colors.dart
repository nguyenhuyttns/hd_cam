import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF7C3FFF);
  static const Color textMain = Color(0xFF434343);
  static const Color textInactive = Color(0xFFBEB7DB);
  static const Color background = Color(0xFFFEFEFE);
  static const Color emptyBg = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  
  // Gradients
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFC868FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient collageGradient = LinearGradient(
    colors: [Color(0xFFFFF4E6), Color(0xFFFFE4CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient editGradient = LinearGradient(
    colors: [Color(0xFFE6F4FF), Color(0xFFCCE8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
