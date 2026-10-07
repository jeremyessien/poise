import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class PopDemo extends PlayableDemo {
  const PopDemo({super.key, required super.play});

  @override
  State<PopDemo> createState() => _PopDemoState();
}

final class _PopDemoState extends State<PopDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _startsAt = 0.4;

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

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.celebrate;
    final settled = _progress.drive(CurveTween(curve: _feel.curve));
    final grows = _feel is Move;

    return AtRest(
      child: AnimatedBuilder(
        animation: settled,
        builder: (context, object) => grows
            ? Transform.scale(
                scale: _startsAt + (1 - _startsAt) * settled.value,
                child: object,
              )
            : object ?? const SizedBox.shrink(),
        child: FadeTransition(
          opacity: grows ? kAlwaysCompleteAnimation : settled,
          child: const LaneObject(),
        ),
      ),
    );
  }
}
