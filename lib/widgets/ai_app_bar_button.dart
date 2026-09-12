import 'package:flutter/material.dart';
import 'ai_chat_sheet.dart';

/// زر الذكاء الاصطناعي — يُضاف لـ AppBar.actions في أي شاشة
IconButton aiAppBarButton(BuildContext context, {String? initialMessage}) {
  return IconButton(
    icon: const Icon(Icons.auto_awesome_rounded),
    color: const Color(0xFF0353A4), // AppColors.accent
    tooltip: 'المساعد الذكي',
    onPressed: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiChatSheet(initialMessage: initialMessage),
    ),
  );
}
