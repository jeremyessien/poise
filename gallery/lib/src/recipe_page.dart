import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import 'code_block.dart';
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
          Text(widget.recipe.title, style: GalleryType.word),
          const SizedBox(height: 8),
          Text(widget.recipe.summary, style: GalleryType.body),
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
          const _Heading('How it moves'),
          for (final word in widget.recipe.words) ...[
            RecipeCurves(word: word, selected: _personality),
            const SizedBox(height: 16),
          ],
          const _Heading('Use it'),
          CodeBlock(code: widget.recipe.code),
          const SizedBox(height: 10),
          Text(
            'Copy the ${widget.recipe.folder} folder from the registry into '
            'lib/poise/ in your app.',
            style: GalleryType.group,
          ),
        ],
      ),
    ),
  );
}

final class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 32, 0, 12),
    child: Text(text, style: GalleryType.listWord.copyWith(fontSize: 28)),
  );
}
