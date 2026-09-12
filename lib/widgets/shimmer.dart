import 'package:flutter/material.dart';

/// Shimmer loading effect — gradient that sweeps left-to-right repeatedly.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _slide = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF252836) : const Color(0xFFE8EDF2);
    final highlight = isDark
        ? const Color(0xFF353849)
        : const Color(0xFFF5F8FC);

    return AnimatedBuilder(
      animation: _slide,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_slide.value - 1, 0),
            end: Alignment(_slide.value + 1, 0),
            colors: [base, highlight, highlight, base],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Full worker-card skeleton using ShimmerBox
class ShimmerWorkerCard extends StatelessWidget {
  const ShimmerWorkerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1A1D27) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 72, height: 72, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 16, radius: 6),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 12,
                  radius: 6,
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    ShimmerBox(width: 60, height: 24, radius: 12),
                    SizedBox(width: 8),
                    ShimmerBox(width: 60, height: 24, radius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
