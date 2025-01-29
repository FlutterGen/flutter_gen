import 'package:example/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class SvgIntegrationsTest extends StatelessWidget {
  const SvgIntegrationsTest({required this.theme});

  final SvgTheme theme;

  @override
  Widget build(BuildContext context) {
    return DefaultSvgTheme(
      theme: theme,
      child: MyAssets.images.icons.dartTest.svg(),
    );
  }
}

void main() {
  group('Test SvgTheme behavior', () {
    const testTheme = SvgTheme(currentColor: Colors.red);

    testWidgets(
      'Passed theme should be null',
      (widgetTester) async {
        await widgetTester.pumpWidget(
          const SvgIntegrationsTest(theme: testTheme),
        );

        var finder = find.byType(SvgPicture);
        expect(finder, findsOneWidget);

        var svgWidget = widgetTester.widget<SvgPicture>(finder);
        var loader = svgWidget.bytesLoader as SvgAssetLoader;

        expect(loader.theme, isNull);
      },
    );

    testWidgets(
      'Taken theme of SvgAssetLoader equals with one passed to parent DefaultSvgTheme',
      (widgetTester) async {
        await widgetTester.pumpWidget(
          const SvgIntegrationsTest(theme: testTheme),
        );

        var finder = find.byType(SvgPicture);
        expect(finder, findsOneWidget);

        var svgWidget = widgetTester.widget<SvgPicture>(finder);
        var loader = svgWidget.bytesLoader as SvgAssetLoader;

        var svgCacheKey = loader.cacheKey(widgetTester.element(finder));

        expect(svgCacheKey.theme, testTheme);
      },
    );
  });
}
