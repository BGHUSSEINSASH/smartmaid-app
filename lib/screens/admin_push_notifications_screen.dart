import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/pro_components.dart';

final _notifProvider = StateProvider<List<_SentNotif>>((ref) => const []);

class _SentNotif {
  final String title;
  final String body;
  final String target;
  final DateTime sentAt;
  const _SentNotif({required this.title, required this.body,
      required this.target, required this.sentAt});
}

class AdminPushNotificationsScreen extends ConsumerStatefulWidget {
  const AdminPushNotificationsScreen({super.key});
  @override
  ConsumerState<AdminPushNotificationsScreen> createState() => _AdminPushState();
}

class _AdminPushState extends ConsumerState<AdminPushNotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'الكل';

  final _targets = ['الكل', 'العملاء فقط', 'العاملات فقط', 'الشركات فقط'];

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('أدخل العنوان والمحتوى'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating));
      return;
    }
    ref.read(_notifProvider.notifier).state = [
      _SentNotif(
          title: _titleCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          target: _target,
          sentAt: DateTime.now()),
      ...ref.read(_notifProvider),
    ];
    _titleCtrl.clear();
    _bodyCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ تم إرسال الإشعار إلى: $_target'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final sent = ref.watch(_notifProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال الإشعارات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProCard(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('إشعار جديد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'العنوان',
                      prefixIcon: Icon(Icons.title_rounded, size: 20)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'المحتوى',
                      prefixIcon: Icon(Icons.message_rounded, size: 20)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _target,
                  decoration: const InputDecoration(
                      labelText: 'المستهدفون',
                      prefixIcon: Icon(Icons.group_rounded, size: 20)),
                  items: _targets.map((t) =>
                      DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _target = v!),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 52, child: ElevatedButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('إرسال الإشعار'),
                )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (sent.isNotEmpty) ...[
            const Text('الإشعارات المُرسلة',
                style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...sent.map((n) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.stroke)),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.title,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(n.body,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  Text('${n.target} • ${_formatTime(n.sentAt)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ])),
              ]),
            )),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}';
}
