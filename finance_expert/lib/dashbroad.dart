import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';
import 'presentation/widgets/glass_container.dart';

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
            _buildConnectionStatusBanner(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildGradientHeader(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildAIInsightCard(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildOverviewCard(sizes),
            SizedBox(height: sizes.sp(20)),
            _buildQuickActions(sizes),
            SizedBox(height: sizes.sp(24)),
            _buildRecentTransactionsHeader(sizes),
            SizedBox(height: sizes.sp(16)),
            _buildTransactionsSection(sizes),
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
                    color: AppColors.secondary.withOpacity(0.3 * _pulseAnimation.value),
                    blurRadius: 18 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                  BoxShadow(
                    color: AppColors.tertiary.withOpacity(0.25 * _pulseAnimation.value),
                    blurRadius: 26 * _pulseAnimation.value,
                    spreadRadius: 3 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.tertiary],
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

    return HoverGlassContainer(
      borderRadius: 12,
      glowColor: hasConnection ? AppColors.primary : AppColors.tertiary,
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasConnection
                      ? [AppColors.primary, Colors.transparent]
                      : [AppColors.tertiary, Colors.transparent],
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
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasConnection ? Icons.link : Icons.link_off,
                    color: hasConnection ? AppColors.primary : AppColors.tertiary,
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
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: sizes.sp(4)),
                      Text(
                        hasConnection
                            ? 'Verileriniz ${_repo.connectedBankNames.join(", ")} üzerinden senkronize ediliyor.'
                            : 'Banka API anahtarlarınızı config/bank_config.dart dosyasına ekleyin ve verilerinizi görmeye başlayın.',
                        style: TextStyle(
                          fontSize: sizes.sp(13),
                          color: AppColors.onSurfaceVariant,
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.sp(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF131A2E),
            Color(0xFF1E2B4C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
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
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: sizes.sp(4)),
                  Text(
                    'Finansal Kaşif',
                    style: TextStyle(
                      fontSize: sizes.sp(24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sizes.sp(12), vertical: sizes.sp(6)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: sizes.sp(8)),
                    Text(
                      'AI Aktif',
                      style: TextStyle(
                        fontSize: sizes.sp(11),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// AI Insight Card
  Widget _buildAIInsightCard(AppSizes sizes) {
    return HoverGlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(sizes.sp(20)),
      glowColor: AppColors.secondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sizes.sp(10)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
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
                        color: AppColors.secondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Şimdi',
                      style: TextStyle(
                        fontSize: sizes.sp(11),
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sizes.sp(6)),
                Text(
                  'Bu ay gıda harcamalarınız %12 azaldı. Tasarrufunuz ile ₺1.200 bütçe fazlası oluşturdunuz! Bu tutarı yatırım sepetinize aktarmak ister misiniz?',
                  style: TextStyle(
                    fontSize: sizes.sp(13),
                    color: AppColors.onSurface,
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
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: sizes.sp(4)),
                      Icon(
                        Icons.arrow_forward,
                        size: sizes.sp(14),
                        color: AppColors.primary,
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

    return HoverGlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(sizes.sp(24)),
      glowColor: AppColors.primary,
      gradientColors: [
        AppColors.primary.withOpacity(0.08),
        Colors.white.withOpacity(0.02),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOPLAM BAKİYE',
            style: TextStyle(
              fontSize: sizes.sp(12),
              color: AppColors.onSurfaceVariant,
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
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              if (_repo.hasData) ...[
                SizedBox(width: sizes.sp(8)),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.primary, size: sizes.sp(14)),
                    SizedBox(width: sizes.sp(4)),
                    Text(
                      'Canlı',
                      style: TextStyle(
                        color: AppColors.primary,
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
                  AppColors.primary,
                  income > 0 ? 0.75 : 0.0,
                  sizes,
                ),
              ),
              SizedBox(width: sizes.sp(16)),
              Expanded(
                child: _buildOverviewProgressColumn(
                  'Gider',
                  _repo.hasData ? '₺${expense.toStringAsFixed(0)}' : '—',
                  AppColors.secondary,
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
            Text(label, style: TextStyle(fontSize: sizes.sp(12), color: AppColors.onSurfaceVariant)),
          ],
        ),
        SizedBox(height: sizes.sp(4)),
        Text(
          amount,
          style: TextStyle(
            fontSize: sizes.sp(20),
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
              backgroundColor: Colors.white.withOpacity(0.1),
              color: color,
              minHeight: sizes.sp(6),
            ),
          ),
        ),
      ],
    );
  }

  /// Hızlı Eylemler
  Widget _buildQuickActions(AppSizes sizes) {
    return Row(
      children: [
        Expanded(
          child: HoverGlassContainer(
            borderRadius: 16,
            glowColor: AppColors.primary,
            onTap: () {},
            padding: EdgeInsets.symmetric(vertical: sizes.sp(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.primary, size: sizes.sp(20)),
                SizedBox(width: sizes.sp(8)),
                Text(
                  'Manuel Ekle',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: sizes.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: sizes.sp(12)),
        Expanded(
          child: HoverGlassContainer(
            borderRadius: 16,
            glowColor: AppColors.secondary,
            onTap: () => navigateToIndex(context, 1), // Navigate to Expenditures
            padding: EdgeInsets.symmetric(vertical: sizes.sp(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.center_focus_strong, color: AppColors.secondary, size: sizes.sp(20)),
                SizedBox(width: sizes.sp(8)),
                Text(
                  'Fişi Tara',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: sizes.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: sizes.sp(12)),
        Expanded(
          child: HoverGlassContainer(
            borderRadius: 16,
            glowColor: AppColors.tertiary,
            onTap: () => navigateToIndex(context, 2), // Navigate to Assistant Screen
            padding: EdgeInsets.symmetric(vertical: sizes.sp(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy, color: AppColors.tertiary, size: sizes.sp(20)),
                SizedBox(width: sizes.sp(8)),
                Text(
                  'AI Plan',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: sizes.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Son İşlemler Başlığı
  Widget _buildRecentTransactionsHeader(AppSizes sizes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Son İşlemler',
          style: TextStyle(
            fontSize: sizes.sp(20),
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => navigateToIndex(context, 1), // Navigate to Expenditures
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            'Tümünü Gör',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: sizes.sp(12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// İşlem listesi (veri yoksa empty state)
  Widget _buildTransactionsSection(AppSizes sizes) {
    final transactions = _repo.getRecentTransactions(count: 5);

    if (transactions.isEmpty) {
      return buildEmptyState(
        icon: Icons.receipt_long,
        title: 'Henüz işlem yok',
        subtitle: 'Banka hesabınızı bağladığınızda işlemleriniz burada görüntülenecek.',
        sizes: sizes,
      );
    }

    return Column(
      children: transactions.map((txn) {
        final isExpense = txn.formattedAmount.contains('-');
        return Padding(
          padding: EdgeInsets.only(bottom: sizes.sp(12)),
          child: HoverGlassContainer(
            borderRadius: 12,
            padding: EdgeInsets.all(sizes.sp(16)),
            glowColor: isExpense ? AppColors.expense : AppColors.income,
            onTap: () {},
            child: Row(
              children: [
                Container(
                  width: sizes.sp(48),
                  height: sizes.sp(48),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(txn.icon, color: AppColors.onSurfaceVariant, size: sizes.sp(24)),
                ),
                SizedBox(width: sizes.sp(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.title,
                        style: TextStyle(fontSize: sizes.sp(15), color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: sizes.sp(4)),
                      Text(
                        txn.category,
                        style: TextStyle(fontSize: sizes.sp(13), color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  txn.formattedAmount,
                  style: TextStyle(
                    fontSize: sizes.sp(18),
                    fontWeight: FontWeight.w600,
                    color: isExpense ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}