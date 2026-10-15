import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gallery_page.dart';
import 'recipes.dart';
import 'settings.dart';
import 'theme.dart';
import 'tour_overlay.dart';
import 'words.dart';

final class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GallerySettingsScope.of(context);
    return GalleryPage(
      title: 'poise',
      backTooltip: 'Back to Gather',
      intro:
          'Motion for Flutter apps, built so your AI agent already knows it. '
          'Everything in Gather is made from these recipes.',
      children: [
        const _SectionTitle('Recipes'),
        _Panel(
          children: [
            for (final recipe in GalleryRecipe.values)
              LinkRow(
                title: recipe.title,
                detail: recipe.words.map((word) => word.name).join(', '),
                onTap: () => Navigator.of(context).pushNamed(recipe.path),
              ),
          ],
        ),
        const _SectionTitle('The ten words'),
        _Panel(
          children: [
            LinkRow(
              title: 'Every word poise uses',
              detail: MotionWord.values.map((word) => word.name).join(', '),
              onTap: () => Navigator.of(context).pushNamed('/words'),
            ),
          ],
        ),
        const _SectionTitle('While you watch'),
        _Panel(
          children: [
            _Toggle(
              title: 'Slow motion',
              detail: 'Everything runs five times slower',
              value: settings.slowMotion,
              onChanged: (value) => settings.slowMotion = value,
            ),
            _Toggle(
              title: 'Reduce motion',
              detail: 'What people who turn animations off see',
              value: settings.reduceMotion,
              onChanged: (value) => settings.reduceMotion = value,
            ),
            _Toggle(
              title: 'Show touches',
              detail: 'A circle wherever a finger lands',
              value: settings.showTouches,
              onChanged: (value) => settings.showTouches = value,
            ),
            LinkRow(
              title: 'Play the tour',
              detail: 'Gather runs itself, ready to record',
              onTap: GalleryTourScope.of(context).play,
            ),
          ],
        ),
      ],
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 32, 4, 10),
    child: Text(text, style: GalleryType.group),
  );
}

final class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: cardDecoration(),
    child: Column(
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0)
            const Divider(height: 1, thickness: 1, color: GalleryColors.grid),
          child,
        ],
      ],
    ),
  );
}

final class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GalleryType.label.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(detail, style: GalleryType.group),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeTrackColor: GalleryColors.ink,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    ),
  );
}
