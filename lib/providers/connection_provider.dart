import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/device_state.dart';
import '../services/binary_parser.dart';
import '../services/websocket_service.dart';

/// Connection lifecycle status.
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
}

/// Manages the WebSocket connection and raw sensor state.
///
/// Listeners (other providers) can register callbacks via [onFrame]
/// to be notified whenever a new sensor frame arrives.
class ConnectionProvider extends ChangeNotifier {
  final WebSocketService _ws = WebSocketService();
  final BinaryParser _parser = BinaryParser();

  final DeviceState esp1 = DeviceState();
  final DeviceState esp2 = DeviceState();

  String _ip = AppConstants.defaultEspIp;
  int _port = AppConstants.defaultEspPort;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _statusMessage;

  // Display copies — updated on every frame.
  List<int> flex1 = List<int>.filled(5, 0);
  Map<String, int> imu1 = {'ax': 0, 'ay': 0, 'az': 0, 'gx': 0, 'gy': 0, 'gz': 0};
  Map<String, int> ypr1 = {'yaw': 0, 'pitch': 0, 'roll': 0};
  List<int> flex2 = List<int>.filled(5, 0);
  Map<String, int> imu2 = {'ax': 0, 'ay': 0, 'az': 0, 'gx': 0, 'gy': 0, 'gz': 0};
  Map<String, int> ypr2 = {'yaw': 0, 'pitch': 0, 'roll': 0};
  bool esp1Connected = false;
  bool esp2Connected = false;

  /// External frame listeners (recording, translation, etc.)
  final List<void Function(int timestampMs)> _frameListeners = [];

  /// External status listeners — called once per status change for UI feedback.
  final List<void Function(ConnectionStatus status, String? message)>
      _statusListeners = [];

  String get ip => _ip;
  int get port => _port;
  bool get isConnected => _status == ConnectionStatus.connected;
  bool get isConnecting => _status == ConnectionStatus.connecting;
  ConnectionStatus get status => _status;
  String? get statusMessage => _statusMessage;

  set ip(String value) {
    _ip = value;
    notifyListeners();
  }

  set port(int value) {
    _port = value;
    notifyListeners();
  }

  void addFrameListener(void Function(int timestampMs) listener) {
    _frameListeners.add(listener);
  }

  void removeFrameListener(void Function(int timestampMs) listener) {
    _frameListeners.remove(listener);
  }

  void addStatusListener(
      void Function(ConnectionStatus status, String? message) listener) {
    _statusListeners.add(listener);
  }

  void removeStatusListener(
      void Function(ConnectionStatus status, String? message) listener) {
    _statusListeners.remove(listener);
  }

  void _setStatus(ConnectionStatus status, [String? message]) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
    for (final listener in _statusListeners) {
      listener(status, message);
    }
  }

  void connect() {
    _setStatus(ConnectionStatus.connecting, 'Connexion a $_ip:$_port...');

    _ws.connect(
      ip: _ip,
      port: _port,
      onJson: _handleJson,
      onBinary: _handleBinary,
      onConnectionChanged: (connected) {
        if (connected) {
          _setStatus(ConnectionStatus.connected, 'Connecte a $_ip:$_port');
        } else {
          // Only show timeout message if we were connecting (not if data stops)
          final msg = _status == ConnectionStatus.connecting
              ? 'Echec: aucune reponse de $_ip:$_port (timeout)'
              : 'Connexion perdue avec $_ip:$_port';
          _setStatus(ConnectionStatus.disconnected, msg);
        }
      },
      onError: (error) {
        _setStatus(ConnectionStatus.disconnected,
            'Erreur de connexion: $error');
      },
    );
  }

  void disconnect() {
    _ws.disconnect();
    _setStatus(ConnectionStatus.disconnected, 'Deconnecte');
  }

  // ── Private handlers ──

  void _handleJson(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;

      if (json.containsKey('esp1')) {
        final d = json['esp1'];
        flex1 = List<int>.from(d['flex']);
        imu1 = Map<String, int>.from(d['imu']);
        if (d.containsKey('ypr')) ypr1 = Map<String, int>.from(d['ypr']);
        esp1Connected = d['connected'] ?? true;
      }

      if (json.containsKey('esp2')) {
        final d = json['esp2'];
        flex2 = List<int>.from(d['flex']);
        imu2 = Map<String, int>.from(d['imu']);
        if (d.containsKey('ypr')) ypr2 = Map<String, int>.from(d['ypr']);
        esp2Connected = d['connected'] ?? true;
      }
    } catch (_) {
      return;
    }

    final ts = DateTime.now().millisecondsSinceEpoch;
    _notifyFrame(ts);
    notifyListeners();
  }

  void _handleBinary(Uint8List data) {
    final result = _parser.parse(data, esp1, esp2);
    if (!result.success) return;

    flex1 = esp1.flex;
    imu1 = esp1.imu;
    ypr1 = esp1.ypr;
    flex2 = esp2.flex;
    imu2 = esp2.imu;
    ypr2 = esp2.ypr;
    esp1Connected = esp1.isRecent();
    esp2Connected = esp2.isRecent();

    _notifyFrame(result.timestamp);
    notifyListeners();
  }

  void _notifyFrame(int timestampMs) {
    for (final listener in _frameListeners) {
      listener(timestampMs);
    }
  }

  Map<String, dynamic> buildHandData(
      List<int> flex, Map<String, int> imu, Map<String, int> ypr) {
    return {
      'gyro': {
        'x': (imu['gx'] ?? 0).toDouble(),
        'y': (imu['gy'] ?? 0).toDouble(),
        'z': (imu['gz'] ?? 0).toDouble(),
      },
      'accel': {
        'x': (imu['ax'] ?? 0).toDouble(),
        'y': (imu['ay'] ?? 0).toDouble(),
        'z': (imu['az'] ?? 0).toDouble(),
      },
      'euler': {
        'yaw': (ypr['yaw'] ?? 0) / 100.0,
        'pitch': (ypr['pitch'] ?? 0) / 100.0,
        'roll': (ypr['roll'] ?? 0) / 100.0,
      },
      'flex_sensors': List<int>.from(flex),
    };
  }

  Map<String, dynamic> buildCurrentFrame(int timestampMs) {
    return {
      'timestamp_ms': timestampMs,
      'left_hand': buildHandData(flex1, imu1, ypr1),
      'right_hand': buildHandData(flex2, imu2, ypr2),
    };
  }

  @override
  void dispose() {
    _ws.disconnect();
    super.dispose();
  }
}
