import 'package:flutter/widgets.dart';
import 'package:flutter_gen_interface/flutter_gen_interface.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';

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
    test('properties and keyName', () {
      const svg = SvgGenImage('assets/icon.svg');
      expect(svg.path, 'assets/icon.svg');
      expect(svg.keyName, 'assets/icon.svg');

      const packageSvg = SvgGenImage('assets/icon.svg', package: 'pkg');
      expect(packageSvg.path, 'assets/icon.svg');
      expect(packageSvg.keyName, r'packages/pkg/assets/icon.svg');
    });

    testWidgets('svg returns SvgPicture widget', (tester) async {
      const svg = SvgGenImage('assets/icon.svg');
      final widget = svg.svg();
      expect(widget.bytesLoader, isA<SvgAssetLoader>());
      final loader = widget.bytesLoader as SvgAssetLoader;
      expect(loader.assetName, 'assets/icon.svg');
      expect(loader.packageName, isNull);
    });

    testWidgets('vec returns SvgPicture widget with AssetBytesLoader', (tester) async {
      const vec = SvgGenImage.vec('assets/icon.vec');
      final widget = vec.svg();
      expect(widget.bytesLoader, isA<AssetBytesLoader>());
      final loader = widget.bytesLoader as AssetBytesLoader;
      expect(loader.assetName, 'assets/icon.vec');
      expect(loader.packageName, isNull);
    });
  });
}
