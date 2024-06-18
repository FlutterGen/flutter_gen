import 'package:collection/collection.dart';
import 'package:flutter_gen_core/settings/flavored_asset.dart';
import 'package:test/test.dart';

void main() {
  group(FlavoredAsset, () {
    test('constructor', () {
      expect(
        FlavoredAsset(path: '').toString(),
        'FlavoredAsset(path: , flavors: {})',
      );
      expect(
        FlavoredAsset(path: 'assets/path'),
        isA<FlavoredAsset>(),
      );
      expect(
        FlavoredAsset(path: 'assets/path', flavors: {}),
        isA<FlavoredAsset>(),
      );
      expect(
        FlavoredAsset(path: 'assets/path', flavors: {'test'}),
        isA<FlavoredAsset>(),
      );
      expect(
        FlavoredAsset(path: '1').copyWith(path: '2'),
        predicate<FlavoredAsset>((e) => e.path == '2'),
      );
      expect(
        FlavoredAsset(path: '1').copyWith(flavors: {'test'}),
        predicate<FlavoredAsset>(
          (e) => SetEquality().equals(e.flavors, {'test'}),
        ),
      );
    });
  });
}
