import '../core/constants/app_constants.dart';

/// Represents the current state of a single ESP32 glove device.
///
/// Stores 14 sensor values: 5 flex sensors + 3-axis accelerometer +
/// 3-axis gyroscope + 3-axis orientation (yaw/pitch/roll).
class DeviceState {
  final List<int> values = List<int>.filled(AppConstants.sensorCountPerDevice, 0);
  bool hasBaseline = false;
  int lastUpdateMs = 0;

  List<int> get flex => values.sublist(0, 5);

  Map<String, int> get imu => {
        'ax': values[5],
        'ay': values[6],
        'az': values[7],
        'gx': values[8],
        'gy': values[9],
        'gz': values[10],
      };

  Map<String, int> get ypr => {
        'yaw': values[11],
        'pitch': values[12],
        'roll': values[13],
      };

  void markUpdated() {
    lastUpdateMs = DateTime.now().millisecondsSinceEpoch;
  }

  bool isRecent({int timeoutMs = AppConstants.deviceTimeoutMs}) {
    return DateTime.now().millisecondsSinceEpoch - lastUpdateMs < timeoutMs;
  }

  void reset() {
    values.fillRange(0, values.length, 0);
    hasBaseline = false;
    lastUpdateMs = 0;
  }
}
