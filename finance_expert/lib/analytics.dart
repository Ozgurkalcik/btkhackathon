import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DataRepository _repo = DataRepository();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    return Scaffold(
      appBar: buildCommonAppBar(context: context, title: 'Analiz'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: sizes.sp(20), right: sizes.sp(20), top: sizes.sp(24), bottom: sizes.sp(120)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Analiz', style: TextStyle(fontSize: sizes.sp(24), fontWeight: FontWeight.bold, color: AppColors.onBackground)),
          SizedBox(height: sizes.sp(4)),
          Text('Finansal sağlık özetiniz', style: TextStyle(fontSize: sizes.sp(14), color: AppColors.onSurfaceVariant)),
          SizedBox(height: sizes.sp(24)),
          _buildDonutChart(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildAiDiagnostics(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildLineChart(sizes),
        ]),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildDonutChart(AppSizes s) {
    final breakdown = _repo.getCategoryBreakdown();
    final totalSpent = breakdown.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(color: AppColors.surfaceContainer.withOpacity(0.7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Kategori Dağılımı', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          Icon(Icons.more_vert, color: AppColors.onSurfaceVariant, size: s.sp(20)),
        ]),
        SizedBox(height: s.sp(16)),
        SizedBox(
          width: s.sp(180), height: s.sp(180),
          child: Stack(alignment: Alignment.center, children: [
            if (breakdown.isNotEmpty)
              Positioned.fill(child: CustomPaint(painter: _DonutChartPainter(segments: _buildSegments(breakdown, totalSpent))))
            else
              Positioned.fill(child: CustomPaint(painter: _DonutChartPainter(segments: [_ChartSegment(1.0, Colors.white.withOpacity(0.1))]))),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('TOPLAM', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
              SizedBox(height: s.sp(2)),
              Text(totalSpent > 0 ? '₺${totalSpent.toStringAsFixed(0)}' : '—', style: TextStyle(fontSize: s.sp(22), fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            ]),
          ]),
        ),
        SizedBox(height: s.sp(16)),
        if (breakdown.isEmpty)
          Text('Veri bekleniyor...', style: TextStyle(fontSize: s.sp(13), color: AppColors.onSurfaceVariant)),
      ]),
    );
  }

  List<_ChartSegment> _buildSegments(Map<String, double> breakdown, double total) {
    final colors = [AppColors.primary, AppColors.tertiary, AppColors.secondary, AppColors.onBackground, AppColors.error];
    int i = 0;
    return breakdown.entries.map((e) => _ChartSegment(e.value / total, colors[i++ % colors.length])).toList();
  }

  Widget _buildAiDiagnostics(AppSizes s) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainer.withOpacity(0.7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.tertiary, Colors.transparent])))),
          Padding(
            padding: EdgeInsets.all(s.sp(16)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: EdgeInsets.all(s.sp(8)), decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.auto_awesome, color: AppColors.tertiary, size: s.sp(20))),
              SizedBox(width: s.sp(16)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AI Teşhis', style: TextStyle(fontSize: s.sp(18), fontWeight: FontWeight.w600, color: AppColors.tertiary)),
                SizedBox(height: s.sp(4)),
                Text(
                  _repo.hasData ? 'Harcama verileriniz analiz ediliyor. Burada anomali tespitleri ve optimizasyon önerileri gösterilecek.' : 'Banka bağlantınız kurulduğunda AI harcama kalıplarınızı analiz edecek ve önerilerde bulunacak.',
                  style: TextStyle(fontSize: s.sp(14), color: AppColors.onSurface, height: 1.4),
                ),
              ])),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildLineChart(AppSizes s) {
    return Container(
      padding: EdgeInsets.all(s.sp(16)),
      decoration: BoxDecoration(color: AppColors.surfaceContainer.withOpacity(0.7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Aylık Trend', style: TextStyle(fontSize: s.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            SizedBox(height: s.sp(2)),
            Text('Veri bekleniyor', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ]),
        ]),
        SizedBox(height: s.sp(24)),
        SizedBox(
          height: s.sp(150), width: double.infinity,
          child: CustomPaint(painter: _LineChartPainter(dataPoints: const [], lineColor: AppColors.primary)),
        ),
        SizedBox(height: s.sp(8)),
        Text('Banka verileriniz bağlandığında aylık harcama trendi burada gösterilecek.', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 12;
    const sw = 12.0;
    double start = -math.pi / 2;
    for (var seg in segments) {
      final sweep = seg.percentage * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, Paint()..color = seg.color..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  _LineChartPainter({required this.dataPoints, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.50), Offset(size.width, size.height * 0.50), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), gridPaint);
    if (dataPoints.isEmpty) return;
    final stepX = size.width / (dataPoints.length - 1);
    final pts = <Offset>[for (int i = 0; i < dataPoints.length; i++) Offset(i * stepX, dataPoints[i])];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cx = pts[i].dx + (pts[i + 1].dx - pts[i].dx) / 2;
      path.cubicTo(cx, pts[i].dy, cx, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    canvas.drawPath(path, Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _ChartSegment {
  final double percentage;
  final Color color;
  _ChartSegment(this.percentage, this.color);
}