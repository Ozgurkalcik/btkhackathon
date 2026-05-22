import 'package:flutter_test/flutter_test.dart';
import 'package:finance_expert/core/security/totp_service.dart';

void main() {
  group('TotpService Tests', () {
    test('generateSecret produces valid Base32 secret', () {
      final secret = TotpService.generateSecret();
      expect(secret.length, equals(16));
      
      // Base32 characters only
      final base32Regex = RegExp(r'^[A-Z2-7]+$');
      expect(base32Regex.hasMatch(secret), isTrue);
    });

    test('generateCode produces a 6-digit numeric string', () {
      final secret = TotpService.generateSecret();
      final code = TotpService.generateCode(secret);
      
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('verifyCode validates a correct code within window', () {
      final secret = TotpService.generateSecret();
      final code = TotpService.generateCode(secret);
      
      final isValid = TotpService.verifyCode(secret, code);
      expect(isValid, isTrue);
    });

    test('verifyCode rejects incorrect or invalid length codes', () {
      final secret = TotpService.generateSecret();
      
      expect(TotpService.verifyCode(secret, '12345'), isFalse); // too short
      expect(TotpService.verifyCode(secret, '1234567'), isFalse); // too long
      expect(TotpService.verifyCode(secret, 'abcdef'), isFalse); // non-numeric
      expect(TotpService.verifyCode(secret, '000000'), isFalse); // incorrect
    });

    test('verifyCode tolerates minor clock drift (+/- 30s)', () {
      final secret = TotpService.generateSecret();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Generate code for 30 seconds ago
      final pastCode = TotpService.generateCode(secret, timeMs: now - 30000);
      
      // Verify code with current time (which should fall in the drift window)
      final isValid = TotpService.verifyCode(secret, pastCode);
      expect(isValid, isTrue);
    });
  });
}
