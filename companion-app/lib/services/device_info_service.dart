import 'package:battery_plus/battery_plus.dart';
import 'connection_service.dart';
import 'dart:async';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final Battery _battery = Battery();
  final ConnectionService _connectionService = ConnectionService();
  Timer? _updateTimer;

  void startMonitoring() {
    // Ensure only one timer is active
    stopMonitoring();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendDeviceInfo();
    });
    _sendDeviceInfo();
  }

  void stopMonitoring() {
    _updateTimer?.cancel();
  }

  Future<void> _sendDeviceInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      await _connectionService.sendMessage({
        'type': 'device_info',
        'data': {
          'battery': {
            'level': batteryLevel,
            'state': batteryState.toString(),
          },
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      print('Error sending device info: $e');
    }
  }
}
