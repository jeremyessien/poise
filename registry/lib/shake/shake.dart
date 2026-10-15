import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// Shakes its child, the "no" of motion, using the `attention` word. Use it
/// for a wrong password, a code that didn't work, a form that can't be sent.
///
/// It shakes every time [trigger] changes, so pass something that changes on
/// each failed attempt, like a count of attempts. The shake dies away along
/// the personality's `attention` curve, so playful wobbles longer than crisp.
///
/// When the phone asks for less motion, the child dims and brightens once
/// instead of moving. A shake says nothing to a screen reader, so give it an
/// [announcement] to read out each time.
final class Shake extends StatefulWidget {
  const Shake({
    super.key,
    required this.trigger,
    required this.child,
    this.announcement,
    this.reach = 12,
  });

  /// Shakes whenever this changes.
  final Object? trigger;

  final Widget child;

  /// Read out by screen readers on every shake, like "That code didn't work".
  final String? announcement;

  /// How far each swing goes, in logical pixels.
  final double reach;

  @override
  State<Shake> createState() => _ShakeState();
}

final class _ShakeState extends State<Shake>
    with SingleTickerProviderStateMixin {
  static const _swings = 3;
  static const _dimmedTo = 0.4;

  late final AnimationController _progress;
  late Feel _feel;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _feel = context.motion.attention;
  }

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger == widget.trigger) return;
    _progress
      ..duration = _feel.duration
      ..forward(from: 0);
    if (widget.announcement case final message?) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
        assertiveness: Assertiveness.assertive,
      );
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  double _sideways(double t) {
    final dyingAway = 1 - _feel.curve.transform(t);
    return widget.reach * math.sin(t * _swings * 2 * math.pi) * dyingAway;
  }

  @override
  Widget build(BuildContext context) {
    final moves = _feel is Move;
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => Transform.translate(
        offset: Offset(moves ? _sideways(_progress.value) : 0, 0),
        child: child,
      ),
      child: FadeTransition(
        opacity: moves
            ? kAlwaysCompleteAnimation
            : _progress.drive(const _Flash(_dimmedTo)),
        child: widget.child,
      ),
    );
  }
}

/// Dims to [dimmedTo] halfway through and back to exactly full at both
/// ends, so a resting child keeps no fade layer.
final class _Flash extends Animatable<double> {
  const _Flash(this.dimmedTo);

  final double dimmedTo;

  @override
  double transform(double t) =>
      t == 0 || t == 1 ? 1 : 1 - (1 - dimmedTo) * math.sin(t * math.pi);
}
