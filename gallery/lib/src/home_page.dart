import 'package:flutter/material.dart';

import 'curve_glyph.dart';
import 'package:poise_registry/pressable/pressable.dart';
import 'theme.dart';
import 'words.dart';

final class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        children: [
          const Text('poise', style: GalleryType.word),
          const SizedBox(height: 8),
          const Text(
            'Ten words for motion, each one running in calm, crisp and '
            'playful side by side.',
            style: GalleryType.body,
          ),
          for (final group in WordGroup.values) ...[
            const SizedBox(height: 36),
            Text(group.title, style: GalleryType.group),
            const SizedBox(height: 12),
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
      semanticLabel: '${word.name}. ${word.description}',
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
            const Icon(Icons.chevron_right, color: GalleryColors.quietInk),
          ],
        ),
      ),
    ),
  );
}
