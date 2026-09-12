import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const _tips = [
    _Tip(
      icon: Icons.cleaning_services_rounded,
      title: 'نصيحة التنظيف اليومي',
      body: 'ابدأ دائماً من الأعلى إلى الأسفل ومن الداخل إلى الخارج لضمان عدم إعادة تلوث الأماكن النظيفة.',
      color: AppColors.primary,
    ),
    _Tip(
      icon: Icons.kitchen_rounded,
      title: 'نظافة المطبخ',
      body: 'استخدمي خليط الماء والخل لتنظيف الأسطح الرخامية. يزيل البقع الصعبة ويعقم في نفس الوقت.',
      color: AppColors.accent,
    ),
    _Tip(
      icon: Icons.bathtub_rounded,
      title: 'الحمامات والرخام',
      body: 'البابيكربونات (بيكنج صودا) مع الماء تعطيك معجوناً فعالاً لتنظيف البلاط والرخام.',
      color: AppColors.success,
    ),
    _Tip(
      icon: Icons.weekend_rounded,
      title: 'aintenance الأثاث',
      body: 'لأثاث الخشب، استخدمي قطعة قماش مبللة بماء عادي مع قليل من زيت الزيتون لللمعان.',
      color: AppColors.warning,
    ),
    _Tip(
      icon: Icons.content_cut_rounded,
      title: 'ترتيب وتنظيم',
      body: 'قاعدة الأشياء الثلاثة: ما استخدمتيه في آخر 3 أشهر احتفظي به، وما لا يزيد عن 3 سنوات يمكنك التخلص منه.',
      color: AppColors.error,
    ),
    _Tip(
      icon: Icons.air_rounded,
      title: 'تنقية الهواء',
      body: 'افتحي النوافذ 15 دقيقة يومياً للتهوية الطبيعية. تقليل الرطوبة يمنع العفن والأوساخ.',
      color: AppColors.primary,
    ),
    _Tip(
      icon: Icons.local_laundry_service_rounded,
      title: 'غسيل الملابس',
      body: 'افصلي الملابس حسب اللون قبل الغسل. استخدمي ماء بارداً للمعافا ودافئاً لل言われ.',
      color: AppColors.accent,
    ),
    _Tip(
      icon: Icons.child_care_rounded,
      title: 'رعاية الأطفال',
      body: 'اجعلي وقت النظافة تجربة ممتعة للأطفال بتشغيل موسيقى مرحة وتقسيم المهام حسب العمر.',
      color: AppColors.success,
    ),
    _Tip(
      icon: Icons.pets_rounded,
      title: 'إذا كان لديك حيوان أليف',
      body: 'استخدمي مكنسة كهربائية قبل الممسحة العادية لإزالة الشعر. ماء خل مخفف يزيل الروائح.',
      color: AppColors.warning,
    ),
    _Tip(
      icon: Icons.spa_rounded,
      title: 'نصائح النباتات',
      body: 'اغسلي أوراق النباتات بالسفنجة مرة كل أسبوع. استخدمي ماء الخضروات المتبقة كسماد طبيعي.',
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('نصائح التنظيف 💡')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _tips.length,
        itemBuilder: (context, i) {
          final tip = _tips[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tip.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(tip.icon, size: 24, color: tip.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(tip.body,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.6)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _Tip({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });
}
