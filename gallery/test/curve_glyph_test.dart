import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/curve_glyph.dart';
import 'package:gallery/src/words.dart';

void main() {
  for (final word in MotionWord.values) {
    testWidgets('draws a glyph for ${word.name}', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: CurveGlyph(word: word)),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(CurveGlyph)), CurveGlyph.size);
    });
  }

  test('every word has its own address', () {
    for (final word in MotionWord.values) {
      expect(GalleryWord.fromPath(word.path), word);
    }
    expect(GalleryWord.fromPath('/nowhere'), isNull);
  });
}
