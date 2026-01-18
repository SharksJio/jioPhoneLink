import 'package:telephony/telephony.dart';
import 'connection_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final Telephony _telephony = Telephony.instance;
  final ConnectionService _connectionService = ConnectionService();

  Future<void> initialize() async {
    final hasPermission = await Permission.sms.isGranted;
    if (!hasPermission) {
      await Permission.sms.request();
    }
  }

  Future<void> syncMessages() async {
    try {
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      );

      final messageList = messages.map((msg) => {
        'address': msg.address,
        'body': msg.body,
        'date': msg.date != null 
            ? DateTime.fromMillisecondsSinceEpoch(msg.date!).toIso8601String()
            : DateTime.now().toIso8601String(),
      }).toList();

      await _connectionService.sendMessage({
        'type': 'sms_sync',
        'data': {
          'messages': messageList,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      print('Error syncing messages: $e');
    }
  }
}
