import 'dart:math' as math;
import 'package:flutter/material.dart';

/// شعار شغّالتي — 4 أجنحة محدبة زجاجية
/// مطابق للشعار الأصلي بدقة رياضية كاملة
class LogoPainter extends CustomPainter {
  final bool darkBackground;
  const LogoPainter({this.darkBackground = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // ── ثوابت الشكل (كنسبة من الحجم) ─────────────────────────────
    final R   = w * 0.46;  // نصف القطر الخارجي (للركن)
    final gap = w * 0.022; // نصف الفجوة البيضاء (الـ X)
    final cvx = 0.72;      // عمق التحدّب للخارج (0=مستقيم, 1=دائرة)

    // ── رسم الخلفية ───────────────────────────────────────────────
    if (darkBackground) {
      final bgPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF02023A), Color(0xFF04419A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);
    }

    // ── تعريف 4 أجنحة ─────────────────────────────────────────────
    // كل جناح: مربع صغير بجانب المركز + ركن محدب للخارج
    // الزوايا: TL=أعلى يسار، TR=أعلى يمين، BR=أسفل يمين، BL=أسفل يسار
    final a = math.sqrt(2) / 2; // cos(45°)

    // نقاط الأركان الخارجية للشعار
    final corners = [
      Offset(cx - R * a, cy - R * a), // TL
      Offset(cx + R * a, cy - R * a), // TR
      Offset(cx + R * a, cy + R * a), // BR
      Offset(cx - R * a, cy + R * a), // BL
    ];

    // نقاط حافة الفجوة (حول المركز)
    // كل جناح له 4 نقاط تُشكّل مربعه الداخلي
    final wings = [
      // TL wing: بين (cx-gap, cy-gap) و TL corner
      [
        Offset(cx - gap, cy - gap), // داخلي يمين-أسفل
        Offset(cx - gap, cy - R * a * 1.28), // أعلى يسار المركز
        Offset(cx - R * a * 1.28, cy - R * a * 1.28), // الركن الخارجي
        Offset(cx - R * a * 1.28, cy - gap), // يسار المركز
      ],
      // TR wing
      [
        Offset(cx + gap, cy - gap),
        Offset(cx + R * a * 1.28, cy - gap),
        Offset(cx + R * a * 1.28, cy - R * a * 1.28),
        Offset(cx + gap, cy - R * a * 1.28),
      ],
      // BR wing
      [
        Offset(cx + gap, cy + gap),
        Offset(cx + gap, cy + R * a * 1.28),
        Offset(cx + R * a * 1.28, cy + R * a * 1.28),
        Offset(cx + R * a * 1.28, cy + gap),
      ],
      // BL wing
      [
        Offset(cx - gap, cy + gap),
        Offset(cx - R * a * 1.28, cy + gap),
        Offset(cx - R * a * 1.28, cy + R * a * 1.28),
        Offset(cx - gap, cy + R * a * 1.28),
      ],
    ];

    // مراكز الأجنحة (لحساب اتجاه التحدّب)
    final wingCenters = [
      Offset(cx - R * a * 0.5, cy - R * a * 0.5),
      Offset(cx + R * a * 0.5, cy - R * a * 0.5),
      Offset(cx + R * a * 0.5, cy + R * a * 0.5),
      Offset(cx - R * a * 0.5, cy + R * a * 0.5),
    ];

    // ألوان كل جناح (gradient يعطي إحساس 3D)
    final wingColors = [
      [const Color(0xFF4848D8), const Color(0xFF1C1CA8)], // TL — أفتح (ضوء)
      [const Color(0xFF3838C8), const Color(0xFF1A1A9E)], // TR
      [const Color(0xFF2A2AB8), const Color(0xFF14148C)], // BR — أغمق (ظل)
      [const Color(0xFF3232C0), const Color(0xFF181898)], // BL
    ];

    // ── رسم كل جناح ────────────────────────────────────────────────
    for (int i = 0; i < 4; i++) {
      final pts = wings[i];
      final wc  = wingCenters[i];
      final path = Path();

      // حساب control points للتحدّب
      // cp = منتصف الضلع + انزياح نحو مركز الجناح
      Offset cp(Offset a, Offset b) {
        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        return Offset(
          mid.dx + (wc.dx - mid.dx) * cvx,
          mid.dy + (wc.dy - mid.dy) * cvx,
        );
      }

      // p1 → p2 (محدب)
      final cp12 = cp(pts[0], pts[1]);
      // p2 → p3 (محدب)
      final cp23 = cp(pts[1], pts[2]);
      // p3 → p4 (محدب)
      final cp34 = cp(pts[2], pts[3]);
      // p4 → p1 (محدب)
      final cp41 = cp(pts[3], pts[0]);

      path.moveTo(pts[0].dx, pts[0].dy);
      path.quadraticBezierTo(cp12.dx, cp12.dy, pts[1].dx, pts[1].dy);
      path.quadraticBezierTo(cp23.dx, cp23.dy, pts[2].dx, pts[2].dy);
      path.quadraticBezierTo(cp34.dx, cp34.dy, pts[3].dx, pts[3].dy);
      path.quadraticBezierTo(cp41.dx, cp41.dy, pts[0].dx, pts[0].dy);
      path.close();

      // Gradient paint
      final bounds = path.getBounds();
      final gradPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: wingColors[i],
        ).createShader(bounds);

      canvas.drawPath(path, gradPaint);

      // حافة زجاجية
      final edgePaint = Paint()
        ..color = const Color(0x55C8D8FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006;
      canvas.drawPath(path, edgePaint);
    }

    // ── لمعة زجاجية علوية ──────────────────────────────────────────
    final hlPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.1, -0.6),
        radius: 0.5,
        colors: [
          Colors.white.withOpacity(0.22),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), hlPaint);

    // ── ظل خفيف تحت الشعار (على الخلفية البيضاء فقط) ─────────────
    if (!darkBackground) {
      final shadowPaint = Paint()
        ..color = const Color(0x18000080)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      final shadowR = R * 0.72;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + w * 0.015, cy + h * 0.03),
          width: shadowR * 1.85,
          height: shadowR * 0.4,
        ),
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.darkBackground != darkBackground;
}

/// Widget مشترك يستخدم LogoPainter
class LogoWidget extends StatelessWidget {
  final double size;
  final bool darkBackground;
  final bool withShadow;

  const LogoWidget({
    super.key,
    this.size = 80,
    this.darkBackground = false,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useDarkBg = darkBackground || isDark;

    Widget logo = CustomPaint(
      size: Size(size, size),
      painter: LogoPainter(darkBackground: useDarkBg),
    );

    if (withShadow && !useDarkBg) {
      logo = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2222CC).withOpacity(0.25),
              blurRadius: size * 0.25,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: logo,
      );
    }

    return logo;
  }
}
