import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DataRepository _repo = DataRepository();

  @override
  void initState() {
    super.initState();
    _repo.initialize();
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
            SizedBox(height: sizes.sp(24)),
            _buildOverviewCard(sizes),
            SizedBox(height: sizes.sp(24)),
            _buildQuickActions(sizes),
            SizedBox(height: sizes.sp(24)),
            _buildRecentTransactionsHeader(sizes),
            SizedBox(height: sizes.sp(16)),
            _buildTransactionsSection(sizes),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  /// Banka bağlantı durumu banneri
  Widget _buildConnectionStatusBanner(AppSizes sizes) {
    final hasConnection = _repo.hasBankConnections;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasConnection
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.tertiary.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  /// Gelir/Gider Genel Bakış Kartı
  Widget _buildOverviewCard(AppSizes sizes) {
    final totalBalance = _repo.totalBalance;
    final income = _repo.totalIncome;
    final expense = _repo.totalExpense;
    final maxVal = income > 0 ? income : 1.0;

    return Container(
      padding: EdgeInsets.all(sizes.sp(24)),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.2,
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6],
        ),
      ),
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
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.1),
          color: color,
          minHeight: sizes.sp(6),
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }

  /// Hızlı Eylemler
  Widget _buildQuickActions(AppSizes sizes) {
    return SizedBox(
      height: sizes.sp(48),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildActionButton(
            label: 'Manuel Ekle',
            icon: Icons.add,
            bgColor: AppColors.primary,
            textColor: AppColors.onPrimary,
            sizes: sizes,
          ),
          SizedBox(width: sizes.sp(12)),
          _buildActionButton(
            label: 'Fişi Tara',
            icon: Icons.center_focus_strong,
            bgColor: AppColors.surfaceContainerHighest,
            textColor: AppColors.onSurface,
            hasBorder: true,
            sizes: sizes,
            onTap: () => navigateToIndex(context, 2),
          ),
          SizedBox(width: sizes.sp(12)),
          _buildActionButton(
            label: 'AI Plan',
            icon: Icons.smart_toy,
            iconColor: AppColors.tertiary,
            bgColor: AppColors.surfaceContainerHighest,
            textColor: AppColors.onSurface,
            hasBorder: true,
            sizes: sizes,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required AppSizes sizes,
    Color? iconColor,
    bool hasBorder = false,
    VoidCallback? onTap,
  }) {
    return Container(
      width: sizes.hp(0.33).clamp(110, 160),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: hasBorder ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? textColor, size: sizes.sp(20)),
            SizedBox(width: sizes.sp(8)),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: sizes.sp(12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
          onPressed: () {},
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
      children: transactions.map((txn) => Padding(
        padding: EdgeInsets.only(bottom: sizes.sp(12)),
        child: Container(
          padding: EdgeInsets.all(sizes.sp(16)),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
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
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}