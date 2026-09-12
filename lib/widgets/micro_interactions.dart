import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
// Advanced Micro-Interactions & Advanced UI Elements
// ─────────────────────────────────────────────────────────────────

/// Animated like button with haptic feedback
class AnimatedLikeButton extends StatefulWidget {
  final bool initialLiked;
  final Function(bool) onChanged;
  final double size;
  final Color activeColor;

  const AnimatedLikeButton({
    super.key,
    this.initialLiked = false,
    required this.onChanged,
    this.size = 28,
    this.activeColor = const Color(0xFF2FB78A),
  });

  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    _isLiked = !_isLiked;
    if (_isLiked) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onChanged(_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        ),
        child: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? widget.activeColor : AppColors.muted,
          size: widget.size,
        ),
      ),
    );
  }
}

/// Floating action button with ripple effect
class FloatingActionButtonPro extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color backgroundColor;
  final double size;

  const FloatingActionButtonPro({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor = const Color(0xFF2FB78A),
    this.size = 56,
  });

  @override
  State<FloatingActionButtonPro> createState() =>
      _FloatingActionButtonProState();
}

class _FloatingActionButtonProState extends State<FloatingActionButtonPro>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: Material(
        elevation: 8,
        shape: CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withAlpha(77),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: _onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  if (widget.label != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated counter with increment/decrement
class AnimatedCounter extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;
  final int minValue;
  final int maxValue;

  const AnimatedCounter({
    super.key,
    this.initialValue = 1,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue = 999,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late int _value;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    if (_value < widget.maxValue) {
      _controller.forward(from: 0);
      setState(() => _value++);
      widget.onChanged(_value);
    }
  }

  void _decrement() {
    if (_value > widget.minValue) {
      _controller.forward(from: 0);
      setState(() => _value--);
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.stroke),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _decrement,
            icon: const Icon(Icons.remove),
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: SizedBox(
              width: 50,
              child: Text(
                _value.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _increment,
            icon: const Icon(Icons.add),
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

/// Animated toggle switch
class ToggleSwitchPro extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onChanged;
  final String? activeLabel;
  final String? inactiveLabel;

  const ToggleSwitchPro({
    super.key,
    this.initialValue = false,
    required this.onChanged,
    this.activeLabel,
    this.inactiveLabel,
  });

  @override
  State<ToggleSwitchPro> createState() => _ToggleSwitchProState();
}

class _ToggleSwitchProState extends State<ToggleSwitchPro>
    with SingleTickerProviderStateMixin {
  late bool _isActive;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialValue;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isActive ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _isActive = !_isActive;
    if (_isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onChanged(_isActive);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _isActive ? AppColors.primary.withAlpha(77) : AppColors.stroke,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.inactiveLabel != null && !_isActive)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  widget.inactiveLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.5, 0),
                end: const Offset(0.5, 0),
              ).animate(_controller),
              child: Container(
                width: 44,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.activeLabel != null && _isActive)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  widget.activeLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Animated progress indicator
class AnimatedProgressBar extends StatefulWidget {
  final double value; // 0 to 1
  final Duration duration;
  final Color activeColor;
  final Color backgroundColor;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.activeColor = const Color(0xFF2FB78A),
    this.backgroundColor = const Color(0xFFE8F8F2),
    this.height = 6,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animatedValue = Tween<double>(
          begin: 0,
          end: widget.value,
        ).evaluate(_controller);
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: widget.height,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
          ),
        );
      },
    );
  }
}

/// Animated notification badge
class AnimatedBadge extends StatefulWidget {
  final int count;
  final Color color;
  final TextStyle? textStyle;

  const AnimatedBadge({
    super.key,
    required this.count,
    this.color = const Color(0xFF2FB78A),
    this.textStyle,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count && widget.count > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) return const SizedBox.shrink();

    return ScaleTransition(
      scale: Tween<double>(
        begin: 1.5,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.count > 99 ? '99+' : widget.count.toString(),
          style:
              widget.textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Smooth page transition indicator
class PageIndicatorPro extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  const PageIndicatorPro({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor = const Color(0xFF2FB78A),
    this.inactiveColor = const Color(0xFFE8F8F2),
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: isActive ? 1.0 : 0.0, end: isActive ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: size + (isActive ? size * 0.6 * value : 0),
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
                color: Color.lerp(inactiveColor, activeColor, value),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Animated tabs with underline
class AnimatedTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;
  final int initialIndex;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedTabBar({
    super.key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
    this.activeColor = const Color(0xFF2FB78A),
    this.inactiveColor = AppColors.muted,
  });

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
      widget.onTabChanged(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
      labelColor: widget.activeColor,
      unselectedLabelColor: widget.inactiveColor,
      indicatorColor: widget.activeColor,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

/// Swipe to delete/action list item
class SwipeActionListItem extends StatefulWidget {
  final Widget child;
  final Function() onDelete;
  final Color deleteColor;
  final Duration animationDuration;

  const SwipeActionListItem({
    super.key,
    required this.child,
    required this.onDelete,
    this.deleteColor = const Color(0xFFDC2626),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SwipeActionListItem> createState() => _SwipeActionListItemState();
}

class _SwipeActionListItemState extends State<SwipeActionListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _dragOffset;

  @override
  void initState() {
    super.initState();
    _dragOffset = Offset.zero;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragEnd() {
    if (_dragOffset.dx < -80) {
      widget.onDelete();
      _controller.forward();
    } else {
      _controller.reverse();
      setState(() => _dragOffset = Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = Offset(
            (_dragOffset.dx + details.delta.dx).clamp(-100.0, 0.0),
            0,
          );
        });
      },
      onHorizontalDragEnd: (_) => _handleDragEnd(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: widget.deleteColor,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete_outline, color: Colors.white, size: 24),
            ),
          ),
          Transform.translate(offset: _dragOffset, child: widget.child),
        ],
      ),
    );
  }
}
