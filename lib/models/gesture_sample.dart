import 'dart:math';

/// A single recorded gesture consisting of multiple sensor data points.
class GestureSample {
  final int sampleId;
  int startTimestampMs;
  int lastTimestampMs;
  final String startedAtIso;
  final List<Map<String, dynamic>> dataPoints = [];

  GestureSample({
    required this.sampleId,
    required this.startedAtIso,
  })  : startTimestampMs = -1,
        lastTimestampMs = -1;

  int get durationMs {
    if (startTimestampMs < 0 || lastTimestampMs < 0) return 0;
    return max(0, lastTimestampMs - startTimestampMs);
  }

  bool get isEmpty => dataPoints.isEmpty;
  int get pointCount => dataPoints.length;
}
