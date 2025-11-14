import 'package:flutter/material.dart';

class MidControls extends StatelessWidget {
  final bool showMidControls;
  final double currentZoom;
  final VoidCallback onAmpPressed;
  final VoidCallback onWBPressed;
  final VoidCallback onZoomPressed;
  final VoidCallback onBrightnessPressed;

  const MidControls({
    super.key,
    required this.showMidControls,
    required this.currentZoom,
    required this.onAmpPressed,
    required this.onWBPressed,
    required this.onZoomPressed,
    required this.onBrightnessPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 154, // Đặt thấp hơn để sát với chữ Photo, Video
      child: AnimatedOpacity(
        opacity: showMidControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(
            0.4,
          ), // Thêm màu nền giống BottomControls
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // AMP button
                _buildMidButton(label: 'AMP', onTap: onAmpPressed),

                // WB button
                _buildMidButton(label: 'WB', onTap: onWBPressed),

                // Zoom button
                _buildMidButton(
                  label: '${currentZoom.toStringAsFixed(1)}x',
                  onTap: onZoomPressed,
                ),

                // Brightness button
                _buildMidButton(
                  icon: Icons.wb_sunny_outlined,
                  onTap: onBrightnessPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMidButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                label ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
