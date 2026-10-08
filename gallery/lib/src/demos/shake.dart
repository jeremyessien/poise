import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class ShakeDemo extends PlayableDemo {
  const ShakeDemo({super.key, required super.play});

  @override
  State<ShakeDemo> createState() => _ShakeDemoState();
}

final class _ShakeDemoState extends State<ShakeDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _reach = 14.0;
  static const _swings = 3;
  static const _dimmedTo = 0.4;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: 1,
  );
  late Feel _feel;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  void replay() {
    _progress.duration = _feel.duration;
    _progress.forward(from: 0);
  }

  double _sideways(double t) {
    final settling = 1 - _feel.curve.transform(t);
    return _reach * math.sin(t * _swings * 2 * math.pi) * settling;
  }

  double _flash(double t) => 1 - (1 - _dimmedTo) * math.sin(t * math.pi);

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.attention;
    final shakes = _feel is Move;

    return AtRest(
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, object) => Transform.translate(
          offset: Offset(shakes ? _sideways(_progress.value) : 0, 0),
          child: object,
        ),
        child: FadeTransition(
          opacity: shakes
              ? kAlwaysCompleteAnimation
              : _progress.drive(_FlashTween(_flash)),
          child: const LaneObject(),
        ),
      ),
    );
  }
}

final class _FlashTween extends Animatable<double> {
  _FlashTween(this._at);

  final double Function(double) _at;

  @override
  double transform(double t) => _at(t);
}
