import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants/app_constants.dart';

/// Runs TFLite inference on gesture frame batches.
///
/// Loads a model from assets along with an optional StandardScaler
/// for feature normalization. Accepts a batch of sensor frames and
/// returns a human-readable classification result.
class ModelRunner {
  Interpreter? _interpreter;
  bool _loading = false;
  String? _error;
  List<double>? _scalerCenter;
  List<double>? _scalerScale;

  bool get isReady => _interpreter != null && _error == null;
  String? get error => _error;
  bool get hasScaler => _scalerCenter != null && _scalerScale != null;

  Future<void> load() async {
    if (_loading || _interpreter != null) return;
    _loading = true;
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: options,
      );
      try {
        _interpreter!.resizeInputTensor(0, [
          1,
          AppConstants.maxSequenceLength,
          AppConstants.numFeatures,
        ]);
        _interpreter!.allocateTensors();
      } catch (e) {
        _error = 'Forme entree invalide. Reconvertis le modele en '
            '${AppConstants.maxSequenceLength} x ${AppConstants.numFeatures}.';
        return;
      }
      await _loadScaler();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
    }
  }

  Future<String> predict(List<Map<String, dynamic>> frames) async {
    if (!isReady) return 'Modele non charge.';
    final input = _buildInput(frames);
    final output = List.generate(
      1,
      (_) => List<double>.filled(AppConstants.gestureClasses.length, 0.0),
    );
    _interpreter!.run(input, output);
    return _formatOutput(output.first);
  }

  // ── Private helpers ──

  List<List<List<double>>> _buildInput(List<Map<String, dynamic>> frames) {
    final sequence = List.generate(
      AppConstants.maxSequenceLength,
      (_) => List<double>.filled(AppConstants.numFeatures, 0.0),
    );
    final length = frames.length < AppConstants.maxSequenceLength
        ? frames.length
        : AppConstants.maxSequenceLength;
    for (int i = 0; i < length; i++) {
      final features = _extractFeatures(frames[i]);
      if (features.length == AppConstants.numFeatures) {
        sequence[i] = _normalize(features);
      }
    }
    return [sequence];
  }

  List<double> _extractFeatures(Map<String, dynamic> frame) {
    final left = Map<String, dynamic>.from(frame['left_hand'] ?? {});
    final right = Map<String, dynamic>.from(frame['right_hand'] ?? {});
    return [..._extractHand(left), ..._extractHand(right)];
  }

  List<double> _extractHand(Map<String, dynamic> hand) {
    final gyro = Map<String, dynamic>.from(hand['gyro'] ?? {});
    final accel = Map<String, dynamic>.from(hand['accel'] ?? {});
    final flex = (hand['flex_sensors'] as List?) ?? const [];
    final euler = Map<String, dynamic>.from(
      hand['euler'] ?? hand['orientation'] ?? {},
    );
    return [
      _toDouble(gyro['x']),
      _toDouble(gyro['y']),
      _toDouble(gyro['z']),
      _toDouble(accel['x']),
      _toDouble(accel['y']),
      _toDouble(accel['z']),
      ..._padFlex(flex),
      _toDouble(euler['yaw']),
      _toDouble(euler['pitch']),
      _toDouble(euler['roll']),
    ];
  }

  List<double> _padFlex(List flex) {
    final values = List<double>.filled(5, 0.0);
    final count = flex.length < 5 ? flex.length : 5;
    for (int i = 0; i < count; i++) {
      values[i] = _toDouble(flex[i]);
    }
    return values;
  }

  List<double> _normalize(List<double> features) {
    if (!hasScaler) return features;
    final scaled = List<double>.filled(AppConstants.numFeatures, 0.0);
    for (int i = 0; i < AppConstants.numFeatures; i++) {
      final scale = _scalerScale![i];
      scaled[i] = scale == 0 ? 0.0 : (features[i] - _scalerCenter![i]) / scale;
    }
    return scaled;
  }

  String _formatOutput(List<double> scores) {
    if (scores.isEmpty) return 'Aucune sortie modele.';
    final indices = List<int>.generate(scores.length, (i) => i);
    indices.sort((a, b) => scores[b].compareTo(scores[a]));
    final best = indices.first;
    final bestLabel = AppConstants.gestureClasses[best];
    final bestPct = (scores[best] * 100).toStringAsFixed(1);
    if (indices.length == 1) return '$bestLabel $bestPct%';
    final second = indices[1];
    final secondLabel = AppConstants.gestureClasses[second];
    final secondPct = (scores[second] * 100).toStringAsFixed(1);
    return '$bestLabel $bestPct% | $secondLabel $secondPct%';
  }

  Future<void> _loadScaler() async {
    try {
      final raw = await rootBundle.loadString('assets/scaler.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final center =
          (data['center'] as List).map((v) => (v as num).toDouble()).toList();
      final scale =
          (data['scale'] as List).map((v) => (v as num).toDouble()).toList();
      if (center.length == AppConstants.numFeatures &&
          scale.length == AppConstants.numFeatures) {
        _scalerCenter = center;
        _scalerScale = scale;
      }
    } catch (_) {
      // Scaler is optional — raw data is used if absent.
    }
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
