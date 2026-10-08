import 'package:flutter/material.dart';
import 'package:poise/poise.dart';

import 'gallery_page.dart';
import 'gather/personality_dial.dart';
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
    final recipes = GalleryRecipe.values.where(
      (recipe) => recipe.words.contains(widget.word),
    );

    return GalleryPage(
      title: widget.word.name,
      intro: widget.word.description,
      children: [
        const SizedBox(height: 28),
        RecipeCurves(word: widget.word, selected: _highlighted, titled: false),
        const SizedBox(height: 16),
        PoiseScope(
          motion: _highlighted.motion,
          child: Center(
            child: PersonalityDial(
              selected: _highlighted,
              onChanged: (personality) =>
                  setState(() => _highlighted = personality),
            ),
          ),
        ),
        const SectionHeading('Recipes that use it'),
        if (recipes.isEmpty)
          const Text(
            'None yet. Its recipe is on the way.',
            style: GalleryType.body,
          )
        else
          for (final recipe in recipes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LinkRow(
                title: recipe.title,
                detail: recipe.summary,
                card: true,
                onTap: () => Navigator.of(context).pushNamed(recipe.path),
              ),
            ),
      ],
    );
  }
}
