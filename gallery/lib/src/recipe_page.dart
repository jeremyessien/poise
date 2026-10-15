import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import 'code_block.dart';
import 'gallery_page.dart';
import 'gather/personality_dial.dart';
import 'recipe_curves.dart';
import 'recipe_stages.dart';
import 'recipes.dart';
import 'theme.dart';

final class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.recipe});

  final GalleryRecipe recipe;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

final class _RecipePageState extends State<RecipePage> {
  var _personality = Personality.calm;

  @override
  Widget build(BuildContext context) => GalleryPage(
    title: widget.recipe.title,
    intro: widget.recipe.summary,
    children: [
      const SizedBox(height: 24),
      PoiseScope(
        motion: _personality.motion,
        child: Column(
          children: [
            RecipeStage(recipe: widget.recipe, replayKey: _personality),
            const SizedBox(height: 16),
            PersonalityDial(
              selected: _personality,
              onChanged: (personality) =>
                  setState(() => _personality = personality),
            ),
          ],
        ),
      ),
      const SectionHeading('How it moves'),
      for (final word in widget.recipe.words) ...[
        RecipeCurves(word: word, selected: _personality),
        const SizedBox(height: 16),
      ],
      const SectionHeading('Use it'),
      CodeBlock(code: widget.recipe.code),
      const SizedBox(height: 10),
      Text(
        'Copy the ${widget.recipe.folder} folder from the registry into '
        'lib/poise/ in your app.',
        style: GalleryType.group,
      ),
    ],
  );
}
