import 'package:flutter/cupertino.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/count_up/count_up.dart';
import 'package:poise_registry/heart_burst/heart_burst.dart';
import 'package:poise_registry/poise_route/poise_route.dart';
import 'package:poise_registry/poise_sheet/poise_sheet.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/shimmer/shimmer.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';
import 'package:poise_registry/success_check/success_check.dart';
import 'package:poise_registry/text_swap/text_swap.dart';

import 'gather/event_card.dart';
import 'gather/event_details.dart';
import 'gather/event_page.dart';
import 'gather/event_skeleton.dart';
import 'gather/events.dart';
import 'gather/gather_button.dart';
import 'gather/gather_style.dart';
import 'gather/gather_toast.dart';
import 'gather/promo_code.dart';
import 'recipes.dart';

final class RecipeStage extends StatelessWidget {
  const RecipeStage({super.key, required this.recipe, required this.replayKey});

  final GalleryRecipe recipe;
  final Object replayKey;

  @override
  Widget build(BuildContext context) => GatherTheme(
    child: Container(
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GatherColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GatherColors.hairline),
      ),
      child: switch (recipe) {
        GalleryRecipe.pressable => const _PressableStage(),
        GalleryRecipe.reveal => const _RevealStage(),
        GalleryRecipe.poiseSheet => const _SheetStage(),
        GalleryRecipe.textSwap => const _TextSwapStage(),
        GalleryRecipe.countUp => const _CountUpStage(),
        GalleryRecipe.successCheck => const _SuccessCheckStage(),
        GalleryRecipe.shake => const _ShakeStage(),
        GalleryRecipe.heartBurst => const _HeartBurstStage(),
        GalleryRecipe.poiseRoute => const _RouteStage(),
        GalleryRecipe.shimmer => const _ShimmerStage(),
        GalleryRecipe.staggeredColumn => _StaggerStage(replayKey: replayKey),
      },
    ),
  );
}

final class _PressableStage extends StatelessWidget {
  const _PressableStage();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 24),
      EventCard(
        event: sampleEvents.first,
        saved: false,
        onOpen: () {},
        onToggleSaved: () {},
      ),
      const SizedBox(height: 24),
      GatherButton(label: const Text('Join event'), onTap: () {}),
      const SizedBox(height: 16),
      const Text('Press and hold either one', style: GatherType.detail),
    ],
  );
}

final class _RevealStage extends StatefulWidget {
  const _RevealStage();

  @override
  State<_RevealStage> createState() => _RevealStageState();
}

final class _RevealStageState extends State<_RevealStage> {
  var _shown = true;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 200,
        child: Center(
          child: Reveal(
            visible: _shown,
            child: const GatherToast(text: 'Saved to your plans'),
          ),
        ),
      ),
      GatherButton(
        label: Text(_shown ? 'Hide' : 'Show'),
        onTap: () => setState(() => _shown = !_shown),
      ),
      const SizedBox(height: 12),
      const Text(
        'Tap twice quickly to see it turn around',
        style: GatherType.detail,
      ),
    ],
  );
}

final class _TextSwapStage extends StatefulWidget {
  const _TextSwapStage();

  @override
  State<_TextSwapStage> createState() => _TextSwapStageState();
}

final class _TextSwapStageState extends State<_TextSwapStage> {
  var _state = JoinState.open;

  JoinState get _next => JoinState.values[(_state.index + 1) % 3];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 96),
      GatherButton(
        label: TextSwap(_state.label),
        onTap: () => setState(() => _state = _next),
      ),
      const SizedBox(height: 16),
      const Text(
        'Tap it to move it along: Join, Joining…, You\'re in',
        style: GatherType.detail,
      ),
      const SizedBox(height: 96),
    ],
  );
}

final class _CountUpStage extends StatefulWidget {
  const _CountUpStage();

  @override
  State<_CountUpStage> createState() => _CountUpStageState();
}

final class _CountUpStageState extends State<_CountUpStage> {
  static const _full = 40;
  static const _group = 7;

  var _spots = _full;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 56),
      CountUp(value: _spots, style: GatherType.title.copyWith(fontSize: 64)),
      const Text('spots left', style: GatherType.subtitle),
      const SizedBox(height: 40),
      GatherButton(
        label: Text(_spots < _group ? 'Open more spots' : 'A group joins'),
        onTap: () =>
            setState(() => _spots = _spots < _group ? _full : _spots - _group),
      ),
      const SizedBox(height: 16),
    ],
  );
}

final class _SuccessCheckStage extends StatefulWidget {
  const _SuccessCheckStage();

  @override
  State<_SuccessCheckStage> createState() => _SuccessCheckStageState();
}

final class _SuccessCheckStageState extends State<_SuccessCheckStage> {
  var _paid = false;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 40),
      SuccessCheck(shown: _paid, size: 96, semanticLabel: 'Payment sent'),
      const SizedBox(height: 16),
      TextSwap(
        _paid ? 'Payment sent' : 'Ready to pay',
        style: GatherType.eventTitle,
      ),
      const SizedBox(height: 32),
      GatherButton(
        label: Text(_paid ? 'Start again' : r'Pay $40'),
        onTap: () => setState(() => _paid = !_paid),
      ),
      const SizedBox(height: 16),
    ],
  );
}

final class _ShimmerStage extends StatelessWidget {
  const _ShimmerStage();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Shimmer(
        child: Column(
          children: [
            for (var row = 0; row < 3; row++)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: EventSkeleton(),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Turn the dial: calm and crisp breathe, playful sweeps',
        style: GatherType.detail,
      ),
    ],
  );
}

final class _RouteStage extends StatelessWidget {
  const _RouteStage();

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        EventCard(
          event: sampleEvents[2],
          saved: false,
          onOpen: () => _open(context, motion),
          onToggleSaved: () {},
        ),
        const SizedBox(height: 24),
        GatherButton(
          label: const Text('Open the event page'),
          onTap: () => _open(context, motion),
        ),
        const SizedBox(height: 16),
        const Text(
          'On an iPhone, swipe back from the left edge',
          style: GatherType.detail,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _open(BuildContext context, PoiseMotion motion) =>
      Navigator.of(context).push(
        PoiseRoute<void>(
          motion: motion,
          builder: (_) => EventPage(event: sampleEvents[2]),
        ),
      );
}

final class _HeartBurstStage extends StatefulWidget {
  const _HeartBurstStage();

  @override
  State<_HeartBurstStage> createState() => _HeartBurstStageState();
}

final class _HeartBurstStageState extends State<_HeartBurstStage> {
  var _liked = false;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 80),
      Semantics(
        button: true,
        label: _liked ? 'Unlike' : 'Like',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _liked = !_liked),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: HeartBurst(
              liked: _liked,
              child: Icon(
                _liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 72,
                color: _liked
                    ? GatherColors.accent
                    : GatherColors.secondaryText,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Tap the heart. Tap again to take it back.',
        style: GatherType.detail,
      ),
      const SizedBox(height: 64),
    ],
  );
}

final class _ShakeStage extends StatelessWidget {
  const _ShakeStage();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(height: 96),
      PromoCode(),
      SizedBox(height: 16),
      Text(
        'Try any code. Only ${PromoCode.working} works.',
        style: GatherType.detail,
      ),
      SizedBox(height: 96),
    ],
  );
}

final class _SheetStage extends StatefulWidget {
  const _SheetStage();

  @override
  State<_SheetStage> createState() => _SheetStageState();
}

final class _SheetStageState extends State<_SheetStage> {
  var _open = false;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                EventCard(
                  event: sampleEvents[1],
                  saved: false,
                  onOpen: () => setState(() => _open = true),
                  onToggleSaved: () {},
                ),
                const SizedBox(height: 20),
                GatherButton(
                  label: const Text('Open details'),
                  onTap: () => setState(() => _open = true),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Drag it, nudge it, or throw it away',
                  style: GatherType.detail,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: PoiseSheet(
              open: _open,
              onClose: () => setState(() => _open = false),
              child: EventDetails(
                event: sampleEvents[1],
                joinState: JoinState.open,
                onJoin: () {},
                onOpenPage: () {},
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

final class _StaggerStage extends StatefulWidget {
  const _StaggerStage({required this.replayKey});

  final Object replayKey;

  @override
  State<_StaggerStage> createState() => _StaggerStageState();
}

final class _StaggerStageState extends State<_StaggerStage> {
  var _replays = 0;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      StaggeredColumn(
        replayKey: (widget.replayKey, _replays),
        children: [
          for (final event in sampleEvents)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EventRow(event: event),
            ),
        ],
      ),
      const SizedBox(height: 16),
      GatherButton(
        label: const Text('Replay'),
        onTap: () => setState(() => _replays++),
      ),
    ],
  );
}

final class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final GatherEvent event;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: GatherColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: GatherColors.hairline),
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: event.tile, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(event.title, style: GatherType.eventTitle)),
        Text('${event.day} ${event.date}', style: GatherType.detail),
      ],
    ),
  );
}
