import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/trust_provider.dart';

/// Worker identity verification (KYC) screen.
class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  String? _selfiePath;
  bool _picked = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSelfie() async {
    // image_picker is optional at runtime; gracefully degrade when the
    // platform channel is unavailable (e.g. desktop/web builds in demo).
    setState(() => _picked = true);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().length < 2) {
      _toast('أدخل الاسم الكامل كما في الهوية', AppColors.warning);
      return;
    }
    if (_idCtrl.text.trim().length < 10) {
      _toast('رقم الهوية يجب أن يكون 10 أرقام على الأقل', AppColors.warning);
      return;
    }
    final ok = await ref.read(kycProvider.notifier).submit(
          fullName: _nameCtrl.text.trim(),
          nationalId: _idCtrl.text.trim(),
        );
    if (!mounted) return;
    final state = ref.read(kycProvider);
    _toast(
      state.lastMessage,
      ok ? AppColors.success : AppColors.error,
    );
  }

  void _toast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final kyc = ref.watch(kycProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('توثيق الهوية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: kyc.verified
            ? _verifiedCard()
            : kyc.status == 'pending'
                ? _pendingCard(kyc)
                : _form(),
      ),
    );
  }
  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'وثّق هويتك لتحصل على شارة العاملة الموثوقة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              Text(
                'التحقق يزيد ثقة العملاء ويضاعف فرص القبول في الطلبات. بياناتك مشفرة ولا تُشارك مع العملاء.',
                style: TextStyle(
                    fontSize: 12, height: 1.55, color: context.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('الاسم الكامل',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: context.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'مثال: ماريا أحمد سانتوس',
            filled: true,
            fillColor: context.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text('رقم الهوية الوطنية',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: context.ink)),
        const SizedBox(height: 6),
        TextField(
          controller: _idCtrl,
          keyboardType: TextInputType.number,
          maxLength: 15,
          decoration: InputDecoration(
            hintText: '10 أرقام على الأقل',
            filled: true,
            fillColor: context.surface,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: ref.read(kycProvider).submitting ? null : _submit,
            icon: ref.read(kycProvider).submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.verified_rounded),
            label: const Text('إرسال طلب التوثيق',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
      ],
    );
  }
  Widget _pendingCard(KycState kyc) {
    return Center(
      child: SurfaceCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.warning, size: 36),
            ),
            const SizedBox(height: 14),
            const Text('طلبك قيد المراجعة',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'نراجع بياناتك حالياً — تستغرق المراجعة حتى 24 ساعة. سنخطرك فور اكتمال التوثيق.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, height: 1.55, color: context.mutedText),
            ),
          ],
        ),
      ),
    );
  }
  Widget _verifiedCard() {
    return Center(
      child: SurfaceCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded,
                  color: AppColors.success, size: 38),
            ),
            const SizedBox(height: 14),
            const Text('حسابك موثّق ✓',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'ستظهر شارة التوثيق على ملفك لجميع العملاء، وستحصل على أولوية في ظهور نتائج البحث.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, height: 1.55, color: context.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
