import 'package:flutter/material.dart';

class BasePopup extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final double bottom;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double borderRadius;
  final double backgroundAlpha;

  const BasePopup({
    super.key,
    required this.isVisible,
    required this.child,
    this.bottom = 215,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.borderRadius = 30,
    this.backgroundAlpha = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      child: Visibility(
        visible: isVisible,
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(backgroundAlpha),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
