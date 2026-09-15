import 'package:flutter/material.dart';

/// Breakpoints وأدوات Responsive Design لتطبيق شغّالتي
/// يدعم: هاتف + تابلت + ويندوز
class Bp {
  // ── حدود أحجام الشاشة ─────────────────────────────────────────
  static const double phoneMax   = 600;   // < 600px = هاتف
  static const double tabletMax  = 1200;  // 600-1199px = تابلت
                                          // >= 1200px = ديسكتوب/ويندوز

  // ── maxWidth للمحتوى ──────────────────────────────────────────
  static const double contentMax  = 720;  // أقصى عرض للمحتوى
  static const double formMax     = 440;  // أقصى عرض للنماذج (login...)
  static const double cardMax     = 560;  // أقصى عرض للبطاقات الفردية

  // ── Getters مساعدة ────────────────────────────────────────────
  static double w(BuildContext c)  => MediaQuery.sizeOf(c).width;
  static double h(BuildContext c)  => MediaQuery.sizeOf(c).height;

  static bool isPhone(BuildContext c)   => w(c) < phoneMax;
  static bool isTablet(BuildContext c)  => w(c) >= phoneMax && w(c) < tabletMax;
  static bool isDesktop(BuildContext c) => w(c) >= tabletMax;
  static bool isWide(BuildContext c)    => w(c) >= phoneMax; // تابلت+

  // ── قيم نسبية مقيّدة ──────────────────────────────────────────

  /// حجم شعار الـ Splash
  static double logoSize(BuildContext c) =>
      (w(c) * 0.30).clamp(100.0, 200.0);

  /// حجم الخط الرئيسي
  static double titleFontSize(BuildContext c) =>
      (w(c) * 0.050).clamp(20.0, 42.0);

  /// حجم الخط الثانوي
  static double subtitleFontSize(BuildContext c) =>
      (w(c) * 0.034).clamp(12.0, 18.0);

  /// padding أفقي عام للصفحات
  static double hPad(BuildContext c) =>
      isPhone(c) ? 16.0 : isTablet(c) ? 24.0 : 32.0;

  /// padding عمودي
  static double vPad(BuildContext c) =>
      isPhone(c) ? 16.0 : 24.0;

  /// عدد أعمدة الـ Grid
  static int gridCols(BuildContext c) =>
      isPhone(c) ? 1 : isTablet(c) ? 2 : 3;

  /// ارتفاع NavBar
  static double navBarHeight(BuildContext c) =>
      isPhone(c) ? 68.0 : isTablet(c) ? 72.0 : 64.0;

  /// margin الـ NavBar
  static EdgeInsets navBarMargin(BuildContext c) => EdgeInsets.fromLTRB(
    isPhone(c) ? 16.0 : 28.0,
    0,
    isPhone(c) ? 16.0 : 28.0,
    isPhone(c) ? 16.0 : 20.0,
  );

  /// نصف قطر الـ NavBar
  static double navBarRadius(BuildContext c) =>
      isPhone(c) ? 30.0 : 24.0;

  /// padding سفلي لـ ListView (فوق NavBar)
  static double listBottomPad(BuildContext c) =>
      MediaQuery.of(c).padding.bottom + navBarHeight(c) + (isPhone(c) ? 20 : 28);
}

// ─────────────────────────────────────────────────────────────────
/// ContentBox — يُقيّد عرض المحتوى على الشاشات الكبيرة
/// يُستخدم لتغليف محتوى الشاشات الرئيسية
class ContentBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool center;

  const ContentBox({
    super.key,
    required this.child,
    this.maxWidth = Bp.contentMax,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Bp.isPhone(context)) return child;

    final box = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    return center ? Center(child: box) : box;
  }
}

// ─────────────────────────────────────────────────────────────────
/// SliverContentBox — نسخة Sliver لـ ContentBox
class SliverContentBox extends StatelessWidget {
  final Widget sliver;
  final double maxWidth;

  const SliverContentBox({
    super.key,
    required this.sliver,
    this.maxWidth = Bp.contentMax,
  });

  @override
  Widget build(BuildContext context) {
    if (Bp.isPhone(context)) return sliver;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: ((Bp.w(context) - maxWidth) / 2).clamp(0.0, double.infinity),
      ),
      sliver: sliver,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
/// FormCard — بطاقة للنماذج (login, register...) على الشاشات الكبيرة
class FormCard extends StatelessWidget {
  final Widget child;
  const FormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Bp.isPhone(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Bp.formMax),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: child,
          ),
        ),
      ),
    );
  }
}
