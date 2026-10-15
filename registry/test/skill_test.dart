import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

import '../tool/skill_references.dart';

void main() {
  final skill = Directory('../skill/poise');
  final skillFile = File('${skill.path}/SKILL.md');
  final references = buildSkillReferences(Directory('lib'));

  test('SKILL.md has the frontmatter agents look for', () {
    final text = skillFile.readAsStringSync();
    final frontmatter = RegExp(
      r'^---\nname: (.+)\ndescription: (.+)\n---\n',
    ).firstMatch(text);
    expect(frontmatter, isNotNull, reason: 'frontmatter is missing');
    final name = frontmatter!.group(1)!;
    final description = frontmatter.group(2)!;
    expect(name, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
    expect(name, skill.uri.pathSegments.lastWhere((s) => s.isNotEmpty));
    expect(description.length, inInclusiveRange(1, 1024));
  });

  test('SKILL.md stays short enough to load whole', () {
    expect(skillFile.readAsLinesSync().length, lessThan(300));
  });

  test('SKILL.md names every word and every recipe', () {
    final text = skillFile.readAsStringSync();
    for (final word in MotionWord.values) {
      expect(text, contains('`${word.name}`'), reason: word.name);
    }
    for (final recipe in references.keys) {
      expect(text, contains('references/$recipe.md'), reason: recipe);
    }
  });

  test('every file SKILL.md points at exists', () {
    final links = RegExp(
      r'\]\(([^)#]+)\)',
    ).allMatches(skillFile.readAsStringSync());
    expect(links, isNotEmpty);
    for (final link in links) {
      final path = link.group(1)!;
      if (path.startsWith('http')) continue;
      expect(File('${skill.path}/$path').existsSync(), isTrue, reason: path);
    }
  });

  test('the references match the registry, so run build_skill if not', () {
    final out = Directory('${skill.path}/references');
    final onDisk = {
      for (final file in out.listSync().whereType<File>())
        file.uri.pathSegments.last.replaceAll('.md', ''): file
            .readAsStringSync(),
    };
    expect(onDisk.keys, unorderedEquals(references.keys));
    for (final MapEntry(key: name, value: text) in references.entries) {
      expect(onDisk[name], text, reason: '$name.md is out of date');
    }
  });
}
