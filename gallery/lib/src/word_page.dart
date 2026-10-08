import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise_registry/pressable/pressable.dart';

import 'recipe_curves.dart';
import 'recipes.dart';
import 'theme.dart';
import 'words.dart';

final class WordPage extends StatefulWidget {
  const WordPage({super.key, required this.word});

  final MotionWord word;

  @override
  State<WordPage> createState() => _WordPageState();
}

final class _WordPageState extends State<WordPage> {
  var _highlighted = Personality.calm;

  @override
  Widget build(BuildContext context) {
    final recipes = GalleryRecipe.values
        .where((recipe) => recipe.words.contains(widget.word))
        .toList();

    return Scaffold(
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
            Text(widget.word.name, style: GalleryType.word),
            const SizedBox(height: 8),
            Text(widget.word.description, style: GalleryType.body),
            const SizedBox(height: 28),
            RecipeCurves(word: widget.word, selected: _highlighted),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                for (final personality in Personality.values)
                  ChoiceChip(
                    label: Text(personality.label),
                    selected: personality == _highlighted,
                    onSelected: (_) =>
                        setState(() => _highlighted = personality),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
              child: Text(
                'Recipes that use it',
                style: GalleryType.listWord.copyWith(fontSize: 28),
              ),
            ),
            if (recipes.isEmpty)
              const Text(
                'None yet. Its recipe is on the way.',
                style: GalleryType.body,
              )
            else
              for (final recipe in recipes) _RecipeLink(recipe: recipe),
          ],
        ),
      ),
    );
  }
}

final class _RecipeLink extends StatelessWidget {
  const _RecipeLink({required this.recipe});

  final GalleryRecipe recipe;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Pressable(
      onTap: () => Navigator.of(context).pushNamed(recipe.path),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
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
                  Text(
                    recipe.title,
                    style: GalleryType.label.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(recipe.summary, style: GalleryType.group),
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
