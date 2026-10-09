import 'package:flutter/cupertino.dart';
import 'package:poise/poise.dart';

import 'package:poise_registry/count_up/count_up.dart';
import 'package:poise_registry/success_check/success_check.dart';
import 'package:poise_registry/text_swap/text_swap.dart';

import 'events.dart';
import 'gather_button.dart';
import 'gather_style.dart';
import 'promo_code.dart';

/// Where someone is in joining an event.
enum JoinState {
  open('Join'),
  joining('Joining…'),
  joined("You're in");

  const JoinState(this.label);

  final String label;
}

/// What the sheet shows when an event is opened in Gather.
final class EventDetails extends StatelessWidget {
  const EventDetails({
    super.key,
    required this.event,
    required this.joinState,
    required this.onJoin,
    required this.onOpenPage,
    this.spotsLeft,
  });

  /// Heads the details, and gives the tour something to drag the sheet by.
  static const heading = 'About this event';

  final GatherEvent event;
  final JoinState joinState;
  final VoidCallback onJoin;
  final VoidCallback onOpenPage;

  static const seeFullEvent = 'See full event';

  /// Spots still open, when it differs from the event's own count because
  /// someone joined.
  final int? spotsLeft;

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
          child: Text('${event.day} ${event.date} · ${event.time}'),
        ),
        _Fact(icon: CupertinoIcons.location_solid, child: Text(event.place)),
        _Fact(
          icon: CupertinoIcons.person_2_fill,
          child: CountUp(
            value: spotsLeft ?? event.spotsLeft,
            format: spotsLeftLabel,
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.only(top: 12),
          onPressed: onOpenPage,
          child: const Text(
            seeFullEvent,
            style: TextStyle(color: GatherColors.accent),
          ),
        ),
        const SizedBox(height: 8),
        const PromoCode(),
        const SizedBox(height: 16),
        GatherButton(
          label: AnimatedSize(
            duration: context.motion.change.duration,
            curve: context.motion.change.curve,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (joinState == JoinState.joined) ...[
                  const SuccessCheck(
                    shown: true,
                    size: 22,
                    color: GatherColors.card,
                    tickColor: GatherColors.accent,
                    semanticLabel: 'Joined',
                  ),
                  const SizedBox(width: 8),
                ],
                TextSwap(joinState.label),
              ],
            ),
          ),
          onTap: onJoin,
        ),
      ],
    ),
  );
}

final class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: GatherColors.secondaryText),
        const SizedBox(width: 10),
        Expanded(
          child: DefaultTextStyle.merge(
            style: GatherType.subtitle,
            child: child,
          ),
        ),
      ],
    ),
  );
}
