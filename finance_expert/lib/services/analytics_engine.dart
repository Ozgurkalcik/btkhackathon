import 'package:flutter/material.dart';
import '../models/transaction.dart'; // TransactionType: income, expense içerdiği varsayılmıştır.

enum InsightType { health, saving, warning, lifestyle, success }

class InsightResult {
  final String title;
  final String description;
  final String actionPlan; // Kullanıcıya ne yapması gerektiğini söyleyen kısım
  final String severity; // "low", "medium", "high", "critical"
  final IconData icon;
  final Color color;
  final InsightType type;
  final double totalAmount;

  InsightResult({
    required this.title,
    required this.description,
    required this.actionPlan,
    required this.severity,
    required this.icon,
    required this.color,
    required this.type,
    this.totalAmount = 0.0,
  });
}

class AnalyticsEngine {
  static const List<String> _fastFoodKeywords = [
    'MCDONALDS', 'BURGER KING', 'KFC', 'POPEYES', 'ARBYS', 'DOMINOS', 'PIZZA', 'SUBWAY', 
    'YEMEKSEPETI', 'GETIRYEMEK', 'TRENDYOL YEMEK', 'TAVUK DUNYASI', 'SBARRO', 'KOMAGENE',
    'DONER', 'DÖNER', 'OSES', 'STARBUCKS', 'KAHVE DUNYASI'
  ];

  static const List<String> _subscriptionKeywords = [
    'NETFLIX', 'SPOTIFY', 'YOUTUBE PREMIUM', 'DISNEY', 'APPLE.COM/BILL', 'GOOGLE STORAGE',
    'AMAZON PRIME', 'EXXEN', 'BLUTV', 'ADOBE', 'CANVA', 'CHATGPT', 'MIDJOURNEY'
  ];

  static const List<String> _transportKeywords = [
    'UBER', 'BITAKSI', 'MARTI', 'BINBIN', 'TAXI', 'PETROL OFISI', 'SHELL', 'OPET'
  ];

  List<InsightResult> analyzeHabits(List<Transaction> transactions) {
    List<InsightResult> results = [];
    
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentExpenses = transactions.where((t) => 
        t.date.isAfter(thirtyDaysAgo) && t.type == TransactionType.expense
    ).toList();

    final totalExpense = recentExpenses.fold(0.0, (sum, item) => sum + item.amount);

    if (recentExpenses.isEmpty) return [];

    // 1. ANALİZ: Fast Food & Sağlık Finansmanı
    _analyzeFoodHabits(recentExpenses, results);

    // 2. ANALİZ: "Latte Factor" (Küçük ama sık harcamalar)
    _analyzeMicroLeakages(recentExpenses, results);

    // 3. ANALİZ: Abonelik Denetçisi
    _analyzeSubscriptions(recentExpenses, results);

    // 4. ANALİZ: Hafta Sonu Harcama Eğilimi
    _analyzeWeekendSpikes(recentExpenses, results);

    // 5. ANALİZ: Gece Kuşu (Dürtüsel Alışveriş)
    _analyzeNightShopping(recentExpenses, results);

    // Başarı Durumu: Eğer kritik uyarı yoksa ve bütçe dengeliyse
    if (results.isEmpty) {
      results.add(InsightResult(
        title: 'Finansal Ustalık',
        description: 'Bu ay harcamalarınız mükemmel bir dengede görünüyor.',
        actionPlan: 'Bu disiplini korumak için birikim hesabınıza otomatik aktarım talimatı verebilirsiniz.',
        severity: 'low',
        icon: Icons.emoji_events,
        color: Colors.green,
        type: InsightType.success,
      ));
    }

    return results;
  }

  void _analyzeFoodHabits(List<Transaction> txns, List<InsightResult> results) {
    final foodTxns = txns.where((t) {
      final name = (t.resolvedMerchant ?? t.title).toUpperCase();
      return _fastFoodKeywords.any((k) => name.contains(k));
    }).toList();

    double total = foodTxns.fold(0, (sum, item) => sum + item.amount);
    
    if (foodTxns.length >= 12) {
      results.add(InsightResult(
        title: 'Mutfak Yerine Restoran',
        description: 'Son 30 günde ${foodTxns.length} kez dışarıdan yemek yemişsiniz (₺${total.toStringAsFixed(0)}).',
        actionPlan: 'Haftalık yemek hazırlığı (Meal Prep) yaparak ayda yaklaşık ₺${(total * 0.6).toStringAsFixed(0)} tasarruf edebilirsiniz.',
        severity: 'high',
        icon: Icons.bakery_dining,
        color: Colors.redAccent,
        type: InsightType.health,
        totalAmount: total,
      ));
    }
  }

  void _analyzeMicroLeakages(List<Transaction> txns, List<InsightResult> results) {
    // 100 TL altı, aynı kategoride çok sık yapılan harcamalar
    Map<String, int> smallSpends = {};
    double smallTotal = 0;

    for (var t in txns) {
      if (t.amount > 0 && t.amount < 150) {
        smallSpends[t.category] = (smallSpends[t.category] ?? 0) + 1;
        smallTotal += t.amount;
      }
    }

    bool hasLeak = smallSpends.values.any((count) => count > 15);
    if (hasLeak) {
      results.add(InsightResult(
        title: 'Küçük Sızıntılar Dağı Deliyor',
        description: 'Küçük meblağlı ( <150 TL) harcamalarınız toplamda ₺${smallTotal.toStringAsFixed(0)} tutmuş.',
        actionPlan: 'Bu harcamalar genellikle fark edilmez. Günlük nakit limit belirleyerek bu "görünmez" giderleri kontrol altına alın.',
        severity: 'medium',
        icon: Icons.plumbing,
        color: Colors.orange,
        type: InsightType.saving,
        totalAmount: smallTotal,
      ));
    }
  }

  void _analyzeSubscriptions(List<Transaction> txns, List<InsightResult> results) {
    final subs = txns.where((t) {
      final name = (t.resolvedMerchant ?? t.title).toUpperCase();
      return _subscriptionKeywords.any((k) => name.contains(k));
    }).toList();

    if (subs.length > 5) {
      double total = subs.fold(0, (sum, item) => sum + item.amount);
      results.add(InsightResult(
        title: 'Abonelik Sarmalı',
        description: 'Aktif olarak ${subs.length} farklı dijital servise ödeme yapıyorsunuz.',
        actionPlan: 'Kullanmadığınız servisleri iptal edin. Yıllık plana geçmek %20 tasarruf sağlayabilir.',
        severity: 'medium',
        icon: Icons.subscriptions,
        color: Colors.blueAccent,
        type: InsightType.saving,
        totalAmount: total,
      ));
    }
  }

  void _analyzeWeekendSpikes(List<Transaction> txns, List<InsightResult> results) {
    double weekendTotal = 0;
    double weekdayTotal = 0;

    for (var t in txns) {
      if (t.date.weekday == DateTime.saturday || t.date.weekday == DateTime.sunday) {
        weekendTotal += t.amount;
      } else {
        weekdayTotal += t.amount;
      }
    }

    // Hafta sonu günlük harcama ortalaması hafta içinden 3 kat fazlaysa
    if (weekendTotal > weekdayTotal) {
      results.add(InsightResult(
        title: 'Hafta Sonu Etkisi',
        description: 'Tüm ay harcamanızın yarısından fazlasını hafta sonlarında yapıyorsunuz.',
        actionPlan: 'Cumartesi günleri için kendinize bir "eğlence bütçesi" limiti koyun ve aşmamaya çalışın.',
        severity: 'medium',
        icon: Icons.weekend,
        color: Colors.purpleAccent,
        type: InsightType.lifestyle,
        totalAmount: weekendTotal,
      ));
    }
  }

  void _analyzeNightShopping(List<Transaction> txns, List<InsightResult> results) {
    final nightTxns = txns.where((t) => t.date.hour >= 23 || t.date.hour <= 5).toList();
    if (nightTxns.length > 4) {
      double total = nightTxns.fold(0, (sum, item) => sum + item.amount);
      results.add(InsightResult(
        title: 'Gece Harcaması Riski',
        description: 'Gece geç saatlerde ${nightTxns.length} adet işlem tespit edildi.',
        actionPlan: 'Gece yapılan alışverişler genellikle daha sonra pişmanlık getirir. Sepete eklediğiniz ürünleri 24 saat bekletme kuralını uygulayın.',
        severity: 'medium',
        icon: Icons.nightlight_round,
        color: Colors.indigo,
        type: InsightType.warning,
        totalAmount: total,
      ));
    }
  }
}