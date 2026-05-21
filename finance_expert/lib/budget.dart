import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DataRepository _repo = DataRepository();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Akıllı Bütçe'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: sizes.sp(20), right: sizes.sp(20), top: sizes.sp(24), bottom: sizes.sp(120)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiInsightBanner(sizes),
            SizedBox(height: sizes.sp(24)),
            _buildMonthlyHeader(sizes),
            SizedBox(height: sizes.sp(16)),
            _buildBudgetBars(sizes),
            SizedBox(height: sizes.sp(24)),
            _buildAutomationButton(sizes),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildAiInsightBanner(AppSizes s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.tertiary, Colors.transparent])))),
          Padding(
            padding: EdgeInsets.all(s.sp(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.bolt, color: AppColors.tertiary, size: s.sp(18)),
                SizedBox(width: s.sp(6)),
                Text('AI ÖNERİSİ', style: TextStyle(fontSize: s.sp(12), color: AppColors.tertiary, fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: s.sp(8)),
              Text(
                _repo.hasData ? 'Harcamalarınız analiz ediliyor...' : 'Banka hesabınızı bağlayarak kişisel tasarruf önerileri alın.',
                style: TextStyle(fontSize: s.sp(15), color: AppColors.onSurface, height: 1.4),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildMonthlyHeader(AppSizes s) {
    final cats = _repo.budgetCategories;
    final spent = cats.fold(0.0, (sum, c) => sum + c.spent);
    final limit = cats.fold(0.0, (sum, c) => sum + c.limit);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Aylık Özet', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      Text(cats.isNotEmpty ? '₺${spent.toStringAsFixed(0)} / ₺${limit.toStringAsFixed(0)}' : 'Veri bekleniyor', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildBudgetBars(AppSizes s) {
    final cats = _repo.budgetCategories;
    if (cats.isEmpty) return buildEmptyState(icon: Icons.pie_chart_outline, title: 'Bütçe kategorisi yok', subtitle: 'Banka bağlantınız kurulduğunda harcamalar kategorize edilecek.', sizes: s);
    return Container(
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: cats.map((c) {
        final color = c.isOverBudget ? AppColors.error : (c.progress > 0.85 ? AppColors.tertiary : AppColors.primary);
        return Padding(padding: EdgeInsets.only(bottom: s.sp(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(c.name, style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurface, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            Text(c.statusText, style: TextStyle(fontSize: s.sp(12), color: color, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: s.sp(8)),
          LinearProgressIndicator(value: c.progress.clamp(0.0, 1.0), backgroundColor: Colors.white.withOpacity(0.1), color: color, minHeight: s.sp(8), borderRadius: BorderRadius.circular(999)),
        ]));
      }).toList()),
    );
  }

  Widget _buildAutomationButton(AppSizes s) {
    return Column(children: [
      SizedBox(
        width: double.infinity, height: s.sp(56),
        child: ElevatedButton(
          onPressed: _repo.hasData ? () {} : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, disabledBackgroundColor: AppColors.surfaceContainerHighest, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.auto_awesome, size: s.sp(20)),
            SizedBox(width: s.sp(8)),
            Text('Bu bütçeyi uygula', style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
      SizedBox(height: s.sp(12)),
      Text('AI kategori limitlerini otomatik ayarlayacak.', textAlign: TextAlign.center, style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant)),
    ]);
  }
}