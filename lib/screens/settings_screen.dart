import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/currency_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../data/models.dart';
import 'customer_settings_screen.dart';
import 'worker_settings_screen.dart';
import 'payment_cards_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GroupCard(title: 'المظهر واللغة', children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_rounded,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.darkMode,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('مظهر داكن مريح للعين',
                    style: TextStyle(fontSize: 12)),
                value: settings.darkMode,
                activeThumbColor: AppColors.primary,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).toggleDarkMode(),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_auto_rounded,
                    color: AppColors.primary),
                title: const Text('حسب النظام',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('يتبع إعداد الجهاز تلقائياً',
                    style: TextStyle(fontSize: 12)),
                value: settings.followSystem,
                activeThumbColor: AppColors.primary,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).useSystemTheme(),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.language_rounded,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.language,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('عربي')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (s) =>
                      ref.read(settingsProvider.notifier).setLanguage(s.first),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStateProperty.all(const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700))),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            _GroupCard(title: 'التشغيل', children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_rounded,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.notifications,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('تنبيهات الحجوزات والعروض',
                    style: TextStyle(fontSize: 12)),
                value: settings.notificationsEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => ref
                    .read(settingsProvider.notifier)
                    .toggleNotifications(),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.currency_exchange_rounded,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.currency,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                trailing: SegmentedButton<AppCurrency>(
                  segments: const [
                    ButtonSegment(value: AppCurrency.usd, label: Text('\$ USD')),
                    ButtonSegment(
                        value: AppCurrency.iqd, label: Text('د.ع IQD')),
                  ],
                  selected: {currency},
                  onSelectionChanged: (s) =>
                      ref.read(currencyProvider.notifier).set(s.first),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      textStyle: WidgetStateProperty.all(const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700))),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            _GroupCard(title: 'الأمان', children: [
              ListTile(
                leading: const Icon(Icons.shield_rounded, color: AppColors.primary),
                title: const Text('الأمان والخصوصية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('قفل التطبيق، البصمة، الأجهزة', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => context.push('/security'),
              ),
            ]),
            const SizedBox(height: 14),
            _roleSettingsCard(context, ref),
            const SizedBox(height: 14),
            _GroupCard(title: 'حول', children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.aboutApp,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('شغّالتي v1.1.0',
                    style: TextStyle(fontSize: 12)),
                onTap: () => showAboutDialog(context: context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: AppColors.primary),
                title: Text(AppLocalizations.of(context)!.privacyPolicy,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                subtitle: const Text('كيف نحمي بياناتك',
                    style: TextStyle(fontSize: 12)),
                onTap: () => context.push('/privacy-policy'),
              ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content:
                          const Text('هل تريد الخروج من حسابك الحالي؟'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('إلغاء')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('خروج',
                                style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4))),
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: Text(AppLocalizations.of(context)!.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleSettingsCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final (icon, label, subtitle, screen) = switch (user.role) {
      AppRole.customer => (
          Icons.person_rounded,
          'إعدادات حساب العميل',
          'العناوين، البطاقات، الإشعارات',
          const CustomerSettingsScreen(),
        ),
      AppRole.worker => (
          Icons.woman_rounded,
          'إعدادات حساب العاملة',
          'الجدول، المهارات، البيانات البنكية',
          const WorkerSettingsScreen(),
        ),
      AppRole.company => (
          Icons.business_rounded,
          'إعدادات الشركة',
          'بيانات الشركة، العمليات، المالية',
          const WorkerSettingsScreen(),  // placeholder until company settings done
        ),
      AppRole.admin => (
          Icons.admin_panel_settings_rounded,
          'إعدادات حساب الإدارة',
          'الصلاحيات، السجل، الأمان المتقدم',
          const WorkerSettingsScreen(),  // placeholder
        ),
    };

    return _GroupCard(title: 'إعدادات الحساب', children: [
      ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
      if (user.role == AppRole.customer || user.role == AppRole.worker) ...[
        const Divider(height: 1, indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
          title: const Text('إدارة بطاقات الدفع', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
          subtitle: const Text('إضافة وإدارة بطاقاتك البنكية', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_left_rounded),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentCardsScreen())),
        ),
      ],
    ]);
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _GroupCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5)),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: AppColors.stroke)),
          child: Column(children: children),
        ),
      ],
    );
  }
}



