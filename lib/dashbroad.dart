import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';
import 'presentation/widgets/glass_container.dart';
import 'models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final DataRepository _repo = DataRepository();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _repo.initialize();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: 'Finance Expert',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: sizes.sp(20),
          right: sizes.sp(20),
          top: sizes.sp(16),
          bottom: sizes.sp(120),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildBankAccountsList(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildConnectionStatusBanner(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildGradientHeader(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildAIInsightCard(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildSmartInsights(sizes),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Floating above bottom nav bar
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.3 * _pulseAnimation.value),
                    blurRadius: 18 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                  BoxShadow(
                    color: colorScheme.tertiary.withOpacity(0.25 * _pulseAnimation.value),
                    blurRadius: 26 * _pulseAnimation.value,
                    spreadRadius: 3 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorScheme.secondary, colorScheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: () => navigateToIndex(context, 2), // Navigate to Assistant Screen
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  highlightElevation: 0,
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  /// Banka bağlantı durumu banneri
  Widget _buildConnectionStatusBanner(AppSizes sizes) {
    final hasConnection = _repo.hasBankConnections;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return HoverGlassContainer(
      borderRadius: 12,
      glowColor: hasConnection ? colorScheme.primary : colorScheme.tertiary,
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasConnection
                      ? [colorScheme.primary, Colors.transparent]
                      : [colorScheme.tertiary, Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sizes.sp(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(sizes.sp(8)),
                  decoration: BoxDecoration(
                    color: hasConnection
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasConnection ? Icons.link : Icons.link_off,
                    color: hasConnection ? colorScheme.primary : colorScheme.tertiary,
                    size: sizes.sp(20),
                  ),
                ),
                SizedBox(width: sizes.sp(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasConnection
                            ? '${_repo.connectedBankCount} banka bağlı'
                            : 'Banka bağlantısı yok',
                        style: TextStyle(
                          fontSize: sizes.sp(15),
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sizes.sp(4)),
                      Text(
                        hasConnection
                            ? 'Verileriniz ${_repo.connectedBankNames.join(", ")} üzerinden senkronize ediliyor.'
                            : 'Banka API anahtarlarınızı config/bank_config.dart dosyasına ekleyin ve verilerinizi görmeye başlayın.',
                        style: TextStyle(
                          fontSize: sizes.sp(13),
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Gradient Header
  Widget _buildGradientHeader(AppSizes sizes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.sp(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF131A2E), const Color(0xFF1E2B4C)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldin,',
                    style: TextStyle(
                      fontSize: sizes.sp(14),
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: sizes.sp(4)),
                  Text(
                    'Finansal Kaşif',
                    style: TextStyle(
                      fontSize: sizes.sp(24),
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sizes.sp(12), vertical: sizes.sp(6)),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: sizes.sp(8)),
                    Text(
                      'AI Aktif',
                      style: TextStyle(
                        fontSize: sizes.sp(11),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.sp(16)),
          Text(
            'Bütçe durumun bu ay mükemmel görünüyor! Yapay zeka senin için yeni tasarruf önerileri hazırladı.',
            style: TextStyle(
              fontSize: sizes.sp(13),
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// AI Insight Card
  Widget _buildAIInsightCard(AppSizes sizes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return HoverGlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(sizes.sp(20)),
      glowColor: colorScheme.secondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sizes.sp(10)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.secondary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: sizes.sp(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YAPAY ZEKA ANALİZİ',
                      style: TextStyle(
                        fontSize: sizes.sp(11),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Şimdi',
                      style: TextStyle(
                        fontSize: sizes.sp(11),
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.sp(6)),
                Text(
                  'Bu ay gıda harcamalarınız %12 azaldı. Tasarrufunuz ile ₺1.200 bütçe fazlası oluşturdunuz! Bu tutarı yatırım sepetinize aktarmak ister misiniz?',
                  style: TextStyle(
                    fontSize: sizes.sp(13),
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sizes.sp(12)),
                InkWell(
                  onTap: () => navigateToIndex(context, 2), // Navigate to Assistant Screen
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Öneriyi İncele',
                        style: TextStyle(
                          fontSize: sizes.sp(12),
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: sizes.sp(4)),
                      Icon(
                        Icons.arrow_forward,
                        size: sizes.sp(14),
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gelir/Gider Genel Bakış Kartı
  Widget _buildOverviewCard(AppSizes sizes) {
    final totalBalance = _repo.totalBalance;
    final income = _repo.totalIncome;
    final expense = _repo.totalExpense;
    final maxVal = income > 0 ? income : 1.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return HoverGlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(sizes.sp(24)),
      glowColor: colorScheme.primary,
      gradientColors: [
        colorScheme.primary.withOpacity(0.08),
        colorScheme.onSurface.withOpacity(0.02),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TÜM HESAPLAR KONSOLİDE DURUM',
            style: TextStyle(
              fontSize: sizes.sp(12),
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: sizes.sp(8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _repo.hasData
                        ? '₺${totalBalance.toStringAsFixed(2)}'
                        : '₺0,00',
                    style: TextStyle(
                      fontSize: sizes.sp(32),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              if (_repo.hasData) ...[
                SizedBox(width: sizes.sp(8)),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: colorScheme.primary, size: sizes.sp(14)),
                    SizedBox(width: sizes.sp(4)),
                    Text(
                      'Canlı',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: sizes.sp(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: sizes.sp(32)),
          Row(
            children: [
              Expanded(
                child: _buildOverviewProgressColumn(
                  'Gelir',
                  _repo.hasData ? '₺${income.toStringAsFixed(0)}' : '—',
                  colorScheme.primary,
                  income > 0 ? 0.75 : 0.0,
                  sizes,
                ),
              ),
              SizedBox(width: sizes.sp(16)),
              Expanded(
                child: _buildOverviewProgressColumn(
                  'Gider',
                  _repo.hasData ? '₺${expense.toStringAsFixed(0)}' : '—',
                  colorScheme.secondary,
                  maxVal > 0 ? (expense / maxVal).clamp(0.0, 1.0) : 0.0,
                  sizes,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewProgressColumn(
      String label, String amount, Color color, double progress, AppSizes sizes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: sizes.sp(8),
              height: sizes.sp(8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: sizes.sp(8)),
            Text(label, style: TextStyle(fontSize: sizes.sp(12), color: colorScheme.onSurfaceVariant)),
          ],
        ),
        SizedBox(height: sizes.sp(4)),
        Text(
          amount,
          style: TextStyle(
            fontSize: sizes.sp(20),
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: sizes.sp(8)),
        Container(
          height: sizes.sp(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.onSurface.withOpacity(0.1),
              color: color,
              minHeight: sizes.sp(6),
            ),
          ),
        ),
      ],
    );
  }

  /// Ayrı Ayrı Banka Hesapları Özeti
  Widget _buildBankAccountsList(AppSizes sizes) {
    if (!_repo.hasData || _repo.accounts.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BANKA HESAPLARINIZ',
          style: TextStyle(
            fontSize: sizes.sp(12),
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: sizes.sp(16)),
        SizedBox(
          height: sizes.sp(160),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _repo.accounts.length,
            separatorBuilder: (context, index) => SizedBox(width: sizes.sp(16)),
            itemBuilder: (context, index) {
              final account = _repo.accounts[index];
              // Bu hesaba ait işlemleri bulup gelir/gideri hesaplıyoruz.
              final txns = _repo.getTransactionsByBank(account.bankId);
              final inc = txns.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
              final exp = txns.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

              return Container(
                width: sizes.sp(220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: colorScheme.surfaceContainer.withOpacity(0.4),
                  border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
                ),
                padding: EdgeInsets.all(sizes.sp(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: sizes.sp(32),
                          height: sizes.sp(32),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(Icons.account_balance, color: Colors.blueGrey, size: sizes.sp(18)),
                          ),
                        ),
                        SizedBox(width: sizes.sp(12)),
                        Expanded(
                          child: Text(
                            account.bankName,
                            style: TextStyle(
                              fontSize: sizes.sp(14),
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.sp(16)),
                    Text(
                      '₺${account.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: sizes.sp(20),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gelir', style: TextStyle(fontSize: sizes.sp(10), color: colorScheme.onSurfaceVariant)),
                            Text('₺${inc.toStringAsFixed(0)}', style: TextStyle(fontSize: sizes.sp(12), color: colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gider', style: TextStyle(fontSize: sizes.sp(10), color: colorScheme.onSurfaceVariant)),
                            Text('₺${exp.toStringAsFixed(0)}', style: TextStyle(fontSize: sizes.sp(12), color: colorScheme.error, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Akıllı İçgörüler (Zenginleştirilmiş Pipeline'dan beslenen detaylı kartlar)
  Widget _buildSmartInsights(AppSizes sizes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKILLI İÇGÖRÜLER',
          style: TextStyle(
            fontSize: sizes.sp(12),
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: sizes.sp(16)),

        // Lokasyon Haritası Modülü
        HoverGlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.all(sizes.sp(20)),
          glowColor: colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sizes.sp(8)),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on, color: colorScheme.primary, size: sizes.sp(20)),
                  ),
                  SizedBox(width: sizes.sp(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sık Ziyaret Edilen Lokasyon',
                          style: TextStyle(fontSize: sizes.sp(12), color: colorScheme.onSurfaceVariant),
                        ),
                        SizedBox(height: sizes.sp(4)),
                        Text(
                          'Malatya Park AVM',
                          style: TextStyle(fontSize: sizes.sp(16), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sizes.sp(12), vertical: sizes.sp(6)),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(
                      '4 İşlem',
                      style: TextStyle(fontSize: sizes.sp(12), fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizes.sp(16)),
              Text(
                'Bu ayki harcamalarınızın %22\'si bu lokasyonda gerçekleşti. Yemek ve kozmetik mağazaları başı çekiyor.',
                style: TextStyle(fontSize: sizes.sp(13), color: colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),

        SizedBox(height: sizes.sp(16)),

        // Sektörel Sapma Uyarısı
        HoverGlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.all(sizes.sp(20)),
          glowColor: colorScheme.error,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(sizes.sp(8)),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: colorScheme.error, size: sizes.sp(20)),
              ),
              SizedBox(width: sizes.sp(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sektörel Harcama Sapması',
                      style: TextStyle(fontSize: sizes.sp(12), color: colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: sizes.sp(4)),
                    Text(
                      'Kozmetik / Kişisel Bakım',
                      style: TextStyle(fontSize: sizes.sp(16), fontWeight: FontWeight.bold, color: colorScheme.error),
                    ),
                    SizedBox(height: sizes.sp(8)),
                    Text(
                      'Normal bütçe limitinizin %30 üzerindesiniz. NACE kodlarına göre bu sektördeki enflasyon ve harcama hacminiz ciddi artışta.',
                      style: TextStyle(fontSize: sizes.sp(13), color: colorScheme.onSurfaceVariant, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}