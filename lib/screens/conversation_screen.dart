import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../core/ui/time_format.dart';
import '../providers/chat_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  final bool isSupport;

  const ConversationScreen({super.key, this.conversationId})
      : isSupport = false;

  const ConversationScreen.support({super.key})
      : conversationId = null,
        isSupport = true;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ChatMsg {
  final String senderId;
  final String content;
  final DateTime time;
  _ChatMsg(this.senderId, this.content, this.time);
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;
  final List<_ChatMsg> _supportMessages = [];

  String get _title =>
      widget.isSupport ? 'دعم SmartMaid' : _convField((c) => c.worker.name);

  String get _avatarUrl => widget.isSupport
      ? 'https://i.pravatar.cc/150?img=13'
      : _convField((c) => c.worker.imageUrl);

  String _convField(String Function(dynamic c) f) {
    for (final c in ref.read(chatProvider)) {
      if (c.id == widget.conversationId) return f(c);
    }
    return '';
  }

  List<_ChatMsg> get _messages {
    if (widget.isSupport) return _supportMessages;
    for (final c in ref.watch(chatProvider)) {
      if (c.id == widget.conversationId) {
        return c.messages.map((m) => _ChatMsg(m.senderId, m.content, m.timestamp)).toList();
      }
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.isSupport && _supportMessages.isEmpty) {
      _supportMessages.add(_ChatMsg(
          'support', 'مرحباً بك في دعم SmartMaid 👋 كيف نساعدك اليوم؟', DateTime.now()));
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    HapticFeedback.lightImpact();
    setState(() {
      if (widget.isSupport) {
        _supportMessages.add(_ChatMsg('me', text, DateTime.now()));
      } else {
        ref
            .read(chatProvider.notifier)
            .sendMessage(widget.conversationId!, 'u1', text);
      }
      _typing = true;
    });
    _jumpBottom();
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        if (widget.isSupport) {
          _supportMessages.add(_ChatMsg('support',
              'شكراً لتواصلك! سيراجع فريقنا رسالتك ويرد عليك خلال دقائق 💜', DateTime.now()));
        } else {
          String workerId = 'w1';
          for (final c in ref.read(chatProvider)) {
            if (c.id == widget.conversationId) workerId = c.worker.id;
          }
          ref.read(chatProvider.notifier).sendMessage(
              widget.conversationId!, workerId, 'تم استلام رسالتك، سأرد عليك في أقرب وقت 😊');
        }
      });
      _jumpBottom();
    });
  }

  void _jumpBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 90,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = _messages;

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(url: _avatarUrl, radius: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(_title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages(msgs)),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildMessages(List<_ChatMsg> msgs) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: msgs.length + (_typing ? 1 : 0),
      itemBuilder: (context, i) {
        if (_typing && i == msgs.length) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.stroke),
              ),
              child: Text('يكتب الآن...',
                  style: TextStyle(fontSize: 12, color: context.mutedText)),
            ),
          );
        }
        final m = msgs[i];
        final showDay = i == 0 || m.time.day != msgs[i - 1].time.day;
        final mine = m.senderId == 'me' || m.senderId == 'u1';
        return Column(
          children: [
            if (showDay) _dayChip(m.time, context),
            _bubble(m, mine, context),
          ],
        );
      },
    );
  }

  Widget _dayChip(DateTime time, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(daySeparatorLabel(time),
            style: TextStyle(fontSize: 10.5, color: context.mutedText)),
      ),
    );
  }

  Widget _bubble(_ChatMsg m, bool mine, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: m.content));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم نسخ الرسالة'),
            behavior: SnackBarBehavior.floating));
      },
      child: Align(
        alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: mine ? AppColors.primary : context.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 4 : 18),
              bottomRight: Radius.circular(mine ? 18 : 4),
            ),
            border: Border.all(
                color: mine ? AppColors.primary : context.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.content,
                  style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: mine ? Colors.white : context.ink)),
              const SizedBox(height: 4),
              Text(DateFormat('HH:mm').format(m.time),
                  style: TextStyle(
                      fontSize: 9.5,
                      color: mine ? Colors.white60 : AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالة...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            IconButton(
              onPressed: _send,
              icon:
                  const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  final String url;
  final double radius;
  const AppAvatar({super.key, required this.url, this.radius = 24});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          context.isDark ? Colors.white10 : const Color(0xFFE9EDF7),
      backgroundImage: NetworkImage(url),
    );
  }
}
