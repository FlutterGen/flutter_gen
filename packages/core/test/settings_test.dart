import 'package:collection/collection.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:flutter_gen_core/settings/flavored_asset.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:test/test.dart';

void main() {
  group(AssetType, () {
    test('constructor', () {
      final assetType = AssetType(
        rootPath: 'root',
        path: 'assets/single.jpg',
        flavors: {'flavor'},
      );
      expect(assetType, isA<AssetType>());
      expect(assetType.name, 'assets/single');
      expect(assetType.baseName, 'single');
      expect(assetType.extension, '.jpg');
      expect(assetType.isUnKnownMime, false);
      expect(
        assetType,
        predicate<AssetType>(
          (e) => const SetEquality().equals(e.flavors, {'flavor'}),
        ),
      );
      expect(
        assetType.toString(),
        'AssetType(rootPath: root, path: assets/single.jpg, flavors: {flavor})',
      );
    });
  });

  group(FlavoredAsset, () {
    test('constructor', () {
      expect(
        const FlavoredAsset(path: '').toString(),
        'FlavoredAsset(path: , flavors: {})',
      );
      expect(
        const FlavoredAsset(path: 'assets/path'),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: 'assets/path', flavors: {}),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: 'assets/path', flavors: {'test'}),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: '1').copyWith(path: '2'),
        predicate<FlavoredAsset>((e) => e.path == '2'),
      );
      expect(
        const FlavoredAsset(path: '1').copyWith(flavors: {'test'}),
        predicate<FlavoredAsset>(
          (e) => const SetEquality().equals(e.flavors, {'test'}),
        ),
      );
    });
  });

  group(FlutterGenElementAssetsOutputsStyle, () {
    test('fromJson', () {
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('dot-delimiter'),
        equals(FlutterGenElementAssetsOutputsStyle.dotDelimiterStyle),
      );
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('snake-case'),
        equals(FlutterGenElementAssetsOutputsStyle.snakeCaseStyle),
      );
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('camel-case'),
        equals(FlutterGenElementAssetsOutputsStyle.camelCaseStyle),
      );
      expect(
        () => FlutterGenElementAssetsOutputsStyle.fromJson('wrong'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toJson', () {
      for (final style in FlutterGenElementAssetsOutputsStyle.values) {
        expect(style.toJson(), equals(style.name));
      }
    });
  });
}
