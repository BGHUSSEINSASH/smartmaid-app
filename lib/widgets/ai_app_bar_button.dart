import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'ai_chat_sheet.dart';

/// زر الذكاء الاصطناعي — يُضاف لـ AppBar.actions في أي شاشة
/// اللون يتكيف تلقائياً مع الوضع الداكن
IconButton aiAppBarButton(BuildContext context, {String? initialMessage}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return IconButton(
    icon: const Icon(Icons.auto_awesome_rounded),
    // في الوضع الداكن: أبيض واضح بدل الأزرق الداكن
    color: isDark ? Colors.white : AppColors.accent,
    tooltip: 'المساعد الذكي',
    onPressed: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiChatSheet(initialMessage: initialMessage),
    ),
  );
}
