import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/security_provider.dart';
import 'app_lock_screen.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(securityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الأمان والخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.lock_rounded,
                      color: AppColors.primary),
                  title: const Text('قفل التطبيق برمز PIN',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(
                      'يُطلب رمز الحماية عند فتح التطبيق',
                      style: TextStyle(fontSize: 12)),
                  value: security.lockEnabled,
                  onChanged: (v) async {
                    if (v) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AppLockScreen(
                            setupMode: true,
                            onDone: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    } else {
                      await ref
                          .read(securityProvider.notifier)
                          .disableLock();
                    }
                  },
                ),
                if (security.lockEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.password_rounded,
                        color: AppColors.primary),
                    title: const Text('تغيير رمز الحماية',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppLockScreen(
                          setupMode: true,
                          onDone: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded,
                        color: AppColors.primary),
                    title: const Text('استخدام البصمة',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('عند توفّر جهاز يدعم البصمة',
                        style: TextStyle(fontSize: 12)),
                    value: security.biometricEnabled,
                    onChanged: (v) =>
                        ref.read(securityProvider.notifier).setBiometric(v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.devices_rounded,
                      color: AppColors.primary),
                  title: const Text('الأجهزة النشطة',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('هذا الجهاز — نشط الآن',
                      style: TextStyle(fontSize: 12)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.shield_rounded,
                      color: AppColors.success),
                  title: const Text('حالة الحماية',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      security.lockEnabled
                          ? 'مؤمّن برمز حماية'
                          : 'الحماية الإضافية غير مفعّلة',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}
