import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom vector painter for the Trylo cyclical heart-arrow logo mark.
class TryloHeartIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const TryloHeartIcon({
    super.key,
    this.size = 32.0,
    this.color = Colors.white,
    this.strokeWidth = 2.8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TryloHeartPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _TryloHeartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _TryloHeartPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Outer heart shape path
    final path = Path();
    final topDipX = w * 0.50;
    final topDipY = h * 0.32;

    path.moveTo(topDipX, topDipY);

    // Right lobe
    path.cubicTo(
      w * 0.62, h * 0.12,
      w * 0.88, h * 0.18,
      w * 0.88, h * 0.40,
    );

    // Right lower curve towards bottom
    path.cubicTo(
      w * 0.88, h * 0.58,
      w * 0.70, h * 0.74,
      w * 0.50, h * 0.81,
    );

    // Bottom loop towards left
    path.cubicTo(
      w * 0.38, h * 0.83,
      w * 0.26, h * 0.82,
      w * 0.18, h * 0.72,
    );

    // Left lower curve up
    path.cubicTo(
      w * 0.12, h * 0.62,
      w * 0.12, h * 0.52,
      w * 0.12, h * 0.40,
    );

    // Left lobe back to top center
    path.cubicTo(
      w * 0.12, h * 0.18,
      w * 0.38, h * 0.12,
      topDipX, topDipY,
    );

    canvas.drawPath(path, paint);

    // Bottom left-pointing arrow
    final arrowTipX = w * 0.45;
    final arrowTipY = h * 0.81;
    final arrowLen = w * 0.11;

    final arrowPath1 = Path();
    arrowPath1.moveTo(
      arrowTipX + arrowLen * math.cos(math.pi / 5.5),
      arrowTipY - arrowLen * math.sin(math.pi / 5.5),
    );
    arrowPath1.lineTo(arrowTipX, arrowTipY);
    arrowPath1.lineTo(
      arrowTipX + arrowLen * math.cos(math.pi / 5.5),
      arrowTipY + arrowLen * math.sin(math.pi / 5.5),
    );

    canvas.drawPath(arrowPath1, paint);

    // Inner loop curve connecting the cycle
    final innerLoop = Path();
    innerLoop.moveTo(w * 0.32, h * 0.68);
    innerLoop.cubicTo(
      w * 0.42, h * 0.64,
      w * 0.58, h * 0.64,
      w * 0.68, h * 0.68,
    );
    canvas.drawPath(innerLoop, paint);

    // Inner loop right-pointing arrow
    final innerArrowTipX = w * 0.56;
    final innerArrowTipY = h * 0.65;
    final innerArrowLen = w * 0.09;

    final arrowPath2 = Path();
    arrowPath2.moveTo(
      innerArrowTipX - innerArrowLen * math.cos(math.pi / 5.5),
      innerArrowTipY - innerArrowLen * math.sin(math.pi / 5.5),
    );
    arrowPath2.lineTo(innerArrowTipX, innerArrowTipY);
    arrowPath2.lineTo(
      innerArrowTipX - innerArrowLen * math.cos(math.pi / 5.5),
      innerArrowTipY + innerArrowLen * math.sin(math.pi / 5.5),
    );

    canvas.drawPath(arrowPath2, paint);
  }

  @override
  bool shouldRepaint(covariant _TryloHeartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
