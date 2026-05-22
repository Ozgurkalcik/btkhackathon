import 'package:flutter/material.dart';
import '../../navigation_helper.dart';
import '../widgets/glass_container.dart';
import '../../services/data_repository.dart';
import '../../services/analytics_engine.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DataRepository _repo = DataRepository();
  final AnalyticsEngine _engine = AnalyticsEngine();
  
  late List<InsightResult> _insights;

  @override
  void initState() {
    super.initState();
    if (!_repo.isInitialized) {
      _repo.initialize();
    }
    // Analiz motorunu çalıştır
    _insights = _engine.analyzeHabits(
      _repo.transactions, 
      currentBalance: _repo.totalBalance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes(context);
    final selectedIndex = getSelectedIndexFromRoute(context);

    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: 'Davranış Analizi',
      ),
      body: _repo.hasData 
        ? _buildContent(sizes) 
        : buildEmptyState(
            icon: Icons.analytics,
            title: 'Analiz İçin Veri Bekleniyor',
            subtitle: 'Harcama alışkanlıklarınızı analiz edebilmemiz için en az 1 haftalık veriye ihtiyacımız var.',
            sizes: sizes,
          ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildContent(AppSizes sizes) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: sizes.sp(20),
        right: sizes.sp(20),
        top: sizes.sp(16),
        bottom: sizes.sp(120),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(sizes),
          SizedBox(height: sizes.sp(24)),
          Text(
            'YAPAY ZEKA ÇIKARIMLARI',
            style: TextStyle(
              fontSize: sizes.sp(12),
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: sizes.sp(16)),
          ..._insights.map((insight) => _buildInsightCard(insight, sizes)),
          
          SizedBox(height: sizes.sp(24)),
          Text(
            'AYLIK KATEGORİ DAĞILIMI',
            style: TextStyle(
              fontSize: sizes.sp(12),
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: sizes.sp(16)),
          _buildChartPlaceholder(sizes), // Pasta grafik temsili
        ],
      ),
    );
  }

  Widget _buildHeader(AppSizes sizes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.sp(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B233E), Color(0xFF131A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.tertiary, size: sizes.sp(24)),
              SizedBox(width: sizes.sp(12)),
              Text(
                'Davranışsal Analiz',
                style: TextStyle(
                  fontSize: sizes.sp(20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.sp(16)),
          Text(
            'Son 30 günlük harcamalarınız incelenerek psikolojik ve fiziksel sağlığınızı etkileyen gizli kalıplar (pattern) çıkarıldı.',
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

  Widget _buildInsightCard(InsightResult insight, AppSizes sizes) {
    return Padding(
      padding: EdgeInsets.only(bottom: sizes.sp(16)),
      child: HoverGlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.all(sizes.sp(20)),
        glowColor: insight.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sizes.sp(10)),
                  decoration: BoxDecoration(
                    color: insight.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(insight.icon, color: insight.color, size: sizes.sp(24)),
                ),
                SizedBox(width: sizes.sp(16)),
                Expanded(
                  child: Text(
                    insight.title,
                    style: TextStyle(
                      fontSize: sizes.sp(16),
                      fontWeight: FontWeight.bold,
                      color: insight.color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.sp(16)),
            Text(
              insight.description,
              style: TextStyle(
                fontSize: sizes.sp(14),
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
            if (insight.actionPlan.isNotEmpty) ...[
              SizedBox(height: sizes.sp(16)),
              Container(
                padding: EdgeInsets.all(sizes.sp(12)),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: insight.color.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: insight.color, size: sizes.sp(18)),
                    SizedBox(width: sizes.sp(12)),
                    Expanded(
                      child: Text(
                        insight.actionPlan,
                        style: TextStyle(
                          fontSize: sizes.sp(13),
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (insight.totalAmount > 0) ...[
              SizedBox(height: sizes.sp(12)),
              _buildStat(sizes, 'Tahmini Maliyet/Tasarruf', '₺${insight.totalAmount.toStringAsFixed(0)}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(AppSizes sizes, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sizes.sp(11),
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: sizes.sp(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: sizes.sp(16),
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder(AppSizes sizes) {
    // Basit bir bar grafik çizimi
    final breakdown = _repo.getCategoryBreakdown();
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final maxVal = breakdown.values.fold(0.0, (a, b) => a > b ? a : b);

    return HoverGlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.all(sizes.sp(20)),
      glowColor: AppColors.primary,
      child: Column(
        children: breakdown.entries.take(5).map((entry) {
          final percentage = maxVal > 0 ? entry.value / maxVal : 0.0;
          return Padding(
            padding: EdgeInsets.only(bottom: sizes.sp(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: TextStyle(color: AppColors.onSurface, fontSize: sizes.sp(12))),
                    Text('₺${entry.value.toStringAsFixed(0)}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: sizes.sp(12))),
                  ],
                ),
                SizedBox(height: sizes.sp(6)),
                Container(
                  height: sizes.sp(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
