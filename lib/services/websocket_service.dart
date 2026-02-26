import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Callback signatures for WebSocket events.
typedef OnJsonData = void Function(String data);
typedef OnBinaryData = void Function(Uint8List data);
typedef OnConnectionChanged = void Function(bool connected);
typedef OnError = void Function(String error);

/// Manages the WebSocket connection to the ESP32 master device.
///
/// Uses [channel.ready] to verify the TCP + WebSocket handshake before
/// reporting "connected". This prevents the UI from showing a false
/// "Connecte" when the ESP32 is unreachable.
class WebSocketService {
  WebSocketChannel? _channel;
  bool _connected = false;

  /// Session counter — incremented on every connect()/disconnect() to
  /// ignore stale callbacks from a previous channel's onDone/onError.
  int _session = 0;

  bool get isConnected => _connected;

  /// Connect to the ESP32 at the given IP address.
  ///
  /// [onConnectionChanged] is called with `true` only after the WebSocket
  /// handshake completes successfully. If the server is unreachable,
  /// [onError] is called with a user-friendly message instead.
  void connect({
    required String ip,
    int port = 81,
    required OnJsonData onJson,
    required OnBinaryData onBinary,
    required OnConnectionChanged onConnectionChanged,
    OnError? onError,
  }) {
    disconnect();
    final session = ++_session;

    try {
      final uri = Uri.parse('ws://$ip:$port');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          if (session != _session) return;
          if (data is String) {
            onJson(data);
          } else if (data is Uint8List) {
            onBinary(data);
          }
        },
        onError: (error) {
          if (session != _session) return;
          _connected = false;
          onError?.call(_friendlyError(error));
          onConnectionChanged(false);
        },
        onDone: () {
          if (session != _session) return;
          _connected = false;
          onConnectionChanged(false);
        },
      );

      // Wait for the actual TCP + WebSocket handshake to complete
      // before reporting "connected".
      _channel!.ready.timeout(const Duration(seconds: 5)).then((_) {
        if (session != _session) return;
        _connected = true;
        onConnectionChanged(true);
      }).catchError((error) {
        if (session != _session) return;
        _connected = false;
        _channel?.sink.close();
        _channel = null;
        onError?.call(_friendlyError(error));
        onConnectionChanged(false);
      });
    } catch (e) {
      _connected = false;
      onError?.call(e.toString());
      onConnectionChanged(false);
    }
  }

  /// Close the current connection.
  void disconnect() {
    _session++;
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }

  String _friendlyError(dynamic error) {
    final msg = error.toString();
    if (msg.contains('Connection refused')) {
      return 'Connexion refusee — verifiez que l\'ESP32 est allume';
    }
    if (msg.contains('No route to host') ||
        msg.contains('Network is unreachable')) {
      return 'Hote injoignable — verifiez le WiFi du gant';
    }
    if (msg.contains('TimeoutException')) {
      return 'Timeout — aucune reponse (verifiez IP et WiFi)';
    }
    if (msg.contains('Connection timed out')) {
      return 'Timeout — l\'ESP32 ne repond pas';
    }
    if (msg.contains('SocketException')) {
      return 'Erreur reseau — verifiez la connexion WiFi';
    }
    return 'Erreur connexion: $msg';
  }
}
