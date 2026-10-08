import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// Makes any widget respond to a press using the `feedback` motion word.
///
/// While held, the child shrinks slightly and springs back on release, in
/// whatever personality the nearest `PoiseScope` sets. When the phone asks for
/// less motion it dims instead of shrinking. [onTap] fires on release.
final class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
  });

  final VoidCallback onTap;

  /// What a screen reader announces for this button. Leave it out when the
  /// child's own text already says it. Buttons inside the child stay
  /// reachable either way.
  final String? semanticLabel;
  final Widget child;

  @override
  State<Pressable> createState() => _PressableState();
}

final class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  static const _pressedScale = 0.97;

  late final AnimationController _press = AnimationController(vsync: this);
  late Feel _feel;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    _press.duration = _feel.duration;
    _press.forward();
  }

  void _up() {
    _press.reverseDuration = _feel.duration;
    _press.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.feedback;
    final pressed = _press.drive(CurveTween(curve: _feel.curve));
    final travels = _feel is Move;

    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _down(),
        onTapUp: (_) {
          _up();
          widget.onTap();
        },
        onTapCancel: _up,
        child: AnimatedBuilder(
          animation: pressed,
          builder: (context, child) => travels
              ? Transform.scale(
                  scale: 1 - (1 - _pressedScale) * pressed.value,
                  child: child,
                )
              : child ?? const SizedBox.shrink(),
          child: FadeTransition(
            opacity: travels
                ? kAlwaysCompleteAnimation
                : pressed.drive(Tween(begin: 1, end: 0.7)),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
