import 'dart:math' as math;
import 'package:flutter/material.dart';

/// شعار شغّالتي — 4 وسادات مربعة محدبة للخارج
/// الأضلاع الخارجية محدبة للخارج (بعيداً عن مركز الصورة)
/// مطابق للشعار الأصلي: وسادات + فجوة X بيضاء
class LogoPainter extends CustomPainter {
  final bool darkBackground;
  const LogoPainter({this.darkBackground = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w  = size.width;
    final h  = size.height;
    final cx = w / 2;
    final cy = h / 2;

    if (darkBackground) {
      final bgPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF02023A), Color(0xFF04419A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);
    }

    // gap = نصف عرض الفجوة (X البيضاء)
    // ext = امتداد كل وسادة من المركز للحافة الخارجية
    // cvx = شدة التحدب للخارج
    final gap = w * 0.038;
    final ext = w * 0.42;
    final cvx = 0.62;

    final pads = [
      // TL
      [Offset(cx-gap,cy-gap), Offset(cx-gap,cy-ext), Offset(cx-ext,cy-ext), Offset(cx-ext,cy-gap)],
      // TR
      [Offset(cx+gap,cy-gap), Offset(cx+ext,cy-gap), Offset(cx+ext,cy-ext), Offset(cx+gap,cy-ext)],
      // BR
      [Offset(cx+gap,cy+gap), Offset(cx+gap,cy+ext), Offset(cx+ext,cy+ext), Offset(cx+ext,cy+gap)],
      // BL
      [Offset(cx-gap,cy+gap), Offset(cx-ext,cy+gap), Offset(cx-ext,cy+ext), Offset(cx-gap,cy+ext)],
    ];

    final padColors = [
      [const Color(0xFF5050E0), const Color(0xFF2020B5)],
      [const Color(0xFF4040D0), const Color(0xFF1E1EA8)],
      [const Color(0xFF2E2EC0), const Color(0xFF181898)],
      [const Color(0xFF3838C8), const Color(0xFF1A1AA0)],
    ];

    for (int i = 0; i < 4; i++) {
      final pts = pads[i];
      final path = Path();

      // cp للخارج: منتصف الضلع + انزياح بعيداً عن cx,cy
      Offset cpOut(Offset a, Offset b) {
        final mx = (a.dx + b.dx) / 2;
        final my = (a.dy + b.dy) / 2;
        return Offset(mx + (mx - cx) * cvx, my + (my - cy) * cvx);
      }

      path.moveTo(pts[0].dx, pts[0].dy);
      // ضلع 0→1 (أحد الأضلاع الداخلية — مستقيم)
      path.lineTo(pts[1].dx, pts[1].dy);
      // ضلع 1→2 (الحافة الخارجية الأولى — محدب للخارج)
      final cp12 = cpOut(pts[1], pts[2]);
      path.quadraticBezierTo(cp12.dx, cp12.dy, pts[2].dx, pts[2].dy);
      // ضلع 2→3 (الحافة الخارجية الثانية — محدب للخارج)
      final cp23 = cpOut(pts[2], pts[3]);
      path.quadraticBezierTo(cp23.dx, cp23.dy, pts[3].dx, pts[3].dy);
      // ضلع 3→0 (الضلع الداخلي الآخر — مستقيم)
      path.lineTo(pts[0].dx, pts[0].dy);
      path.close();

      final bounds = path.getBounds();
      final gradPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: padColors[i],
        ).createShader(bounds);
      canvas.drawPath(path, gradPaint);

      final edgePaint = Paint()
        ..color = const Color(0x65C8DAFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.007
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, edgePaint);
    }

    // لمعة زجاجية
    final hlPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.55),
        radius: 0.55,
        colors: [Colors.white.withOpacity(0.28), Colors.white.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), hlPaint);

    // ظل ناعم
    if (!darkBackground) {
      final shadowPaint = Paint()
        ..color = const Color(0x1A000088)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + ext * 0.85), width: ext * 1.6, height: ext * 0.28),
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.darkBackground != darkBackground;
}

class LogoWidget extends StatelessWidget {
  final double size;
  final bool darkBackground;
  final bool withShadow;
  const LogoWidget({super.key, this.size=80, this.darkBackground=false, this.withShadow=true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size(size, size),
      painter: LogoPainter(darkBackground: darkBackground || isDark),
    );
  }
}
