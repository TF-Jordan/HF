import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Displays yaw/pitch/roll orientation in a styled row.
class OrientationDisplay extends StatelessWidget {
  final Map<String, int> ypr;

  const OrientationDisplay({super.key, required this.ypr});

  String _formatAngle(int raw) => '${(raw / 100.0).toStringAsFixed(1)}°';

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    final entries = [
      ('Yaw', ypr['yaw'] ?? 0, c.primary),
      ('Pitch', ypr['pitch'] ?? 0, c.accent),
      ('Roll', ypr['roll'] ?? 0, c.success),
    ];

    return Row(
      children: entries.map((entry) {
        final (label, value, color) = entry;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: entry != entries.last ? 8 : 0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.glassBorder),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAngle(value),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
