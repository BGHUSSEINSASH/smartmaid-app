import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/address_provider.dart';
import '../providers/payment_cards_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/currency_provider.dart';
import '../l10n/app_localizations.dart';
import 'payment_cards_screen.dart';

/// شاشة إعدادات موحّدة ذكية — تكتشف الدور وتعرض الأقسام المناسبة.
class UnifiedSettingsScreen extends ConsumerStatefulWidget {
  const UnifiedSettingsScreen({super.key});
  @override
  ConsumerState<UnifiedSettingsScreen> createState() => _UnifiedSettingsState();
}

class _UnifiedSettingsState extends ConsumerState<UnifiedSettingsScreen> {
  // حقول قابلة للتعديل
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _ibanCtrl;
  late TextEditingController _bankCtrl;
  late TextEditingController _instructionsCtrl;

  // تفضيلات عامة
  bool _notifyBooking = true;
  bool _notifyArrival = true;
  bool _notifyComplete = true;
  bool _notifyOffers = true;
  bool _notifyNewJob = true;
  bool _notifyPayment = true;
  bool _notifyReport = true;

  // عاملة
  bool _autoAccept = false;
  bool _available = true;
  int _maxDailyJobs = 3;
  double _maxDistance = 20;
  String _workerLangPref = 'عربية';
  final _allSkills = ['تنظيف عام','طبخ','رعاية أطفال','كبار السن','غسيل وكواء','تنظيف عميق'];
  late Set<String> _selectedSkills;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _bioCtrl = TextEditingController(text: user?.workerInfo?.bio ?? '');
    _ibanCtrl = TextEditingController(text: user?.workerInfo?.iban ?? '');
    _bankCtrl = TextEditingController(text: user?.workerInfo?.bankName ?? '');
    _instructionsCtrl = TextEditingController();
    _selectedSkills = Set.from(user?.workerInfo?.skills ?? ['تنظيف عام']);
    _available = user?.workerInfo?.kycStatus == KycStatus.approved;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _bioCtrl.dispose();
    _ibanCtrl.dispose(); _bankCtrl.dispose(); _instructionsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(authProvider.notifier).updateProfile(
      user.copyWith(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim()),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('✅ تم حفظ الإعدادات بنجاح'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final settings = ref.watch(settingsProvider);
    final currency = ref.watch(currencyProvider);
    final sub = ref.watch(subscriptionProvider);
    final addresses = ref.watch(addressProvider);
    final cards = ref.watch(paymentCardsProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('الإعدادات'),
          actions: [
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('حفظ'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── صورة الملف الشخصي ──────────────────────────
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage(user.imageUrl),
                    backgroundColor: AppColors.stroke,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(child: _roleBadge(user.role)),
            const SizedBox(height: 20),

            // ── قسم 1: بيانات الحساب ────────────────────────
            _section('بيانات الحساب', icon: Icons.person_rounded, children: [
              _editField(_nameCtrl, 'الاسم الكامل', Icons.person_outline_rounded),
              _editField(_phoneCtrl, 'رقم الهاتف', Icons.phone_rounded,
                  type: TextInputType.phone),
              _infoTile(Icons.alternate_email_rounded, 'البريد الإلكتروني',
                  user.email, locked: true),
              if (user.role == AppRole.customer) ...[
                _infoTile(Icons.flag_rounded, 'الجنسية',
                    user.customerInfo?.nationality.isEmpty != false ? 'غير محددة' : user.customerInfo!.nationality),
                _infoTile(Icons.people_rounded, 'الجنس',
                    user.customerInfo?.gender.isEmpty != false ? 'غير محدد' : user.customerInfo!.gender),
              ],
              if (user.role == AppRole.worker) ...[
                _infoTile(Icons.flag_rounded, 'الجنسية', user.workerInfo?.nationality ?? 'غير محددة'),
                _infoTile(Icons.badge_rounded, 'رقم جواز السفر',
                    user.workerInfo?.passportNumber.isEmpty != false ? 'غير محدد' : '${user.workerInfo!.passportNumber.substring(0, 3)}***'),
                _editFieldMultiline(_bioCtrl, 'النبذة التعريفية', Icons.info_outline_rounded),
                _skillsSection(),
              ],
              if (user.role == AppRole.company) ...[
                _infoTile(Icons.business_rounded, 'اسم الشركة',
                    user.companyInfo?.companyName ?? 'غير محدد'),
                _infoTile(Icons.article_rounded, 'رقم السجل التجاري',
                    user.companyInfo?.commercialRegNo ?? 'غير محدد'),
                _infoTile(Icons.location_city_rounded, 'المدينة',
                    user.companyInfo?.city ?? 'غير محددة'),
                _infoTile(Icons.price_change_rounded, 'العمولة',
                    '${((user.companyInfo?.commissionRate ?? 0.20) * 100).round()}% (تعينها الإدارة)',
                    locked: true),
              ],
              if (user.role == AppRole.admin) ...[
                _infoTile(Icons.admin_panel_settings_rounded, 'الدور الوظيفي', 'مدير أعلى (SuperAdmin)', locked: true),
                _infoTile(Icons.verified_user_rounded, 'الصلاحيات', 'كاملة (24 صلاحية)', locked: true),
                _infoTile(Icons.access_time_rounded, 'آخر دخول', 'منذ 5 دقائق', locked: true),
              ],
            ]),

            // ── قسم 2: الإشعارات ───────────────────────────
            _section('الإشعارات', icon: Icons.notifications_rounded, children: [
              if (user.role == AppRole.customer || user.role == AppRole.admin) ...[
                _switchRow('تأكيد الحجز', Icons.check_circle_rounded, _notifyBooking, (v) => setState(() => _notifyBooking = v)),
                _switchRow('وصول العاملة', Icons.directions_walk_rounded, _notifyArrival, (v) => setState(() => _notifyArrival = v)),
                _switchRow('انتهاء الخدمة', Icons.done_all_rounded, _notifyComplete, (v) => setState(() => _notifyComplete = v)),
                _switchRow('العروض والخصومات', Icons.local_offer_rounded, _notifyOffers, (v) => setState(() => _notifyOffers = v)),
              ],
              if (user.role == AppRole.worker) ...[
                _switchRow('طلب عمل جديد', Icons.work_rounded, _notifyNewJob, (v) => setState(() => _notifyNewJob = v)),
                _switchRow('تحويل مالي', Icons.account_balance_wallet_rounded, _notifyPayment, (v) => setState(() => _notifyPayment = v)),
                _switchRow('إلغاء حجز', Icons.cancel_rounded, _notifyBooking, (v) => setState(() => _notifyBooking = v)),
              ],
              if (user.role == AppRole.company) ...[
                _switchRow('طلب جديد', Icons.inbox_rounded, _notifyNewJob, (v) => setState(() => _notifyNewJob = v)),
                _switchRow('تقرير أسبوعي', Icons.bar_chart_rounded, _notifyReport, (v) => setState(() => _notifyReport = v)),
                _switchRow('تحويل مالي', Icons.account_balance_wallet_rounded, _notifyPayment, (v) => setState(() => _notifyPayment = v)),
              ],
            ]),

            // ── قسم 3: المظهر واللغة ────────────────────────
            _section('المظهر واللغة', icon: Icons.palette_rounded, children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                title: const Text('الوضع الداكن', style: TextStyle(fontWeight: FontWeight.w700)),
                value: settings.darkMode,
                onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_auto_rounded, color: AppColors.primary),
                title: const Text('حسب إعداد الجهاز', style: TextStyle(fontWeight: FontWeight.w700)),
                value: settings.followSystem,
                onChanged: (_) => ref.read(settingsProvider.notifier).useSystemTheme(),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: const Text('اللغة', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('عربي')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (s) => ref.read(settingsProvider.notifier).setLanguage(s.first),
                  style: ButtonStyle(visualDensity: VisualDensity.compact,
                      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.currency_exchange_rounded, color: AppColors.primary),
                title: const Text('العملة', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: SegmentedButton<AppCurrency>(
                  segments: const [
                    ButtonSegment(value: AppCurrency.usd, label: Text('\$ USD')),
                    ButtonSegment(value: AppCurrency.iqd, label: Text('د.ع IQD')),
                  ],
                  selected: {currency},
                  onSelectionChanged: (s) => ref.read(currencyProvider.notifier).set(s.first),
                  style: ButtonStyle(visualDensity: VisualDensity.compact,
                      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                ),
              ),
            ]),

            // ── قسم 4: الأمان ────────────────────────────────
            _section('الأمان والخصوصية', icon: Icons.shield_rounded, children: [
              ListTile(
                leading: const Icon(Icons.lock_rounded, color: AppColors.primary),
                title: const Text('الأمان المتقدم', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('قفل PIN، البصمة، الأجهزة النشطة'),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => Navigator.pushNamed(context, '/security'),
              ),
              if (user.role != AppRole.admin)
                _switchRow('إخفاء رقم الهاتف', Icons.phone_locked_rounded, false, (_) {}),
            ]),

            // ── قسم 5: المالية (غير الإدارة) ─────────────────
            if (user.role != AppRole.admin) ...[
              _section('المالية والدفع', icon: Icons.account_balance_wallet_rounded, children: [
                if (user.role == AppRole.customer || user.role == AppRole.worker)
                  ListTile(
                    leading: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                    title: const Text('بطاقاتي البنكية', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${cards.length} بطاقة محفوظة'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentCardsScreen())),
                  ),
                if (user.role == AppRole.customer || user.role == AppRole.company)
                  ListTile(
                    leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    title: const Text('عناويني', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${addresses.length} عنوان محفوظ'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),
                if (user.role == AppRole.customer)
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: const Text('لغة العاملة المفضّلة', style: TextStyle(fontWeight: FontWeight.w700)),
                    trailing: DropdownButton<String>(
                      value: _workerLangPref, underline: const SizedBox(),
                      items: ['عربية','إنجليزية','فلبينية'].map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _workerLangPref = v!),
                    ),
                  ),
                if (user.role == AppRole.worker) ...[
                  _editField(_bankCtrl, 'اسم البنك', Icons.account_balance_rounded),
                  _editField(_ibanCtrl, 'رقم IBAN', Icons.numbers_rounded),
                ],
              ]),
            ],

            // ── قسم 6: تفضيلات العمل (عاملة + شركة) ─────────
            if (user.role == AppRole.worker) ...[
              _section('تفضيلات العمل', icon: Icons.work_rounded, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('حالتي', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(_available ? 'متاحة — تستقبل الطلبات' : 'غير متاحة', style: TextStyle(fontSize: 12, color: _available ? AppColors.success : AppColors.muted)),
                    ])),
                    Switch.adaptive(value: _available, onChanged: (v) => setState(() => _available = v), activeColor: AppColors.success),
                  ]),
                ),
                _switchRow('قبول الطلبات تلقائياً', Icons.auto_awesome_rounded, _autoAccept, (v) => setState(() => _autoAccept = v)),
                _sliderTile('الحد الأقصى يومياً', '$_maxDailyJobs طلبات', _maxDailyJobs.toDouble(), 1, 10, (v) => setState(() => _maxDailyJobs = v.round())),
                _sliderTile('نطاق الخدمة', '${_maxDistance.round()} كم', _maxDistance, 5, 100, (v) => setState(() => _maxDistance = v)),
              ]),
            ],

            // ── قسم 7: الاشتراك ──────────────────────────────
            if (user.role != AppRole.admin)
              _section('اشتراكي', icon: Icons.workspace_premium_rounded, children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: sub.isActive ? AppColors.warning.withValues(alpha: .12) : AppColors.stroke,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        sub.isActive ? Icons.workspace_premium_rounded : Icons.person_rounded,
                        color: sub.isActive ? AppColors.warning : AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sub.isActive ? sub.tier.arabicLabel : 'الخطة المجانية',
                          style: TextStyle(fontWeight: FontWeight.w900, color: sub.isActive ? AppColors.warning : AppColors.textPrimary)),
                      if (sub.isActive && sub.expiresAt != null)
                        Text('تنتهي: ${_formatDate(sub.expiresAt!)}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      if (!sub.isActive)
                        const Text('ترقّ للحصول على مزايا حصرية', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    ])),
                    if (!sub.isActive)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/subscription'),
                        child: const Text('ترقية'),
                      ),
                  ]),
                ),
              ]),

            const SizedBox(height: 16),

            // ── زر الحفظ ─────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('حفظ جميع الإعدادات'),
              ),
            ),
            const SizedBox(height: 12),

            // ── تسجيل الخروج ─────────────────────────────────
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: .4))),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('خروج', style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    // GoRouter يُعيد التوجيه تلقائياً بسبب refreshListenable
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(t?.logout ?? 'تسجيل الخروج'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Widget helpers ───────────────────────────────────────────

  Widget _section(String title, {required IconData icon, required List<Widget> children}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4, right: 2),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13.5)),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children.asMap().entries.map((e) {
            final last = e.key == children.length - 1;
            return Column(children: [
              e.value,
              if (!last) const Divider(height: 1, indent: 16, endIndent: 16),
            ]);
          }).toList(),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }

  Widget _roleBadge(AppRole role) {
    final (icon, label, color) = switch (role) {
      AppRole.customer => (Icons.person_rounded, 'عميل', AppColors.primary),
      AppRole.worker => (Icons.woman_rounded, 'عاملة', const Color(0xFF7C3AED)),
      AppRole.company => (Icons.business_rounded, 'شركة', const Color(0xFF0EA5E9)),
      AppRole.admin => (Icons.admin_panel_settings_rounded, 'مدير النظام', const Color(0xFF16A34A)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: .25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
    );
  }

  Widget _editField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withValues(alpha: .5))),
      ),
    ),
  );

  Widget _editFieldMultiline(TextEditingController ctrl, String label, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: TextField(
      controller: ctrl,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, size: 20),
        border: InputBorder.none, enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withValues(alpha: .5))),
      ),
    ),
  );

  Widget _infoTile(IconData icon, String label, String value, {bool locked = false}) => ListTile(
    leading: Icon(icon, color: locked ? AppColors.muted : AppColors.primary),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(color: locked ? AppColors.muted : AppColors.textSecondary, fontSize: 13)),
      if (!locked) const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
      if (locked) const Icon(Icons.lock_outline_rounded, color: AppColors.stroke, size: 16),
    ]),
    onTap: locked ? null : () {},
  );

  Widget _switchRow(String label, IconData icon, bool value, ValueChanged<bool> onChanged) =>
      SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        value: value, onChanged: onChanged,
      );

  Widget _skillsSection() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('المهارات', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 6, children: _allSkills.map((s) {
        final sel = _selectedSkills.contains(s);
        return FilterChip(
          label: Text(s, style: const TextStyle(fontSize: 12)),
          selected: sel,
          selectedColor: AppColors.primary.withValues(alpha: .15),
          checkmarkColor: AppColors.primary,
          onSelected: (v) => setState(() => v ? _selectedSkills.add(s) : _selectedSkills.remove(s)),
        );
      }).toList()),
    ]),
  );

  Widget _sliderTile(String label, String display, double value, double min, double max, ValueChanged<double> cb) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(display, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
        ]),
      ),
      Slider(value: value, min: min, max: max, onChanged: cb),
    ]);

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
