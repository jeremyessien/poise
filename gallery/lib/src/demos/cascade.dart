import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class StaggerDemo extends PlayableDemo {
  const StaggerDemo({super.key, required super.play});

  @override
  State<StaggerDemo> createState() => _StaggerDemoState();
}

final class _StaggerDemoState extends State<StaggerDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  static const _items = 4;
  static const _itemSize = 20.0;
  static const _gap = 8.0;
  static const _risesFrom = 48.0;

  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: 1,
  );
  late PoiseMotion _motion;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Duration get _total =>
      _motion.enter.duration + _motion.stagger * (_items - 1);

  @override
  void replay() {
    _progress.duration = _total;
    _progress.forward(from: 0);
  }

  Interval _turnOf(int item, Curve curve) {
    final total = _total.inMicroseconds;
    final start = (_motion.stagger * item).inMicroseconds / total;
    final end = start + _motion.enter.duration.inMicroseconds / total;
    return Interval(start, end.clamp(start, 1.0), curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    _motion = context.motion;
    final enter = _motion.enter;
    final travels = enter is Move;

    return AtRest(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var item = 0; item < _items; item++) ...[
            if (item > 0) const SizedBox(height: _gap),
            _Item(
              rise: _progress.drive(
                CurveTween(curve: _turnOf(item, enter.curve)),
              ),
              opacity: _progress.drive(
                CurveTween(
                  curve: _turnOf(item, travels ? Curves.easeOut : enter.curve),
                ),
              ),
              travels: travels,
              primary: item == 0,
            ),
          ],
        ],
      ),
    );
  }
}

final class _Item extends StatelessWidget {
  const _Item({
    required this.rise,
    required this.opacity,
    required this.travels,
    required this.primary,
  });

  final Animation<double> rise;
  final Animation<double> opacity;
  final bool travels;
  final bool primary;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: rise,
    builder: (context, object) => Transform.translate(
      offset: Offset(
        0,
        travels ? _StaggerDemoState._risesFrom * (1 - rise.value) : 0,
      ),
      child: object,
    ),
    child: FadeTransition(
      opacity: opacity,
      child: LaneObject(size: _StaggerDemoState._itemSize, primary: primary),
    ),
  );
}
