import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// Where a [Reveal]'s child comes from as it arrives. [start] and [end]
/// follow the reading direction, so they mirror in right-to-left languages.
enum RevealFrom { bottom, top, start, end }

/// Brings its child in with the `enter` motion word when [visible] turns true,
/// and takes it away with `exit` when it turns false.
///
/// Both run on real springs, so a change of mind halfway turns the child
/// around from wherever it is, keeping its momentum. When the phone asks for
/// less motion, the child fades in place instead of travelling.
///
/// A hidden child keeps its space but can't be tapped and is hidden from
/// screen readers. Use [onHidden] to remove it once it has gone.
final class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.visible,
    required this.child,
    this.from = RevealFrom.bottom,
    this.distance = 16,
    this.revealOnFirstBuild = true,
    this.onHidden,
  });

  final bool visible;
  final Widget child;
  final RevealFrom from;

  /// How far the child travels, in logical pixels.
  final double distance;

  /// Whether a child that starts out visible animates in when it first
  /// appears, or is simply there.
  final bool revealOnFirstBuild;

  /// Called once the child has finished leaving.
  final VoidCallback? onHidden;

  @override
  State<Reveal> createState() => _RevealState();
}

final class _RevealState extends State<Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shown = AnimationController.unbounded(
    vsync: this,
    value: widget.visible && !widget.revealOnFirstBuild ? 1 : 0,
  );
  late PoiseMotion _motion;
  late Feel _feel;
  var _settledIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = context.motion;
    if (!_settledIn) {
      _settledIn = true;
      _feel = _motion.enter;
      if (widget.visible && widget.revealOnFirstBuild) _animate(visible: true);
    }
  }

  @override
  void didUpdateWidget(Reveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != widget.visible) {
      _animate(visible: widget.visible);
    }
  }

  @override
  void dispose() {
    _shown.dispose();
    super.dispose();
  }

  Future<void> _animate({required bool visible}) async {
    _feel = visible ? _motion.enter : _motion.exit;
    final target = visible ? 1.0 : 0.0;
    final run = switch (_feel) {
      Move(:final spring) => _shown.animateWith(
        SpringSimulation(spring, _shown.value, target, _shown.velocity),
      ),
      Fade(:final duration, :final curve) => _shown.animateTo(
        target,
        duration: duration,
        curve: curve,
      ),
    };
    try {
      await run.orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    _shown.value = target;
    if (!visible) widget.onHidden?.call();
  }

  Offset _awayFromRest(TextDirection direction) {
    final towardsStart = direction == TextDirection.ltr ? -1.0 : 1.0;
    return switch (widget.from) {
      RevealFrom.bottom => Offset(0, widget.distance),
      RevealFrom.top => Offset(0, -widget.distance),
      RevealFrom.start => Offset(towardsStart * widget.distance, 0),
      RevealFrom.end => Offset(-towardsStart * widget.distance, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final away = _awayFromRest(Directionality.of(context));

    return IgnorePointer(
      ignoring: !widget.visible,
      child: ExcludeSemantics(
        excluding: !widget.visible,
        child: AnimatedBuilder(
          animation: _shown,
          builder: (context, child) => Transform.translate(
            offset: _feel is Move ? away * (1 - _shown.value) : Offset.zero,
            child: child,
          ),
          child: FadeTransition(
            opacity: _shown.drive(_UnitInterval()),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

final class _UnitInterval extends Animatable<double> {
  @override
  double transform(double t) => t.clamp(0.0, 1.0);
}
