import 'dart:typed_data';

import '../core/constants/app_constants.dart';
import '../models/device_state.dart';
import '../models/sensor_layout.dart';

/// Result of parsing a binary WebSocket frame.
class ParsedFrame {
  final int timestamp;
  final bool success;

  const ParsedFrame({required this.timestamp, required this.success});
  const ParsedFrame.failed() : timestamp = 0, success = false;
}

/// Parses the compact binary protocol from the ESP32 master.
///
/// Frame format (little-endian):
///   [timestamp 4B][bitmask 4B][deltas int16...]
///
/// The bitmask encodes which sensors have changed values.
/// Bits 0..13 = ESP1, bits 14..27 = ESP2 (14-sensor layout).
class BinaryParser {
  static const List<SensorLayout> _layouts = [
    SensorLayout(
      AppConstants.sensorCountPerDevice,
      AppConstants.fullMask,
      true,
    ),
    SensorLayout(
      AppConstants.legacySensorCount,
      AppConstants.legacyFullMask,
      false,
    ),
  ];

  /// Parse a binary payload and update the two device states in place.
  ParsedFrame parse(Uint8List data, DeviceState esp1, DeviceState esp2) {
    if (data.length < 8) return const ParsedFrame.failed();

    final view = ByteData.sublistView(data);
    int offset = 0;

    final timestamp = view.getUint32(0, Endian.little);
    offset += 4;

    final combinedMask = view.getUint32(offset, Endian.little);
    offset += 4;

    final layout = _selectLayout(combinedMask, data.length);
    if (layout == null) return const ParsedFrame.failed();

    final maskEsp1 = combinedMask & layout.fullMask;
    final maskEsp2 = (combinedMask >> layout.sensorCount) & layout.fullMask;

    if (!_processDevice(esp1, maskEsp1, layout, view, data.length, offset,
        (o) => offset = o)) {
      return const ParsedFrame.failed();
    }
    if (!_processDevice(esp2, maskEsp2, layout, view, data.length, offset,
        (o) => offset = o)) {
      return const ParsedFrame.failed();
    }

    return ParsedFrame(timestamp: timestamp, success: true);
  }

  bool _processDevice(
    DeviceState state,
    int mask,
    SensorLayout layout,
    ByteData view,
    int len,
    int offset,
    void Function(int) setOffset,
  ) {
    if (mask == 0) {
      setOffset(offset);
      return true;
    }

    final isFull = mask == layout.fullMask;

    for (int i = 0; i < layout.sensorCount; i++) {
      if ((mask & (1 << i)) != 0) {
        if (offset + 2 > len) return false;
        final delta = view.getInt16(offset, Endian.little);
        offset += 2;
        if (!state.hasBaseline || isFull) {
          state.values[i] = delta;
        } else {
          state.values[i] += delta;
        }
      }
    }

    state.hasBaseline = state.hasBaseline || isFull;
    state.markUpdated();
    setOffset(offset);
    return true;
  }

  SensorLayout? _selectLayout(int combinedMask, int totalLength) {
    for (final layout in _layouts) {
      final maskEsp1 = combinedMask & layout.fullMask;
      final maskEsp2 = (combinedMask >> layout.sensorCount) & layout.fullMask;
      final expectedLength =
          8 + 2 * (_bitCount(maskEsp1) + _bitCount(maskEsp2));
      if (expectedLength == totalLength) return layout;
    }
    return null;
  }

  int _bitCount(int value) {
    int count = 0;
    int v = value;
    while (v != 0) {
      count += (v & 1);
      v >>= 1;
    }
    return count;
  }
}
