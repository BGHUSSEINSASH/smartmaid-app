import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';
import '../providers/admin_providers.dart';
import '../widgets/pro_components.dart';

class AdminCommissionsScreen extends ConsumerWidget {
  const AdminCommissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissions = ref.watch(companyCommissionsProvider);
    final settings = ref.watch(systemSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة العمولات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // العمولة الافتراضية العالمية
          ProCard(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('العمولة الافتراضية للمنصة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('${(settings.defaultCommissionRate * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              Slider(
                value: settings.defaultCommissionRate,
                min: 0.05, max: 0.40, divisions: 35,
                label: '${(settings.defaultCommissionRate * 100).round()}%',
                onChanged: (v) => ref.read(systemSettingsProvider.notifier)
                    .setCommissionRate(v),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('5%', style: TextStyle(fontSize: 11)),
                const Text('40%', style: TextStyle(fontSize: 11)),
              ]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(companyCommissionsProvider.notifier)
                      .resetAll(settings.defaultCommissionRate);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم تطبيق العمولة الافتراضية على كل الشركات'),
                    behavior: SnackBarBehavior.floating));
                },
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: const Text('تطبيق على كل الشركات'),
              )),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('عمولة كل شركة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...DemoData.companies.map((co) {
            final rate = commissions[co.id] ?? settings.defaultCommissionRate;
            return _CompanyCommissionCard(
              companyId: co.id,
              companyName: co.name,
              logoUrl: co.logoUrl,
              currentRate: rate,
              onChanged: (v) => ref.read(companyCommissionsProvider.notifier)
                  .setRate(co.id, v),
            );
          }),
        ],
      ),
    );
  }
}

class _CompanyCommissionCard extends ConsumerStatefulWidget {
  final String companyId;
  final String companyName;
  final String logoUrl;
  final double currentRate;
  final ValueChanged<double> onChanged;
  const _CompanyCommissionCard({
    required this.companyId, required this.companyName,
    required this.logoUrl, required this.currentRate,
    required this.onChanged});

  @override
  ConsumerState<_CompanyCommissionCard> createState() =>
      _CompanyCommissionCardState();
}

class _CompanyCommissionCardState
    extends ConsumerState<_CompanyCommissionCard> {
  late double _rate;

  @override
  void initState() {
    super.initState();
    _rate = widget.currentRate;
  }

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22,
              backgroundImage: NetworkImage(widget.logoUrl),
              backgroundColor: AppColors.stroke),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.companyName,
              style: const TextStyle(fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${(_rate * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w900,
                    color: AppColors.primary)),
          ),
        ]),
        Slider(
          value: _rate, min: 0.05, max: 0.40, divisions: 35,
          label: '${(_rate * 100).round()}%',
          onChanged: (v) => setState(() => _rate = v),
          onChangeEnd: widget.onChanged,
        ),
      ]),
    );
  }
}
