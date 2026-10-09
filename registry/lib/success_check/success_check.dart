import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// A tick that draws itself when something has worked: a payment going
/// through, a task done, a place booked.
///
/// When [shown] turns true, a circle pops in with the `celebrate` word and the
/// tick is drawn inside it. When it turns false, the whole mark fades away
/// with `exit`. The tick is painted straight from the animation, so nothing
/// rebuilds while it draws.
///
/// When the phone asks for less motion, the finished tick fades in, already
/// drawn. Screen readers hear [semanticLabel] once it's shown.
final class SuccessCheck extends StatefulWidget {
  const SuccessCheck({
    super.key,
    required this.shown,
    this.size = 56,
    this.color = const Color(0xFF2E7D52),
    this.tickColor = const Color(0xFFFFFFFF),
    this.semanticLabel = 'Done',
  });

  final bool shown;
  final double size;
  final Color color;
  final Color tickColor;
  final String semanticLabel;

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

final class _SuccessCheckState extends State<SuccessCheck>
    with SingleTickerProviderStateMixin {
  static const _tickStarts = 0.35;
  static const _poppedFrom = 0.4;

  late final AnimationController _progress;
  late PoiseMotion _motion;
  var _settledIn = false;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = context.motion;
    if (!_settledIn) {
      _settledIn = true;
      if (widget.shown) _show();
    }
  }

  @override
  void didUpdateWidget(SuccessCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shown == widget.shown) return;
    widget.shown ? _show() : _hide();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _show() {
    _leaving = false;
    _progress
      ..duration = _motion.celebrate.duration
      ..forward(from: 0);
  }

  /// Leaving only fades. Playing the celebrate curve backwards would still
  /// overshoot, and exits never bounce.
  void _hide() {
    _leaving = true;
    _progress.animateBack(0, duration: _motion.exit.duration);
  }

  @override
  Widget build(BuildContext context) {
    final celebrate = _motion.celebrate;
    final pops = celebrate is Move;
    final appear = _progress.drive(
      CurveTween(curve: pops ? celebrate.curve : Curves.easeOut),
    );
    final drawn = pops
        ? _progress.drive(
            CurveTween(
              curve: const Interval(_tickStarts, 1, curve: Curves.easeOutCubic),
            ),
          )
        : kAlwaysCompleteAnimation;

    return Semantics(
      label: widget.shown ? widget.semanticLabel : null,
      liveRegion: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: appear,
          builder: (context, mark) => Transform.scale(
            scale: pops && !_leaving
                ? _poppedFrom + (1 - _poppedFrom) * appear.value
                : 1,
            child: mark,
          ),
          child: FadeTransition(
            opacity: _progress.drive(CurveTween(curve: Curves.easeOut)),
            child: CustomPaint(
              painter: _TickPainter(
                drawn: drawn,
                color: widget.color,
                tickColor: widget.tickColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.drawn,
    required this.color,
    required this.tickColor,
  }) : super(repaint: drawn);

  final Animation<double> drawn;
  final Color color;
  final Color tickColor;

  static const _points = [
    Offset(0.28, 0.52),
    Offset(0.44, 0.67),
    Offset(0.72, 0.36),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    canvas.drawCircle(size.center(Offset.zero), radius, Paint()..color = color);

    final tick = Path()
      ..moveTo(_points[0].dx * size.width, _points[0].dy * size.height)
      ..lineTo(_points[1].dx * size.width, _points[1].dy * size.height)
      ..lineTo(_points[2].dx * size.width, _points[2].dy * size.height);
    final progress = drawn.value.clamp(0.0, 1.0);
    if (progress == 0) return;
    final partial = Path();
    for (final metric in tick.computeMetrics()) {
      partial.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }
    canvas.drawPath(
      partial,
      Paint()
        ..color = tickColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.09
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TickPainter oldDelegate) =>
      oldDelegate.drawn != drawn ||
      oldDelegate.color != color ||
      oldDelegate.tickColor != tickColor;
}
