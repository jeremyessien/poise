import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class PressDemo extends PlayableDemo {
  const PressDemo({super.key, required super.play});

  @override
  State<PressDemo> createState() => _PressDemoState();
}

final class _PressDemoState extends State<PressDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _pressedScale = 0.82;
  static const _pressedOpacity = 0.5;
  static const _held = Duration(milliseconds: 120);

  late final AnimationController _press = AnimationController(vsync: this);
  late Feel _feel;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Future<void> replay() async {
    _press
      ..duration = _feel.duration
      ..reverseDuration = _feel.duration;
    try {
      await _press.forward(from: 0).orCancel;
      await Future<void>.delayed(_held);
      if (mounted) await _press.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.feedback;
    final pressed = _press.drive(CurveTween(curve: _feel.curve));
    final travels = _feel is Move;

    return AtRest(
      child: AnimatedBuilder(
        animation: pressed,
        builder: (context, object) => travels
            ? Transform.scale(
                scale: 1 - (1 - _pressedScale) * pressed.value,
                child: object,
              )
            : object ?? const SizedBox.shrink(),
        child: FadeTransition(
          opacity: travels
              ? kAlwaysCompleteAnimation
              : _press.drive(Tween(begin: 1, end: _pressedOpacity)),
          child: const LaneObject(),
        ),
      ),
    );
  }
}
