import 'package:flutter_test/flutter_test.dart';
import 'package:jio_companion/services/connection_service.dart';

void main() {
  group('ConnectionService Tests', () {
    late ConnectionService connectionService;

    setUp(() {
      connectionService = ConnectionService();
    });

    test('ConnectionService is a singleton', () {
      final instance1 = ConnectionService();
      final instance2 = ConnectionService();
      expect(instance1, equals(instance2));
    });

    test('isConnected returns false initially', () async {
      final isConnected = await connectionService.isConnected();
      expect(isConnected, isFalse);
    });

    test('sendMessage handles null channel gracefully', () async {
      // Should not throw even if channel is null
      expect(
        () async => await connectionService.sendMessage({'test': 'data'}),
        returnsNormally,
      );
    });
  });
}
