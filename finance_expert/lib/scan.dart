import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';

class ResolutionScreen extends StatefulWidget {
  const ResolutionScreen({super.key});
  @override
  State<ResolutionScreen> createState() => _ResolutionScreenState();
}

class _ResolutionScreenState extends State<ResolutionScreen> {
  final DataRepository _repo = DataRepository();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'İşlem Çözümleme'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: sizes.sp(20), right: sizes.sp(20), top: sizes.sp(24), bottom: sizes.sp(120)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildPipeline(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildSectorScroll(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildResolvedHeader(sizes),
          SizedBox(height: sizes.sp(16)),
          _buildResolvedList(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildAccuracyBanner(sizes),
        ]),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildPipeline(AppSizes s) {
    final hasApi = _repo.hasBankConnections;
    return Container(
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('İŞLEM HATTI', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          Row(children: [
            Container(width: s.sp(8), height: s.sp(8), decoration: BoxDecoration(shape: BoxShape.circle, color: hasApi ? AppColors.primary : AppColors.onSurfaceVariant)),
            SizedBox(width: s.sp(6)),
            Text(hasApi ? 'API AKTİF' : 'API BAĞLANTI BEKLENİYOR', style: TextStyle(color: hasApi ? AppColors.primary : AppColors.onSurfaceVariant, fontSize: s.sp(11), fontWeight: FontWeight.bold)),
          ]),
        ]),
        SizedBox(height: s.sp(24)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _pipeNode(Icons.storage, 'Ham Banka Verisi', false, s),
          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: s.sp(8)), child: CustomPaint(size: Size(double.infinity, s.sp(10)), painter: _ArrowPainter()))),
          _pipeNode(Icons.memory, 'TOBB API', hasApi, s),
        ]),
        SizedBox(height: s.sp(24)),
        Container(
          padding: EdgeInsets.all(s.sp(12)),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryContainer.withOpacity(0.2))),
          child: Row(children: [
            Container(width: s.sp(40), height: s.sp(40), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryContainer), child: Icon(hasApi ? Icons.check_circle : Icons.hourglass_empty, color: AppColors.onPrimaryContainer, size: s.sp(20))),
            SizedBox(width: s.sp(16)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Çözümlenmiş Sonuç', style: TextStyle(fontSize: s.sp(13), color: AppColors.onSurfaceVariant)),
              SizedBox(height: s.sp(2)),
              Text(hasApi ? 'Çözümleme aktif' : 'API bağlantısı bekleniyor', style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.bold, color: hasApi ? AppColors.primary : AppColors.onSurfaceVariant)),
            ])),
          ]),
        ),
      ]),
    );
  }

  Widget _pipeNode(IconData icon, String label, bool active, AppSizes s) {
    return SizedBox(
      width: s.sp(85),
      child: Column(children: [
        Container(
          width: s.sp(48), height: s.sp(48),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: active ? AppColors.primary : AppColors.onSurfaceVariant, size: s.sp(22)),
        ),
        SizedBox(height: s.sp(8)),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: s.sp(11), color: active ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildSectorScroll(AppSizes s) {
    final sectors = [
      ('Giyim', Icons.checkroom),
      ('Yemek', Icons.restaurant),
      ('Market', Icons.shopping_cart),
      ('Kozmetik', Icons.face),
      ('Faturalar', Icons.bolt),
    ];
    return SizedBox(
      height: s.sp(44),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sectors.length,
        itemBuilder: (ctx, i) {
          return Container(
            margin: EdgeInsets.only(right: s.sp(8)),
            padding: EdgeInsets.symmetric(horizontal: s.sp(16), vertical: s.sp(8)),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(children: [
              Icon(sectors[i].$2, color: AppColors.primary, size: s.sp(18)),
              SizedBox(width: s.sp(8)),
              Text(sectors[i].$1, style: TextStyle(color: AppColors.onBackground, fontSize: s.sp(12), fontWeight: FontWeight.w600)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildResolvedHeader(AppSizes s) {
    final txnCount = _repo.transactions.length;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Çözümlenmiş İşlemler', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      Text(txnCount > 0 ? '$txnCount İşlem' : 'Veri yok', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildResolvedList(AppSizes s) {
    final txns = _repo.transactions;
    if (txns.isEmpty) {
      return buildEmptyState(icon: Icons.search_off, title: 'Çözümlenmiş işlem yok', subtitle: 'Banka verileriniz bağlandığında işlemler otomatik olarak çözümlenip kategorize edilecek.', sizes: s);
    }
    return Column(children: txns.take(5).map((t) => Container(
      margin: EdgeInsets.only(bottom: s.sp(12)),
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(children: [
        Container(width: s.sp(40), height: s.sp(40), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(t.icon, color: AppColors.primary, size: s.sp(20))),
        SizedBox(width: s.sp(16)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.resolvedMerchant ?? t.title, style: TextStyle(fontSize: s.sp(16), fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          SizedBox(height: s.sp(2)),
          Text(t.category, style: TextStyle(fontSize: s.sp(13), color: AppColors.onSurfaceVariant)),
        ])),
        Text(t.formattedAmount, style: TextStyle(fontSize: s.sp(14), fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      ]),
    )).toList());
  }

  Widget _buildAccuracyBanner(AppSizes s) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(s.sp(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.auto_awesome, color: AppColors.tertiary, size: s.sp(32)),
          SizedBox(width: s.sp(16)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Doğruluk Artışı', style: TextStyle(fontSize: s.sp(18), fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: s.sp(4)),
            Text(
              _repo.hasData ? 'API işlemlerinizi başarıyla çözümlüyor.' : 'API bağlantınız kurulduğunda işlem çözümleme doğruluğu burada gösterilecek.',
              style: TextStyle(fontSize: s.sp(14), color: AppColors.onSurfaceVariant, height: 1.3),
            ),
          ])),
        ]),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(size.width - 6, cy), paint);
    canvas.drawPath(Path()..moveTo(size.width, cy)..lineTo(size.width - 6, cy - 4)..lineTo(size.width - 6, cy + 4)..close(), Paint()..color = AppColors.primaryContainer..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}