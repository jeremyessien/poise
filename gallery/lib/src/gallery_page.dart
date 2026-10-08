import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'theme.dart';

/// A page on chart paper: a back button, a big title, a line of intro, then
/// whatever the page is about.
final class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.intro,
    required this.children,
    this.backTooltip = 'Back',
  });

  final String title;
  final String intro;
  final String backTooltip;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: backTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                CupertinoIcons.chevron_back,
                color: GalleryColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: GalleryType.word),
          const SizedBox(height: 8),
          Text(intro, style: GalleryType.body),
          ...children,
        ],
      ),
    ),
  );
}

final class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
    child: Text(text, style: GalleryType.listWord.copyWith(fontSize: 28)),
  );
}

/// A pressable row that leads somewhere: a title, a line of detail and a
/// chevron. Set [card] to give it its own panel.
final class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.title,
    required this.detail,
    required this.onTap,
    this.card = false,
  });

  final String title;
  final String detail;
  final VoidCallback onTap;
  final bool card;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: card
          ? cardDecoration()
          : const BoxDecoration(color: GalleryColors.lane),
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
                  maxLines: card ? null : 1,
                  overflow: card ? null : TextOverflow.ellipsis,
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
  );
}
