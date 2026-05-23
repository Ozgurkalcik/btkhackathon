import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';
import 'models/account.dart';
import 'presentation/widgets/glass_container.dart';

/// Finansal Hedef Veri Modeli
class FinancialGoal {
  final String title;
  final double targetAmount;
  double currentAmount;
  final IconData icon;

  FinancialGoal({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
}

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> with SingleTickerProviderStateMixin {
  final DataRepository _repo = DataRepository();

  // Simülatör ve Kullanıcı Verileri
  bool _useSimulationMode = false;
  double _simIncome = 40000.0;
  double _simExpense = 28000.0;
  double _simDebtPayment = 6000.0; // Aylık taksitler (kart, kredi vb.)
  double _simEmergencyFund = 50000.0;

  // Harcama Davranışı Kontrol Listesi
  bool _habitImpulse = false;       // Dürtüsel alışveriş
  bool _habitSubscriptions = false; // Plansız abonelikler
  bool _habitLuxury = false;        // Gereksiz lüks tüketim
  bool _habitPaydayLoop = false;    // Maaş günü döngüsü

  // Kredi kartı asgari taksit döngüsü uyarısı
  bool _cardMinimumLoop = false;

  // Finansal Hedefler Listesi
  late List<FinancialGoal> _goals;

  // Aktif Sekme (0: Analiz & Skor, 1: Simülatör & Alışkanlıklar, 2: Finansal Hedefler)
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    // Eğer banka verisi yoksa doğrudan simülasyon modunu aktif et
    _useSimulationMode = !_repo.hasData;
    
    // Varsayılan Hedefleri Başlat
    _goals = [
      FinancialGoal(title: 'Ev Almak (Peşinat)', targetAmount: 500000, currentAmount: 150000, icon: Icons.home),
      FinancialGoal(title: 'Yatırım Sepeti', targetAmount: 150000, currentAmount: 45000, icon: Icons.trending_up),
      FinancialGoal(title: 'Bireysel Emeklilik', targetAmount: 250000, currentAmount: 85000, icon: Icons.savings),
      FinancialGoal(title: 'Eğitim Bütçesi', targetAmount: 80000, currentAmount: 20000, icon: Icons.school),
    ];
  }

  // Dinamik verileri getiren getter'lar
  double get currentIncome => _useSimulationMode ? _simIncome : (_repo.totalIncome > 0 ? _repo.totalIncome : 40000.0);
  double get currentExpense => _useSimulationMode ? _simExpense : (_repo.totalExpense > 0 ? _repo.totalExpense : 28000.0);
  double get currentDebtPayment => _useSimulationMode ? _simDebtPayment : 6000.0;
  
  double get currentEmergencyFund {
    if (_useSimulationMode) return _simEmergencyFund;
    final savings = _repo.accounts.where((a) => a.type == AccountType.savings).fold(0.0, (sum, a) => sum + a.balance);
    return savings > 0 ? savings : 12000.0; // fallback
  }

  /// Finansal Sağlık Skoru ve Metriklerini Dinamik Hesaplayan Motor
  Map<String, dynamic> _calculateHealthScore() {
    final income = currentIncome;
    final expense = currentExpense;
    final debtPayment = currentDebtPayment;
    final emergencyFund = currentEmergencyFund;

    // 1. Gelir-Gider Dengesi (Max 25 Puan)
    final netRemaining = income - expense;
    double balanceScore = 0;
    if (netRemaining > 0) {
      // Gelirin %30'u ve fazlası kalıyorsa tam puan (25)
      balanceScore = ((netRemaining / income) / 0.3) * 25.0;
      balanceScore = balanceScore.clamp(0.0, 25.0);
    }

    // 2. Tasarruf & Birikim Oranı (Max 25 Puan)
    // a. Birikim Oranı (Max 12.5) -> Gelirin %20'si birikime gidiyorsa tam puan
    final savingsRate = income > 0 ? (netRemaining.clamp(0.0, double.infinity) / income) * 100 : 0.0;
    double savingsRateScore = (savingsRate / 20.0) * 12.5;
    savingsRateScore = savingsRateScore.clamp(0.0, 12.5);

    // b. Acil Durum Fonu Gücü (Max 12.5) -> Aylık giderlerin 6 katını karşılıyorsa tam puan
    final efMonths = expense > 0 ? emergencyFund / expense : 0.0;
    double efScore = (efMonths / 6.0) * 12.5;
    efScore = efScore.clamp(0.0, 12.5);
    
    final savingsScore = savingsRateScore + efScore;

    // 3. Borç Yönetimi (Max 20 Puan)
    // Borç / Gelir Oranı (DTI) %20 ve altındaysa tam puan (20)
    // %20 - %50 arası doğrusal düşüş, %50 üzeri ise 0 puan
    final dti = income > 0 ? (debtPayment / income) * 100 : 0.0;
    double debtScore = 20.0;
    if (dti > 20) {
      debtScore = 20.0 - ((dti - 20.0) / 30.0) * 20.0;
      debtScore = debtScore.clamp(0.0, 20.0);
    }
    if (dti > 50) {
      debtScore = 0.0;
    }

    // 4. Harcama Davranışı (Max 15 Puan)
    // Seçilen her kötü davranış alışkanlığı skoru -3.75 puan düşürür
    double behaviorScore = 15.0;
    int badHabitsCount = 0;
    if (_habitImpulse) { behaviorScore -= 3.75; badHabitsCount++; }
    if (_habitSubscriptions) { behaviorScore -= 3.75; badHabitsCount++; }
    if (_habitLuxury) { behaviorScore -= 3.75; badHabitsCount++; }
    if (_habitPaydayLoop) { behaviorScore -= 3.75; badHabitsCount++; }
    behaviorScore = behaviorScore.clamp(0.0, 15.0);

    // 5. Finansal Güvenlik (Max 15 Puan)
    // Acil durum fonu aylık giderlerin en az 3 katı ise (7.5 puan)
    // DTI oranı %35'in altında ise (7.5 puan)
    double securityScore = 0.0;
    if (efMonths >= 3) {
      securityScore += 7.5;
    } else {
      securityScore += (efMonths / 3.0) * 7.5;
    }
    if (dti <= 35) {
      securityScore += 7.5;
    } else if (dti <= 50) {
      securityScore += ((50.0 - dti) / 15.0) * 7.5;
    }
    securityScore = securityScore.clamp(0.0, 15.0);

    // Ek Cezalar: Kredi Kartı Asgari Tutar Sarmalı Cezası (-10 Puan)
    double penalty = 0.0;
    if (_cardMinimumLoop) {
      penalty = 10.0;
    }

    final totalScore = (balanceScore + savingsScore + debtScore + behaviorScore + securityScore - penalty).clamp(0.0, 100.0);

    return {
      'total': totalScore,
      'balanceScore': balanceScore,
      'savingsScore': savingsScore,
      'savingsRate': savingsRate,
      'efMonths': efMonths,
      'debtScore': debtScore,
      'dti': dti,
      'behaviorScore': behaviorScore,
      'badHabitsCount': badHabitsCount,
      'securityScore': securityScore,
      'penalty': penalty,
    };
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final metrics = _calculateHealthScore();
    final double score = metrics['total'];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dinamik Skor Durum Rengi
    Color scoreColor = colorScheme.error;
    String scoreStatus = 'Kritik';
    if (score >= 80) {
      scoreColor = colorScheme.primary;
      scoreStatus = 'Mükemmel';
    } else if (score >= 60) {
      scoreColor = colorScheme.tertiary;
      scoreStatus = 'Sağlıklı';
    } else if (score >= 40) {
      scoreColor = colorScheme.secondary;
      scoreStatus = 'Orta';
    }

    return Scaffold(
      extendBody: true,
      appBar: buildCommonAppBar(context: context, title: 'Finansal Sağlık'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: sizes.sp(20),
          right: sizes.sp(20),
          top: sizes.sp(20),
          bottom: sizes.sp(120),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreGaugeCard(sizes, score, scoreColor, scoreStatus),
            SizedBox(height: sizes.sp(20)),
            _buildTabSelector(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildActiveTabContent(sizes, metrics, scoreColor),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, getSelectedIndexFromRoute(context)),
    );
  }

  /// Premium Gauge Gösterge Kartı
  Widget _buildScoreGaugeCard(AppSizes s, double score, Color scoreColor, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    return HoverGlassContainer(
      borderRadius: 24,
      padding: EdgeInsets.all(s.sp(20)),
      glowColor: scoreColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SAĞLIK ENDEKSİ',
                style: TextStyle(
                  fontSize: s.sp(12),
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Simülatör',
                    style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(width: s.sp(8)),
                  SizedBox(
                    height: s.sp(24),
                    child: Switch(
                      value: _useSimulationMode,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _useSimulationMode = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: s.sp(16)),
          Center(
            child: SizedBox(
              width: s.sp(200),
              height: s.sp(200),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PremiumGaugePainter(score: score, progressColor: scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${score.toInt()}',
                        style: TextStyle(
                          fontSize: s.sp(48),
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -1,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: s.sp(12), vertical: s.sp(4)),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: s.sp(12),
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: s.sp(20)),
          _buildAiAdviceCard(s, score),
        ],
      ),
    );
  }

  /// AI Asistan Doktor Tavsiye Metni
  Widget _buildAiAdviceCard(AppSizes s, double score) {
    final colorScheme = Theme.of(context).colorScheme;
    String advice = 'Verileriniz yüklendiğinde AI analiziniz oluşturulacak.';
    if (score >= 80) {
      advice = 'Harika! Finansal sağlığınız mükemmel durumda. Kazancınız giderlerinizin üzerinde ve birikim oranınız çok sağlıklı. Tasarruflarınızı yatırıma dönüştürmeye devam edip finansal özgürlük hedeflerinize sadık kalabilirsiniz.';
    } else if (score >= 60) {
      advice = 'İyi düzeyde bir finansal sağlığınız var. Ancak acil durum fonunuzu biraz daha güçlendirmeli ve aylık borç yükünüzün bütçenizi sıkıştırmaması için harcamalarınızı optimize etmelisiniz.';
    } else if (score >= 40) {
      advice = 'Finansal sağlığınız sınırda. Dürtüsel alışverişlerinizi kısarak tasarruf oranınızı artırmalı ve aylık taksitlerinizi azaltacak bütçe kontrol önlemleri almalısınız.';
    } else {
      advice = 'Finansal sağlığınız alarm veriyor! Gelir-gider dengeniz bozulmuş veya borç sarmalındasınız. Kredi kartı borçlarını asgariyle döndürmekten kaçınarak acil bütçe planlaması yapmanız önerilir.';
    }

    return Container(
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(s.sp(8)),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.psychology, color: colorScheme.primary, size: s.sp(20)),
          ),
          SizedBox(width: s.sp(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YAPAY ZEKA FİNANS DOKTORU',
                  style: TextStyle(
                    fontSize: s.sp(10),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: s.sp(4)),
                Text(
                  advice,
                  style: TextStyle(
                    fontSize: s.sp(13),
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Glassmorphism Sekme Seçici (TabSelector)
  Widget _buildTabSelector(AppSizes s) {
    return GlassContainer(
      height: s.sp(48),
      borderRadius: 12,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(0, 'Analiz', s),
          _buildTabItem(1, 'Simülatör', s),
          _buildTabItem(2, 'Hedeflerim', s),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title, AppSizes s) {
    final isSelected = _activeTab == index;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: s.sp(13),
            ),
          ),
        ),
      ),
    );
  }

  /// Aktif Sekme İçeriği
  Widget _buildActiveTabContent(AppSizes s, Map<String, dynamic> metrics, Color themeColor) {
    switch (_activeTab) {
      case 0:
        return _buildAnalysisTab(s, metrics);
      case 1:
        return _buildSimulatorTab(s);
      case 2:
        return _buildGoalsTab(s);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  //  SEKME 1: TEMEL SAĞLIK ANALİZİ (6 BİLEŞEN)
  // ==========================================
  Widget _buildAnalysisTab(AppSizes s, Map<String, dynamic> m) {
    final net = currentIncome - currentExpense;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 1. Gelir-Gider Dengesi Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.swap_horiz,
          color: net >= 0 ? colorScheme.primary : colorScheme.error,
          title: '1. Gelir-Gider Dengesi',
          subtitle: net >= 0 ? 'Pozitif Sağlık Göstergesi' : 'Bütçe Açığı Var',
          child: Column(
            children: [
              _buildMetricRow('Gelir:', '₺${currentIncome.toStringAsFixed(0)}', s),
              _buildMetricRow('Gider:', '₺${currentExpense.toStringAsFixed(0)}', s),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              _buildMetricRow(
                'Kalan / Tasarruf:',
                '₺${net.toStringAsFixed(0)}',
                s,
                valueColor: net >= 0 ? colorScheme.primary : colorScheme.error,
                isBold: true,
              ),
              SizedBox(height: s.sp(10)),
              Text(
                net >= 0
                    ? 'Kazandığınızdan daha az harcıyorsunuz. Bu durum güçlü finansal dayanıklılık ve pozitif finansal sağlığın ana temelidir.'
                    : 'Giderleriniz gelirinizi aşmış durumda. Bütçenizi dengelemek için harcamalarınızı acilen azaltmalısınız.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        // 2. Tasarruf ve Birikim Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.account_balance_wallet,
          color: colorScheme.tertiary,
          title: '2. Tasarruf ve Birikim',
          subtitle: 'Düzenli Birikim & Acil Durum Fonu',
          child: Column(
            children: [
              _buildMetricRow('Tasarruf Oranı:', '%${m['savingsRate'].toStringAsFixed(1)}', s),
              _buildMetricRow('Acil Durum Büyüklüğü:', '₺${currentEmergencyFund.toStringAsFixed(0)}', s),
              _buildMetricRow('Karşılama Kapasitesi:', '${m['efMonths'].toStringAsFixed(1)} Ay', s),
              SizedBox(height: s.sp(10)),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (m['savingsRate'] / 20.0).clamp(0.0, 1.0),
                  color: colorScheme.tertiary,
                  backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                  minHeight: s.sp(6),
                ),
              ),
              SizedBox(height: s.sp(10)),
              Text(
                'Önerilen tasarruf oranı %10 ila %20 arasındadır. Acil durum fonunuzun ise beklenmedik kriz durumları için 3 ila 6 aylık sabit giderinizi karşılaması gerekir.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        // 3. Borç Yönetimi Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.credit_score,
          color: m['dti'] > 40 ? colorScheme.error : colorScheme.secondary,
          title: '3. Borç Yönetimi',
          subtitle: 'Borç / Gelir Oranı ve Faiz Kontrolü',
          child: Column(
            children: [
              _buildMetricRow('Borç Taksit Yükü (Aylık):', '₺${currentDebtPayment.toStringAsFixed(0)}', s),
              _buildMetricRow('Borç / Gelir Oranı (DTI):', '%${m['dti'].toStringAsFixed(1)}', s),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              if (_cardMinimumLoop)
                Container(
                  margin: EdgeInsets.only(bottom: s.sp(10)),
                  padding: EdgeInsets.all(s.sp(10)),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: colorScheme.error, size: s.sp(18)),
                      SizedBox(width: s.sp(8)),
                      Expanded(
                        child: Text(
                          'Kredi kartınızı sürekli minimum ödemeyle kapatmak faiz sarmalına sokar.',
                          style: TextStyle(fontSize: s.sp(11), color: colorScheme.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                m['dti'] <= 35
                    ? 'Borç yükünüz makul sınırlarda (%35 altı). Aylık ödemelerinizi düzenli olarak kapatabiliyorsunuz.'
                    : 'Dikkat! Aylık borç oranınız kritik seviyede (%35 üzeri). Gelirinizin büyük kısmı kredi ve kart borçlarına gidiyor.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        // 4. Harcama Davranışı Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.shopping_bag,
          color: m['badHabitsCount'] > 1 ? colorScheme.error : colorScheme.primary,
          title: '4. Harcama Davranışı',
          subtitle: 'Zararlı Alışkanlık Analizi',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHabitStatusRow('Dürtüsel Alışveriş Yapma', _habitImpulse, s),
              _buildHabitStatusRow('Plansız / Gereksiz Abonelikler', _habitSubscriptions, s),
              _buildHabitStatusRow('Aşırı Lüks Tüketim', _habitLuxury, s),
              _buildHabitStatusRow('"Maaş Gününe Kadar Sıkışma" Döngüsü', _habitPaydayLoop, s),
              SizedBox(height: s.sp(10)),
              Text(
                'Finansal sağlık sadece rakamlardan ibaret değildir, aynı zamanda harcama davranışınızın kalitesidir. Dürtüsel harcamaları keserek bütçenizi hızla toparlayabilirsiniz.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        // 5. Finansal Güvenlik Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.shield,
          color: colorScheme.secondary,
          title: '5. Finansal Güvenlik',
          subtitle: 'Kriz Dayanıklılık Kapasitesi',
          child: Column(
            children: [
              _buildMetricRow('Acil Masraf Dayanımı:', m['efMonths'] >= 3 ? 'Tam Dayanıklı' : 'Zayıf Dayanıklı', s,
                  valueColor: m['efMonths'] >= 3 ? colorScheme.primary : colorScheme.error),
              _buildMetricRow('İş Kaybı Güvencesi:', '${m['efMonths'].toStringAsFixed(1)} Ay Yaşam Desteği', s),
              SizedBox(height: s.sp(10)),
              Text(
                'Hastalık, iş kaybı veya ani ekonomik kriz durumlarında borç batağına düşmeden tamamen ayakta kalabilmeniz için acil durum yedek akçenizin hazır olması şarttır.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        // 6. Finansal Hedefler Kartı
        _buildPillarCard(
          s: s,
          icon: Icons.flag,
          color: colorScheme.tertiary,
          title: '6. Finansal Hedefler',
          subtitle: 'Geleceğe Dönük Bütçe Planlama',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ev alma, yatırım yapma, emeklilik ve iş kurma gibi hedeflerin bütçelenmesi tasarruflarınıza odaklanmanızı sağlar. ${_goals.length} adet aktif finansal hedefiniz bulunuyor.',
                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
              SizedBox(height: s.sp(12)),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _activeTab = 2; // Hedefler sekmesine git
                    });
                  },
                  icon: Icon(Icons.arrow_right_alt, color: colorScheme.primary),
                  label: Text('Hedeflerimi Yönet', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  //  SEKME 2: FİNANSAL SAĞLIK SİMÜLATÖRÜ
  // ==========================================
  Widget _buildSimulatorTab(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FİNANSAL DURUM PARAMETRELERİ',
          style: TextStyle(fontSize: s.sp(12), color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        SizedBox(height: s.sp(12)),

        // Gelir Ayarı
        _buildSliderCard(
          title: 'Aylık Net Gelir',
          value: _simIncome,
          min: 10000,
          max: 150000,
          divisions: 140,
          unit: 'TL',
          s: s,
          onChanged: (val) {
            setState(() {
              _simIncome = val;
            });
          },
        ),

        // Gider Ayarı
        _buildSliderCard(
          title: 'Aylık Sabit Gider',
          value: _simExpense,
          min: 5000,
          max: 100000,
          divisions: 95,
          unit: 'TL',
          s: s,
          onChanged: (val) {
            setState(() {
              _simExpense = val;
            });
          },
        ),

        // Borç Taksit Ayarı
        _buildSliderCard(
          title: 'Aylık Taksit / Borç Ödemeleri',
          value: _simDebtPayment,
          min: 0,
          max: 50000,
          divisions: 100,
          unit: 'TL',
          s: s,
          onChanged: (val) {
            setState(() {
              _simDebtPayment = val;
            });
          },
        ),

        // Acil Durum Fonu Ayarı
        _buildSliderCard(
          title: 'Acil Durum Nakit Birikimi',
          value: _simEmergencyFund,
          min: 0,
          max: 300000,
          divisions: 120,
          unit: 'TL',
          s: s,
          onChanged: (val) {
            setState(() {
              _simEmergencyFund = val;
            });
          },
        ),

        SizedBox(height: s.sp(20)),
        Text(
          'HARCAMA DAVRANIŞLARI VE RİSKLER',
          style: TextStyle(fontSize: s.sp(12), color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        SizedBox(height: s.sp(12)),

        // Davranış ve Kredi Kartı Asgari Checkbox'ları
        GlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.all(s.sp(16)),
          child: Column(
            children: [
              _buildSwitchRow(
                title: 'Kredi kartımı sürekli minimum tutarla ödüyorum.',
                value: _cardMinimumLoop,
                s: s,
                onChanged: (val) {
                  setState(() {
                    _cardMinimumLoop = val;
                  });
                },
              ),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              _buildSwitchRow(
                title: 'Dürtüsel (anlık isteklerle) alışveriş yaparım.',
                value: _habitImpulse,
                s: s,
                onChanged: (val) {
                  setState(() {
                    _habitImpulse = val;
                  });
                },
              ),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              _buildSwitchRow(
                title: 'Plansız, takip etmediğim aboneliklerim var.',
                value: _habitSubscriptions,
                s: s,
                onChanged: (val) {
                  setState(() {
                    _habitSubscriptions = val;
                  });
                },
              ),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              _buildSwitchRow(
                title: 'Bütçemi aşacak gereksiz lüks tüketim yaparım.',
                value: _habitLuxury,
                s: s,
                onChanged: (val) {
                  setState(() {
                    _habitLuxury = val;
                  });
                },
              ),
              Divider(color: colorScheme.onSurface.withValues(alpha: 0.1)),
              _buildSwitchRow(
                title: 'Maaş günü öncesi sürekli nakit sıkışıklığı çekerim.',
                value: _habitPaydayLoop,
                s: s,
                onChanged: (val) {
                  setState(() {
                    _habitPaydayLoop = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  //  SEKME 3: FİNANSAL HEDEFLERİM
  // ==========================================
  Widget _buildGoalsTab(AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HEDEF LİSTESİ VE BİRİKİM DURUMU',
              style: TextStyle(fontSize: s.sp(12), color: colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: colorScheme.primary, size: s.sp(28)),
              onPressed: () => _showAddGoalDialog(s),
            ),
          ],
        ),
        SizedBox(height: s.sp(12)),

        Column(
          children: _goals.map((goal) {
            return Container(
              margin: EdgeInsets.only(bottom: s.sp(16)),
              child: HoverGlassContainer(
                borderRadius: 16,
                padding: EdgeInsets.all(s.sp(16)),
                glowColor: colorScheme.tertiary,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(s.sp(10)),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(goal.icon, color: colorScheme.tertiary, size: s.sp(22)),
                        ),
                        SizedBox(width: s.sp(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              ),
                              SizedBox(height: s.sp(4)),
                              Text(
                                'Hedef: ₺${goal.targetAmount.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '%${(goal.progress * 100).toStringAsFixed(0)}',
                          style: TextStyle(fontSize: s.sp(18), fontWeight: FontWeight.bold, color: colorScheme.tertiary),
                        ),
                      ],
                    ),
                    SizedBox(height: s.sp(12)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        color: colorScheme.tertiary,
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                        minHeight: s.sp(8),
                      ),
                    ),
                    SizedBox(height: s.sp(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Biriken: ₺${goal.currentAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: s.sp(13), color: colorScheme.onSurfaceVariant),
                        ),
                        SizedBox(
                          width: s.sp(160),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: colorScheme.tertiary,
                              thumbColor: colorScheme.tertiary,
                              overlayColor: colorScheme.tertiary.withValues(alpha: 0.2),
                              trackHeight: 3.0,
                            ),
                            child: Slider(
                              value: goal.currentAmount,
                              min: 0,
                              max: goal.targetAmount,
                              onChanged: (val) {
                                setState(() {
                                  goal.currentAmount = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Yeni Hedef Ekleme Pop-up Form Dialog
  void _showAddGoalDialog(AppSizes s) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController targetController = TextEditingController();
    final TextEditingController currentController = TextEditingController();
    IconData selectedIcon = Icons.stars;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> icons = [
      {'icon': Icons.home, 'label': 'Ev'},
      {'icon': Icons.directions_car, 'label': 'Araba'},
      {'icon': Icons.flight_takeoff, 'label': 'Seyahat'},
      {'icon': Icons.trending_up, 'label': 'Yatırım'},
      {'icon': Icons.school, 'label': 'Eğitim'},
      {'icon': Icons.business, 'label': 'İş Kurma'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              title: Text('Yeni Finansal Hedef Ekle', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Hedef Adı',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
                      ),
                    ),
                    SizedBox(height: s.sp(12)),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Hedef Bütçe Tutarı (TL)',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
                      ),
                    ),
                    SizedBox(height: s.sp(12)),
                    TextField(
                      controller: currentController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Mevcut Birikim Tutarı (TL)',
                        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2))),
                      ),
                    ),
                    SizedBox(height: s.sp(20)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Hedef İkonu Seçin:', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ),
                    SizedBox(height: s.sp(8)),
                    Wrap(
                      spacing: 8,
                      children: icons.map((iconData) {
                        final isSelected = selectedIcon == iconData['icon'];
                        return ChoiceChip(
                          label: Icon(iconData['icon'], color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant, size: 18),
                          selected: isSelected,
                          selectedColor: colorScheme.tertiary,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          onSelected: (val) {
                            setDialogState(() {
                              selectedIcon = iconData['icon'];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final target = double.tryParse(targetController.text.trim()) ?? 0;
                    final current = double.tryParse(currentController.text.trim()) ?? 0;

                    if (title.isNotEmpty && target > 0) {
                      setState(() {
                        _goals.add(FinancialGoal(
                          title: title,
                          targetAmount: target,
                          currentAmount: current,
                          icon: selectedIcon,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  //  YARDIMCI KÜÇÜK BİLEŞEN WIDGET'LARI
  // ==========================================

  Widget _buildPillarCard({
    required AppSizes s,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: s.sp(16)),
      child: GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.all(s.sp(16)),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(s.sp(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: s.sp(20)),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: s.sp(15), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: s.sp(12), color: colorScheme.onSurfaceVariant),
          ),
          iconColor: colorScheme.onSurfaceVariant,
          collapsedIconColor: colorScheme.onSurfaceVariant,
          childrenPadding: EdgeInsets.only(top: s.sp(12)),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const Border(), // Sınır çizgilerini kaldır
          collapsedShape: const Border(),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, AppSizes s, {Color? valueColor, bool isBold = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.sp(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: s.sp(13), color: colorScheme.onSurfaceVariant)),
          Text(
            value,
            style: TextStyle(
              fontSize: s.sp(14),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStatusRow(String title, bool isActive, AppSizes s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.sp(4)),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.cancel : Icons.check_circle,
            color: isActive ? colorScheme.error : colorScheme.primary,
            size: s.sp(18),
          ),
          SizedBox(width: s.sp(8)),
          Text(
            title,
            style: TextStyle(
              fontSize: s.sp(13),
              color: isActive ? colorScheme.error.withValues(alpha: 0.8) : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required AppSizes s,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: s.sp(12)),
      child: GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.all(s.sp(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: s.sp(13), color: colorScheme.onSurfaceVariant)),
                Text(
                  '₺${value.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: s.sp(14), fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colorScheme.primary,
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withValues(alpha: 0.2),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required AppSizes s,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.sp(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: s.sp(13), color: colorScheme.onSurface),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colorScheme.error,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Gelişmiş Özel Çizimli Neon Gauge Painter
class PremiumGaugePainter extends CustomPainter {
  final double score;
  final Color progressColor;

  PremiumGaugePainter({required this.score, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 16;
    const strokeWidth = 12.0;

    // Arka plan izi (Track)
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // İnce iç dekoratif halka
    final innerTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, innerTrackPaint);

    // İlerleme Yayı (Gradient Sweep)
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          progressColor.withValues(alpha: 0.3),
          progressColor,
        ],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double sweepAngle = (score / 100.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Dış Kalibrasyon Çizgileri (Dashes)
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10.0) * math.pi / 180;
      final start = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 14) * math.cos(angle),
        center.dy + (radius + 14) * math.sin(angle),
      );
      canvas.drawLine(start, end, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumGaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.progressColor != progressColor;
}