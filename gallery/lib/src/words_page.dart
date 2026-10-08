import 'package:flutter/cupertino.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'curve_glyph.dart';
import 'gallery_page.dart';
import 'theme.dart';
import 'words.dart';

final class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) => GalleryPage(
    title: 'The ten words',
    intro:
        'Every piece of motion in poise is one of these. Apps, recipes and '
        'agents all use the same words.',
    children: [
      for (final group in WordGroup.values) ...[
        const SizedBox(height: 32),
        Text(group.title, style: GalleryType.group),
        const SizedBox(height: 10),
        for (final word in MotionWord.values.where((w) => w.group == group))
          _WordRow(word: word),
      ],
    ],
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
        decoration: cardDecoration(),
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
