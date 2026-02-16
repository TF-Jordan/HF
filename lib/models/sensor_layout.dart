/// Describes a binary protocol sensor layout variant.
class SensorLayout {
  final int sensorCount;
  final int fullMask;
  final bool hasYpr;

  const SensorLayout(this.sensorCount, this.fullMask, this.hasYpr);
}
