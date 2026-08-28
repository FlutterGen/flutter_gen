import 'package:flutter/widgets.dart';
import 'package:flutter_gen_interface/flutter_gen_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetGenImage', () {
    test('properties and keyName', () {
      const image = AssetGenImage('assets/image.png');
      expect(image.path, 'assets/image.png');
      expect(image.keyName, 'assets/image.png');

      const packageImage = AssetGenImage('assets/image.png', package: 'pkg');
      expect(packageImage.path, 'assets/image.png');
      expect(packageImage.keyName, r'packages/pkg/assets/image.png');
    });

    testWidgets('provider returns AssetImage', (tester) async {
      const image = AssetGenImage('assets/image.png');
      final provider = image.provider() as AssetImage;
      expect(provider.assetName, 'assets/image.png');
      expect(provider.package, isNull);

      const packageImage = AssetGenImage('assets/image.png', package: 'pkg');
      final packageProvider = packageImage.provider() as AssetImage;
      expect(packageProvider.assetName, 'assets/image.png');
      expect(packageProvider.package, 'pkg');
    });

    testWidgets('image returns Image widget', (tester) async {
      const image = AssetGenImage('assets/image.png');
      final widget = image.image();
      expect(widget.image, isA<AssetImage>());
      final assetImage = widget.image as AssetImage;
      expect(assetImage.assetName, 'assets/image.png');
    });
  });

  group('SvgGenImage', () {
    test('properties and keyName for standard svg', () {
      const svg = SvgGenImage(
        'assets/icon.svg',
        size: Size(24, 24),
        flavors: {'free'},
      );
      expect(svg.path, 'assets/icon.svg');
      expect(svg.keyName, 'assets/icon.svg');
      expect(svg.size, const Size(24, 24));
      expect(svg.flavors, {'free'});
      expect(svg.isVecFormat, isFalse);
      expect(svg.package, isNull);

      const packageSvg = SvgGenImage('assets/icon.svg', package: 'pkg');
      expect(packageSvg.path, 'assets/icon.svg');
      expect(packageSvg.keyName, r'packages/pkg/assets/icon.svg');
      expect(packageSvg.package, 'pkg');
    });

    test('properties and keyName for vec format', () {
      const vec = SvgGenImage.vec(
        'assets/icon.vec',
        size: Size(32, 32),
        flavors: {'premium'},
        package: 'pkg',
      );
      expect(vec.path, 'assets/icon.vec');
      expect(vec.keyName, r'packages/pkg/assets/icon.vec');
      expect(vec.size, const Size(32, 32));
      expect(vec.flavors, {'premium'});
      expect(vec.isVecFormat, isTrue);
      expect(vec.package, 'pkg');
    });
  });
}
