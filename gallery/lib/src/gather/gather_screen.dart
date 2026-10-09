import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/poise_sheet/poise_sheet.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';

import '../theme.dart';
import 'event_card.dart';
import 'event_details.dart';
import 'events.dart';
import 'gather_style.dart';
import 'gather_toast.dart';
import 'personality_dial.dart';

final class GatherScreen extends StatefulWidget {
  const GatherScreen({super.key});

  @override
  State<GatherScreen> createState() => _GatherScreenState();
}

final class _GatherScreenState extends State<GatherScreen> {
  static const _toastStays = Duration(milliseconds: 1800);
  static const _joinTakes = Duration(milliseconds: 900);

  var _personality = Personality.calm;
  final _saved = <int>{};
  int? _opened;
  final _joins = <int, JoinState>{};
  final _joinTimers = <Timer>[];
  var _sheetOpen = false;
  var _toastVisible = false;
  var _toastText = '';
  Timer? _toastTimer;

  @override
  void dispose() {
    for (final timer in _joinTimers) {
      timer.cancel();
    }
    _toastTimer?.cancel();
    super.dispose();
  }

  void _join(int index) {
    if (_joins[index] case JoinState.joining || JoinState.joined) return;
    setState(() => _joins[index] = JoinState.joining);
    _joinTimers.add(
      Timer(_joinTakes * timeDilation, () {
        if (mounted) setState(() => _joins[index] = JoinState.joined);
      }),
    );
  }

  void _toggleSaved(int index) {
    final nowSaved = !_saved.contains(index);
    setState(() {
      nowSaved ? _saved.add(index) : _saved.remove(index);
      _toastText = nowSaved ? 'Saved to your plans' : 'Removed from your plans';
      _toastVisible = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(_toastStays * timeDilation, () {
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
                    replayKey: _personality,
                    children: [
                      for (final (index, event) in sampleEvents.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(
                            event: event,
                            saved: _saved.contains(index),
                            onOpen: () => setState(() {
                              _opened = index;
                              _sheetOpen = true;
                            }),
                            onToggleSaved: () => _toggleSaved(index),
                          ),
                        ),
                    ],
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
                  child: GatherToast(text: _toastText),
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
            Positioned.fill(
              child: PoiseSheet(
                open: _sheetOpen,
                onClose: () => setState(() => _sheetOpen = false),
                child: switch (_opened) {
                  final index? => EventDetails(
                    event: sampleEvents[index],
                    joinState: _joins[index] ?? JoinState.open,
                    onJoin: () => _join(index),
                  ),
                  null => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
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
