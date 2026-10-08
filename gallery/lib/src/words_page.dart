import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'curve_glyph.dart';
import 'theme.dart';
import 'words.dart';

final class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                CupertinoIcons.chevron_back,
                color: GalleryColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('The ten words', style: GalleryType.word),
          const SizedBox(height: 8),
          const Text(
            'Every piece of motion in poise is one of these. Apps, recipes '
            'and agents all use the same words.',
            style: GalleryType.body,
          ),
          for (final group in WordGroup.values) ...[
            const SizedBox(height: 32),
            Text(group.title, style: GalleryType.group),
            const SizedBox(height: 10),
            for (final word in MotionWord.values.where((w) => w.group == group))
              _WordRow(word: word),
          ],
        ],
      ),
    ),
  );
}

final class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});

  final MotionWord word;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Pressable(
      onTap: () => Navigator.of(context).pushNamed(word.path),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        decoration: BoxDecoration(
          color: GalleryColors.lane,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GalleryColors.grid),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.name, style: GalleryType.listWord),
                  const SizedBox(height: 2),
                  Text(word.description, style: GalleryType.body),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CurveGlyph(word: word),
            const SizedBox(width: 4),
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
