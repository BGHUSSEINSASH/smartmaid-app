import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/settings_provider.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('الإتاحة ♿')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Text scale
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields_rounded,
                        size: 22, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('حجم الخط',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: context.ink)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('أ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: settings.textScale,
                        min: 0.8,
                        max: 1.8,
                        divisions: 5,
                        label: '${(settings.textScale * 100).toInt()}%',
                        onChanged: (v) =>
                            ref.read(settingsProvider.notifier).setTextScale(v),
                      ),
                    ),
                    const Text('أ', style: TextStyle(fontSize: 24)),
                  ],
                ),
                Text(
                  'الحجم الحالي: ${(settings.textScale * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // High contrast
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.contrast_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تباين عالٍ',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                      const Text('يزيد وضوح العناصر للرؤية المنخفضة',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Switch(
                  value: settings.highContrast,
                  onChanged: (_) =>
                      ref.read(settingsProvider.notifier).toggleHighContrast(),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Reduce motion
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.animation_rounded,
                      color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تقليل الحركة',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                      const Text('يقلل الانتقالات والأنيميشن',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Switch(
                  value: settings.reduceMotion,
                  onChanged: (_) =>
                      ref.read(settingsProvider.notifier).toggleReduceMotion(),
                  activeColor: AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('معاينة',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: context.ink)),
                const SizedBox(height: 12),
                Text(
                  'هذا نص تجريبي لإظهار حجم الخط الحالي. يمكنك تعديل الإعدادات أعلاه لرؤية التغيير.',
                  style: TextStyle(
                      fontSize: 14 * settings.textScale,
                      fontWeight: settings.highContrast
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: settings.highContrast
                          ? Colors.white
                          : context.mutedText,
                      height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
