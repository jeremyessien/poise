import 'package:flutter/cupertino.dart';

import 'events.dart';
import 'gather_style.dart';

/// What the sheet shows when an event is opened in Gather.
final class EventDetails extends StatelessWidget {
  const EventDetails({super.key, required this.event});

  /// Heads the details, and gives the tour something to drag the sheet by.
  static const heading = 'About this event';

  final GatherEvent event;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(heading, style: GatherType.detail),
        const SizedBox(height: 4),
        Text(event.title, style: GatherType.title.copyWith(fontSize: 28)),
        const SizedBox(height: 12),
        _Fact(
          icon: CupertinoIcons.calendar,
          text: '${event.day} ${event.date} · ${event.time}',
        ),
        _Fact(icon: CupertinoIcons.location_solid, text: event.place),
        _Fact(
          icon: CupertinoIcons.person_2_fill,
          text: '${event.spotsLeft} spots left',
        ),
      ],
    ),
  );
}

final class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: GatherColors.secondaryText),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GatherType.subtitle)),
      ],
    ),
  );
}
