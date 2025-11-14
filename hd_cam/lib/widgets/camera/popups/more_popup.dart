import 'package:flutter/material.dart';

class MorePopup extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onGridTap;
  final VoidCallback onFocusTap;
  final VoidCallback onExposureTap;
  final VoidCallback onCollageTap;
  final VoidCallback onClose;

  const MorePopup({
    super.key,
    required this.isVisible,
    required this.onGridTap,
    required this.onFocusTap,
    required this.onExposureTap,
    required this.onCollageTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoreOptionItem(
                Icons.grid_on,
                'Grid',
                onTap: onGridTap,
              ),
              _buildMoreOptionItem(
                Icons.center_focus_strong,
                'Focus',
                onTap: onFocusTap,
              ),
              _buildMoreOptionItem(
                Icons.exposure,
                'Exposure',
                onTap: onExposureTap,
              ),
              _buildMoreOptionItem(
                Icons.hd_outlined,
                'Resolution',
                onTap: () {
                  onClose();
                  // Show snackbar for resolution
                },
              ),
              _buildMoreOptionItem(
                Icons.view_comfy_outlined,
                'Collage',
                onTap: onCollageTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOptionItem(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
