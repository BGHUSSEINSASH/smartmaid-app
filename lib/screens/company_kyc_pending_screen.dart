import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../widgets/pro_components.dart';

class CompanyKycPendingScreen extends ConsumerWidget {
  const CompanyKycPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.pageBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: .1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.warning, width: 2),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: AppColors.warning, size: 48),
              ),
              const SizedBox(height: 28),

              const Text(
                'حسابك قيد المراجعة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'تم استلام طلب تسجيل شركتك وسيتم مراجعته من فريق SmartMaid خلال 24-48 ساعة عمل.',
                style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // خطوات المراجعة
              ProCard(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _KycStep(
                    number: '1',
                    title: 'استلام الطلب',
                    subtitle: 'تم استلام بيانات شركتك',
                    done: true,
                  ),
                  const SizedBox(height: 16),
                  _KycStep(
                    number: '2',
                    title: 'مراجعة المستندات',
                    subtitle: 'التحقق من السجل التجاري وبيانات الاتصال',
                    done: false,
                    active: true,
                  ),
                  const SizedBox(height: 16),
                  _KycStep(
                    number: '3',
                    title: 'الموافقة وتفعيل الحساب',
                    subtitle: 'ستصلك رسالة تأكيد فور الموافقة',
                    done: false,
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(children: [
                  Icon(Icons.info_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ستصلك إشعار فور مراجعة طلبك. تأكد أن البيانات المدخلة صحيحة.',
                      style: TextStyle(color: AppColors.primary, fontSize: 12.5),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.support_agent_rounded),
                  label: const Text('التواصل مع الدعم'),
                  onPressed: () => context.push('/support'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KycStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  const _KycStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.done,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.success
        : active
            ? AppColors.primary
            : AppColors.muted;

    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: active ? 2 : 1),
        ),
        child: Center(
          child: done
              ? Icon(Icons.check_rounded, color: color, size: 18)
              : Text(number,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.primary : null)),
          Text(subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ]),
      ),
      if (active)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('جارٍ المراجعة',
              style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
    ]);
  }
}
