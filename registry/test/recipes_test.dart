import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const motionWords = {
  'feedback',
  'enter',
  'exit',
  'transition',
  'change',
  'attention',
  'celebrate',
  'follow',
  'loop',
  'stagger',
};

void main() {
  final recipeFolders =
      Directory('lib').listSync().whereType<Directory>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final recipeNames = {
    for (final folder in recipeFolders)
      folder.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
  };

  test('the registry has recipes', () {
    expect(recipeFolders, isNotEmpty);
  });

  for (final folder in recipeFolders) {
    final name = folder.uri.pathSegments.lastWhere((s) => s.isNotEmpty);

    group(name, () {
      late YamlMap recipe;

      setUpAll(() {
        final manifest = File('${folder.path}/recipe.yaml');
        expect(manifest.existsSync(), isTrue, reason: 'recipe.yaml is missing');
        final parsed = loadYaml(manifest.readAsStringSync());
        if (parsed is! YamlMap) fail('recipe.yaml is not a map of fields');
        recipe = parsed;
      });

      test('is named after its folder', () {
        expect(recipe['name'], name);
      });

      test('has a title and a one-line summary', () {
        expect(recipe['title'], isA<String>());
        expect(recipe['summary'], isA<String>());
        expect(recipe['summary'], isNot(contains('\n')));
      });

      test('uses only the ten motion words', () {
        final words = recipe['words'];
        if (words is! YamlList) fail('words should be a list');
        expect(words, isNotEmpty);
        expect(motionWords.containsAll(words), isTrue, reason: '$words');
      });

      test('lists files that exist', () {
        final files = recipe['files'];
        if (files is! YamlList) fail('files should be a list');
        expect(files, isNotEmpty);
        for (final file in files) {
          expect(
            File('${folder.path}/$file').existsSync(),
            isTrue,
            reason: '$file',
          );
        }
      });

      test('needs only recipes that exist', () {
        final needs = recipe['needs'];
        if (needs is! YamlList) fail('needs should be a list');
        for (final other in needs) {
          expect(recipeNames, contains(other));
        }
      });

      test('says which version it arrived in', () {
        expect(recipe['since'], matches(RegExp(r'^\d+\.\d+\.\d+$')));
      });

      test('explains itself in a README', () {
        expect(File('${folder.path}/README.md').existsSync(), isTrue);
      });
    });
  }
}
