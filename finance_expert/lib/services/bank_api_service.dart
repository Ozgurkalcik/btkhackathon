import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/bank_config.dart';
import '../models/account.dart';
import '../models/transaction.dart';

/// Banka API provider'ı için abstract interface
///
/// Her banka için concrete sınıf bu interface'i implemente edecek.
/// API key'ler [BankRegistry] üzerinden konfigüre edilir.
abstract class BankApiProvider {
  final BankApiConfig config;

  BankApiProvider(this.config);

  /// Hesap listesini çek
  Future<List<Account>> fetchAccounts();

  /// Belirli bir hesabın işlem geçmişini çek
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Toplam bakiyeyi çek
  Future<double> fetchTotalBalance();

  /// Bağlantı sağlığını kontrol et
  Future<bool> testConnection();

  /// Standart HTTP GET isteği (tüm provider'lar kullanabilir)
  Future<Map<String, dynamic>> apiGet(String endpoint) async {
    if (!config.isReady) {
      throw BankApiException(
        bankId: config.id,
        message: '${config.name} API yapılandırması eksik. Lütfen API anahtarınızı ekleyin.',
      );
    }

    final url = Uri.parse('${config.baseUrl}$endpoint');
    final headers = _buildHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw BankApiException(
          bankId: config.id,
          message: '${config.name} API yetkilendirme hatası. API anahtarınızı kontrol edin.',
          statusCode: 401,
        );
      } else {
        throw BankApiException(
          bankId: config.id,
          message: '${config.name} API hatası: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is BankApiException) rethrow;
      throw BankApiException(
        bankId: config.id,
        message: '${config.name} bağlantı hatası: $e',
      );
    }
  }

  /// Standart HTTP POST isteği
  Future<Map<String, dynamic>> apiPost(String endpoint, Map<String, dynamic> body) async {
    if (!config.isReady) {
      throw BankApiException(
        bankId: config.id,
        message: '${config.name} API yapılandırması eksik.',
      );
    }

    final url = Uri.parse('${config.baseUrl}$endpoint');
    final headers = _buildHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw BankApiException(
          bankId: config.id,
          message: '${config.name} API hatası: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is BankApiException) rethrow;
      throw BankApiException(
        bankId: config.id,
        message: '${config.name} bağlantı hatası: $e',
      );
    }
  }

  /// API istekleri için header'ları oluştur
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (config.hasApiKey) {
      headers['Authorization'] = 'Bearer ${config.apiKey}';
    }

    if (config.hasCredentials) {
      headers['X-Client-Id'] = config.clientId!;
      headers['X-Client-Secret'] = config.clientSecret!;
    }

    return headers;
  }
}

// ══════════════════════════════════════════════════════════════════
//  BANKA PROVIDER İMPLEMENTASYONLARI
//  API key'lerinizi ekledikten sonra ilgili bankanın
//  fetch metodlarını doldurmanız gerekecek.
// ══════════════════════════════════════════════════════════════════

/// Ziraat Bankası API Provider
class ZiraatBankProvider extends BankApiProvider {
  ZiraatBankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async {
    // TODO: Ziraat API endpoint'i ile hesapları çek
    // Örnek: final data = await apiGet('/accounts');
    return [];
  }

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Ziraat API endpoint'i ile işlemleri çek
    return [];
  }

  @override
  Future<double> fetchTotalBalance() async {
    // TODO: Toplam bakiye hesapla
    return 0.0;
  }

  @override
  Future<bool> testConnection() async {
    // TODO: API bağlantı testi
    return false;
  }
}

/// VakıfBank API Provider
class VakifbankProvider extends BankApiProvider {
  VakifbankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async {
    // TODO: VakıfBank API implementasyonu
    return [];
  }

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return [];
  }

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

/// Garanti BBVA API Provider
class GarantiBankProvider extends BankApiProvider {
  GarantiBankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async {
    // TODO: Garanti BBVA API implementasyonu
    return [];
  }

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return [];
  }

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

/// İş Bankası API Provider
class IsbankProvider extends BankApiProvider {
  IsbankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async => [];

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      [];

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

/// Akbank API Provider
class AkbankProvider extends BankApiProvider {
  AkbankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async => [];

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      [];

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

/// Yapı Kredi API Provider
class YapikrediProvider extends BankApiProvider {
  YapikrediProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async => [];

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      [];

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

/// Genel / Henüz implemente edilmemiş banka provider'ı
class GenericBankProvider extends BankApiProvider {
  GenericBankProvider(super.config);

  @override
  Future<List<Account>> fetchAccounts() async => [];

  @override
  Future<List<Transaction>> fetchTransactions({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      [];

  @override
  Future<double> fetchTotalBalance() async => 0.0;

  @override
  Future<bool> testConnection() async => false;
}

// ══════════════════════════════════════════════════════════════════
//  FACTORY & HATA YÖNETİMİ
// ══════════════════════════════════════════════════════════════════

/// Banka ID'sine göre doğru provider'ı oluşturur
class BankProviderFactory {
  static BankApiProvider create(BankApiConfig config) {
    switch (config.id) {
      case 'ziraat':
        return ZiraatBankProvider(config);
      case 'vakifbank':
        return VakifbankProvider(config);
      case 'garanti':
        return GarantiBankProvider(config);
      case 'isbank':
        return IsbankProvider(config);
      case 'akbank':
        return AkbankProvider(config);
      case 'yapikredi':
        return YapikrediProvider(config);
      default:
        return GenericBankProvider(config);
    }
  }
}

/// Banka API hata sınıfı
class BankApiException implements Exception {
  final String bankId;
  final String message;
  final int? statusCode;

  BankApiException({
    required this.bankId,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'BankApiException[$bankId]: $message (HTTP $statusCode)';
}
