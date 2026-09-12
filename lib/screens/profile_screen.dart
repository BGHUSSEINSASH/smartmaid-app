import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/subscription_provider.dart';
import 'address_screen.dart';
import 'catalog_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'favorites_screen.dart';
import 'loyalty_screen.dart';
import 'notifications_screen.dart';
import 'offers_screen.dart';
import 'referral_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user ?? DemoData.admin;
    final bookingsCount = ref.watch(myBookingsProvider).length;
    final favCount = ref.watch(favoritesProvider).length;
    final points = ref.watch(loyaltyProvider).points;
    final addresses = ref.watch(addressProvider).length;
    final sub = ref.watch(subscriptionProvider);
    final roleLabel = user.role.arabicLabel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // الـ padding السفلي = ارتفاع navbar (62) + margin (20) + bottom safe area + هامش إضافي
    final bottomPad = MediaQuery.of(context).padding.bottom + 100;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [aiAppBarButton(context, initialMessage: 'كيف أحسن ملفي الشخصي؟')],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        children: [
          // ── بطاقة المستخدم ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: AppRadii.card,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // الصورة الشخصية
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: NetworkImage(user.imageUrl),
                        ),
                        // مؤشر الاشتراك النشط
                        if (sub.isActive)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: sub.tier == SubscriptionTier.platinum
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFFD97706),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Icon(
                                sub.tier == SubscriptionTier.platinum
                                    ? Icons.diamond_rounded
                                    : Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                roleLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (sub.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white30),
                                ),
                                child: Text(
                                  sub.tier.arabicLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                    // زر تعديل الملف
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── إحصائيات سريعة ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MiniStat(label: 'الحجوزات', value: '$bookingsCount', icon: Icons.book_online_rounded),
                      _StatDivider(),
                      _MiniStat(label: 'المفضلة', value: '$favCount', icon: Icons.favorite_rounded),
                      _StatDivider(),
                      _MiniStat(label: 'النقاط', value: '$points', icon: Icons.stars_rounded),
                      _StatDivider(),
                      _MiniStat(label: 'العناوين', value: '$addresses', icon: Icons.location_on_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── قسم: المالية والمكافآت ───────────────────────────────────
          _SectionLabel('المالية والمكافآت'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF0353A4),
              title: 'محفظة SmartPay',
              subtitle: 'الرصيد، الشحن، والمعاملات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
            _MenuItem(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFD97706),
              title: 'نقاط المكافآت',
              subtitle: '$points نقطة — استبدلها بخصومات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoyaltyScreen())),
            ),
            _MenuItem(
              icon: Icons.card_giftcard_rounded,
              iconColor: const Color(0xFF16A34A),
              title: 'العروض والكوبونات',
              subtitle: 'خصومات حصرية لك',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OffersScreen())),
            ),
            _MenuItem(
              icon: Icons.workspace_premium_rounded,
              iconColor: sub.isActive
                  ? (sub.tier == SubscriptionTier.platinum
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFD97706))
                  : AppColors.muted,
              title: 'اشتراك SmartGold',
              subtitle: sub.isActive
                  ? '${sub.tier.arabicLabel} — ينتهي ${sub.expiresAt!.day}/${sub.expiresAt!.month}'
                  : 'اشترك لخصومات حصرية',
              trailing: sub.isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'نشط',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    )
                  : null,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
            ),
          ]),

          const SizedBox(height: 16),

          // ── قسم: حسابي وتفضيلاتي ────────────────────────────────────
          _SectionLabel('حسابي وتفضيلاتي'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.edit_rounded,
              iconColor: AppColors.primary,
              title: 'تعديل الملف الشخصي',
              subtitle: 'الاسم، الهاتف، الصورة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _MenuItem(
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFE11D48),
              title: 'المفضلة',
              subtitle: '$favCount عاملة محفوظة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen())),
            ),
            _MenuItem(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF0E7490),
              title: 'عناويني',
              subtitle: '$addresses عناوين محفوظة',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddressScreen())),
            ),
            _MenuItem(
              icon: Icons.notifications_rounded,
              iconColor: const Color(0xFFDB2777),
              title: 'الإشعارات',
              subtitle: 'آخر التحديثات والعروض',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            _MenuItem(
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF7C3AED),
              title: 'ادعُ أصدقاءك',
              subtitle: '+100 نقطة لكل صديق ينضم',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReferralScreen())),
            ),
          ]),

          const SizedBox(height: 16),

          // ── قسم: الدعم والإعدادات ────────────────────────────────────
          _SectionLabel('الدعم والإعدادات'),
          const SizedBox(height: 8),
          _MenuCard(items: [
            _MenuItem(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF0353A4),
              title: 'الأسئلة الشائعة',
              subtitle: 'إجابات سريعة عن أكثر ما يُسأل',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FaqScreen())),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              iconColor: AppColors.muted,
              title: 'الإعدادات',
              subtitle: 'اللغة، الثيم، العملة، الإشعارات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _MenuItem(
              icon: Icons.cleaning_services_rounded,
              iconColor: const Color(0xFF16A34A),
              title: 'دليل الخدمات',
              subtitle: 'استعرض 110 خدمة مرتبة حسب الفئات',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen())),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Widgets مساعدة ──────────────────────────────────────────────

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 0),
      child: Row(children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ]),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: AppColors.stroke,
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: iconColor.withValues(alpha: 0.08),
        highlightColor: iconColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // أيقونة ملونة
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // trailing مخصص أو السهم الافتراضي
              trailing ??
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}


