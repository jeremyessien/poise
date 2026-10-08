import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'recipes.dart';
import 'settings.dart';
import 'theme.dart';
import 'words.dart';

final class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GallerySettingsScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back to Gather',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  CupertinoIcons.chevron_back,
                  color: GalleryColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text('poise', style: GalleryType.word),
            const SizedBox(height: 8),
            const Text(
              'Motion for Flutter apps, built so your AI agent already knows '
              'it. Everything in Gather is made from these recipes.',
              style: GalleryType.body,
            ),
            const _SectionTitle('Recipes'),
            _Panel(
              children: [
                for (final recipe in GalleryRecipe.values)
                  _Row(
                    title: recipe.title,
                    detail: recipe.words.map((word) => word.name).join(', '),
                    onTap: () => Navigator.of(context).pushNamed(recipe.path),
                  ),
              ],
            ),
            const _SectionTitle('The ten words'),
            _Panel(
              children: [
                _Row(
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
              ],
            ),
          ],
        ),
      ),
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
    decoration: BoxDecoration(
      color: GalleryColors.lane,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: GalleryColors.grid),
    ),
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

final class _Row extends StatelessWidget {
  const _Row({required this.title, required this.detail, required this.onTap});

  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: ColoredBox(
      color: GalleryColors.lane,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GalleryType.label.copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: GalleryType.group,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 18,
              color: GalleryColors.quietInk,
            ),
          ],
        ),
      ),
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
  );
}
