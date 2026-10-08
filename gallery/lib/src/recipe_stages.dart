import 'package:flutter/cupertino.dart';
import 'package:poise_registry/pressable/pressable.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';

import 'gather/event_card.dart';
import 'gather/events.dart';
import 'gather/gather_style.dart';
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
      StageButton(label: 'Join event', onTap: () {}),
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
          child: Reveal(visible: _shown, child: const SavedToast()),
        ),
      ),
      StageButton(
        label: _shown ? 'Hide' : 'Show',
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
      StageButton(label: 'Replay', onTap: () => setState(() => _replays++)),
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

final class SavedToast extends StatelessWidget {
  const SavedToast({super.key});

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
          'Saved to your plans',
          style: GatherType.detail.copyWith(color: GatherColors.dialText),
        ),
      ],
    ),
  );
}

final class StageButton extends StatelessWidget {
  const StageButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GatherColors.accent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: GatherType.eventTitle.copyWith(color: GatherColors.card),
      ),
    ),
  );
}
