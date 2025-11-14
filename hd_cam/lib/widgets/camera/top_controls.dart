import 'package:flutter/material.dart';

class TopControls extends StatelessWidget {
  final bool showTopControls;
  final String selectedRatio;
  final bool isFlashOn;
  final bool showRatioPopup;
  final bool showTimerPopup;
  final bool showToolPopup;
  final bool showMorePopup;
  final VoidCallback onBackPressed;
  final VoidCallback onRatioPressed;
  final VoidCallback onFlashPressed;
  final VoidCallback onTimerPressed;
  final VoidCallback onToolPressed;
  final VoidCallback onMorePressed;

  const TopControls({
    super.key,
    required this.showTopControls,
    required this.selectedRatio,
    required this.isFlashOn,
    required this.showRatioPopup,
    required this.showTimerPopup,
    required this.showToolPopup,
    required this.showMorePopup,
    required this.onBackPressed,
    required this.onRatioPressed,
    required this.onFlashPressed,
    required this.onTimerPressed,
    required this.onToolPressed,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: showTopControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          // Background tối trong suốt, 1 màu duy nhất
          color: Colors.black.withOpacity(0.4),
          child: SafeArea(
            bottom: false,
            child: Padding(
              // Tăng padding để cao hơn
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  _buildTopButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: onBackPressed,
                  ),

                  // Expanded để các icon còn lại cách đều
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Ratio button
                        _buildTopButton(
                          label: selectedRatio,
                          isActive: showRatioPopup,
                          onTap: onRatioPressed,
                        ),

                        // Flash button
                        _buildTopButton(
                          icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                          isActive: isFlashOn,
                          onTap: onFlashPressed,
                        ),

                        // Timer button
                        _buildTopButton(
                          icon: Icons.timer_outlined,
                          isActive: showTimerPopup,
                          onTap: onTimerPressed,
                        ),

                        // Tool button
                        _buildTopButton(
                          icon: Icons.tune,
                          isActive: showToolPopup,
                          onTap: onToolPressed,
                        ),

                        // More button
                        _buildTopButton(
                          icon: Icons.more_horiz,
                          isActive: showMorePopup,
                          onTap: onMorePressed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    IconData? icon,
    String? label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
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
