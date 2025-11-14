import 'package:flutter/material.dart';

class ExposurePopup extends StatelessWidget {
  final bool isVisible;
  final double exposureValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  const ExposurePopup({
    super.key,
    required this.isVisible,
    required this.exposureValue,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const double popupAlpha = 0.7;

    return Positioned(
      bottom: 215,
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: popupAlpha),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Exposure',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: onClose,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    '-2EV',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: exposureValue,
                      min: -2.0,
                      max: 2.0,
                      divisions: 40,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withValues(alpha: 0.3),
                      onChanged: onChanged,
                    ),
                  ),
                  const Text(
                    '+2EV',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
