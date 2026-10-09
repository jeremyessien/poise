import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'gather_style.dart';

/// An event's own page, opened from its details.
final class EventPage extends StatelessWidget {
  const EventPage({super.key, required this.event});

  final GatherEvent event;

  @override
  Widget build(BuildContext context) => GatherTheme(
    child: Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(
                  CupertinoIcons.chevron_back,
                  semanticLabel: 'Back',
                  color: GatherColors.text,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: event.tile,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(event.day, style: GatherType.tileDay),
                  Text(
                    event.date,
                    style: GatherType.tileDate.copyWith(fontSize: 56),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(event.title, style: GatherType.title),
            const SizedBox(height: 6),
            Text('${event.place} · ${event.time}', style: GatherType.subtitle),
            const SizedBox(height: 20),
            Text(event.about, style: GatherType.subtitle),
          ],
        ),
      ),
    ),
  );
}
