import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('الخدمات المتاحة')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _HeroCard(totalCount: 110);
          }

          final section = _sections[index - 1];

          return Card(
            color: AppColors.panel,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.card,
              side: const BorderSide(color: AppColors.border),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              iconColor: AppColors.primary,
              collapsedIconColor: AppColors.muted,
              title: Text(
                section.title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                section.subtitle,
                style: const TextStyle(color: AppColors.muted),
              ),
              children: [
                const SizedBox(height: 6),
                ...section.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 7, right: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: AppColors.ink,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _HeroCard extends StatelessWidget {
  final int totalCount;

  const _HeroCard({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الخدمات المتاحة',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'استعرض $totalCount خدمة مرتبة حسب الفئات',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.aquaSoft,
              borderRadius: AppRadii.pill,
            ),
            child: const Text(
              '110 خدمة',
              style: TextStyle(
                color: AppColors.aquaStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogSection {
  final String title;
  final String subtitle;
  final List<String> items;

  const _CatalogSection({
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

const List<_CatalogSection> _sections = [
  _CatalogSection(
    title: 'الخدمات',
    subtitle: 'الخدمات الأساسية والمتقدمة',
    items: [
      'تنظيف المنزل الشامل',
      'تنظيف المطبخ المتقدم',
      'تنظيف الحمام العميق',
      'تنظيف النوافذ والزجاج',
      'تنظيف السجاد والموكيت',
      'تلميع الأرضيات',
      'تنظيف التكييف والفلاتر',
      'غسيل الملابس والكي',
      'تنظيف الثلاجة والفرن',
      'تنظيف المفروشات والأثاث',
    ],
  ),
  _CatalogSection(
    title: 'الأسعار',
    subtitle: 'باقات وأسعار مرنة',
    items: [
      'تنظيف شامل: 150 ريال',
      'تنظيف معيار: 100 ريال',
      'تنظيف أسبوعي: 280 ريال',
      'تنظيف شهري: 500 ريال',
      'تنظيف المطبخ: 60 ريال',
      'تنظيف الحمام: 50 ريال',
      'غسيل الملابس: 40 ريال',
      'تنظيف النوافذ: 80 ريال',
      'تنظيف السجاد: 120 ريال',
      'خدمة إضافية: 25 ريال',
    ],
  ),
  _CatalogSection(
    title: 'التوفرية',
    subtitle: 'أوقات مرنة وخدمة يومية',
    items: [
      'متوفر يومياً من 8 ص إلى 8 م',
      'خدمة في أيام الويكند',
      'حجز في نفس اليوم متاح',
      'توفر عند الطلب الطارئ',
      'جدول زمني مرن حسب احتياجك',
      'تواجد في 6 أيام أسبوعياً',
      'وقت تقديري للخدمة: 2-4 ساعات',
      'إمكانية تمديد الخدمة بطلب إضافي',
      'حجز للشهر القادم مفتوح',
      'أولويات حجز للعملاء المميزين',
    ],
  ),
  _CatalogSection(
    title: 'التقييمات',
    subtitle: 'مؤشرات الرضا والجودة',
    items: [
      'متوسط التقييم: 4.8 من 5',
      '2,340 تقييم موثق من عملاء',
      'نسبة الرضا: 96%',
      'أفضل خدمة: تنظيف شامل',
      'أسرع وقت استجابة: 15 دقيقة',
      'أكثر خدمة مطلوبة: التنظيف الأسبوعي',
      'تقييمات إيجابية: 2,250 تقييم',
      'تقييمات محايدة: 70 تقييم',
      'تقييمات سلبية: 20 تقييم',
      'آخر تقييم: أمس في 6 م',
    ],
  ),
  _CatalogSection(
    title: 'الحجوزات',
    subtitle: 'إدارة الطلبات بسهولة',
    items: [
      'احجز الآن بضغطة زر واحدة',
      'تأكيد الحجز فوري خلال دقيقة',
      'اختر التاريخ والوقت المناسب',
      'إمكانية الإلغاء حتى 24 ساعة قبل',
      'تعديل الحجز في أي وقت',
      'تنبيهات قبل الموعد بـ24 و2 ساعة',
      'سجل الحجوزات السابقة والمستقبلة',
      'ملاحظات إضافية للخدمة الخاصة',
      'حجوزات متكررة: أسبوعياً أو شهرياً',
      'تأكيد دخول موظفة للمنزل',
    ],
  ),
  _CatalogSection(
    title: 'طرق الدفع',
    subtitle: 'خيارات دفع متعددة',
    items: [
      'الدفع عند استلام الخدمة',
      'تحويل بنكي سريع والتحويل الفوري',
      'بطاقة ائتمان أو خصم',
      'محفظة رقمية (Apple Pay, Google Pay)',
      'تطبيق المحفظة الإلكترونية',
      'دفع نصف المبلغ قبل والنصف بعد',
      'بطاقات المتاجر والجهات',
      'تحويل عبر تطبيقات التحويل',
      'اشتراكات شهرية توفر 15%',
      'استرجاع الأموال ضمان 100%',
    ],
  ),
  _CatalogSection(
    title: 'أنواع التنظيف',
    subtitle: 'خدمات مخصصة حسب المكان',
    items: [
      'تنظيف الفلل والقصور',
      'تنظيف الشقق والأدوار',
      'تنظيف المكاتب والشركات',
      'تنظيف المدارس والمؤسسات',
      'تنظيف المحلات التجارية',
      'تنظيف الخزانات والصهاريج',
      'تنظيف الكنب والسجاد بالبخار',
      'تنظيف ما بعد الإصلاح والتجديد',
      'تنظيف المطاعم والمقاهي',
      'تنظيف العمائر السكنية',
    ],
  ),
  _CatalogSection(
    title: 'الخبرة',
    subtitle: 'فريق مدرّب وموثوق',
    items: [
      'أكثر من 8 سنوات بالخدمة',
      'متدربة على أحدث الطرق',
      'شهادات تدريب معترف بها',
      'خبرة مع عائلات VIP',
      'تعامل مع حالات خاصة واحتياجات',
      'معرفة بالمنظفات الآمنة والصحية',
      'سرعة وكفاءة في التنظيف',
      'احترام الخصوصية والأمان',
      'تدريب مستمر كل 3 أشهر',
      'فريق متعاون واحترافي',
    ],
  ),
  _CatalogSection(
    title: 'المناطق',
    subtitle: 'التغطية الجغرافية',
    items: [
      'الرياض: جميع الأحياء',
      'الشرقية: الخبر والدمام والقطيف',
      'الغربية: جدة ومكة والمدينة',
      'الجنوبية: أبها والطائف',
      'الوسطى: القصيم وحائل',
      'الشمالية: تبوك والجوف',
      'توسع دائم لمناطق جديدة',
      'تسليم متاح حتى 50 كم',
      'خدمة في الضواحي والقرى',
      'نقل مجاني للمنطقة المحددة',
    ],
  ),
  _CatalogSection(
    title: 'السياسات',
    subtitle: 'الأمان والالتزام',
    items: [
      'عدم الإفصاح عن بيانات العميل',
      'احترام الخصوصية المطلقة',
      'عدم الدخول بدون تصريح مكتوب',
      'تأمين كامل على الممتلكات',
      'سياسة عدم الضرر والتلف',
      'حق الإلغاء في أي وقت',
      'ضمان جودة الخدمة',
      'عدم تسريب أرقام هواتف',
      'اتفاقيات سرية صارمة',
      'امتثال كامل للقوانين المحلية',
    ],
  ),
  _CatalogSection(
    title: 'الدعم',
    subtitle: 'مساعدة سريعة على مدار الساعة',
    items: [
      'خدمة العملاء: 24/7',
      'الرد على الأسئلة خلال ساعة',
      'دعم عبر الواتس آب والهاتف',
      'حل المشاكل فوري بلا تأخير',
      'موظف دعم متخصص دائماً',
      'ملخص الخدمة بعد الانتهاء',
      'نموذج رأي العميل والملاحظات',
      'استجابة سريعة للشكاوى',
      'برنامج ولاء وحوافز',
      'تطبيق جوال سهل الاستخدام',
    ],
  ),
];
