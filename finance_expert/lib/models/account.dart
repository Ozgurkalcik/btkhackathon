/// Banka hesap veri modeli
class Account {
  final String id;
  final String bankId;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final double balance;
  final AccountType type;
  final String currency;
  final DateTime? lastSynced;

  Account({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.balance,
    required this.type,
    this.currency = 'TRY',
    this.lastSynced,
  });

  /// Bakiyeyi formatlanmış TL string'i olarak döndürür
  String get formattedBalance => '₺${balance.toStringAsFixed(2)}';

  /// JSON'dan oluştur
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      bankId: json['bankId'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountName: json['accountName'] as String? ?? '',
      balance: (json['balance'] as num).toDouble(),
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.checking,
      ),
      currency: json['currency'] as String? ?? 'TRY',
      lastSynced: json['lastSynced'] != null
          ? DateTime.parse(json['lastSynced'] as String)
          : null,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankId': bankId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'balance': balance,
      'type': type.name,
      'currency': currency,
      'lastSynced': lastSynced?.toIso8601String(),
    };
  }
}

enum AccountType { checking, savings, credit, investment }
