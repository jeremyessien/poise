import 'dart:io';

import 'package:yaml/yaml.dart';

/// The reference file the skill ships for each recipe, keyed by recipe name,
/// built from the recipe's manifest and README so the two can't drift.
Map<String, String> buildSkillReferences(Directory registryLib) {
  final manifests = {
    for (final folder in registryLib.listSync().whereType<Directory>())
      _nameOf(folder): _Manifest.read(folder),
  };
  return {
    for (final MapEntry(key: name, value: manifest) in manifests.entries)
      name: manifest.reference(manifests),
  };
}

String _nameOf(Directory folder) =>
    folder.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);

final class _Manifest {
  _Manifest({
    required this.name,
    required this.title,
    required this.summary,
    required this.words,
    required this.haptics,
    required this.files,
    required this.needs,
    required this.readme,
  });

  factory _Manifest.read(Directory folder) {
    final facts = loadYaml(
      File('${folder.path}/recipe.yaml').readAsStringSync(),
    );
    if (facts is! YamlMap) {
      throw FormatException('${folder.path}/recipe.yaml is not a map');
    }
    return _Manifest(
      name: facts['name'] as String,
      title: facts['title'] as String,
      summary: facts['summary'] as String,
      words: (facts['words'] as YamlList).cast<String>(),
      haptics: (facts['haptics'] as YamlList).cast<String>(),
      files: (facts['files'] as YamlList).cast<String>(),
      needs: (facts['needs'] as YamlList).cast<String>(),
      readme: File('${folder.path}/README.md').readAsStringSync(),
    );
  }

  final String name;
  final String title;
  final String summary;
  final List<String> words;
  final List<String> haptics;
  final List<String> files;
  final List<String> needs;
  final String readme;

  /// This recipe and everything it needs, in the order to copy them.
  List<String> foldersToCopy(Map<String, _Manifest> all) {
    final folders = <String>[];
    void add(String recipe) {
      if (folders.contains(recipe)) return;
      for (final other in all[recipe]!.needs) {
        add(other);
      }
      folders.add(recipe);
    }

    add(name);
    return folders;
  }

  String reference(Map<String, _Manifest> all) {
    final folders = foldersToCopy(all).map((f) => '`$f/`').join(', ');
    final imports = [
      for (final file in files) "import 'package:my_app/poise/$name/$file';",
    ].join('\n');
    final body = readme.split('\n').skipWhile((line) => line.startsWith('# '));
    return '''
# $title

$summary

- **Words:** ${words.join(', ')}
- **Haptics:** ${haptics.isEmpty ? 'none' : haptics.join(', ')}
- **Copy into `lib/poise/`:** $folders
- **Import:**

```dart
$imports
```

${body.join('\n').trim()}
''';
  }
}
