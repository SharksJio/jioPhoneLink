import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/connection_service.dart';
import '../services/device_info_service.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectionService _connectionService = ConnectionService();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final SmsService _smsService = SmsService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestPermissions();
    await _notificationService.initialize();
    await _smsService.initialize();
    _deviceInfoService.startMonitoring();
    
    setState(() => _isInitialized = true);
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.notification,
      Permission.sms,
      Permission.phone,
      Permission.storage,
    ].request();
  }

  @override
  void dispose() {
    _deviceInfoService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jio Phone Link'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildSyncCard('Notifications', Icons.notifications, () {
                  // Trigger notification sync
                }),
                const SizedBox(height: 12),
                _buildSyncCard('Messages', Icons.message, () {
                  _smsService.syncMessages();
                }),
                const SizedBox(height: 12),
                _buildSyncCard('Call Logs', Icons.phone, () {
                  // Trigger call log sync
                }),
                const SizedBox(height: 12),
                _buildSyncCard('Files', Icons.folder, () {
                  // Trigger file sharing
                }),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _connectionService.disconnect();
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed('/pairing');
                  },
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Connected to Tablet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Your phone is connected and syncing data with your tablet.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text('Sync now'),
        trailing: const Icon(Icons.sync),
        onTap: onTap,
      ),
    );
  }
}
