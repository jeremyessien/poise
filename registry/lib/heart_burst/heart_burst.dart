import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// The like: when [liked] turns true, its child pops with the `celebrate`
/// word while a ring and a burst of particles fly out around it. Unliking is
/// quiet, a small press with `feedback`, because taking a like back isn't a
/// celebration.
///
/// Wrap the heart icon itself, and swap the icon for a filled one as usual;
/// [HeartBurst] only adds the motion. The ring and particles are painted
/// straight from the animation, so nothing rebuilds while they fly.
///
/// When the phone asks for less motion, nothing pops or flies. The filled
/// icon says it on its own.
final class HeartBurst extends StatefulWidget {
  const HeartBurst({
    super.key,
    required this.liked,
    required this.child,
    this.color = const Color(0xFFFF5A5F),
  });

  final bool liked;
  final Widget child;

  /// The colour of the ring and the particles.
  final Color color;

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

final class _HeartBurstState extends State<HeartBurst>
    with TickerProviderStateMixin {
  static const _poppedFrom = 0.55;
  static const _pressedTo = 0.85;

  late final AnimationController _pop;
  late final AnimationController _press;
  late PoiseMotion _motion;

  /// Counts presses, so a cancelled press doesn't release the one after it.
  var _presses = 0;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(vsync: this, value: 1);
    _press = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = context.motion;
  }

  @override
  void didUpdateWidget(HeartBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liked == widget.liked || _motion.reducesMotion) return;
    if (widget.liked) {
      _pop
        ..duration = _motion.celebrate.duration
        ..forward(from: 0);
    } else {
      final press = ++_presses;
      _press
        ..duration = _motion.feedback.duration
        ..forward(from: 0).whenCompleteOrCancel(() {
          if (mounted && press == _presses) _press.reverse();
        });
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final celebrate = _motion.celebrate;
    final popping = _pop.drive(CurveTween(curve: celebrate.curve));
    final pressing = _press.drive(CurveTween(curve: _motion.feedback.curve));

    return CustomPaint(
      painter: _BurstPainter(progress: _pop, color: widget.color),
      child: AnimatedBuilder(
        animation: Listenable.merge([popping, pressing]),
        builder: (context, heart) => Transform.scale(
          scale:
              (_poppedFrom + (1 - _poppedFrom) * popping.value) *
              (1 - (1 - _pressedTo) * pressing.value),
          child: heart,
        ),
        child: widget.child,
      ),
    );
  }
}

/// The ring and particles, drawn around the child and allowed to spill out
/// of its bounds.
final class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  static const _particles = 8;
  static const _reach = 1.25;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final fading = 1 - Curves.easeIn.transform(t);
    final out = Curves.easeOutCubic.transform(t);

    canvas.drawCircle(
      centre,
      radius * (0.6 + 0.6 * out),
      Paint()
        ..color = color.withValues(alpha: 0.5 * fading)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, radius * 0.25 * (1 - out)),
    );

    final particle = Paint()..color = color.withValues(alpha: fading);
    for (var i = 0; i < _particles; i++) {
      final angle = i * 2 * math.pi / _particles - math.pi / 2;
      final distance = radius * (0.7 + _reach * out);
      canvas.drawCircle(
        centre + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius * 0.14 * (1 - out * 0.7),
        particle,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
