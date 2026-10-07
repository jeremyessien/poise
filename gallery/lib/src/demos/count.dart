import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import '../theme.dart';
import 'playable.dart';

final class CountDemo extends PlayableDemo {
  const CountDemo({super.key, required super.play});

  @override
  State<CountDemo> createState() => _CountDemoState();
}

final class _CountDemoState extends State<CountDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _poppedFrom = 0.55;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: 1,
  );
  late Feel _feel;
  var _count = 1;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  void replay() {
    setState(() => _count = _count == 9 ? 1 : _count + 1);
    _progress.duration = _feel.duration;
    _progress.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.change;
    final settled = _progress.drive(CurveTween(curve: _feel.curve));
    final pops = _feel is Move;
    final previous = _count == 1 ? 9 : _count - 1;

    return AtRest(
      child: LaneObject(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: ReverseAnimation(_progress),
              child: _Digit(previous),
            ),
            AnimatedBuilder(
              animation: settled,
              builder: (context, digit) => pops
                  ? Transform.scale(
                      scale: _poppedFrom + (1 - _poppedFrom) * settled.value,
                      child: digit,
                    )
                  : digit ?? const SizedBox.shrink(),
              child: FadeTransition(
                opacity: pops ? _progress : settled,
                child: _Digit(_count),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _Digit extends StatelessWidget {
  const _Digit(this.value);

  final int value;

  @override
  Widget build(BuildContext context) => Text(
    '$value',
    style: GalleryType.label.copyWith(fontSize: 20, color: GalleryColors.paper),
  );
}
