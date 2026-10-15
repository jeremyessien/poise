import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

import '../reveal/reveal.dart';

/// A column whose children arrive one after another, each with the `enter`
/// word, spaced by the personality's `stagger` gap.
///
/// Every child arrives through a [Reveal], so it gets the same springs and
/// reduce-motion behaviour. When the phone asks for less motion the gap is
/// zero and everything fades in together. Change [replayKey] to play the
/// cascade again. Children added later arrive in turn after the rest.
final class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.replayKey,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.from = RevealFrom.bottom,
    this.distance = 16,
  });

  final List<Widget> children;

  /// Changing this plays the cascade again from the first child.
  final Object? replayKey;

  final CrossAxisAlignment crossAxisAlignment;
  final RevealFrom from;
  final double distance;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

final class _StaggeredColumnState extends State<StaggeredColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  var _gap = Duration.zero;
  var _arrived = 0;
  var _round = 0;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController.unbounded(vsync: this)
      ..addListener(_letNextArrive);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gap = context.motion.stagger;
    if (!_started) {
      _started = true;
      _startCascade();
    }
  }

  @override
  void didUpdateWidget(StaggeredColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey) {
      setState(() => _round++);
      _startCascade();
    } else if (widget.children.length > oldWidget.children.length) {
      _continueTo(widget.children.length);
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _startCascade() {
    _clock.stop();
    _clock.value = 0;
    _arrived = math.min(1, widget.children.length);
    _continueTo(widget.children.length);
  }

  void _continueTo(int count) {
    if (_gap == Duration.zero) {
      _arrived = count;
      return;
    }
    final lastArrival = (count - 1).toDouble();
    final remaining = lastArrival - _clock.value;
    if (remaining <= 0) return;
    _clock.animateTo(lastArrival, duration: _gap * remaining);
  }

  void _letNextArrive() {
    final arrived = math.min(widget.children.length, _clock.value.floor() + 1);
    if (arrived != _arrived) setState(() => _arrived = arrived);
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: widget.crossAxisAlignment,
    children: [
      for (final (index, child) in widget.children.indexed)
        Reveal(
          key: ValueKey((_round, index)),
          visible: index < _arrived,
          from: widget.from,
          distance: widget.distance,
          child: child,
        ),
    ],
  );
}
