import 'package:flutter/material.dart';
import 'base_popup.dart';

class ZoomPopup extends StatelessWidget {
  final bool isVisible;
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onChanged;

  const ZoomPopup({
    super.key,
    required this.isVisible,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BasePopup(
      isVisible: isVisible,
      child: Row(
        children: [
          Text(
            '${minZoom.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: Slider(
              value: currentZoom,
              min: minZoom,
              max: maxZoom,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: onChanged,
            ),
          ),
          Text(
            '${maxZoom.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
