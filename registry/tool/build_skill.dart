import 'dart:io';

import 'skill_references.dart';

/// Writes the skill's recipe references from the registry. Run from the
/// registry package: `dart run tool/build_skill.dart`.
void main() {
  final references = buildSkillReferences(Directory('lib'));
  final out = Directory('../skill/poise/references')
    ..createSync(recursive: true);
  for (final stale in out.listSync().whereType<File>()) {
    if (!references.containsKey(_stem(stale))) stale.deleteSync();
  }
  for (final MapEntry(key: name, value: text) in references.entries) {
    File('${out.path}/$name.md').writeAsStringSync(text);
  }
  stdout.writeln('Wrote ${references.length} references to ${out.path}');
}

String _stem(File file) => file.uri.pathSegments.last.replaceAll('.md', '');
