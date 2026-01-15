import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'connection_service.dart';
import 'dart:convert';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ConnectionService _connectionService = ConnectionService();

  Future<void> pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        int fileSize = await file.length();

        // For demonstration - in production, you'd want to chunk large files
        if (fileSize < 10 * 1024 * 1024) { // 10MB limit
          List<int> fileBytes = await file.readAsBytes();
          String base64File = base64Encode(fileBytes);

          await _connectionService.sendMessage({
            'type': 'file_transfer',
            'data': {
              'fileName': fileName,
              'fileSize': fileSize,
              'fileData': base64File,
              'timestamp': DateTime.now().toIso8601String(),
            },
          });
        } else {
          throw Exception('File too large. Maximum size is 10MB.');
        }
      }
    } catch (e) {
      print('Error sending file: $e');
      rethrow;
    }
  }

  Future<void> receiveFile(String fileName, String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      print('File saved: ${file.path}');
    } catch (e) {
      print('Error receiving file: $e');
      rethrow;
    }
  }
}
