import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/ai/assistant_engine.dart';
import '../core/api/api_client.dart';
import '../core/theme/app_theme.dart';

class AiChatSheet extends ConsumerStatefulWidget {
  final String? initialMessage;
  const AiChatSheet({super.key, this.initialMessage});

  @override
  ConsumerState<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends ConsumerState<AiChatSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _typing = false;

  // صوت
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  bool _speechAvailable = false;
  double _soundLevel = 0;

  static const _quickReplies = [
    'ابحثي لي عن عاملة تنظيف عميق',
    'ما أفضل عاملة طبخ متاحة؟',
    'احجز لي عاملة غداً الصباح',
    'الفرق بين الحجز الشهري والسنوي؟',
    'كيف أتتبع حجزي الحالي؟',
    'ما أسعار الخدمات؟',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _addBot('مرحباً! 👋 أنا مساعدك الذكي في SmartMaid.\nكيف أساعدك اليوم؟ يمكنك الكتابة أو الضغط على 🎤 للتحدث.');
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.initialMessage!));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final ok = await _speech.initialize(
        onError: (_) => _stopListening(),
        onStatus: (s) { if (s == 'done' || s == 'notListening') _stopListening(); },
      );
      if (mounted) setState(() => _speechAvailable = ok);
    } catch (_) {}
  }

  Future<void> _toggleListen() async {
    HapticFeedback.lightImpact();
    if (_listening) { _stopListening(); return; }
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الميكروفون غير متاح على هذا الجهاز'),
        backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        setState(() => _ctrl.text = r.recognizedWords);
        _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
        if (r.finalResult) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _stopListening();
            if (_ctrl.text.trim().isNotEmpty) _send(_ctrl.text.trim());
          });
        }
      },
      onSoundLevelChange: (l) { if (mounted) setState(() => _soundLevel = l.clamp(0, 10)); },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'ar_SA',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) setState(() { _listening = false; _soundLevel = 0; });
  }

  void _addBot(String text, {List<AssistantMatch> matches = const []}) {
    if (!mounted) return;
    setState(() => _msgs.add(_Msg(text: text, fromUser: false, matches: matches)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 300,
            duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    if (!mounted) return;
    setState(() { _msgs.add(_Msg(text: text, fromUser: true)); _typing = true; });
    _scrollToBottom();

    // 1. محاولة Backend أولاً
    String? backendReply;
    try {
      final resp = await ApiClient.post('/ai/chat', {'message': text})
          .timeout(const Duration(seconds: 8));
      backendReply = resp?['reply']?.toString();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _typing = false);

    if (backendReply != null && backendReply.isNotEmpty) {
      _addBot(backendReply);
    } else {
      // 2. Fallback محلي ذكي
      await Future.delayed(const Duration(milliseconds: 400));
      final result = _localReply(text);
      if (mounted) _addBot(result.text, matches: result.matches);
    }
  }

  _ReplyResult _localReply(String query) {
    final q = query.toLowerCase();

    if (q.contains('سنوي') || q.contains('سنة') || q.contains('annual')) {
      return _ReplyResult(text: '📅 الحجز السنوي:\n• وفّر حتى 30% مقارنة بالشهري\n• عاملة ثابتة بأيام وأوقات محددة\n• ملاحظات دائمة لا تحتاج تكرارها\n\nلتجربته: الرئيسية → "حجز سنوي" ✨');
    }
    if (q.contains('سعر') || q.contains('تكلفة') || q.contains('كم')) {
      return _ReplyResult(text: 'أسعارنا تبدأ من:\n• \$25/ساعة — تنظيف عادي\n• \$30/ساعة — تنظيف عميق\n• \$35/ساعة — رعاية أطفال\n\nمع خصم 30% للحجز السنوي 🎁\nاطلع على كل الأسعار في شاشة الحجز.');
    }
    if (q.contains('تتبع') || q.contains('حجزي') || q.contains('طلبي') || q.contains('وين')) {
      return _ReplyResult(text: 'لمتابعة حجزك الحالي:\n1. اضغط على تبويب "حجوزاتي"\n2. اختر الحجز النشط\n3. ستجد موقع العاملة وحالة الخدمة لحظة بلحظة 📍\n\nعادةً تصل العاملة خلال 30 دقيقة من وقت الحجز.');
    }
    if (q.contains('شكر') || q.contains('عظيم') || q.contains('ممتاز') || q.contains('رائع')) {
      return _ReplyResult(text: 'شكراً لك! 😊 سعيدة بمساعدتك. هل تحتاج شيئاً آخر؟');
    }

    // بحث عاملات
    final matches = matchWorkers(query);
    if (matches.isNotEmpty) {
      final top = matches.take(3).toList();
      return _ReplyResult(
        text: '🔍 وجدت ${matches.length} عاملة تناسب طلبك:\n${top.map((m) => '• ${m.name} — ${m.reason} (${(m.matchScore * 100).round()}% تطابق)').join('\n')}\n\nاضغط على اسم العاملة للحجز مباشرة 👇',
        matches: top,
      );
    }

    // اقتراح تصحيح
    final suggestion = suggestCorrection(query);
    if (suggestion != null) {
      return _ReplyResult(text: 'لم أجد نتائج لـ "$query".\nهل تقصد: "$suggestion"؟ 🤔\n\nيمكنني مساعدتك في:\n• البحث عن عاملة\n• معرفة الأسعار\n• الحجز السنوي\n• تتبع الطلبات');
    }

    final generic = [
      'يمكنني مساعدتك في:\n• 🔍 البحث عن عاملة بالكتابة أو الصوت\n• 📅 حجز سنوي بخصم 30%\n• 💰 الاستفسار عن الأسعار\n• 📍 تتبع الطلبات\n\nماذا تحتاج؟',
      'أهلاً! دعني أساعدك. أخبرني نوع الخدمة التي تحتاجها (تنظيف، طبخ، رعاية...) وسأجد لك الأفضل 🌟',
    ];
    return _ReplyResult(text: generic[DateTime.now().millisecond % generic.length]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.stroke, borderRadius: BorderRadius.circular(2))),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('المساعد الذكي', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text('AI + بحث صوتي • متاح 24/7', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
          ]),
        ),
        const Divider(height: 1),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _msgs.length) return const _TypingIndicator();
            return _MsgBubble(msg: _msgs[i]);
          },
        )),
        // Quick replies (only first time)
        if (_msgs.length == 1)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                  ),
                  child: Text(_quickReplies[i], style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // مؤشر الاستماع
        if (_listening)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ...List.generate(5, (i) => AnimatedContainer(
                duration: Duration(milliseconds: 100 + i * 30),
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: 4 + (_soundLevel * (i % 3 == 1 ? 2 : 1.5)).clamp(0, 18),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(width: 10),
              const Text('جارٍ الاستماع...', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        // Input
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                decoration: InputDecoration(
                  hintText: _listening ? 'تحدّث الآن...' : 'اكتب رسالتك...',
                  filled: true,
                  fillColor: isDark ? AppColors.bgDeep : AppColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // زر الميكروفون
            GestureDetector(
              onTap: _toggleListen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: _listening ? null : null,
                  color: _listening ? AppColors.error.withValues(alpha: .12) : AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _listening ? AppColors.error.withValues(alpha: .4) : AppColors.primary.withValues(alpha: .2)),
                ),
                child: Icon(
                  _listening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: _listening ? AppColors.error : AppColors.primary, size: 20,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // زر الإرسال
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  final List<AssistantMatch> matches;
  const _Msg({required this.text, required this.fromUser, this.matches = const []});
}

class _ReplyResult {
  final String text;
  final List<AssistantMatch> matches;
  const _ReplyResult({required this.text, this.matches = const []});
}

class _MsgBubble extends StatelessWidget {
  final _Msg msg;
  const _MsgBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: msg.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: msg.fromUser ? AppColors.heroGradient : null,
            color: msg.fromUser ? null : (isDark ? AppColors.bgDeep : AppColors.bg),
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomRight: msg.fromUser ? const Radius.circular(4) : null,
              bottomLeft: msg.fromUser ? null : const Radius.circular(4),
            ),
          ),
          child: Text(msg.text, style: TextStyle(color: msg.fromUser ? Colors.white : null, fontSize: 14, height: 1.55)),
        ),
        // عاملات مقترحة
        if (msg.matches.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: msg.matches.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (m.imageUrl != null)
                CircleAvatar(radius: 12, backgroundImage: NetworkImage(m.imageUrl!)),
              if (m.imageUrl != null) const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Text('${(m.matchScore * 100).round()}% تطابق', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
              ]),
            ]),
          )).toList()),
        ],
      ]),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingState();
}
class _TypingState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: const Radius.circular(4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final p = ((_c.value * 3) - i).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 7, height: 7,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3 + p * 0.7), shape: BoxShape.circle),
          );
        },
      ))),
    ),
  );
}

