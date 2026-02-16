import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/gesture_sample.dart';
import '../services/export_service.dart';
import 'connection_provider.dart';

/// Manages gesture recording, labelling, and data export.
class RecordingProvider extends ChangeNotifier {
  final ConnectionProvider _connection;
  final ExportService _export = ExportService();

  RecordingProvider(this._connection) {
    _connection.addFrameListener(_onFrame);
  }

  final Map<String, List<GestureSample>> samplesByLabel = {};
  final List<String> labels = List<String>.from(AppConstants.defaultLabels);
  final Map<String, int> labelCounts = {};

  String selectedLabel = AppConstants.defaultLabels.first;
  bool isRecording = false;
  bool isPaused = false;
  int sessionId = 0;
  int sessionSamples = 0;
  int totalSamples = 0;
  String? lastExportPath;

  /// Configurable collection target points (default from constants).
  int _collectionTargetPoints = AppConstants.collectionTargetPoints;
  int get collectionTargetPoints => _collectionTargetPoints;
  set collectionTargetPoints(int value) {
    if (value > 0) {
      _collectionTargetPoints = value;
      notifyListeners();
    }
  }

  /// Configurable capture duration in seconds (0 = no limit, auto-stop by points).
  int _captureDurationSeconds = 0;
  int get captureDurationSeconds => _captureDurationSeconds;
  set captureDurationSeconds(int value) {
    if (value >= 0) {
      _captureDurationSeconds = value;
      notifyListeners();
    }
  }

  /// Stopwatch for capture timing.
  final Stopwatch _captureStopwatch = Stopwatch();
  Duration get captureElapsed => _captureStopwatch.elapsed;

  GestureSample? _currentSample;

  // ── Recording ──

  void startRecording() {
    if (isRecording) return;
    sessionId += 1;
    sessionSamples = 0;
    isRecording = true;
    isPaused = false;
    _captureStopwatch.reset();
    _captureStopwatch.start();
    _startNewSample();
    notifyListeners();
  }

  void _startNewSample() {
    final samples = samplesByLabel.putIfAbsent(
      selectedLabel,
      () => <GestureSample>[],
    );
    final sampleId = samples.length + 1;
    _currentSample = GestureSample(
      sampleId: sampleId,
      startedAtIso: DateTime.now().toIso8601String(),
    );
    samples.add(_currentSample!);
    totalSamples += 1;
    labelCounts[selectedLabel] = (labelCounts[selectedLabel] ?? 0) + 1;
  }

  void _onFrame(int timestampMs) {
    if (!isRecording || isPaused || _currentSample == null) return;

    final sample = _currentSample!;
    if (sample.startTimestampMs < 0) {
      sample.startTimestampMs = timestampMs;
    }
    sample.lastTimestampMs = timestampMs;

    final relativeTs = timestampMs - sample.startTimestampMs;
    sample.dataPoints.add({
      'timestamp_ms': relativeTs < 0 ? 0 : relativeTs,
      'left_hand': _connection.buildHandData(
          _connection.flex1, _connection.imu1, _connection.ypr1),
      'right_hand': _connection.buildHandData(
          _connection.flex2, _connection.imu2, _connection.ypr2),
    });

    sessionSamples = sample.dataPoints.length;
    // Auto-stop when reaching target points
    if (sessionSamples >= _collectionTargetPoints) {
      _stopRecording();
    }
    // Auto-stop when reaching duration limit (if set)
    else if (_captureDurationSeconds > 0 &&
        _captureStopwatch.elapsed.inSeconds >= _captureDurationSeconds) {
      _stopRecording();
    }
    notifyListeners();
  }

  /// Pause the current recording (frames are ignored but sample is kept).
  void pauseRecording() {
    if (!isRecording || isPaused) return;
    isPaused = true;
    _captureStopwatch.stop();
    notifyListeners();
  }

  /// Resume recording after pause.
  void resumeRecording() {
    if (!isRecording || !isPaused) return;
    isPaused = false;
    _captureStopwatch.start();
    notifyListeners();
  }

  /// Cancel the current recording and discard the sample.
  void cancelRecording() {
    if (!isRecording && _currentSample == null) return;
    // Remove the current sample from samplesByLabel
    if (_currentSample != null) {
      final samples = samplesByLabel[selectedLabel];
      if (samples != null && samples.contains(_currentSample)) {
        samples.remove(_currentSample);
        totalSamples = totalSamples > 0 ? totalSamples - 1 : 0;
        labelCounts[selectedLabel] =
            ((labelCounts[selectedLabel] ?? 1) - 1).clamp(0, 999999);
      }
    }
    isRecording = false;
    isPaused = false;
    _captureStopwatch.stop();
    _captureStopwatch.reset();
    sessionSamples = 0;
    _currentSample = null;
    notifyListeners();
  }

  void _stopRecording() {
    isRecording = false;
    isPaused = false;
    _captureStopwatch.stop();
    _currentSample = null;
  }

  // ── Labels ──

  void selectLabel(String label) {
    selectedLabel = label;
    labelCounts.putIfAbsent(label, () => 0);
    notifyListeners();
  }

  void addLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || labels.contains(trimmed)) return;
    labels.add(trimmed);
    selectedLabel = trimmed;
    labelCounts.putIfAbsent(trimmed, () => 0);
    samplesByLabel.putIfAbsent(trimmed, () => <GestureSample>[]);
    notifyListeners();
  }

  void removeLabel(String label) {
    if (!labels.contains(label)) return;
    labels.remove(label);
    // Remove associated data
    final removedSamples = samplesByLabel.remove(label);
    if (removedSamples != null) {
      totalSamples -= removedSamples.length;
    }
    labelCounts.remove(label);
    // Select another label if the removed one was selected
    if (selectedLabel == label) {
      selectedLabel = labels.isNotEmpty ? labels.first : '';
    }
    notifyListeners();
  }

  void renameLabel(String oldLabel, String newLabel) {
    final trimmed = newLabel.trim();
    if (trimmed.isEmpty || !labels.contains(oldLabel)) return;
    if (trimmed == oldLabel) return;
    if (labels.contains(trimmed)) return; // prevent duplicates

    final index = labels.indexOf(oldLabel);
    labels[index] = trimmed;
    // Move associated data
    if (samplesByLabel.containsKey(oldLabel)) {
      samplesByLabel[trimmed] = samplesByLabel.remove(oldLabel)!;
    }
    if (labelCounts.containsKey(oldLabel)) {
      labelCounts[trimmed] = labelCounts.remove(oldLabel)!;
    }
    if (selectedLabel == oldLabel) {
      selectedLabel = trimmed;
    }
    notifyListeners();
  }

  // ── Export ──

  /// Copy JSON to clipboard. Returns the content length, or -1 if empty,
  /// or 0 if clipboard failed.
  Future<int> copyJson() async {
    final content = _export.buildJson(
      labels: labels,
      samplesByLabel: samplesByLabel,
    );
    if (content.isEmpty) return -1;
    final ok = await _export.copyToClipboard(content);
    return ok ? content.length : 0;
  }

  Future<String?> exportToFile() async {
    final content = _export.buildJson(
      labels: labels,
      samplesByLabel: samplesByLabel,
    );
    if (content.isEmpty) return null;
    final filename = _export.generateFileName();
    final path = await _export.writeToFile(filename, content);
    if (path != null) {
      lastExportPath = path;
      notifyListeners();
    }
    return path;
  }

  // ── Clear ──

  void clearAll() {
    samplesByLabel.clear();
    totalSamples = 0;
    labelCounts.clear();
    sessionId = 0;
    sessionSamples = 0;
    _currentSample = null;
    isRecording = false;
    isPaused = false;
    lastExportPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connection.removeFrameListener(_onFrame);
    super.dispose();
  }
}
