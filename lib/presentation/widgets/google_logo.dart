import 'package:flutter/material.dart';

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double rectSize = size.width;
    final double strokeWidth = rectSize * 0.24;
    final double radius = (rectSize - strokeWidth) / 2;
    final Offset center = Offset(rectSize / 2, rectSize / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Red: Top arc. Covers from -115 degrees to -25 degrees.
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.007, 1.571, false, paint);

    // Yellow: Left arc. Covers from -205 degrees to -115 degrees.
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.578, 1.571, false, paint);

    // Green: Bottom arc. Covers from 45 degrees to 155 degrees.
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.785, 1.920, false, paint);

    // Blue: Right bottom arc. Covers from -25 degrees to 45 degrees.
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.436, 1.222, false, paint);

    // Horizontal bar of the 'G'
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double barHeight = strokeWidth;
    final Rect barRect = Rect.fromLTRB(
      center.dx,
      center.dy - barHeight / 2,
      center.dx + radius + strokeWidth / 2,
      center.dy + barHeight / 2,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const GoogleLogoPainter(),
      ),
    );
  }
}
