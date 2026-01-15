import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  WebSocketChannel? _channel;
  String? _tabletAddress;
  bool _isConnected = false;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<bool> isConnected() async {
    final prefs = await SharedPreferences.getInstance();
    _tabletAddress = prefs.getString('tablet_address');
    return _tabletAddress != null && _isConnected;
  }

  Future<void> connect(String address) async {
    try {
      _tabletAddress = address;
      _channel = WebSocketChannel.connect(Uri.parse('ws://$address:8080'));
      
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            _messageController.add(data);
            // Set connected on first successful message
            if (!_isConnected) {
              _isConnected = true;
            }
          } catch (e) {
            print('Error decoding message: $e');
          }
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (error) {
          _isConnected = false;
          print('WebSocket error: $error');
        },
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tablet_address', address);
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Failed to connect to tablet');
    }
  }

  Future<void> sendMessage(Map<String, dynamic> data) async {
    final channel = _channel;
    if (channel != null && _isConnected) {
      try {
        channel.sink.add(jsonEncode(data));
      } catch (e) {
        print('Error sending message: $e');
        _isConnected = false;
      }
    }
  }

  Future<void> disconnect() async {
    _channel?.sink.close();
    _isConnected = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tablet_address');
  }

  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}
