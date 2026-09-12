import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/auto_reply_provider.dart';
import '../widgets/pro_components.dart';

class AdminAutoRepliesScreen extends ConsumerStatefulWidget {
  const AdminAutoRepliesScreen({super.key});
  @override
  ConsumerState<AdminAutoRepliesScreen> createState() => _AdminAutoRepliesState();
}

class _AdminAutoRepliesState extends ConsumerState<AdminAutoRepliesScreen> {
  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(autoReplyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الردود التلقائية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('قاعدة جديدة'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => _RuleTile(rule: rules[i]),
      ),
    );
  }

  void _showAddSheet() {
    final keyCtrl = TextEditingController();
    final replyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('قاعدة رد تلقائي جديدة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'الكلمة المفتاحية', prefixIcon: Icon(Icons.search_rounded))),
          const SizedBox(height: 10),
          TextField(controller: replyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'الرد التلقائي', prefixIcon: Icon(Icons.reply_rounded))),
          const SizedBox(height: 14),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (keyCtrl.text.isEmpty || replyCtrl.text.isEmpty) return;
                ref.read(autoReplyProvider.notifier).add(AutoReplyRule(
                  id: 'ar_${DateTime.now().millisecondsSinceEpoch}',
                  keyword: keyCtrl.text.trim(),
                  response: replyCtrl.text.trim(),
                ));
                Navigator.pop(context);
              },
              child: const Text('إضافة القاعدة'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _RuleTile extends ConsumerWidget {
  final AutoReplyRule rule;
  const _RuleTile({required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)),
            child: Text(rule.keyword, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13)),
          ),
          const Spacer(),
          Switch.adaptive(value: rule.isActive, onChanged: (_) => ref.read(autoReplyProvider.notifier).toggle(rule.id)),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () => ref.read(autoReplyProvider.notifier).remove(rule.id),
          ),
        ]),
        const SizedBox(height: 8),
        Text(rule.response, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        if (!rule.isActive) ...[
          const SizedBox(height: 6),
          const Row(children: [Icon(Icons.pause_circle_rounded, color: AppColors.muted, size: 14), SizedBox(width: 4), Text('معطّل', style: TextStyle(fontSize: 11, color: AppColors.muted))]),
        ],
      ]),
    );
  }
}
