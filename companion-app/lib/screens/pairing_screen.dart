import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/connection_service.dart';
import 'home_screen.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final ConnectionService _connectionService = ConnectionService();
  bool _isConnecting = false;
  bool _hasScanned = false;

  Future<void> _connectToTablet(String address) async {
    if (_isConnecting || _hasScanned) return; // Prevent multiple attempts
    
    setState(() {
      _isConnecting = true;
      _hasScanned = true;
    });

    try {
      await _connectionService.connect(address);
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _hasScanned = false); // Allow retry on error
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair with Tablet'),
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _connectToTablet(barcode.rawValue!);
                          break;
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Scan the QR code displayed on your tablet',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showManualConnectionDialog();
                        },
                        child: const Text('Enter Address Manually'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showManualConnectionDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Tablet Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '192.168.1.100',
            labelText: 'IP Address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _connectToTablet(controller.text);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
