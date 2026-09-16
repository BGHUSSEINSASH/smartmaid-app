import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/theme/app_theme.dart';
import '../providers/platform_control_provider.dart';
import 'ai_chat_sheet.dart';

/// SmartSearchBar — مكوّن بحث ذكي مشترك مع صوت وAI
/// يُستخدم في home_screen, search_screen, assistant_screen
class SmartSearchBar extends ConsumerStatefulWidget {
  final String hint;
  final ValueChanged<String> onSearch;
  final TextEditingController? controller;
  final bool autofocus;
  final String? aiInitialMessage;
  final VoidCallback? onTap;

  const SmartSearchBar({
    super.key,
    this.hint = 'ابحث بالنص أو الصوت...',
    required this.onSearch,
    this.controller,
    this.autofocus = false,
    this.aiInitialMessage,
    this.onTap,
  });

  @override
  ConsumerState<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends ConsumerState<SmartSearchBar>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  bool _speechAvailable = false;
  double _soundLevel = 0;
  Timer? _silenceTimer;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    _speech.stop();
    _silenceTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (_) => _stopListening(),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') _stopListening();
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  Future<void> _toggleListen() async {
    HapticFeedback.lightImpact();
    if (_listening) { _stopListening(); return; }

    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('الميكروفون غير متاح على هذا الجهاز. استخدم البحث النصي.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ));
      }
      return;
    }

    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _ctrl.text = result.recognizedWords);
        _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);

        // صمت 2 ثانية → بحث تلقائي
        _silenceTimer?.cancel();
        if (result.finalResult) {
          _silenceTimer = Timer(const Duration(milliseconds: 500), () {
            _stopListening();
            if (_ctrl.text.trim().isNotEmpty) widget.onSearch(_ctrl.text.trim());
          });
        }
      },
      onSoundLevelChange: (level) {
        if (mounted) setState(() => _soundLevel = level.clamp(0, 10));
      },
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
    _silenceTimer?.cancel();
    if (mounted) setState(() { _listening = false; _soundLevel = 0; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final flags = ref.watch(platformFlagsProvider);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ── حقل البحث ──
      GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _listening
                  ? AppColors.primary.withValues(alpha: .6)
                  : AppColors.stroke,
              width: _listening ? 1.5 : 1,
            ),
            boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: _listening ? .12 : .05),
              blurRadius: _listening ? 20 : 10,
              offset: const Offset(0, 4),
            )],
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(
              _listening ? Icons.graphic_eq_rounded : Icons.search_rounded,
              color: _listening ? AppColors.primary : AppColors.muted,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(child: widget.onTap != null
                ? Text(_ctrl.text.isEmpty ? widget.hint : _ctrl.text,
                    style: TextStyle(
                      color: _ctrl.text.isEmpty ? AppColors.muted : AppColors.textPrimary,
                      fontSize: 14,
                    ))
                : TextField(
                    controller: _ctrl,
                    autofocus: widget.autofocus,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) widget.onSearch(v.trim());
                    },
                  )),
            // زر AI — فقط إذا مفعّل
            if (flags.aiChatEnabled)
              _IconBtn(
                icon: Icons.auto_awesome_rounded,
                color: AppColors.accent,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AiChatSheet(
                    initialMessage: widget.aiInitialMessage ?? _ctrl.text,
                  ),
                ),
              ),
            // زر الميكروفون — فقط إذا مفعّل
            if (flags.voiceSearchEnabled)
              _MicButton(
                listening: _listening,
                soundLevel: _soundLevel,
                pulseAnim: _pulseAnim,
                onTap: _toggleListen,
              ),
            const SizedBox(width: 8),
          ]),
        ),
      ),
      // ── مؤشر الاستماع ──
      if (_listening)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _SoundWave(level: _soundLevel),
            const SizedBox(width: 10),
            const Text('جارٍ الاستماع... تحدّث الآن',
                style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _stopListening,
              child: const Icon(Icons.stop_circle_rounded, color: AppColors.error, size: 20),
            ),
          ]),
        ),
    ]);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}

class _MicButton extends StatelessWidget {
  final bool listening;
  final double soundLevel;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;
  const _MicButton({required this.listening, required this.soundLevel,
      required this.pulseAnim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: listening ? pulseAnim.value : 1.0,
          child: Container(
            width: 36, height: 36, margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              gradient: listening ? AppColors.heroGradient : null,
              color: listening ? null : AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: listening ? [BoxShadow(
                color: AppColors.primary.withValues(alpha: .4),
                blurRadius: 8 + soundLevel,
                spreadRadius: soundLevel * 0.3,
              )] : null,
            ),
            child: Icon(
              listening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: listening ? Colors.white : AppColors.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundWave extends StatelessWidget {
  final double level;
  const _SoundWave({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      final height = 4.0 + (level * (i % 3 == 1 ? 2.5 : 1.5)).clamp(0, 18);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        width: 3, height: height,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }));
  }
}

