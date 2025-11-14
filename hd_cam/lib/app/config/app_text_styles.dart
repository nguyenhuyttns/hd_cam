import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Header styles
  static const TextStyle welcomeText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );

  static const TextStyle appTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textMain,
  );

  // Banner styles
  static const TextStyle bannerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle bannerButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // Action button styles
  static const TextStyle actionButtonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );

  // Gallery styles
  static const TextStyle galleryTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  static const TextStyle viewAllText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle emptyText = TextStyle(
    fontSize: 12,
    color: AppColors.textMain,
  );

  static const TextStyle emptyButtonText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Bottom navigation styles
  static const TextStyle bottomNavActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle bottomNavInactive = TextStyle(
    fontSize: 12,
    color: AppColors.textInactive,
  );
}
