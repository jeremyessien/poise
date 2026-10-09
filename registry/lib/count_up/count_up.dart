import 'dart:ui' show FontFeature, lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

import '../text_swap/text_swap.dart';

/// A number that counts to its new value, using the `change` word.
///
/// When [value] changes, the number counts there through the values in
/// between, so a balance of 1,200 visibly climbs to 1,450. Digits are drawn
/// at equal widths, so the number doesn't jiggle as it counts. Screen readers
/// hear only the value it lands on.
///
/// When the phone asks for less motion it doesn't count: the new number
/// fades in through a [TextSwap].
final class CountUp extends StatefulWidget {
  const CountUp({super.key, required this.value, this.format, this.style});

  final num value;

  /// Turns the number into text. Whole numbers count in whole steps; give a
  /// format that shows decimals to see the fractions go by.
  final String Function(num value)? format;

  final TextStyle? style;

  @override
  State<CountUp> createState() => _CountUpState();
}

final class _CountUpState extends State<CountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  late num _from = widget.value;
  late Feel _feel;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _feel = _withoutBounce(context.motion.change);
  }

  /// Counts at the personality's pace but never bounces: a number that
  /// overshoots shows a value that isn't true, like -1 spots left.
  static Feel _withoutBounce(Feel feel) => switch (feel) {
    Move(:final perceivedDuration) => Move(
      perceivedDuration: perceivedDuration,
    ),
    Fade() => feel,
  };

  @override
  void didUpdateWidget(CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = _between(_from, oldWidget.value);
      _progress
        ..duration = _feel.duration
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  num get _shown => _between(_from, widget.value);

  num _between(num from, num to) {
    final t = _feel.curve.transform(_progress.value);
    final value = lerpDouble(from, to, t) ?? to;
    return to is int ? value.round() : value;
  }

  String _text(num value) => widget.format?.call(value) ?? '$value';

  @override
  Widget build(BuildContext context) {
    final style = (widget.style ?? const TextStyle()).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    if (context.motion.reducesMotion) {
      return TextSwap(_text(widget.value), style: style);
    }
    return Semantics(
      liveRegion: true,
      label: _text(widget.value),
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) => Text(_text(_shown), style: style),
      ),
    );
  }
}
