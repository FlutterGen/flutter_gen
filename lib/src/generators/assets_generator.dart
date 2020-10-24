import 'dart:collection';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';

import '../settings/asset_type.dart';
import '../settings/flutter.dart';
import '../settings/flutter_gen.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';
import 'integrations/integration.dart';

String generateAssets(
  String basePath,
  DartFormatter formatter,
  FlutterGen flutterGen,
  FlutterAssets assets,
) {
  if (assets == null || !assets.hasAssets) {
    throw InvalidSettingsException(
        'The value of "flutter/assets:" is incorrect.');
  }

  final importsBuffer = StringBuffer();
  final classesBuffer = StringBuffer();

  final integrations = flutterGen?.integrations?.integrations ?? [];

  if (flutterGen == null || flutterGen.assets.isDefaultStyle) {
    classesBuffer
        .writeln(_dotDelimiterStyleDefinition(basePath, assets, integrations));
  } else if (flutterGen.assets.isSnakeCaseStyle) {
    classesBuffer
        .writeln(_snakeCaseStyleDefinition(basePath, assets, integrations));
  } else if (flutterGen.assets.isCamelCaseStyle) {
    classesBuffer
        .writeln(_camelCaseStyleDefinition(basePath, assets, integrations));
  } else {
    throw 'The value of "flutter_gen/assets/style." is incorrect.';
  }

  classesBuffer.writeln(_assetGenImageClassDefinition);

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
  buffer.writeln(header);
  buffer.writeln(importsBuffer.toString());
  buffer.writeln(classesBuffer.toString());
  return formatter.format(buffer.toString());
}

List<String> _getAssetRelativePathList(
  String basePath,
  FlutterAssets assets,
) {
  final assetRelativePathList = <String>[];
  for (final assetName in assets.assets) {
    final assetAbsolutePath = join(basePath, assetName);
    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      assetRelativePathList.addAll(Directory(assetAbsolutePath)
          .listSync()
          .whereType<File>()
          .map((e) => relative(e.path, from: basePath))
          .toList());
    } else if (FileSystemEntity.isFileSync(assetAbsolutePath)) {
      assetRelativePathList.add(relative(assetAbsolutePath, from: basePath));
    }
  }
  return assetRelativePathList;
}

AssetType _constructAssetTree(List<String> assetRelativePathList) {
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
    assetTypeMap[parentPath].addChild(assetType);
  }
  return assetTypeMap['.'];
}

_Statement _createAssetTypeStatement(
  String basePath,
  AssetType assetType,
  List<Integration> integrations,
  String Function(AssetType) createName,
) {
  final childAssetAbsolutePath = join(basePath, assetType.path);
  _Statement statement;
  if (assetType.isSupportedImage) {
    statement = _Statement(
      type: 'AssetGenImage',
      name: createName(assetType),
      value: 'AssetGenImage\(\'${posixStyle(assetType.path)}\'\)',
      isConstConstructor: true,
    );
  } else if (FileSystemEntity.isDirectorySync(childAssetAbsolutePath)) {
    final childClassName = '\$${assetType.path.camelCase().capitalize()}Gen';
    statement = _Statement(
      type: childClassName,
      name: createName(assetType),
      value: '$childClassName\(\)',
      isConstConstructor: true,
    );
  } else if (!assetType.isUnKnownMime) {
    final integration = integrations.firstWhere(
      (element) => element.mime == assetType.mime,
      orElse: () => null,
    );
    if (integration == null) {
      statement = _Statement(
        type: 'String',
        name: createName(assetType),
        value: '\'${posixStyle(assetType.path)}\'',
        isConstConstructor: false,
      );
    } else {
      integration.isEnabled = true;
      statement = _Statement(
        type: integration.className,
        name: createName(assetType),
        value: integration.classInstantiate(posixStyle(assetType.path)),
        isConstConstructor: integration.isConstConstructor,
      );
    }
  }
  return statement;
}

/// Generate style like Assets.foo.bar
String _dotDelimiterStyleDefinition(
  String basePath,
  FlutterAssets assets,
  List<Integration> integrations,
) {
  final buffer = StringBuffer();
  final assetRelativePathList = _getAssetRelativePathList(basePath, assets);
  final assetsStaticStatements = <_Statement>[];

  final assetTypeQueue = ListQueue<AssetType>.from(
      _constructAssetTree(assetRelativePathList).children);

  while (assetTypeQueue.isNotEmpty) {
    final assetType = assetTypeQueue.removeFirst();
    final assetAbsolutePath = join(basePath, assetType.path);

    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      final statements = assetType.children
          .map(
            (child) => _createAssetTypeStatement(
              basePath,
              child,
              integrations,
              (element) => element.baseName.camelCase(),
            ),
          )
          .whereType<_Statement>()
          .toList();

      if (assetType.isDefaultAssetsDirectory) {
        assetsStaticStatements.addAll(statements);
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
  String basePath,
  FlutterAssets assets,
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    basePath,
    assets,
    integrations,
    (assetType) => withoutExtension(assetType.path)
        .replaceFirst(RegExp(r'asset(s)?'), '')
        .camelCase(),
  );
}

/// Generate style like Assets.foo_bar
String _snakeCaseStyleDefinition(
  String basePath,
  FlutterAssets assets,
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    basePath,
    assets,
    integrations,
    (assetType) => withoutExtension(assetType.path)
        .replaceFirst(RegExp(r'asset(s)?'), '')
        .snakeCase(),
  );
}

String _flatStyleDefinition(
  String basePath,
  FlutterAssets assets,
  List<Integration> integrations,
  String Function(AssetType) createName,
) {
  final statements = _getAssetRelativePathList(basePath, assets)
      .distinct()
      .sorted()
      .map(
        (relativePath) => _createAssetTypeStatement(
          basePath,
          AssetType(relativePath),
          integrations,
          createName,
        ),
      )
      .whereType<_Statement>()
      .toList();
  return _assetsClassDefinition(statements);
}

String _assetsClassDefinition(List<_Statement> statements) {
  final statementsBlock = statements
      .map((statement) => '  ${statement.toStaticFieldString()}')
      .join('\n');
  return '''
class Assets {
  Assets._();
  
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

const String _assetGenImageClassDefinition = '''

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName)
      : _assetName = assetName,
        super(assetName);
  final String _assetName;

  Image image({
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

  String get path => _assetName;
}
''';

class _Statement {
  const _Statement({
    this.type,
    this.name,
    this.value,
    this.isConstConstructor,
  });

  final String type;
  final String name;
  final String value;
  final bool isConstConstructor;

  String toGetterString() =>
      '$type get $name => ${isConstConstructor ? 'const' : ''} $value;';

  String toStaticFieldString() => 'static const $type $name = $value;';
}
