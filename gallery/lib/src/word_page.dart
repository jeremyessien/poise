import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import 'demos/demos.dart';
import 'lane.dart';
import 'lane_curve.dart';
import 'settings.dart';
import 'theme.dart';
import 'word_feel.dart';
import 'words.dart';

final class WordPage extends StatefulWidget {
  const WordPage({super.key, required this.word});

  final MotionWord word;

  @override
  State<WordPage> createState() => _WordPageState();
}

final class _WordPageState extends State<WordPage> {
  final _play = PlaySignal();

  double get _curveWindow =>
      Personality.values
          .map((p) => feltMicros(widget.word.feelIn(p.motion)))
          .fold(0, math.max)
          .toDouble() *
      curveWindowStretch;

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'All words',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: GalleryColors.ink),
            ),
          ),
          const SizedBox(height: 8),
          _WordTitle(word: widget.word),
          const SizedBox(height: 8),
          Text(widget.word.description, style: GalleryType.body),
          const SizedBox(height: 24),
          const GalleryControls(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, personality) in Personality.values.indexed)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
                    child: Lane(
                      personality: personality,
                      child: PoiseScope(
                        motion: personality.motion,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            LaneCurve(
                              word: widget.word,
                              color: personality.color,
                              windowMicros: _curveWindow,
                            ),
                            demoFor(widget.word, _play),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _play.play, child: const Text('Play')),
        ],
      ),
    ),
  );
}

final class _WordTitle extends StatefulWidget {
  const _WordTitle({required this.word});

  final MotionWord word;

  @override
  State<_WordTitle> createState() => _WordTitleState();
}

final class _WordTitleState extends State<_WordTitle>
    with SingleTickerProviderStateMixin {
  static const _rise = 24.0;

  late final AnimationController _arrival = AnimationController(vsync: this);
  late Feel _feel;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = context.motion;
    _feel = motion.reducesMotion ? motion.enter : PoiseMotion.calm.enter;
    if (!_started) {
      _started = true;
      _arrival
        ..duration = _feel.duration
        ..forward();
    }
  }

  @override
  void dispose() {
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settled = _arrival.drive(CurveTween(curve: _feel.curve));
    final travels = _feel is Move;
    return FadeTransition(
      opacity: _arrival,
      child: AnimatedBuilder(
        animation: settled,
        builder: (context, title) => Transform.translate(
          offset: Offset(0, travels ? _rise * (1 - settled.value) : 0),
          child: title,
        ),
        child: Text(widget.word.name, style: GalleryType.word),
      ),
    );
  }
}
