import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/utils/identifer.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:mime/mime.dart' show lookupMimeType;
import 'package:path/path.dart' as p;

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class ShaderType {
  ShaderType({
    required this.rootPath,
    required this.path,
    required this.flavors,
  });

  final String rootPath;
  final String path;
  final Set<String> flavors;

  final List<ShaderType> _children = List.empty(growable: true);

  bool get isDefaultShadersDirectory => path == 'shaders' || path == 'shader';

  String? get mime => lookupMimeType(path);

  bool get isIgnoreFile {
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
  }

  bool get isUnKnownMime => mime == null;

  /// Returns a name for this shader.
  String get name => p.withoutExtension(path);

  String get baseName => p.basenameWithoutExtension(path);

  String get extension => p.extension(path);

  /// Returns the full absolute path for reading the shader file.
  String get fullPath => p.join(rootPath, path);

  // Replace to Posix style for Windows separator.
  String get posixStylePath => path.replaceAll(r'\', r'/');

  List<ShaderType> get children => _children.sortedBy((e) => e.path);

  void addChild(ShaderType type) {
    _children.add(type);
  }

  @override
  String toString() => 'ShaderType('
      'rootPath: $rootPath, '
      'path: $path, '
      'flavors: $flavors'
      ')';
}

/// Represents a ShaderType with modifiers on it to mutate the [name] to ensure
/// it is unique in a larger list and a valid dart identifer.
///
/// See [ShaderTypeIterable.mapToUniqueShaderType] for the algorithm.
class UniqueShaderType extends ShaderType {
  UniqueShaderType({
    required ShaderType shaderType,
    this.style = camelCase,
    this.basenameOnly = false,
    this.needExtension = false,
    this.suffix = '',
  }) : super(
          rootPath: shaderType.rootPath,
          path: shaderType.path,
          flavors: shaderType.flavors,
        );

  /// Convert the shader name to a correctly styled name, e.g camelCase or
  /// snakeCase.
  final String Function(String) style;

  /// Include just the basename of the shader in the [name],
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
    // Omit root directory from the name if it is either shader or shaders.
    // TODO(bramp): Maybe move this into the _flatStyleDefinition
    String result = path.replaceFirst(RegExp(r'^shader(s)?[/\\]'), '');
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
    return 'UniqueShaderType{'
        'rootPath: $rootPath, '
        'path: $path, '
        'style: $style, '
        'needExtension: $needExtension, '
        'suffix: $suffix}';
  }
}

extension ShaderTypeIterable on Iterable<ShaderType> {
  /// Takes a Iterable<ShaderType> and mutates the ShaderType's to ensure each
  /// ShaderType has a unique name.
  ///
  /// The strategy is as follows:
  ///
  /// 1) Convert the shader file name, to a valid dart identifier, that is
  ///  - Replace non ASCII chars with ASCII.
  ///  - Ensure the name starts with a letter (not number or _).
  ///  - Style the name per the camelCase or snakeCase rules.
  /// 2) Use the shader name without extension. If unique and not a dart reserved
  ///    word use that.
  /// 3) Use the shader name with extension. If unique and not a dart reserved
  ///    word use that.
  /// 4) If there are any collisions, append a underscore suffix to each item
  ///    until they are unique.
  ///
  /// Because the name change can cause it to clash with an existing name, the
  /// code is run iteratively until no collision are found. This can be a little
  /// more expensive, but it simplier.
  ///
  Iterable<UniqueShaderType> mapToUniqueShaderType(
    String Function(String) style, {
    bool justBasename = false,
  }) {
    List<UniqueShaderType> shaders = map((e) => UniqueShaderType(
          shaderType: e,
          style: style,
          needExtension: false,
          suffix: '',
          basenameOnly: justBasename,
        )).toList();

    while (true) {
      // Check if we have any name collisions.
      final dups = shaders.groupBy((e) => e.name).values;

      // No more duplicates, so we can bail.
      if (dups.every((list) => list.length == 1)) break;

      // Otherwise start to process the list and mutate the shaders as needed.
      shaders = dups
          .map((list) {
            assert(list.isNotEmpty,
                'The groupBy list of shaders should not be empty.');

            // Check the first element in the list. Since we grouped by each
            // list element should have the same name.
            final name = list[0].name;
            final isValidIdentifer = isValidVariableIdentifier(name);

            // TODO(bramp): In future we should also check this name doesn't collide
            // with the integration's class name (e.g ShaderGenImage).

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
            list.forEachIndexed((shader, index) {
              // Shouldn't need to mutate the first item (unless it's an invalid
              // identifer).
              if (index == 0 && isValidIdentifer) return;

              // Append a extra suffixes to each item so they hopefully become unique
              suffix = '${suffix}_';
              shader.suffix += suffix;
            });

            return list;
          })
          .flatten()
          .toList();
    }

    assert(shaders.map((e) => e.name).distinct().length == shaders.length,
        'There are duplicate names in the shader list.');

    return shaders;
  }
}
