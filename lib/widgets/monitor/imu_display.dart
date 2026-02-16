import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Displays IMU accelerometer + gyroscope data in a compact layout.
class ImuDisplay extends StatelessWidget {
  final Map<String, int> imu;

  const ImuDisplay({super.key, required this.imu});

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _AxisGroup(
            title: 'Accelerometre',
            icon: Icons.speed_rounded,
            values: {
              'X': imu['ax'] ?? 0,
              'Y': imu['ay'] ?? 0,
              'Z': imu['az'] ?? 0,
            },
            color: c.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AxisGroup(
            title: 'Gyroscope',
            icon: Icons.rotate_right_rounded,
            values: {
              'X': imu['gx'] ?? 0,
              'Y': imu['gy'] ?? 0,
              'Z': imu['gz'] ?? 0,
            },
            color: c.accentAlt,
          ),
        ),
      ],
    );
  }
}

class _AxisGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, int> values;
  final Color color;

  const _AxisGroup({
    required this.title,
    required this.icon,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...values.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: TextStyle(
                        color: c.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${e.value}',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
