import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  late final Map<String, bool> _active = {
    for (final u in [
      DemoData.customer,
      DemoData.workerUser,
      DemoData.companyUser,
      DemoData.admin,
    ])
      u.id: true,
    'u5': false,
  };

  static const _extra = [
    ('u5', 'سارة العتيبي', 'sara@example.com', '👤'),
  ];

  String _roleLabel(String id) => switch (id) {
        'u1' => 'عميل',
        'u2' => 'عاملة',
        'u3' => 'إدارة',
        'u4' => 'شركة',
        _ => 'عميل',
      };

  @override
  Widget build(BuildContext context) {
    final users = [
      (DemoData.customer.id, DemoData.customer.name, DemoData.customer.email, '👤'),
      (DemoData.workerUser.id, DemoData.workerUser.name, DemoData.workerUser.email, '👩‍💼'),
      (DemoData.admin.id, DemoData.admin.name, DemoData.admin.email, '🛡️'),
      (DemoData.companyUser.id, DemoData.companyUser.name, DemoData.companyUser.email, '🏢'),
      ..._extra,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('المستخدمون (${users.length})')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final (id, name, email, emoji) = users[i];
          final active = _active[id] ?? true;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: active
                                    ? null
                                    : AppColors.textHint)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(_roleLabel(id),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                    ]),
                    Text(email,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              FilterChip(
                label: Text(active ? 'نشط' : 'موقوف',
                    style: const TextStyle(fontSize: 11)),
                selected: active,
                selectedColor: AppColors.success.withValues(alpha: 0.15),
                checkmarkColor: AppColors.success,
                onSelected: (_) =>
                    setState(() => _active[id] = !active),
              ),
            ]),
          );
        },
      ),
    );
  }
}
