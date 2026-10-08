import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

enum TravelDirection { arriving, leaving }

final class TravelDemo extends PlayableDemo {
  const TravelDemo({super.key, required this.direction, required super.play});

  final TravelDirection direction;

  @override
  State<TravelDemo> createState() => _TravelDemoState();
}

final class _TravelDemoState extends State<TravelDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: widget.direction == TravelDirection.arriving ? 1 : 0,
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

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    _feel = switch (widget.direction) {
      TravelDirection.arriving => motion.enter,
      TravelDirection.leaving => motion.exit,
    };

    final settled = _progress.drive(CurveTween(curve: _feel.curve));
    final opacity = switch ((_feel, widget.direction)) {
      (Move(), _) => kAlwaysCompleteAnimation,
      (Fade(), TravelDirection.arriving) => settled,
      (Fade(), TravelDirection.leaving) => ReverseAnimation(settled),
    };

    return AtRest(
      child: AnimatedBuilder(
        animation: settled,
        builder: (context, object) => Transform.translate(
          offset: Offset(0, _travelFromRest(settled.value)),
          child: object,
        ),
        child: FadeTransition(opacity: opacity, child: const LaneObject()),
      ),
    );
  }

  double _travelFromRest(double t) {
    const distance = LaneGeometry.belowLane - LaneGeometry.restTop;
    return switch ((_feel, widget.direction)) {
      (Fade(), _) => 0,
      (Move(), TravelDirection.arriving) => _between(distance, 0, t),
      (Move(), TravelDirection.leaving) => _between(0, distance, t),
    };
  }

  double _between(double from, double to, double t) =>
      lerpDouble(from, to, t) ?? to;
}
