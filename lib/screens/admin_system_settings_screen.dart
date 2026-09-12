import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/admin_providers.dart';
import '../widgets/pro_components.dart';

class AdminSystemSettingsScreen extends ConsumerWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(systemSettingsProvider);
    final n = ref.read(systemSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات النظام')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupCard(title: 'المالية', children: [
            _SliderTile(
              label: 'الحد الأدنى للسحب',
              value: s.minWithdrawal,
              min: 10, max: 500, divisions: 49,
              display: '${s.minWithdrawal.round()} د.ك',
              onChanged: n.setMinWithdrawal,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _SliderTile(
              label: 'الحد الأقصى لخصم الكوبون',
              value: s.maxCouponDiscount,
              min: 0.05, max: 1.0, divisions: 19,
              display: '${(s.maxCouponDiscount * 100).round()}%',
              onChanged: n.setMaxCouponDiscount,
            ),
          ]),
          const SizedBox(height: 14),
          _GroupCard(title: 'الميزات', children: [
            SwitchListTile(
              secondary: const Icon(Icons.star_rounded, color: AppColors.primary),
              title: const Text('نقاط الولاء',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('تفعيل نظام نقاط المكافآت'),
              value: s.loyaltyEnabled,
              onChanged: (_) => n.toggleLoyalty(),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            SwitchListTile(
              secondary: const Icon(Icons.people_alt_rounded, color: AppColors.primary),
              title: const Text('الإحالات',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('تفعيل نظام رمز الإحالة'),
              value: s.referralEnabled,
              onChanged: (_) => n.toggleReferral(),
            ),
          ]),
          const SizedBox(height: 14),
          _GroupCard(title: 'الصيانة', children: [
            SwitchListTile(
              secondary: Icon(Icons.build_circle_rounded,
                  color: s.maintenanceMode ? AppColors.error : AppColors.muted),
              title: Text('وضع الصيانة',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: s.maintenanceMode ? AppColors.error : null)),
              subtitle: const Text('يُوقف وصول المستخدمين مؤقتاً'),
              value: s.maintenanceMode,
              onChanged: (v) {
                if (v) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      final ctrl = TextEditingController(
                          text: s.maintenanceMessage);
                      return AlertDialog(
                        title: const Text('تفعيل وضع الصيانة'),
                        content: TextField(
                          controller: ctrl,
                          decoration: const InputDecoration(
                              labelText: 'رسالة الصيانة'),
                          maxLines: 2,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error),
                            onPressed: () {
                              n.setMaintenance(true, msg: ctrl.text);
                              Navigator.pop(context);
                            },
                            child: const Text('تفعيل'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  n.setMaintenance(false);
                }
              },
            ),
            if (s.maintenanceMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('الرسالة: "${s.maintenanceMessage}"',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.error)),
              ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _GroupCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800,
                color: AppColors.muted)),
      ),
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    ]);
  }
}

class _SliderTile extends StatefulWidget {
  final String label;
  final double value;
  final double min, max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;
  const _SliderTile({required this.label, required this.value,
      required this.min, required this.max, required this.divisions,
      required this.display, required this.onChanged});

  @override
  State<_SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<_SliderTile> {
  late double _v;

  @override
  void initState() { super.initState(); _v = widget.value; }
  @override
  void didUpdateWidget(_SliderTile old) {
    super.didUpdateWidget(old);
    _v = widget.value;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          Expanded(child: Text(widget.label,
              style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(widget.display,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.primary)),
        ]),
      ),
      Slider(
        value: _v, min: widget.min, max: widget.max,
        divisions: widget.divisions,
        label: widget.display,
        onChanged: (v) => setState(() => _v = v),
        onChangeEnd: widget.onChanged,
      ),
    ],
  );
}
