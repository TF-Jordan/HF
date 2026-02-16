import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A single flex sensor bar with animated progress and color.
class FlexSensorBar extends StatelessWidget {
  final int index;
  final int value;
  final int maxValue;

  const FlexSensorBar({
    super.key,
    required this.index,
    required this.value,
    this.maxValue = 4095,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final progress = (value / maxValue).clamp(0.0, 1.0);
    final color = c.fingerColors[index % c.fingerColors.length];
    final name = HarmonyColors.fingerNames[index % HarmonyColors.fingerNames.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: c.surface,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [color.withAlpha(180), color],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(80),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 45,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
