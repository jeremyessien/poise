import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';

enum TravelDirection { arriving, leaving }

final class TravelDemo extends StatefulWidget {
  const TravelDemo({super.key, required this.direction, required this.play});

  final TravelDirection direction;
  final Listenable play;

  @override
  State<TravelDemo> createState() => _TravelDemoState();
}

final class _TravelDemoState extends State<TravelDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: widget.direction == TravelDirection.arriving ? 1 : 0,
  );
  late Feel _feel;

  @override
  void initState() {
    super.initState();
    widget.play.addListener(_replay);
  }

  @override
  void didUpdateWidget(TravelDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.play != widget.play) {
      oldWidget.play.removeListener(_replay);
      widget.play.addListener(_replay);
    }
  }

  @override
  void dispose() {
    widget.play.removeListener(_replay);
    _progress.dispose();
    super.dispose();
  }

  void _replay() {
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

    return Stack(
      children: [
        Positioned(
          top: LaneGeometry.restTop,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: settled,
            builder: (context, object) => Transform.translate(
              offset: Offset(0, _travelFromRest(settled.value)),
              child: object,
            ),
            child: FadeTransition(
              opacity: opacity,
              child: const Center(child: LaneObject()),
            ),
          ),
        ),
      ],
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
