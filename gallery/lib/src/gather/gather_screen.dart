import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';

import '../settings.dart';
import '../theme.dart';
import '../tour.dart';
import '../words.dart';
import 'event_card.dart';
import 'events.dart';
import 'gather_style.dart';
import 'personality_dial.dart';

final class GatherScreen extends StatefulWidget {
  const GatherScreen({super.key});

  @override
  State<GatherScreen> createState() => _GatherScreenState();
}

final class _GatherScreenState extends State<GatherScreen> {
  static const _toastStays = Duration(milliseconds: 1800);

  var _personality = Personality.calm;
  final _saved = <int>{};
  final _firstCard = GlobalKey();
  final _secondHeart = GlobalKey();
  final _dial = GlobalKey();
  var _toursSeen = 0;
  var _touring = false;
  var _cascades = 0;
  var _tourCaption = (title: '', line: '');
  var _captionShowing = false;
  var _toastVisible = false;
  var _toastText = '';
  Timer? _toastTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final requested = GallerySettingsScope.of(context).toursRequested;
    if (requested > _toursSeen) {
      _toursSeen = requested;
      _playTour();
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  bool _onScreen() => mounted && (ModalRoute.of(context)?.isCurrent ?? true);

  Future<bool> _turnDialTo(Tour tour, Personality personality) async {
    final dial = _dial.currentContext?.findRenderObject();
    if (dial is! RenderBox) return false;
    return tour.tapAt(PersonalityDial.segmentCentre(dial, personality));
  }

  void _caption(String title, String line) => setState(() {
    _tourCaption = (title: title, line: line);
    _captionShowing = true;
  });

  void _captionWord(MotionWord word) => _caption(word.name, word.description);

  Future<void> _playTour() async {
    if (_touring) return;
    _touring = true;
    final tour = Tour(isStillShowing: _onScreen);
    const beat = Duration(milliseconds: 900);
    try {
      _caption('poise', 'Ten words for motion, all inside one app');
      await tour.pause(const Duration(milliseconds: 1800));

      _captionWord(MotionWord.feedback);
      await tour.pause(beat);
      if (!await tour.tap(
        _firstCard,
        hold: const Duration(milliseconds: 600),
      )) {
        return;
      }
      await tour.pause(beat);

      _captionWord(MotionWord.enter);
      await tour.pause(beat);
      if (!await tour.tap(_secondHeart)) return;
      await tour.pause(const Duration(milliseconds: 1400));

      _captionWord(MotionWord.exit);
      await tour.pause(const Duration(milliseconds: 1500));

      _captionWord(MotionWord.stagger);
      await tour.pause(const Duration(milliseconds: 500));
      if (!_onScreen()) return;
      setState(() => _cascades++);
      await tour.pause(const Duration(milliseconds: 1600));

      _caption(
        'Same code, three personalities',
        'Watch the whole screen change',
      );
      await tour.pause(const Duration(milliseconds: 1400));
      for (final personality in const [
        Personality.crisp,
        Personality.playful,
        Personality.calm,
      ]) {
        if (!await _turnDialTo(tour, personality)) return;
        _caption(personality.label, _feelOf(personality));
        await tour.pause(const Duration(milliseconds: 1900));
      }
    } finally {
      _touring = false;
      if (mounted) setState(() => _captionShowing = false);
    }
  }

  String _feelOf(Personality personality) => switch (personality) {
    Personality.calm => 'Settled and quiet',
    Personality.crisp => 'Quick and exact',
    Personality.playful => 'Springy and alive',
  };

  void _toggleSaved(int index) {
    final nowSaved = !_saved.contains(index);
    setState(() {
      nowSaved ? _saved.add(index) : _saved.remove(index);
      _toastText = nowSaved ? 'Saved to your plans' : 'Removed from your plans';
      _toastVisible = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(_toastStays, () {
      if (mounted) setState(() => _toastVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) => GatherTheme(
    child: PoiseScope(
      motion: _personality.motion,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _PoiseMark(
                      onTap: () => Navigator.of(context).pushNamed('/poise'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Gather', style: GatherType.title),
                  const SizedBox(height: 2),
                  const Text('This week near you', style: GatherType.subtitle),
                  const SizedBox(height: 20),
                  StaggeredColumn(
                    replayKey: (_personality, _cascades),
                    children: [
                      for (final (index, event) in sampleEvents.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(
                            key: index == 0 ? _firstCard : null,
                            heartKey: index == 1 ? _secondHeart : null,
                            event: event,
                            saved: _saved.contains(index),
                            onOpen: () {},
                            onToggleSaved: () => _toggleSaved(index),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 164,
              child: Center(
                child: Reveal(
                  visible: _captionShowing,
                  revealOnFirstBuild: false,
                  child: TourCaption(
                    title: _tourCaption.title,
                    line: _tourCaption.line,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 104,
              child: Center(
                child: Reveal(
                  visible: _toastVisible,
                  revealOnFirstBuild: false,
                  child: _Toast(text: _toastText),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: PersonalityDial(
                      key: _dial,
                      selected: _personality,
                      onChanged: (personality) =>
                          setState(() => _personality = personality),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _Toast extends StatelessWidget {
  const _Toast({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: GatherColors.dial,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.heart_fill,
          size: 16,
          color: GatherColors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GatherType.detail.copyWith(color: GatherColors.dialText),
        ),
      ],
    ),
  );
}

final class _PoiseMark extends StatelessWidget {
  const _PoiseMark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'About poise',
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
        decoration: BoxDecoration(
          color: GalleryColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GalleryColors.grid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: GalleryColors.ink,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('poise', style: GalleryType.listWord.copyWith(fontSize: 20)),
          ],
        ),
      ),
    ),
  );
}
