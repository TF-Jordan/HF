abstract final class AppConstants {
  static const String appName = 'Harmony';
  static const String appTagline = 'Traduction gestuelle intelligente';

  // ── ESP32 defaults ──
  static const String defaultEspIp = '192.168.4.1';
  static const int defaultEspPort = 81;

  // ── Sensor layout ──
  static const int sensorCountPerDevice = 14;
  static const int fullMask = 0x3FFF;
  static const int legacySensorCount = 11;
  static const int legacyFullMask = 0x7FF;

  // ── Data collection ──
  static const int collectionTargetPoints = 66;
  static const int translationBatchSize = 66;

  // ── Model ──
  static const int numFeatures = 28;
  static const int maxSequenceLength = 90;
  static const List<String> gestureClasses = [
    'appeler',
    'espace',
    'harmony',
    'moi',
  ];

  // ── Default labels ──
  static const List<String> defaultLabels = [
    'bonjour',
    'harmony',
    'moi',
    'appeler',
    'merci',
  ];

  // ── Timeouts ──
  static const int deviceTimeoutMs = 1500;
}
