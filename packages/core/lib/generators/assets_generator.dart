import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';

import '../settings/asset_type.dart';
import '../settings/config.dart';
import '../settings/pubspec.dart';
import '../utils/dart_style/dart_style.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';
import 'integrations/flare_integration.dart';
import 'integrations/integration.dart';
import 'integrations/svg_integration.dart';

class AssetsGenConfig {
  AssetsGenConfig._(
    this.rootPath,
    this._packageName,
    this.flutterGen,
    this.assets,
  );

  factory AssetsGenConfig.fromConfig(File pubspecFile, Config config) {
    return AssetsGenConfig._(
      pubspecFile.parent.path,
      config.pubspec.packageName,
      config.pubspec.flutterGen,
      config.pubspec.flutter.assets,
    );
  }

  final String rootPath;
  final String _packageName;
  final FlutterGen flutterGen;
  final List<String> assets;

  String get packageParameterLiteral =>
      flutterGen.assets.packageParameterEnabled ? _packageName : '';
}

String generateAssets(
  AssetsGenConfig config,
  DartFormatter formatter,
  FlutterGen flutterGen,
  String name,
  String packageName,
) {
  if (config.assets.isEmpty) {
    throw InvalidSettingsException(
        'The value of "flutter/assets:" is incorrect.');
  }

  final importsBuffer = StringBuffer();
  final classesBuffer = StringBuffer();

  final integrations = <Integration>[
    // TODO: Until null safety generalizes
    if (config.flutterGen.integrations.flutterSvg)
      SvgIntegration(config.packageParameterLiteral,
          nullSafety: config.flutterGen.nullSafety),
    if (config.flutterGen.integrations.flareFlutter)
      FlareIntegration(nullSafety: config.flutterGen.nullSafety),
  ];

  if (config.flutterGen.assets.isDotDelimiterStyle) {
    classesBuffer.writeln(
        _dotDelimiterStyleDefinition(config, name, packageName, integrations));
  } else if (config.flutterGen.assets.isSnakeCaseStyle) {
    classesBuffer.writeln(
        _snakeCaseStyleDefinition(config, name, packageName, integrations));
  } else if (config.flutterGen.assets.isCamelCaseStyle) {
    classesBuffer.writeln(
        _camelCaseStyleDefinition(config, name, packageName, integrations));
  } else {
    throw 'The value of "flutter_gen/assets/style." is incorrect.';
  }

  // TODO: Until null safety generalizes
  if (config.flutterGen.nullSafety) {
    classesBuffer.writeln(_assetGenImageClassDefinition(
      config.packageParameterLiteral,
    ));
  } else {
    classesBuffer.writeln(_assetGenImageClassDefinitionWithNoNullSafety(
      config.packageParameterLiteral,
    ));
  }

  final imports = <String>{'package:flutter/widgets.dart'};
  integrations
      .where((integration) => integration.isEnabled)
      .forEach((integration) {
    imports.addAll(integration.requiredImports);
    classesBuffer.writeln(integration.classOutput);
  });
  for (final package in imports) {
    importsBuffer.writeln(import(package));
  }

  final buffer = StringBuffer();

  // TODO: Until null safety generalizes
  if (config.flutterGen.nullSafety) {
    buffer.writeln(header);
  } else {
    buffer.writeln(headerWithNoNullSafety);
  }
  buffer.writeln(importsBuffer.toString());
  buffer.writeln(classesBuffer.toString());
  return formatter.format(buffer.toString());
}

List<String> _getAssetRelativePathList(
  String rootPath,
  List<String> assets,
  String name,
) {
  final assetRelativePathList = <String>[];
  for (final assetName in assets) {
    final assetAbsolutePath = join(rootPath, assetName);
    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      assetRelativePathList.addAll(Directory(assetAbsolutePath)
          .listSync()
          .whereType<File>()
          .map((e) => relative(e.path, from: rootPath))
          .toList());
    } else if (FileSystemEntity.isFileSync(assetAbsolutePath)) {
      assetRelativePathList.add(relative(assetAbsolutePath, from: rootPath));
    } else if (assetName.startsWith('packages/$name')) {
      assetRelativePathList
          .add(assetName.replaceFirst('packages/$name', 'lib'));
    }
  }
  return assetRelativePathList;
}

AssetType _constructAssetTree(List<String> assetRelativePathList, String name) {
  // Relative path is the key
  final assetTypeMap = <String, AssetType>{
    '.': AssetType('.'),
  };
  for (final assetPath in assetRelativePathList) {
    var path = assetPath;
    while (path != '.') {
      assetTypeMap.putIfAbsent(path, () => AssetType(path));
      path = dirname(path);
    }
  }
  // Construct the AssetType tree
  for (final assetType in assetTypeMap.values) {
    if (assetType.path == '.') {
      continue;
    }
    final parentPath = dirname(assetType.path);
    assetTypeMap[parentPath]?.addChild(assetType);
  }
  return assetTypeMap['.']!;
}

_Statement? _createAssetTypeStatement(
  String rootPath,
  String packagesName,
  AssetType assetType,
  List<Integration> integrations,
  String name,
) {
  final childAssetAbsolutePath = join(rootPath, assetType.path);
  final path = assetType.path.startsWith('lib')
      ? assetType.path.replaceFirst('lib', 'packages/$packagesName')
      : assetType.path;
  if (assetType.isSupportedImage) {
    return _Statement(
      type: 'AssetGenImage',
      name: name,
      value: 'AssetGenImage\(\'${posixStyle(path)}\'\)',
      isConstConstructor: true,
    );
  } else if (FileSystemEntity.isDirectorySync(childAssetAbsolutePath)) {
    final childClassName = '\$${assetType.path.camelCase().capitalize()}Gen';
    return _Statement(
      type: childClassName,
      name: name,
      value: '$childClassName\(\)',
      isConstConstructor: true,
    );
  } else if (!assetType.isIgnoreFile) {
    final integration = integrations.firstWhereOrNull(
      (element) => element.isSupport(assetType),
    );
    if (integration == null) {
      return _Statement(
        type: 'String',
        name: name,
        value: '\'${posixStyle(path)}\'',
        isConstConstructor: false,
      );
    } else {
      integration.isEnabled = true;
      return _Statement(
        type: integration.className,
        name: name,
        value: integration.classInstantiate(posixStyle(path)),
        isConstConstructor: integration.isConstConstructor,
      );
    }
  }
}

/// Generate style like Assets.foo.bar
String _dotDelimiterStyleDefinition(
  AssetsGenConfig config,
  String name,
  String packageName,
  List<Integration> integrations,
) {
  final buffer = StringBuffer();
  final assetRelativePathList =
      _getAssetRelativePathList(config.rootPath, config.assets, name);
  final assetsStaticStatements = <_Statement>[];

  final assetTypeQueue = ListQueue<AssetType>.from(
      _constructAssetTree(assetRelativePathList, name).children);

  while (assetTypeQueue.isNotEmpty) {
    var assetType = assetTypeQueue.removeFirst();
    final assetAbsolutePath = join(config.rootPath, assetType.path);

    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      final statements = assetType.children
          .mapToIsUniqueWithoutExtension()
          .map(
            (e) => _createAssetTypeStatement(
              config.rootPath,
              name,
              e.assetType,
              integrations,
              (e.isUniqueWithoutExtension
                      ? basenameWithoutExtension(e.assetType.path)
                      : basename(e.assetType.path))
                  .camelCase(),
            ),
          )
          .whereType<_Statement>()
          .toList();

      if (assetType.isDefaultAssetsDirectory) {
        assetsStaticStatements.addAll(statements);
      } else if (assetType.path == 'lib') {
        buffer.writeln(_assetsClassDefinition(statements, packageName));
      } else {
        final className = '\$${assetType.path.camelCase().capitalize()}Gen';
        buffer.writeln(_directoryClassGenDefinition(className, statements));
        // Add this directory reference to Assets class
        // if we are not under the default asset folder
        if (dirname(assetType.path) == '.') {
          assetsStaticStatements.add(_Statement(
            type: className,
            name: assetType.baseName.camelCase(),
            value: '$className\(\)',
            isConstConstructor: true,
          ));
        }
      }

      assetTypeQueue.addAll(assetType.children);
    }
  }
  buffer.writeln(_assetsClassDefinition(assetsStaticStatements));
  return buffer.toString();
}

/// Generate style like Assets.fooBar
String _camelCaseStyleDefinition(
  AssetsGenConfig config,
  String name,
  String packageName,
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    config,
    integrations,
    name,
    packageName,
    (e) => (e.isUniqueWithoutExtension
            ? withoutExtension(e.assetType.path)
            : e.assetType.path)
        .replaceFirst(RegExp(r'asset(s)?'), '')
        .camelCase(),
  );
}

/// Generate style like Assets.foo_bar
String _snakeCaseStyleDefinition(
  AssetsGenConfig config,
  String name,
  String packageName,
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    config,
    integrations,
    name,
    packageName,
    (e) => (e.isUniqueWithoutExtension
            ? withoutExtension(e.assetType.path)
            : e.assetType.path)
        .replaceFirst(RegExp(r'asset(s)?'), '')
        .snakeCase(),
  );
}

String _flatStyleDefinition(
  AssetsGenConfig config,
  List<Integration> integrations,
  String name,
  String packageName,
  String Function(AssetTypeIsUniqueWithoutExtension) createName,
) {
  final buffer = StringBuffer();
  final assetRelativePathList =
      _getAssetRelativePathList(config.rootPath, config.assets, name);
  buffer.writeln(_assetsClassDefinition(
      _createStatement(
        config,
        assetRelativePathList
            .where((path) => path.startsWith('lib/'))
            .toList(growable: false),
        integrations,
        name,
        (assetType) => withoutExtension(assetType.path.replaceFirst('lib/', ''))
            .replaceFirst(RegExp(r'asset(s)?'), '')
            .snakeCase(),
      ),
      packageName));
  buffer.writeln(_assetsClassDefinition(_createStatement(
    config,
    assetRelativePathList
        .where((path) => !path.startsWith('lib/'))
        .toList(growable: false),
    integrations,
    name,
    (assetType) => withoutExtension(assetType.path)
        .replaceFirst(RegExp(r'asset(s)?'), '')
        .snakeCase(),
  )));
  return buffer.toString();
}

List<_Statement> _createStatement(
  AssetsGenConfig config,
  List<String> assetRelativePathList,
  List<Integration> integrations,
  String name,
  String Function(AssetType) createName,
) =>
    assetRelativePathList
        .distinct()
        .sorted()
        .map((relativePath) => AssetType(relativePath))
        .mapToIsUniqueWithoutExtension()
        .map(
          (e) => _createAssetTypeStatement(
            config.rootPath,
            name,
            e.assetType,
            integrations,
            createName(e.assetType),
          ),
        )
        .whereType<_Statement>()
        .toList();

String _assetsClassDefinition(List<_Statement> statements,
    [String name = "Assets"]) {
  final statementsBlock = statements
      .map((statement) => '  ${statement.toStaticFieldString()}')
      .join('\n');
  return '''
class $name {
  $name._();
  
  $statementsBlock
}
''';
}

String _directoryClassGenDefinition(
  String className,
  List<_Statement> statements,
) {
  final statementsBlock = statements
      .map((statement) => '  ${statement.toGetterString()}')
      .join('\n');
  return '''
class $className {
  const $className();
  
  $statementsBlock
}
''';
}

/// Null Safety
String _assetGenImageClassDefinition(String packageName) {
  final optionalParameter =
      packageName.isNotEmpty ? ', package: \'$packageName\'' : '';
  return '''

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName$optionalParameter);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}
''';
}

/// No Null Safety
/// TODO: Until null safety generalizes
String _assetGenImageClassDefinitionWithNoNullSafety(String packageName) {
  final optionalParameter =
      packageName.isNotEmpty ? ', package: \'$packageName\'' : '';
  return '''
class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName$optionalParameter);

  Image image({
    Key key,
    ImageFrameBuilder frameBuilder,
    ImageLoadingBuilder loadingBuilder,
    ImageErrorWidgetBuilder errorBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}
''';
}

class _Statement {
  const _Statement({
    required this.type,
    required this.name,
    required this.value,
    required this.isConstConstructor,
  });

  final String type;
  final String name;
  final String value;
  final bool isConstConstructor;

  String toGetterString() =>
      '$type get $name => ${isConstConstructor ? 'const' : ''} $value;';

  String toStaticFieldString() => 'static const $type $name = $value;';
}
