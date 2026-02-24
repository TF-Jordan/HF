import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Callback signatures for WebSocket events.
typedef OnJsonData = void Function(String data);
typedef OnBinaryData = void Function(Uint8List data);
typedef OnConnectionChanged = void Function(bool connected);
typedef OnError = void Function(String error);

/// Manages the WebSocket connection to the ESP32 master device.
///
/// Connection status is only set to `true` when real data is received,
/// not just when the socket opens. A timeout fires if no data arrives
/// within [_connectTimeoutMs] after opening.
class WebSocketService {
  static const int _connectTimeoutMs = 5000;
  static const int _dataTimeoutMs = 3000;

  WebSocketChannel? _channel;
  bool _connected = false;
  Timer? _connectTimer;
  Timer? _dataTimer;
  OnConnectionChanged? _onConnectionChanged;
  OnError? _onError;

  bool get isConnected => _connected;

  /// Connect to the ESP32 at the given IP address.
  void connect({
    required String ip,
    int port = 81,
    required OnJsonData onJson,
    required OnBinaryData onBinary,
    required OnConnectionChanged onConnectionChanged,
    OnError? onError,
  }) {
    disconnect();
    _onConnectionChanged = onConnectionChanged;
    _onError = onError;

    try {
      final uri = Uri.parse('ws://$ip:$port');
      _channel = WebSocketChannel.connect(uri);

      // Do NOT set _connected = true here.
      // Wait for actual data before confirming connection.

      // Start a timeout: if no data arrives within the timeout, mark as failed.
      _connectTimer?.cancel();
      _connectTimer = Timer(
        const Duration(milliseconds: _connectTimeoutMs),
        () {
          if (!_connected) {
            // No data received within timeout — connection failed.
            disconnect();
            onConnectionChanged(false);
          }
        },
      );

      _channel!.stream.listen(
        (data) {
          // First data received — NOW we are truly connected.
          if (!_connected) {
            _connected = true;
            _connectTimer?.cancel();
            onConnectionChanged(true);
          }

          // Reset the data timeout (heartbeat).
          _resetDataTimer(onConnectionChanged);

          if (data is String) {
            onJson(data);
          } else if (data is Uint8List) {
            onBinary(data);
          }
        },
        onError: (error) {
          _onError?.call(error.toString());
          _setDisconnected();
        },
        onDone: () {
          _setDisconnected();
        },
      );
    } catch (e) {
      _connected = false;
      final msg = e.toString();
      onError?.call(msg);
      onConnectionChanged(false);
    }
  }

  /// Reset the data timeout timer. If no data arrives for [_dataTimeoutMs],
  /// the connection is considered lost.
  void _resetDataTimer(OnConnectionChanged onConnectionChanged) {
    _dataTimer?.cancel();
    _dataTimer = Timer(
      const Duration(milliseconds: _dataTimeoutMs),
      () {
        if (_connected) {
          _setDisconnected();
        }
      },
    );
  }

  void _setDisconnected() {
    final wasConnected = _connected;
    _connected = false;
    _connectTimer?.cancel();
    _dataTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    if (wasConnected) {
      _onConnectionChanged?.call(false);
    }
  }

  /// Close the current connection.
  void disconnect() {
    _connectTimer?.cancel();
    _dataTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }
}
