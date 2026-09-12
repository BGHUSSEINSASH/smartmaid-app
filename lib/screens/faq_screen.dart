import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

const _faqItems = <(String, String)>[
  (
    'كيف أحجز عاملة؟',
    'اختر العاملة المناسبة من الرئيسية أو البحث، حدد التاريخ والوقت ونوع التعاقد، أضف الخدمات الإضافية، ثم أكمل الدفع. ستصلك رسالة تأكيد فوراً.'
  ),
  (
    'ما هي طرق الدفع المتاحة؟',
    'يمكنك الدفع ببطاقة بنكية، أو عبر محفظة SmartPay داخل التطبيق، أو نقداً عند وصول العاملة.'
  ),
  (
    'هل يمكنني إلغاء الحجز؟',
    'نعم، يمكنك الإلغاء مجاناً قبل 24 ساعة من موعد الحجز. الإلغاء بعد ذلك يخضع لسياسة الاسترداد الجزئي (50%).'
  ),
  (
    'كيف تعمل نقاط المكافآت؟',
    'تكسب نقطة عن كل دولار تنفقه، وتقييم 5 نجوم يمنحك +50 نقطة، ودعوة صديق تمنحكما +100 نقطة. استبدل النقاط بخصومات على حجوزاتك القادمة.'
  ),
  (
    'هل العاملات موثّقات؟',
    'جميع عاملاتنا وخاصة العاملات عبر الشركات الشريكة يمررن تحقق الهوية وفحص الخلفية قبل اعتمادهن على المنصة.'
  ),
  (
    'ما هي عمولة المنصة؟',
    'تقتطع المنصة 20% من قيمة كل عملية مكتملة، بينما يحصل العاملة/الشركة على 80% من قيمة الحجز.'
  ),
  (
    'كيف أشحن محفظة SmartPay؟',
    'من شاشة المحفظة اضغط «شحن رصيد»، اختر المبلغ وأكمل الدفع بالبطاقة. الرصيد يظهر فوراً ويمكن استخدامه في أي حجز.'
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('الأسئلة الشائعة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ..._faqItems.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text(e.$1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.muted,
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  children: [
                    Text(e.$2,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: isDark
                                ? Colors.white70
                                : AppColors.muted)),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4))),
            leading: const Icon(Icons.support_agent_rounded,
                color: AppColors.primary),
            title: const Text('لم تجد إجابتك؟',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            subtitle: const Text('تواصل مع فريق الدعم مباشرة',
                style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => context.push('/chat'),
          ),
        ],
      ),
    );
  }
}
