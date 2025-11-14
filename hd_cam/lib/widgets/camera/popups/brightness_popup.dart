import 'package:flutter/material.dart';
import 'base_popup.dart';

class BrightnessPopup extends StatelessWidget {
  final bool isVisible;
  final double brightnessValue;
  final ValueChanged<double> onChanged;

  const BrightnessPopup({
    super.key,
    required this.isVisible,
    required this.brightnessValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BasePopup(
      isVisible: isVisible,
      child: Row(
        children: [
          Text(
            '${(brightnessValue * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: Slider(
              value: brightnessValue,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
