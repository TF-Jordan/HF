import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/connection_provider.dart';
import '../../widgets/monitor/device_card.dart';
import '../../widgets/monitor/labeling_panel.dart';

/// The Monitor tab — data collection and live sensor display.
class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const LabelingPanel(),
          DeviceCard(
            title: 'Main Gauche',
            handIcon: Icons.back_hand_rounded,
            flex: conn.flex1,
            imu: conn.imu1,
            ypr: conn.ypr1,
            connected: conn.esp1Connected,
          ),
          DeviceCard(
            title: 'Main Droite',
            handIcon: Icons.front_hand_rounded,
            flex: conn.flex2,
            imu: conn.imu2,
            ypr: conn.ypr2,
            connected: conn.esp2Connected,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
