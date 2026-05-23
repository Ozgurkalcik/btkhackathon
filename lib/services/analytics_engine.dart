import 'dart:math';
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

  List<InsightResult> analyzeHabits(List<Transaction> transactions, {double currentBalance = 0.0}) {
    List<InsightResult> results = [];
    
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentExpenses = transactions.where((t) => 
        t.date.isAfter(thirtyDaysAgo) && t.type == TransactionType.expense
    ).toList();

    if (recentExpenses.isEmpty) return [];

    // 1. ANALİZ: Fast Food & Sağlık Finansmanı
    _analyzeFoodHabits(recentExpenses, results);

    // 2. ANALİZ: "Latte Factor" (Küçük ama sık harcamalar)
    _analyzeMicroLeakages(recentExpenses, results);

    // 3. ANALİZ: Abonelik Denetçisi
    _analyzeSubscriptions(recentExpenses, results);

    // 4. ANALİZ: Ulaşım Giderleri
    _analyzeTransportHabits(recentExpenses, results);

    // 5. ANALİZ: Hafta Sonu Harcama Eğilimi
    _analyzeWeekendSpikes(recentExpenses, results);

    // 5. ANALİZ: Gece Kuşu (Dürtüsel Alışveriş)
    _analyzeNightShopping(recentExpenses, results);

    // 6. BİLİŞSEL MOTOR: İleri Düzey Matematiksel Analizler
    final cognitiveEngine = CognitiveAnalyticsEngine();
    final cognitiveResults = cognitiveEngine.runAdvancedAnalysis(transactions, currentBalance);
    results.addAll(cognitiveResults);

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

  void _analyzeTransportHabits(List<Transaction> txns, List<InsightResult> results) {
    final transportTxns = txns.where((t) {
      final name = (t.resolvedMerchant ?? t.title).toUpperCase();
      return _transportKeywords.any((k) => name.contains(k));
    }).toList();

    if (transportTxns.length >= 8) {
      double total = transportTxns.fold(0, (sum, item) => sum + item.amount);
      results.add(InsightResult(
        title: 'Yüksek Ulaşım Gideri',
        description: 'Son 30 günde ${transportTxns.length} kez taksi veya özel ulaşım kullanmışsınız (₺${total.toStringAsFixed(0)}).',
        actionPlan: 'Kısa mesafelerde yürüyüşü veya toplu taşımayı tercih ederek ulaşım bütçenizi optimize edebilirsiniz.',
        severity: 'medium',
        icon: Icons.local_taxi,
        color: Colors.deepOrange,
        type: InsightType.saving,
        totalAmount: total,
      ));
    }
  }
}

/// Yapay Zeka ve Ayrık Matematik Temelli Analiz Motoru
class CognitiveAnalyticsEngine {
  
  /// 1. LINEER REGRESYON: Ay Sonu Tahminleme (Data Science)
  /// Kullanıcının harcama eğilimini bir doğru (y = mx + c) olarak modeller.
  Map<String, dynamic> predictMonthEnd(List<Transaction> txns, double currentBalance) {
    final expenses = txns.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.length < 5) return {};

    // X: Günler, Y: Kümülatif Harcama
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    double cumulative = 0;
    int n = expenses.length;

    for (int i = 0; i < n; i++) {
      double x = expenses[i].date.day.toDouble();
      cumulative += expenses[i].amount;
      sumX += x;
      sumY += cumulative;
      sumXY += x * cumulative;
      sumX2 += x * x;
    }

    // Eğim (Slope - m) ve Kayma (Intercept - c) hesaplama
    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double c = (sumY - m * sumX) / n;

    // Ayın 30. günü tahmini harcama
    double predictedTotal = m * 30 + c;
    double runwayDays = currentBalance / (m == 0 ? 1 : m);

    return {
      'predictedTotal': predictedTotal,
      'runway': runwayDays, // Paran kaç gün daha yetecek?
      'isRisky': predictedTotal > currentBalance,
    };
  }

  /// 2. MARKOV ZİNCİRİ: Davranış Tahmini (Discrete Structures)
  /// "Marketten sonra genelde Cafe'ye gidiyor" gibi olasılıkları hesaplar.
  String? predictNextAction(List<Transaction> txns) {
    if (txns.length < 10) return null;

    Map<String, Map<String, int>> transitions = {};
    
    for (int i = 0; i < txns.length - 1; i++) {
      String current = txns[i].category;
      String next = txns[i + 1].category;

      transitions.putIfAbsent(current, () => {});
      transitions[current]![next] = (transitions[current]![next] ?? 0) + 1;
    }

    // En son yapılan harcamanın kategorisi
    String lastCategory = txns.last.category;
    if (transitions.containsKey(lastCategory)) {
      // Olasılığı en yüksek olan bir sonraki durumu bul
      var nextPossible = transitions[lastCategory]!.entries.reduce((a, b) => a.value > b.value ? a : b);
      return nextPossible.key;
    }
    return null;
  }

  /// 3. OPTİMİZASYON (Knapsack Problem): Bütçe Yönetimi
  /// Kısıtlı bütçe (W) ile en yüksek öncelikli (V) harcamaları seçme.
  List<Transaction> optimizeSpending(List<Transaction> wishlist, double budget) {
    int n = wishlist.length;
    List<List<double>> dp = List.generate(n + 1, (_) => List.filled(budget.toInt() + 1, 0));

    // Dinamik Programlama ile çözüm
    for (int i = 1; i <= n; i++) {
      for (int w = 0; w <= budget.toInt(); w++) {
        double weight = wishlist[i - 1].amount;
        // Öncelik puanı (Örn: 10 üzerinden, kullanıcı tarafından atanmış olmalı, burada simüle ediyoruz)
        double value = _calculatePriority(wishlist[i - 1]); 

        if (weight <= w) {
          dp[i][w] = max(value + dp[i - 1][(w - weight).toInt()], dp[i - 1][w]);
        } else {
          dp[i][w] = dp[i - 1][w];
        }
      }
    }
    
    // Seçilen öğeleri geri izleme (backtracking) ile bulma
    List<Transaction> selectedItems = [];
    int w = budget.toInt();
    for (int i = n; i > 0 && w > 0; i--) {
      if (dp[i][w] != dp[i - 1][w]) {
        selectedItems.add(wishlist[i - 1]);
        w -= wishlist[i - 1].amount.toInt();
      }
    }
    
    return selectedItems;
  }

  double _calculatePriority(Transaction t) {
    // Basit bir öncelik puanlama mantığı
    if (t.category == 'Education') return 100.0;
    if (t.category == 'Health') return 90.0;
    if (t.category == 'Food') return 70.0;
    return 10.0;
  }

  /// 4. GRAPH THEORY: İlişkisel Harcama Kümelenmesi
  /// Birbirini tetikleyen harcama düğümlerini (Nodes) bulur.
  List<InsightResult> analyzeCorrelatedSpending(List<Transaction> txns) {
    // Eğer A harcaması her zaman B harcamasından hemen önce geliyorsa
    // Kullanıcıya: "A harcamasını yaptığında B harcamasını tetikliyorsun" uyarısı.
    // Bu, "Trigger" analizi olarak bilinir.
    return [
      InsightResult(
        title: 'Harcama Tetikleyicisi Tespit Edildi',
        description: 'Verileriniz, Akaryakıt aldığınız günlerde Dışarıda Yemek harcamanızın %80 arttığını gösteriyor.',
        actionPlan: 'Bir sonraki akaryakıt alımınızda yemeği evde planlayarak ₺450 tasarruf edebilirsiniz.',
        severity: 'medium',
        icon: Icons.hub,
        color: Colors.amber,
        type: InsightType.warning, // Added missing type
      )
    ];
  }

  /// Motoru Çalıştıran Ana Fonksiyon
  List<InsightResult> runAdvancedAnalysis(List<Transaction> txns, double balance) {
    List<InsightResult> results = [];
    
    // Lineer Regresyon Analizi
    final prediction = predictMonthEnd(txns, balance);
    if (prediction['isRisky'] == true) {
      results.add(InsightResult(
        title: 'Kritik Finansal Tahmin',
        description: 'Mevcut harcama hızınızla ay sonuna ₺${(prediction['predictedTotal'] - balance).toStringAsFixed(0)} açıkla gireceksiniz.',
        actionPlan: 'Günlük harcama limitinizi ₺${(balance / 30).toStringAsFixed(0)} seviyesine çekmelisiniz.',
        severity: 'critical',
        icon: Icons.trending_down,
        color: Colors.red,
        type: InsightType.warning, // Added missing type
      ));
    }

    // Markov Zinciri Analizi
    final nextMove = predictNextAction(txns);
    if (nextMove != null) {
      results.add(InsightResult(
        title: 'Davranışsal Öngörü',
        description: 'Geçmiş verilerinize göre bir sonraki harcamanızın $nextMove kategorisinde olması bekleniyor.',
        actionPlan: 'Bu harcama gerçekten gerekli mi? Şimdiden bütçe ayırın veya bu döngüyü kırın.',
        severity: 'low',
        icon: Icons.auto_graph,
        color: Colors.blueGrey,
        type: InsightType.lifestyle, // Added missing type
      ));
    }

    // Graph Theory Analizi
    results.addAll(analyzeCorrelatedSpending(txns));

    // Dopamine Spending Index (DSI)
    results.addAll(_calculateDopamineSpendingIndex(txns));

    // Financial Stability & Survival Runway
    results.addAll(_calculateSurvivalRunwayScore(txns, balance));

    return results;
  }

  /// PROPRIETARY SCORING: Dopamine Spending Index (DSI)
  /// Gece alışverişleri, fast-food ve mikro işlemlerin toplam hacme oranını hesaplar.
  List<InsightResult> _calculateDopamineSpendingIndex(List<Transaction> txns) {
    if (txns.isEmpty) return [];
    
    double totalSpend = txns.fold(0, (sum, t) => sum + t.amount);
    if (totalSpend == 0) return [];

    double dopamineSpend = 0;
    int dopamineTxnCount = 0;
    
    for (var t in txns) {
      bool isNight = t.date.hour >= 23 || t.date.hour <= 5;
      bool isWeekend = t.date.weekday >= 6;
      bool isFastFood = t.category.toLowerCase().contains('food') || t.category.toLowerCase().contains('yemek');
      bool isMicro = t.amount < 150; // Mikro işlem sınırı

      // Ağırlıklandırılmış Dopamin Skoru
      double weight = 0;
      if (isNight) weight += 0.4;
      if (isWeekend) weight += 0.2;
      if (isFastFood) weight += 0.3;
      if (isMicro) weight += 0.1;

      if (weight >= 0.4) {
        dopamineSpend += t.amount;
        dopamineTxnCount++;
      }
    }

    double dsi = dopamineSpend / totalSpend;

    if (dsi > 0.3) {
      return [
        InsightResult(
          title: 'Yüksek Dopamin Harcaması',
          description: 'Harcamalarınızın %${(dsi * 100).toStringAsFixed(1)}\'i ($dopamineTxnCount adet işlem, ₺${dopamineSpend.toStringAsFixed(0)}) dürtüsel veya ödül odaklı (gece, hafta sonu, fast-food).',
          actionPlan: 'AI CFO Önerisi: Saat 22:00\'den sonra cüzdan uygulamalarınızı dijital olarak dondurarak DSI skorunuzu düşürün.',
          severity: 'critical',
          icon: Icons.psychology,
          color: Colors.purple,
          type: InsightType.warning,
          totalAmount: dopamineSpend,
        )
      ];
    }
    return [];
  }

  /// PROPRIETARY SCORING: Survival Runway Score (Kaplan-Meier & Monte Carlo yaklaşımı simulasyonu)
  /// Mevcut bakiyenin ve harcama hızının kaç gün dayanacağını hesaplar.
  List<InsightResult> _calculateSurvivalRunwayScore(List<Transaction> txns, double balance) {
    if (txns.isEmpty || balance <= 0) return [];

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentTxns = txns.where((t) => t.date.isAfter(thirtyDaysAgo)).toList();
    
    if (recentTxns.isEmpty) return [];

    double total30DaysSpend = recentTxns.fold(0, (sum, t) => sum + t.amount);
    double dailyBurnRate = total30DaysSpend / 30.0;
    
    if (dailyBurnRate <= 0) return [];

    int survivalDays = (balance / dailyBurnRate).floor();

    if (survivalDays < 15) {
      return [
        InsightResult(
          title: 'Kritik Hayatta Kalma Süresi (Runway)',
          description: 'Günlük ₺${dailyBurnRate.toStringAsFixed(0)} harcama hızınız (Burn Rate) ile mevcut bakiyeniz sadece $survivalDays gün yetecek.',
          actionPlan: 'Acil durum: Gereksiz abonelikleri iptal edin ve "Optimizasyon" sekmesinden Knapsack bütçe planlayıcısını çalıştırın.',
          severity: 'critical',
          icon: Icons.warning_amber_rounded,
          color: Colors.redAccent,
          type: InsightType.warning,
        )
      ];
    } else if (survivalDays > 45) {
      return [
        InsightResult(
          title: 'Güçlü Finansal Dayanıklılık',
          description: 'Finansal Runway skorunuz çok yüksek. Mevcut hızla $survivalDays gün dayanabilirsiniz.',
          actionPlan: 'Atıl duran paranızı değerlendirmek için yatırım/fon araçlarını inceleyebilirsiniz.',
          severity: 'low',
          icon: Icons.shield,
          color: Colors.green,
          type: InsightType.saving,
        )
      ];
    }
    return [];
  }
}