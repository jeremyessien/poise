import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'recipes.dart';
import 'theme.dart';

final class RecipePage extends StatelessWidget {
  const RecipePage({super.key, required this.recipe});

  final GalleryRecipe recipe;

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
          Text(recipe.title, style: GalleryType.word),
          const SizedBox(height: 8),
          Text(recipe.summary, style: GalleryType.body),
        ],
      ),
    ),
  );
}
