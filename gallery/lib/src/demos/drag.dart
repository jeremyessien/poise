import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import '../theme.dart';
import 'playable.dart';

final class DragDemo extends PlayableDemo {
  const DragDemo({super.key, required super.play});

  @override
  State<DragDemo> createState() => _DragDemoState();
}

final class _DragDemoState extends State<DragDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _flickFrom = 110.0;
  static const _flickVelocity = -600.0;
  static const _highest = -LaneGeometry.restTop;
  static const _lowest =
      LaneGeometry.belowLane - LaneGeometry.restTop - LaneGeometry.objectSize;

  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
  );
  late Move _feel;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _settle({required double from, required double velocity}) =>
      _offset.animateWith(SpringSimulation(_feel.spring, from, 0, velocity));

  @override
  void replay() => _settle(from: _flickFrom, velocity: _flickVelocity);

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.follow;

    return Stack(
      children: [
        AtRest(
          child: GestureDetector(
            onVerticalDragStart: (_) => _offset.stop(),
            onVerticalDragUpdate: (drag) => _offset.value =
                (_offset.value + drag.delta.dy).clamp(_highest, _lowest),
            onVerticalDragEnd: (release) => _settle(
              from: _offset.value,
              velocity: release.velocity.pixelsPerSecond.dy,
            ),
            child: AnimatedBuilder(
              animation: _offset,
              builder: (context, object) => Transform.translate(
                offset: Offset(0, _offset.value),
                child: object,
              ),
              child: const LaneObject(),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Text(
            'drag me',
            textAlign: TextAlign.center,
            style: GalleryType.group,
          ),
        ),
      ],
    );
  }
}
