import 'dart:io';
import 'package:flutter/material.dart';

class BottomControls extends StatelessWidget {
  final bool showBottomControls;
  final bool isLoading;
  final bool isCapturing;
  final String? lastPhotoPath;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCapturePressed;
  final VoidCallback onSwitchCameraPressed;

  const BottomControls({
    super.key,
    required this.showBottomControls,
    required this.isLoading,
    required this.isCapturing,
    this.lastPhotoPath,
    required this.onGalleryPressed,
    required this.onCapturePressed,
    required this.onSwitchCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: showBottomControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Mode selector (Photo/Video)
                _buildModeSelector(),

                const SizedBox(height: 20),

                // Bottom navigation (Gallery, Capture, Switch)
                _buildBottomNavigation(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton('Photo', true),
        const SizedBox(width: 32),
        _buildModeButton('Video', false),
      ],
    );
  }

  Widget _buildModeButton(String label, bool isSelected) {
    return Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
        fontSize: 16,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery button with last photo thumbnail
          GestureDetector(
            onTap: onGalleryPressed,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child:
                    lastPhotoPath != null && File(lastPhotoPath!).existsSync()
                    ? Image.file(
                        File(lastPhotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 28,
                          );
                        },
                      )
                    : const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),

          // Capture button
          GestureDetector(
            onTap: isCapturing ? null : onCapturePressed,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCapturing ? Colors.grey : Colors.white,
                  width: 5,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isCapturing ? Colors.grey : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Switch camera button
          GestureDetector(
            onTap: isLoading ? null : onSwitchCameraPressed,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isLoading
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
