import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../services/model_runner.dart';
import 'connection_provider.dart';

/// Active translation mode — only one can be active at a time.
enum TranslationMode { none, manual, auto }

/// Manages manual and automatic gesture translation via the TFLite model.
///
/// Manual mode lifecycle: startRecording → stopRecording → predict → reset
/// Auto mode: toggleAutoTranslation (continuous inference loop)
class TranslationProvider extends ChangeNotifier {
  final ConnectionProvider _connection;
  final ModelRunner _model = ModelRunner();

  TranslationProvider(this._connection) {
    _connection.addFrameListener(_onFrame);
    _initModel();
  }

  // ── Model state ──
  bool modelReady = false;
  String? modelError;
  bool get hasScaler => _model.hasScaler;

  // ── Active mode (mutually exclusive) ──
  TranslationMode activeMode = TranslationMode.none;

  // ── Manual translation ──
  bool isManualRecording = false;
  bool manualInferenceInFlight = false;
  String? manualOutput;
  final List<Map<String, dynamic>> _manualFrames = [];
  int _manualSessionId = 0;
  int get manualFrameCount => _manualFrames.length;
  /// True when frames have been captured and recording stopped (ready to predict).
  bool get hasManualFrames =>
      !isManualRecording && _manualFrames.isNotEmpty;

  // ── Auto translation ──
  bool isAutoActive = false;
  bool autoInferenceInFlight = false;
  String? autoOutput;
  final List<Map<String, dynamic>> _autoFrames = [];
  final List<String> autoHistory = [];
  int _autoSessionId = 0;
  int get autoBufferCount => _autoFrames.length;

  // ── Init ──

  Future<void> _initModel() async {
    await _model.load();
    modelReady = _model.isReady;
    modelError = _model.error;
    notifyListeners();
  }

  // ── Frame handler ──

  void _onFrame(int timestampMs) {
    if (!isManualRecording && !isAutoActive) return;
    final frame = _connection.buildCurrentFrame(timestampMs);

    if (isManualRecording) {
      _manualFrames.add(frame);
      notifyListeners();
    }

    if (isAutoActive) {
      _autoFrames.add(frame);
      _tryRunAutoInference();
      notifyListeners();
    }
  }

  // ── Mode switching ──

  /// Switch to manual mode (deactivates auto if active).
  void setManualMode() {
    if (activeMode == TranslationMode.auto) {
      _stopAuto();
    }
    activeMode = TranslationMode.manual;
    notifyListeners();
  }

  /// Switch to auto mode (deactivates manual if active).
  void setAutoMode() {
    if (activeMode == TranslationMode.manual) {
      _resetManual();
    }
    activeMode = TranslationMode.auto;
    notifyListeners();
  }

  // ── Manual translation: separate operations ──

  /// Start recording frames (manual mode).
  void startRecording() {
    if (isManualRecording) return;
    if (activeMode != TranslationMode.manual) {
      setManualMode();
    }
    _manualSessionId += 1;
    _manualFrames.clear();
    manualOutput = null;
    manualInferenceInFlight = false;
    isManualRecording = true;
    notifyListeners();
  }

  /// Stop recording frames without triggering inference.
  void stopRecording() {
    if (!isManualRecording) return;
    isManualRecording = false;
    notifyListeners();
  }

  /// Run inference on the captured frames.
  Future<void> predict() async {
    if (isManualRecording) return; // must stop first
    if (_manualFrames.isEmpty) {
      manualOutput = 'Aucune donnee recue.';
      notifyListeners();
      return;
    }

    final batch = List<Map<String, dynamic>>.from(_manualFrames);
    final sessionId = _manualSessionId;
    manualInferenceInFlight = true;
    notifyListeners();

    final result = await _requestInference(batch);
    if (sessionId != _manualSessionId) return;
    manualInferenceInFlight = false;
    manualOutput = result;
    notifyListeners();
  }

  /// Reset manual state: clear frames and output.
  void resetManual() {
    _resetManual();
    notifyListeners();
  }

  void _resetManual() {
    _manualSessionId += 1;
    isManualRecording = false;
    manualInferenceInFlight = false;
    manualOutput = null;
    _manualFrames.clear();
  }

  // ── Legacy toggle (kept for backward compat but prefer separate calls) ──

  void toggleManualTranslation() {
    if (isManualRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  // ── Auto translation ──

  void toggleAutoTranslation() {
    if (isAutoActive) {
      _stopAuto();
    } else {
      if (activeMode == TranslationMode.manual) {
        _resetManual();
      }
      activeMode = TranslationMode.auto;
      _autoSessionId += 1;
      _autoFrames.clear();
      autoOutput = null;
      isAutoActive = true;
      autoInferenceInFlight = false;
    }
    notifyListeners();
  }

  void _stopAuto() {
    _autoSessionId += 1;
    isAutoActive = false;
    _autoFrames.clear();
    autoInferenceInFlight = false;
  }

  void _tryRunAutoInference() {
    if (autoInferenceInFlight || !isAutoActive) return;
    if (_autoFrames.length < AppConstants.translationBatchSize) return;
    final batch = _autoFrames.sublist(0, AppConstants.translationBatchSize);
    _autoFrames.removeRange(0, AppConstants.translationBatchSize);
    _runAutoInference(batch);
  }

  Future<void> _runAutoInference(List<Map<String, dynamic>> batch) async {
    final sessionId = _autoSessionId;
    autoInferenceInFlight = true;
    notifyListeners();

    final result = await _requestInference(batch);
    if (sessionId != _autoSessionId) return;
    autoInferenceInFlight = false;
    autoOutput = result;
    autoHistory.insert(0, result);
    notifyListeners();
    _tryRunAutoInference();
  }

  Future<String> _requestInference(List<Map<String, dynamic>> batch) async {
    if (!_model.isReady) {
      final err = _model.error;
      return err == null ? 'Modele non charge.' : 'Erreur modele: $err';
    }
    try {
      return await _model.predict(batch);
    } catch (e) {
      return 'Erreur modele: $e';
    }
  }

  @override
  void dispose() {
    _connection.removeFrameListener(_onFrame);
    super.dispose();
  }
}
