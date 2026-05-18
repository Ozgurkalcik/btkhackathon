import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'navigation_helper.dart';
import 'services/data_repository.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});
  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final DataRepository _repo = DataRepository();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndexFromRoute(context);
    final sizes = AppSizes(context);
    return Scaffold(
      extendBody: true,
      appBar: buildCommonAppBar(context: context, title: 'Finansal Sağlık'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: sizes.sp(20), right: sizes.sp(20), top: sizes.sp(24), bottom: sizes.sp(120)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildScoreGauge(sizes),
          SizedBox(height: sizes.sp(24)),
          _buildAiAdvice(sizes),
          SizedBox(height: sizes.sp(24)),
          Text('Harcama Etki Analizi', style: TextStyle(fontSize: sizes.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          SizedBox(height: sizes.sp(16)),
          _buildImpactSection(sizes),
          SizedBox(height: sizes.sp(24)),
          Text('Uyarılar', style: TextStyle(fontSize: sizes.sp(20), fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          SizedBox(height: sizes.sp(16)),
          _buildWarningsSection(sizes),
        ]),
      ),
      bottomNavigationBar: buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildScoreGauge(AppSizes s) {
    final score = _repo.hasData ? 78.0 : 0.0;
    return Container(
      padding: EdgeInsets.all(s.sp(24)),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Center(
        child: Column(children: [
          SizedBox(
            width: s.sp(180), height: s.sp(180),
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(child: CustomPaint(painter: _GaugePainter(score: score, maxScore: 100, trackColor: Colors.white.withOpacity(0.1), progressColor: AppColors.primary))),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_repo.hasData ? '${score.toInt()}' : '—', style: TextStyle(fontSize: s.sp(32), fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                Text('SKOR', style: TextStyle(fontSize: s.sp(12), color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
              ]),
            ]),
          ),
          SizedBox(height: s.sp(16)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: s.sp(12), vertical: s.sp(6)),
            decoration: BoxDecoration(
              color: _repo.hasData ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerHigh,
              border: Border.all(color: _repo.hasData ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_repo.hasData ? Icons.check_circle : Icons.hourglass_empty, color: _repo.hasData ? AppColors.primary : AppColors.onSurfaceVariant, size: s.sp(20)),
              SizedBox(width: s.sp(8)),
              Text(_repo.hasData ? 'İyi' : 'Veri bekleniyor', style: TextStyle(color: _repo.hasData ? AppColors.primary : AppColors.onSurfaceVariant, fontSize: s.sp(16), fontWeight: FontWeight.w600)),
            ]),
          ),
          SizedBox(height: s.sp(8)),
          Text(
            _repo.hasData ? 'Finansal sağlığınız geçen haftaya göre iyileşiyor.' : 'Banka hesabınızı bağlayarak finansal sağlık skorunuzu görün.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: s.sp(14), color: AppColors.onSurfaceVariant),
          ),
        ]),
      ),
    );
  }

  Widget _buildAiAdvice(AppSizes s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(s.sp(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: EdgeInsets.all(s.sp(8)),
              decoration: BoxDecoration(color: AppColors.tertiary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.psychology_alt, color: AppColors.tertiary, size: s.sp(20)),
            ),
            SizedBox(width: s.sp(16)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI OPTİMİZASYON', style: TextStyle(fontSize: s.sp(12), color: AppColors.tertiary, fontWeight: FontWeight.bold)),
              SizedBox(height: s.sp(4)),
              Text(
                _repo.hasData ? 'Harcama verilerinize göre kişiselleştirilmiş tavsiyeler burada gösterilecek.' : 'Verileriniz bağlandığında AI finansal sağlığınızı analiz edecek.',
                style: TextStyle(fontSize: s.sp(15), color: AppColors.onSurface, height: 1.5),
              ),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildImpactSection(AppSizes s) {
    if (!_repo.hasData) {
      return buildEmptyState(icon: Icons.bar_chart, title: 'Etki analizi hazır değil', subtitle: 'Harcama verileriniz toplandığında kategorik etki analizi burada gösterilecek.', sizes: s);
    }
    return const SizedBox.shrink();
  }

  Widget _buildWarningsSection(AppSizes s) {
    if (!_repo.hasData) {
      return buildEmptyState(icon: Icons.notifications_none, title: 'Uyarı yok', subtitle: 'Finansal sağlık uyarıları verileriniz analiz edildikten sonra burada gösterilecek.', sizes: s);
    }
    return const SizedBox.shrink();
  }
}

class _GaugePainter extends CustomPainter {
  final double score, maxScore;
  final Color trackColor, progressColor;
  _GaugePainter({required this.score, required this.maxScore, required this.trackColor, required this.progressColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    const strokeWidth = 8.0;
    canvas.drawCircle(center, radius, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
    double sweepAngle = (score / maxScore) * 2 * math.pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, Paint()..color = progressColor..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = strokeWidth);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.score != score;
}