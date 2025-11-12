import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../camera/v169_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data - sẽ thay bằng real data sau
  List<String> recentPhotos = []; // Empty để test empty state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Take Photo Banner
                    _buildTakePhotoBanner(),

                    // Action Buttons Row
                    _buildActionButtons(),

                    // Gallery Section
                    _buildGallerySection(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 23, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome to", style: AppTextStyles.welcomeText),
          Text("HD Camera", style: AppTextStyles.appTitle),
        ],
      ),
    );
  }

  Widget _buildTakePhotoBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const V169CameraScreen()),
        );
      },
      child: Container(
        height: 130,
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 23),
        decoration: BoxDecoration(
          gradient: AppColors.bannerGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 30,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Take Photo", style: AppTextStyles.bannerTitle),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Let's Go", style: AppTextStyles.bannerButton),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        children: [
          // Collage Maker Button
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.collageGradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.grid_view,
                      size: 30,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Collage Maker", style: AppTextStyles.actionButtonLabel),
                ],
              ),
            ),
          ),

          // Photo Edit Button
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.editGradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 30,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Edit Photo", style: AppTextStyles.actionButtonLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Column(
        children: [
          // Gallery Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 20,
                    color: AppColors.textMain,
                  ),
                  const SizedBox(width: 8),
                  Text("My Gallery", style: AppTextStyles.galleryTitle),
                ],
              ),
              Row(
                children: [
                  Text("View All", style: AppTextStyles.viewAllText),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 17),

          // Photo List or Empty State
          recentPhotos.isEmpty ? _buildEmptyState() : _buildPhotoList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.emptyBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Gallery is empty now",
            style: AppTextStyles.emptyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const V169CameraScreen()),
                );
              },
              child: Text("Go to Camera", style: AppTextStyles.emptyButtonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentPhotos.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            height: 180,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Placeholder for image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 50, color: Colors.grey[500]),
                  ),

                  // Video icon if it's a video (example)
                  if (index % 3 == 0) // Mock condition
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Icon(
                        Icons.play_circle,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home Tab (Active)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 24, color: AppColors.primary),
                const SizedBox(height: 4),
                Text("Home", style: AppTextStyles.bottomNavActive),
              ],
            ),
          ),

          // Camera Tab (Large)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const V169CameraScreen()),
                );
              },
              child: Icon(Icons.camera_alt, size: 48, color: AppColors.textMain),
            ),
          ),

          // Settings Tab (Inactive)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 24, color: AppColors.textInactive),
                const SizedBox(height: 4),
                Text("Settings", style: AppTextStyles.bottomNavInactive),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
