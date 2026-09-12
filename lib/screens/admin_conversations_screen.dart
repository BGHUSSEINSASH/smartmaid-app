import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auto_reply_provider.dart';
import '../widgets/pro_components.dart';

// بيانات محاكاة محادثات الدعم
final _demoTickets = [
  _SupportTicketDemo(id: 't1', user: 'أحمد محمد', role: 'عميل', msg: 'لم يصل رد على طلبي منذ ساعتين', priority: 'عاجل', open: true),
  _SupportTicketDemo(id: 't2', user: 'ماريا سانتوس', role: 'عاملة', msg: 'كيف أسحب أرباحي؟', priority: 'عادي', open: true),
  _SupportTicketDemo(id: 't3', user: 'شركة النظافة المثالية', role: 'شركة', msg: 'مشكلة في الفواتير', priority: 'عالي', open: false),
];

class _SupportTicketDemo {
  final String id, user, role, msg, priority;
  final bool open;
  const _SupportTicketDemo({required this.id, required this.user, required this.role, required this.msg, required this.priority, required this.open});
}

class AdminConversationsScreen extends ConsumerStatefulWidget {
  const AdminConversationsScreen({super.key});
  @override
  ConsumerState<AdminConversationsScreen> createState() => _AdminConvState();
}

class _AdminConvState extends ConsumerState<AdminConversationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المحادثات'),
        bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'مفتوحة'), Tab(text: 'مغلقة')]),
      ),
      body: TabBarView(controller: _tabs, children: [
        _TicketList(tickets: _demoTickets.where((t) => t.open).toList()),
        _TicketList(tickets: _demoTickets.where((t) => !t.open).toList()),
      ]),
    );
  }
}

class _TicketList extends ConsumerWidget {
  final List<_SupportTicketDemo> tickets;
  const _TicketList({required this.tickets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tickets.isEmpty) return EmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'لا توجد محادثات', subtitle: '');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _TicketCard(ticket: tickets[i]),
    );
  }
}

class _TicketCard extends ConsumerWidget {
  final _SupportTicketDemo ticket;
  const _TicketCard({required this.ticket});

  Color get _priorityColor => switch (ticket.priority) {
    'عاجل' => AppColors.error,
    'عالي' => AppColors.warning,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.primaryLight, child: Text(ticket.user.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ticket.user, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(ticket.role, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _priorityColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
            child: Text(ticket.priority, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _priorityColor)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(ticket.msg, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.reply_rounded, size: 16),
            label: const Text('الرد', style: TextStyle(fontSize: 12)),
            onPressed: () => _showReplySheet(context, ref),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            icon: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
            label: const Text('إغلاق', style: TextStyle(fontSize: 12, color: AppColors.success)),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إغلاق التذكرة'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success)),
          )),
        ]),
      ]),
    );
  }

  void _showReplySheet(BuildContext context, WidgetRef ref) {
    final replyCtrl = TextEditingController();
    final autoRules = ref.read(autoReplyProvider);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('الرد على ${ticket.user}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          // Quick replies
          const Text('ردود سريعة:', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(scrollDirection: Axis.horizontal, children: autoRules.take(3).map((r) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ActionChip(label: Text(r.keyword, style: const TextStyle(fontSize: 11)), onPressed: () => replyCtrl.text = r.response),
            )).toList()),
          ),
          const SizedBox(height: 10),
          TextField(controller: replyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'رسالة الرد', prefixIcon: Icon(Icons.message_rounded))),
          const SizedBox(height: 12),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text('إرسال الرد'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('تم إرسال الرد إلى ${ticket.user}'),
                  behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success,
                ));
              },
            ),
          ),
        ]),
      ),
    );
  }
}
