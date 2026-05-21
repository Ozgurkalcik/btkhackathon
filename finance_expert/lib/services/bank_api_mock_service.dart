import 'dart:math';

/// Ziraat Bankası ve TOBB API'lerini simüle eden sahte veri servisi.
/// Harcamaları şirket isimlerinden yola çıkarak kategorize eder.
class BankApiMockService {
  final Random _random = Random();

  /// TOBB veritabanından şirketlerin sektörlerini simüle eden liste
  final Map<String, String> _companySectors = {
    'ZARA': 'Giyim',
    'H&M': 'Giyim',
    'LC WAIKIKI': 'Giyim',
    'MIGROS': 'Market',
    'CARREFOUR': 'Market',
    'BIM': 'Market',
    'STARBUCKS': 'İçecek',
    'CAFE NERO': 'İçecek',
    'MCDONALDS': 'Yemek',
    'BURGER KING': 'Yemek',
    'NUSRET': 'Yemek',
    'GRATIS': 'Kozmetik',
    'WATSONS': 'Kozmetik',
    'SEPHORA': 'Kozmetik',
    'ECZANE': 'Sağlık',
  };

  /// Rastgele harcamalar üretir
  List<MockTransaction> fetchRecentTransactions(int count) {
    final List<String> companies = _companySectors.keys.toList();
    final List<MockTransaction> transactions = [];

    for (int i = 0; i < count; i++) {
      final company = companies[_random.nextInt(companies.length)];
      final category = _companySectors[company] ?? 'Diğer';
      
      // Harcama tutarını rastgele belirle
      double amount = 50.0 + _random.nextDouble() * 500.0;
      if (category == 'Giyim' || category == 'Kozmetik') {
        amount += 300.0 + _random.nextDouble() * 1000.0; // Giyim ve kozmetik daha pahalı
      }

      transactions.add(MockTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: company,
        category: category,
        amount: amount,
        date: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ));
    }

    // Tarihe göre sırala (en yeniler üstte)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }
}

class MockTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  MockTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  String get formattedAmount => '₺${amount.toStringAsFixed(2)}';
}
