import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Google Authenticator / Authy ile uyumlu TOTP (Time-based One-Time Password) Servisi
class TotpService {
  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Base32 kod çözücü (şifrelenmiş gizli anahtarı byte dizisine çevirir)
  static Uint8List _base32Decode(String input) {
    input = input.toUpperCase().replaceAll('=', '');
    int bitBuffer = 0;
    int valBuffer = 0;
    final List<int> bytes = [];

    for (int i = 0; i < input.length; i++) {
      final int charVal = _base32Chars.indexOf(input[i]);
      if (charVal == -1) {
        continue; // Geçersiz karakterleri atla
      }

      valBuffer = (valBuffer << 5) | charVal;
      bitBuffer += 5;

      if (bitBuffer >= 8) {
        bytes.add((valBuffer >> (bitBuffer - 8)) & 0xFF);
        bitBuffer -= 8;
      }
    }
    return Uint8List.fromList(bytes);
  }

  /// Belirli bir zaman dilimi için TOTP kodu üret
  static String generateCode(String secret, {int? timeMs}) {
    final key = _base32Decode(secret);
    final int time = (timeMs ?? DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    final int counter = time ~/ 30;

    // Counter değerini 8-byte big-endian formatına çevir
    final Uint8List counterBytes = Uint8List(8);
    int temp = counter;
    for (int i = 7; i >= 0; i--) {
      counterBytes[i] = temp & 0xFF;
      temp >>= 8;
    }

    // HMAC-SHA1 Hesapla
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(counterBytes);
    final bytes = digest.bytes;

    // Dinamik kesme (Dynamic Truncation)
    final int offset = bytes[bytes.length - 1] & 0x0F;
    final int binary = ((bytes[offset] & 0x7F) << 24) |
                       ((bytes[offset + 1] & 0xFF) << 16) |
                       ((bytes[offset + 2] & 0xFF) << 8) |
                       (bytes[offset + 3] & 0xFF);

    final int code = binary % 1000000;
    return code.toString().padLeft(6, '0');
  }

  /// Girilen 2FA kodunun geçerliliğini doğrula (+/- 30 saniye tolerans ile)
  static bool verifyCode(String secret, String code) {
    if (code.length != 6) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    // Saat sapmalarını (clock drift) önlemek için -30, 0, +30 saniyelik pencereleri kontrol et
    for (int i = -1; i <= 1; i++) {
      final calculated = generateCode(secret, timeMs: now + (i * 30000));
      if (calculated == code) {
        return true;
      }
    }
    return false;
  }

  /// Rastgele Google Authenticator uyumlu gizli anahtar (Secret Key) üret
  static String generateSecret() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(32));
    return bytes.map((b) => _base32Chars[b]).join();
  }
}
