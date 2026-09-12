import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/chat_provider.dart';
import 'assistant_screen.dart';
import 'conversation_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 100),
        children: [
          _AssistantTile(onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AssistantScreen()));
          }),
          const SizedBox(height: 12),
          _SupportTile(onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ConversationScreen.support()));
          }),
          const SizedBox(height: 16),
          if (conversations.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('لا توجد محادثات بعد',
                      style: TextStyle(color: AppColors.muted)),
                ],
              ),
            )
          else
            ...conversations.map((c) {
              final last = c.lastMessage;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(c.worker.imageUrl),
                      ),
                      if (c.unreadCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${c.unreadCount}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(c.worker.name,
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      if (last != null)
                        Text(
                          DateFormat('HH:mm').format(last.timestamp),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    last?.content ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        color: c.unreadCount > 0
                            ? (isDark ? Colors.white : AppColors.textPrimary)
                            : AppColors.muted),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ConversationScreen(conversationId: c.id))),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AssistantTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AssistantTile({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: context.heroSoftGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المساعد الذكي',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text('صف حاجتك وسنقترح أفضل عاملة لك',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final VoidCallback onTap;
  const _SupportTile({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('دعم SmartMaid',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text('متاحون على مدار الساعة لمساعدتك',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
