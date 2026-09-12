import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/trust_provider.dart';

/// Emergency SOS screen — one-tap alert with confirmation sheet.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  final _locationCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmSend() async {
    final location = _locationCtrl.text.trim().isEmpty
        ? 'غير محدد'
        : _locationCtrl.text.trim();
    await ref.read(sosProvider.notifier).trigger(
          location: location,
          note: _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    final msg = ref.read(sosProvider).message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.emergency_rounded,
                color: AppColors.error, size: 30),
          ),
          const SizedBox(height: 12),
          const Text('تأكيد طلب الطوارئ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'سيتم إرسال تنبيه فوري لفريق السلامة مع موقعك. استخدم هذا الزر فقط في الحالات الطارئة الحقيقية.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.5, color: context.mutedText, height: 1.5),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              hintText: 'وصف الموقع (اختياري) — مثال: شقة 12، حي النخيل',
              filled: true,
              fillColor: context.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'وصف الحالة (اختياري)',
              filled: true,
              fillColor: context.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.notes_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Navigator.pop(ctx);
                _confirmSend();
              },
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('إرسال التنبيه الآن',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('رجوع — ليست حالة طارئة'),
          ),
        ]),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final sos = ref.watch(sosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('زر الطوارئ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (sos.phase == SosPhase.sent)
              _SentCard(sos: sos)
            else ...[
              _SosButton(onTap: _showConfirmSheet),
              const SizedBox(height: 26),
              const _WhenToUseCard(),
              const SizedBox(height: 14),
              const _HotlineCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SosButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 190,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            AppColors.error,
            AppColors.error.withValues(alpha: 0.75),
          ]),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 6,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency_rounded, color: Colors.white, size: 56),
            SizedBox(height: 6),
            Text('SOS',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}

/// Success state widget
class _SentCard extends ConsumerWidget {
  final SosState sos;
  const _SentCard({required this.sos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 42),
          ),
          const SizedBox(height: 14),
          const Text('تم إرسال التنبيه',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(sos.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: context.mutedText)),
          if (sos.sentAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'وقت الإرسال: ${sos.sentAt!.hour}:${sos.sentAt!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11.5, color: context.mutedText),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => ref.read(sosProvider.notifier).reset(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إرسال تنبيه جديد'),
          ),
        ],
      ),
    );
  }
}

class _WhenToUseCard extends StatelessWidget {
  const _WhenToUseCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('متى تستخدم زر الطوارئ؟',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.ink)),
          ]),
          const SizedBox(height: 10),
          ...[
            'شعور بالخطر أثناء تواجد أي طرف في المنزل',
            'حادث أو إصابة تحتاج تدخلاً فورياً',
            'موقف أمني يستدعي الجهات المختصة',
          ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(e,
                          style: TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: context.mutedText))),
                ]),
              )),
        ],
      ),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.support_agent_rounded,
              color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الخط الساخن للطوارئ',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: context.mutedText,
                      fontWeight: FontWeight.w700)),
              const Text('911',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
            ],
          ),
        ),
      ]),
    );
  }
}
