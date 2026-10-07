import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class LoopDemo extends PlayableDemo {
  const LoopDemo({super.key, required super.play});

  @override
  State<LoopDemo> createState() => _LoopDemoState();
}

final class _LoopDemoState extends State<LoopDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _bob = 18.0;
  static const _faintest = 0.3;

  late final AnimationController _cycle = AnimationController(vsync: this);
  late PoiseMotion _motion;

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  void replay() {
    if (_cycle.isAnimating) {
      _cycle.animateBack(0, duration: _motion.loop.duration);
      return;
    }
    if (_motion.reducesMotion) return;
    _cycle.repeat(reverse: true, period: _motion.loop.duration);
  }

  @override
  Widget build(BuildContext context) {
    _motion = context.motion;
    if (_motion.reducesMotion && _cycle.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cycle.value = 0;
      });
    }

    final feel = _motion.loop;
    final settled = _cycle.drive(CurveTween(curve: feel.curve));
    final bobs = feel is Move;

    return AtRest(
      child: AnimatedBuilder(
        animation: settled,
        builder: (context, object) => Transform.translate(
          offset: Offset(0, bobs ? -_bob * settled.value : 0),
          child: object,
        ),
        child: FadeTransition(
          opacity: bobs
              ? kAlwaysCompleteAnimation
              : settled.drive(Tween(begin: 1, end: _faintest)),
          child: const LaneObject(),
        ),
      ),
    );
  }
}
