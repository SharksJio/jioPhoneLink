import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'connection_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final ConnectionService _connectionService = ConnectionService();

  Future<void> initialize() async {
    const initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendNotificationToTablet({
    required String title,
    required String body,
    String? packageName,
  }) async {
    await _connectionService.sendMessage({
      'type': 'notification',
      'data': {
        'title': title,
        'body': body,
        'packageName': packageName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }
}
