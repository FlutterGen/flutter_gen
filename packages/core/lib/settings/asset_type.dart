import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/utils/identifer.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:mime/mime.dart' show lookupMimeType;
import 'package:path/path.dart' as p;

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class AssetType {
  AssetType({
    required this.rootPath,
    required this.path,
    required this.flavors,
  });

  final String rootPath;
  final String path;
  final Set<String> flavors;

  final List<AssetType> _children = List.empty(growable: true);
  late final children = _children.sortedBy((e) => e.path);

  late final isDefaultAssetsDirectory = path == 'assets' || path == 'asset';
  late final mime = lookupMimeType(path);
  late final isUnKnownMime = mime == null;

  /// Returns a name for this asset.
  late final name = p.withoutExtension(path);
  late final baseName = p.basenameWithoutExtension(path);
  late final extension = p.extension(path);

  /// Returns the full absolute path for reading the asset file.
  late final fullPath = p.join(rootPath, path);

  // Replace to Posix style for Windows separator.
  late final posixStylePath = path.replaceAll(r'\', r'/');

  late final bool isIgnoreFile = () {
    switch (baseName) {
      case '.DS_Store':
        return true;
    }
    switch (extension) {
      case '.DS_Store':
      case '.swp':
        return true;
    }
    return false;
  }();

  void addChild(AssetType type) {
    _children.add(type);
  }

  @override
  String toString() => 'AssetType('
      'rootPath: $rootPath, '
      'path: $path, '
      'flavors: $flavors'
      ')';
}

/// Represents a AssetType with modifiers on it to mutate the [name] to ensure
/// it is unique in a larger list and a valid dart identifer.
///
/// See [AssetTypeIterable.mapToUniqueAssetType] for the algorithm.
class UniqueAssetType extends AssetType {
  UniqueAssetType({
    required AssetType assetType,
    this.style = camelCase,
    this.basenameOnly = false,
    this.needExtension = false,
    this.suffix = '',
  }) : super(
          rootPath: assetType.rootPath,
          path: assetType.path,
          flavors: assetType.flavors,
        );

  /// Convert the asset name to a correctly styled name, e.g camelCase or
  /// snakeCase.
  final String Function(String) style;

  /// Include just the basename of the asset in the [name],
  /// e.g. 'images/image.png' -> 'image'.
  final bool basenameOnly;

  /// Include the extension in the [name], e.g. 'image.png' -> 'imagePng'.
  bool needExtension;

  /// Optional suffix to append to the [name] to make it unique. Typically just
  /// one or more '_' characters.
  String suffix;

  /// Returns a identifier name, which is ideally unique and valid.
  @override
  String get name {
    // Omit root directory from the name if it is either asset or assets.
    // TODO(bramp): Maybe move this into the _flatStyleDefinition
    String result = path.replaceFirst(RegExp(r'^asset(s)?[/\\]'), '');
    if (basenameOnly) {
      result = p.basename(result);
    }
    if (!needExtension) {
      result = p.withoutExtension(result);
    }
    return style(convertToIdentifier(result)) + suffix;
  }

  @override
  String toString() {
    return 'UniqueAssetType{'
        'rootPath: $rootPath, '
        'path: $path, '
        'style: $style, '
        'needExtension: $needExtension, '
        'suffix: $suffix}';
  }
}

extension AssetTypeIterable on Iterable<AssetType> {
  /// Takes a `Iterable<AssetType>` and mutates the AssetType's to ensure each
  /// AssetType has a unique name.
  ///
  /// The strategy is as follows:
  ///
  /// 1) Convert the asset file name, to a valid dart identifier, that is
  ///  - Replace non ASCII chars with ASCII.
  ///  - Ensure the name starts with a letter (not number or _).
  ///  - Style the name per the camelCase or snakeCase rules.
  /// 2) Use the asset name without extension. If unique and not a dart reserved
  ///    word use that.
  /// 3) Use the asset name with extension. If unique and not a dart reserved
  ///    word use that.
  /// 4) If there are any collisions, append a underscore suffix to each item
  ///    until they are unique.
  ///
  /// Because the name change can cause it to clash with an existing name, the
  /// code is run iteratively until no collision are found. This can be a little
  /// more expensive, but it simplier.
  ///
  Iterable<UniqueAssetType> mapToUniqueAssetType(
    String Function(String) style, {
    bool justBasename = false,
  }) {
    List<UniqueAssetType> assets = map(
      (e) => UniqueAssetType(
        assetType: e,
        style: style,
        needExtension: false,
        suffix: '',
        basenameOnly: justBasename,
      ),
    ).toList();

    while (true) {
      // Check if we have any name collisions.
      final duplicates = assets.groupBy((e) => e.name).values;

      // No more duplicates, so we can bail.
      if (duplicates.every((list) => list.length == 1)) {
        break;
      }

      // Otherwise start to process the list and mutate the assets as needed.
      assets = duplicates
          .map((list) {
            assert(
              list.isNotEmpty,
              'The groupBy list of assets should not be empty.',
            );

            // Check the first element in the list. Since we grouped by each
            // list element should have the same name.
            final name = list[0].name;
            final isValidIdentifer = isValidVariableIdentifier(name);

            // TODO(bramp): In future we should also check this name doesn't collide
            // with the integration's class name (e.g AssetGenImage).

            // No colissions for this name, carry on.
            if (list.length == 1 && isValidIdentifer) {
              return list;
            }

            // We haven't added filename extensions yet, let's try that first
            if (!list.every((e) => e.needExtension)) {
              for (final e in list) {
                e.needExtension = true;
              }

              return list;
            }

            // Ok, we must resolve the conflicts by adding suffixes.
            String suffix = '';
            list.forEachIndexed((asset, index) {
              // Shouldn't need to mutate the first item (unless it's an invalid
              // identifer).
              if (index == 0 && isValidIdentifer) {
                return;
              }

              // Append a extra suffixes to each item so they hopefully become unique
              suffix = '${suffix}_';
              asset.suffix += suffix;
            });

            return list;
          })
          .flatten()
          .toList();
    }

    assert(
      assets.map((e) => e.name).distinct().length == assets.length,
      'There are duplicate names in the asset list.',
    );

    return assets;
  }
}
