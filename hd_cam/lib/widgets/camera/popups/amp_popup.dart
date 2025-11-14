import 'package:flutter/material.dart';
import 'base_popup.dart';

class AmpPopup extends StatelessWidget {
  final bool isVisible;
  final double ampValue;
  final ValueChanged<double> onChanged;

  const AmpPopup({
    super.key,
    required this.isVisible,
    required this.ampValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BasePopup(
      isVisible: isVisible,
      child: Row(
        children: [
          Text(
            '${(ampValue * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: Slider(
              value: ampValue,
              min: 0.0,
              max: 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withValues(alpha: 0.3),
              onChanged: onChanged,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
