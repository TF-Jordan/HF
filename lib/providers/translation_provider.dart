import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../services/model_runner.dart';
import 'connection_provider.dart';

/// Manages manual and automatic gesture translation via the TFLite model.
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

  // ── Manual translation ──
  bool isManualRecording = false;
  bool manualInferenceInFlight = false;
  String? manualOutput;
  final List<Map<String, dynamic>> _manualFrames = [];
  int _manualSessionId = 0;
  int get manualFrameCount => _manualFrames.length;

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

  // ── Manual translation ──

  void toggleManualTranslation() {
    if (isManualRecording) {
      _stopManualTranslation();
    } else {
      _manualSessionId += 1;
      _manualFrames.clear();
      manualOutput = null;
      manualInferenceInFlight = false;
      isManualRecording = true;
      notifyListeners();
    }
  }

  Future<void> _stopManualTranslation() async {
    final batch = List<Map<String, dynamic>>.from(_manualFrames);
    final sessionId = _manualSessionId;
    isManualRecording = false;
    manualInferenceInFlight = true;
    notifyListeners();

    if (batch.isEmpty) {
      manualInferenceInFlight = false;
      manualOutput = 'Aucune donnee recue.';
      notifyListeners();
      return;
    }

    final result = await _requestInference(batch);
    if (sessionId != _manualSessionId) return;
    manualInferenceInFlight = false;
    manualOutput = result;
    _manualFrames.clear();
    notifyListeners();
  }

  // ── Auto translation ──

  void toggleAutoTranslation() {
    if (isAutoActive) {
      _autoSessionId += 1;
      isAutoActive = false;
      _autoFrames.clear();
      autoInferenceInFlight = false;
    } else {
      _autoSessionId += 1;
      _autoFrames.clear();
      autoOutput = null;
      isAutoActive = true;
      autoInferenceInFlight = false;
    }
    notifyListeners();
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
