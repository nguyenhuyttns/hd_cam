import 'package:flutter/material.dart';
import 'base_popup.dart';
import '../../../services/white_balance_service.dart';

class WbPopup extends StatelessWidget {
  final bool isVisible;
  final WhiteBalanceMode currentMode;
  final ValueChanged<WhiteBalanceMode> onModeChanged;

  const WbPopup({
    super.key,
    required this.isVisible,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> wbOptions = [
      {'name': 'Default', 'mode': WhiteBalanceMode.DEFAULT},
      {'name': 'Foggy', 'mode': WhiteBalanceMode.FOGGY},
      {'name': 'Daylight', 'mode': WhiteBalanceMode.DAYLIGHT},
      {'name': 'Spike', 'mode': WhiteBalanceMode.SPIKE},
      {'name': 'Gloom', 'mode': WhiteBalanceMode.GLOAM},
    ];

    return BasePopup(
      isVisible: isVisible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: wbOptions.map((option) {
          final isSelected = currentMode == option['mode'];
          
          return GestureDetector(
            onTap: () => onModeChanged(option['mode']),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Text(
                option['name'],
                style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
