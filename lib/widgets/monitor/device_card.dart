import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../common/glass_card.dart';
import '../common/section_header.dart';
import '../common/status_indicator.dart';
import 'flex_sensor_bar.dart';
import 'imu_display.dart';
import 'orientation_display.dart';

/// Full device sensor card showing flex, IMU, and orientation data.
class DeviceCard extends StatelessWidget {
  final String title;
  final IconData handIcon;
  final List<int> flex;
  final Map<String, int> imu;
  final Map<String, int> ypr;
  final bool connected;

  const DeviceCard({
    super.key,
    required this.title,
    required this.handIcon,
    required this.flex,
    required this.imu,
    required this.ypr,
    required this.connected,
  });

  @override
  Widget build(BuildContext context) {
    final c = HarmonyColors.of(context);
    return AnimatedOpacity(
      opacity: connected ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SectionHeader(
              title: title,
              icon: handIcon,
              trailing: StatusIndicator(
                active: connected,
                label: connected ? 'Actif' : 'Inactif',
              ),
            ),
            const SizedBox(height: 16),

            // Flex sensors
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.scaffold.withAlpha(120),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAPTEURS FLEX',
                    style: TextStyle(
                      color: c.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    5,
                    (i) => FlexSensorBar(index: i, value: flex[i]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // IMU
            Text(
              'DONNEES INERTIELLES',
              style: TextStyle(
                color: c.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ImuDisplay(imu: imu),
            const SizedBox(height: 12),

            // Orientation
            Text(
              'ORIENTATION',
              style: TextStyle(
                color: c.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            OrientationDisplay(ypr: ypr),
          ],
        ),
      ),
    );
  }
}
