import '../config/bank_config.dart';
import '../models/account.dart';
import '../models/budget_category.dart';
import '../models/transaction.dart';
import 'bank_api_service.dart';

/// Merkezi veri yönetim katmanı
///
/// Tüm banka provider'larını birleştirir ve UI'a tek bir veri kaynağı sunar.
/// Banka API'leri bağlandığında bu sınıf otomatik olarak verileri toplar.
class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  /// Aktif banka provider'ları
  final Map<String, BankApiProvider> _providers = {};

  /// Önbelleklenmiş veriler
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  List<BudgetCategory> _budgetCategories = [];

  bool _isInitialized = false;
  bool _isLoading = false;

  // ═══════════════════════════════════════════════
  //  GETTER'LAR
  // ═══════════════════════════════════════════════

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get hasData => _accounts.isNotEmpty || _transactions.isNotEmpty;
  bool get hasBankConnections => _providers.isNotEmpty;

  List<Account> get accounts => List.unmodifiable(_accounts);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<BudgetCategory> get budgetCategories => List.unmodifiable(_budgetCategories);

  /// Toplam bakiye (tüm hesaplar)
  double get totalBalance =>
      _accounts.fold(0.0, (sum, acc) => sum + acc.balance);

  /// Toplam gelir (mevcut ay)
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Toplam gider (mevcut ay)
  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Bağlı banka sayısı
  int get connectedBankCount => _providers.length;

  /// Bağlı banka isimleri
  List<String> get connectedBankNames =>
      _providers.values.map((p) => p.config.name).toList();

  // ═══════════════════════════════════════════════
  //  BAŞLATMA & SENKRONIZASYON
  // ═══════════════════════════════════════════════

  /// Repository'yi başlat ve aktif bankaları kaydet
  Future<void> initialize() async {
    if (_isInitialized) return;

    final activeBanks = BankRegistry.activeBanks;
    for (final bankConfig in activeBanks) {
      final provider = BankProviderFactory.create(bankConfig);
      _providers[bankConfig.id] = provider;
    }

    _isInitialized = true;

    if (_providers.isNotEmpty) {
      await syncAll();
    }
  }

  /// Tüm banka verilerini senkronize et
  Future<void> syncAll() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final allAccounts = <Account>[];
      final allTransactions = <Transaction>[];

      for (final provider in _providers.values) {
        try {
          final accounts = await provider.fetchAccounts();
          allAccounts.addAll(accounts);

          for (final account in accounts) {
            final txns = await provider.fetchTransactions(
              accountId: account.id,
            );
            allTransactions.addAll(txns);
          }
        } catch (e) {
          // Tek bir banka hatası diğerlerini etkilemez
          // ignore: avoid_print
          print('Banka senkronizasyon hatası (${provider.config.name}): $e');
        }
      }

      _accounts = allAccounts;
      _transactions = allTransactions
        ..sort((a, b) => b.date.compareTo(a.date)); // En yeniden eskiye
    } finally {
      _isLoading = false;
    }
  }

  /// Belirli bir bankayı senkronize et
  Future<void> syncBank(String bankId) async {
    final provider = _providers[bankId];
    if (provider == null) return;

    try {
      final accounts = await provider.fetchAccounts();

      // Bu bankaya ait eski hesapları kaldır
      _accounts.removeWhere((a) => a.bankId == bankId);
      _accounts.addAll(accounts);

      // Bu bankaya ait eski işlemleri kaldır ve yenilerini ekle
      _transactions.removeWhere((t) => t.bankSource == bankId);
      for (final account in accounts) {
        final txns = await provider.fetchTransactions(accountId: account.id);
        _transactions.addAll(txns);
      }

      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Banka senkronizasyon hatası ($bankId): $e');
    }
  }

  // ═══════════════════════════════════════════════
  //  VERİ ERİŞİM METODLARı
  // ═══════════════════════════════════════════════

  /// Son N işlemi getir
  List<Transaction> getRecentTransactions({int count = 5}) {
    if (_transactions.isEmpty) return [];
    return _transactions.take(count).toList();
  }

  /// Kategoriye göre işlemleri filtrele
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  /// Bankaya göre işlemleri filtrele
  List<Transaction> getTransactionsByBank(String bankId) {
    return _transactions.where((t) => t.bankSource == bankId).toList();
  }

  /// Tarih aralığına göre işlemleri filtrele
  List<Transaction> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  /// Kategori bazlı harcama dağılımı
  Map<String, double> getCategoryBreakdown() {
    final breakdown = <String, double>{};
    for (final txn in _transactions) {
      if (txn.type == TransactionType.expense) {
        breakdown[txn.category] =
            (breakdown[txn.category] ?? 0) + txn.amount;
      }
    }
    return breakdown;
  }

  /// Bütçe kategorilerini güncelle
  void updateBudgetCategories(List<BudgetCategory> categories) {
    _budgetCategories = categories;
  }

  // ═══════════════════════════════════════════════
  //  BANKA BAĞLANTISI YÖNETİMİ
  // ═══════════════════════════════════════════════

  /// Yeni bir banka bağlantısı ekle
  void addBankConnection(BankApiConfig config) {
    final provider = BankProviderFactory.create(config);
    _providers[config.id] = provider;
  }

  /// Banka bağlantısını kaldır
  void removeBankConnection(String bankId) {
    _providers.remove(bankId);
    _accounts.removeWhere((a) => a.bankId == bankId);
    _transactions.removeWhere((t) => t.bankSource == bankId);
  }

  /// Banka bağlantısını test et
  Future<bool> testBankConnection(String bankId) async {
    final provider = _providers[bankId];
    if (provider == null) return false;
    return provider.testConnection();
  }

  /// Tüm verileri temizle
  void clearAll() {
    _accounts.clear();
    _transactions.clear();
    _budgetCategories.clear();
    _providers.clear();
    _isInitialized = false;
  }
}
