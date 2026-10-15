import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// Makes placeholder shapes look alive while real content loads, using the
/// `loop` word. Wrap the skeleton you show in place of the content.
///
/// Where the personality's `loop` is a fade, the placeholders breathe, dimming
/// and brightening. Where it's a spring, a highlight sweeps across them. When
/// the phone asks for less motion it holds still, because motion that repeats
/// on its own is the hardest kind to sit through.
///
/// It runs only while it's on screen, and stops the moment it's removed, so
/// swap it for the real content as soon as that arrives.
final class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.highlight = const Color(0x99FFFFFF),
  });

  final Widget child;

  /// The colour of the sweep, blended over the placeholders.
  final Color highlight;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

final class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  static const _dimmest = 0.45;

  late final AnimationController _cycle;
  late PoiseMotion _motion;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _cycle = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previous = _started ? _motion : null;
    _motion = context.motion;
    if (!_started || previous != _motion) {
      _started = true;
      _loop();
    }
  }

  void _loop() {
    if (_motion.reducesMotion) {
      _cycle
        ..stop()
        ..value = 0;
      return;
    }
    final period = _motion.loop.duration;
    switch (_motion.loop) {
      case Move():
        _cycle.repeat(period: period);
      case Fade():
        _cycle.repeat(reverse: true, period: period);
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loop = _motion.loop;
    final placeholders = RepaintBoundary(child: widget.child);
    if (_motion.reducesMotion) return placeholders;

    return switch (loop) {
      Fade(:final curve) => FadeTransition(
        opacity: _cycle.drive(
          Tween<double>(
            begin: 1,
            end: _dimmest,
          ).chain(CurveTween(curve: curve)),
        ),
        child: placeholders,
      ),
      Move() => AnimatedBuilder(
        animation: _cycle,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              widget.highlight.withValues(alpha: 0),
              widget.highlight,
              widget.highlight.withValues(alpha: 0),
            ],
            stops: const [0.35, 0.5, 0.65],
            transform: _Sweep(_cycle.value),
          ).createShader(bounds, textDirection: Directionality.of(context)),
          child: child,
        ),
        child: placeholders,
      ),
    };
  }
}

/// Slides the gradient from fully off the start edge to fully off the end.
final class _Sweep extends GradientTransform {
  const _Sweep(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final towardsEnd = textDirection == TextDirection.rtl ? -1.0 : 1.0;
    return Matrix4.translationValues(
      towardsEnd * bounds.width * (progress * 2 - 1),
      0,
      0,
    );
  }
}
