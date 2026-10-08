import 'package:flutter/cupertino.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'events.dart';
import 'gather_style.dart';

final class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.saved,
    required this.onOpen,
    required this.onToggleSaved,
  });

  final GatherEvent event;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onOpen,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GatherColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GatherColors.hairline),
      ),
      child: Row(
        children: [
          _DateTile(event: event),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GatherType.eventTitle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 13,
                      color: GatherColors.secondaryText,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${event.place} · ${event.time}',
                        style: GatherType.detail,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${event.spotsLeft} spots left', style: GatherType.detail),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: saved ? 'Remove from plans' : 'Save to plans',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggleSaved,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  size: 24,
                  color: saved
                      ? GatherColors.accent
                      : GatherColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

final class _DateTile extends StatelessWidget {
  const _DateTile({required this.event});

  final GatherEvent event;

  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 60,
    decoration: BoxDecoration(
      color: event.tile,
      borderRadius: BorderRadius.circular(14),
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(event.day, style: GatherType.tileDay),
        Text(event.date, style: GatherType.tileDate),
      ],
    ),
  );
}
