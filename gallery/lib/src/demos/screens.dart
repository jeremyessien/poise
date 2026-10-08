import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import '../lane.dart';
import 'playable.dart';

final class ScreenChangeDemo extends PlayableDemo {
  const ScreenChangeDemo({super.key, required super.play});

  @override
  State<ScreenChangeDemo> createState() => _ScreenChangeDemoState();
}

final class _ScreenChangeDemoState extends State<ScreenChangeDemo>
    with SingleTickerProviderStateMixin, ReplaysOnPlay {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: 1,
  );
  late Feel _feel;
  var _showingFirst = true;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  void replay() {
    setState(() => _showingFirst = !_showingFirst);
    _progress.duration = _feel.duration;
    _progress.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    _feel = context.motion.transition;
    final settled = _progress.drive(CurveTween(curve: _feel.curve));
    final travels = _feel is Move;
    final incoming = _Screen(filled: !_showingFirst);
    final outgoing = _Screen(filled: _showingFirst);

    return LayoutBuilder(
      builder: (context, lane) {
        final width = lane.maxWidth;
        Widget slide(
          Widget screen,
          Animation<double> opacity,
          double Function(double) from,
        ) => AnimatedBuilder(
          animation: settled,
          builder: (context, child) => Transform.translate(
            offset: Offset(travels ? from(settled.value) : 0, 0),
            child: child,
          ),
          child: FadeTransition(opacity: opacity, child: screen),
        );

        return AtRest(
          child: Stack(
            alignment: Alignment.center,
            children: [
              slide(
                outgoing,
                travels ? kAlwaysCompleteAnimation : ReverseAnimation(settled),
                (t) => -width * t,
              ),
              slide(
                incoming,
                travels ? kAlwaysCompleteAnimation : settled,
                (t) => width * (1 - t),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _Screen extends StatelessWidget {
  const _Screen({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) => filled
      ? const LaneObject(size: 60)
      : const Opacity(
          opacity: 0.35,
          child: LaneObject(size: 60, primary: false),
        );
}
