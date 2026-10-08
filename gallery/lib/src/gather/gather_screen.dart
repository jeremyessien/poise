import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/reveal/reveal.dart';

import '../theme.dart';
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
  var _toastVisible = false;
  var _toastText = '';
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

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
  Widget build(BuildContext context) => Theme(
    data: ThemeData(
      scaffoldBackgroundColor: GatherColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: GatherColors.accent),
    ),
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
                  KeyedSubtree(
                    key: ValueKey(_personality),
                    child: Column(
                      children: [
                        for (final (index, event) in sampleEvents.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Reveal(
                              visible: true,
                              child: EventCard(
                                event: event,
                                saved: _saved.contains(index),
                                onOpen: () {},
                                onToggleSaved: () => _toggleSaved(index),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
