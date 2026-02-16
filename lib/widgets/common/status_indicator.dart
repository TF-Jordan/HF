import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A small pulsing dot indicator with a label.
class StatusIndicator extends StatelessWidget {
  final bool active;
  final String label;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusIndicator({
    super.key,
    required this.active,
    required this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final color = active
        ? (activeColor ?? c.success)
        : (inactiveColor ?? c.textHint);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withAlpha(100),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
