import 'dart:collection';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import '../settings/asset_type.dart';
import '../settings/flutter.dart';
import '../settings/flutter_gen.dart';
import '../utils/camel_case.dart';
import 'generator_helper.dart';
import 'integrations/integration.dart';
import 'integrations/svg_integration.dart';

String generateAssets(File pubspecFile, DartFormatter formatter,
    FlutterGen flutterGen, FlutterAssets assets) {
  assert(assets != null && assets.hasAssets,
      throw 'The value of "flutter/assets:" is incorrect.');

  final importsBuffer = StringBuffer();
  final classesBuffer = StringBuffer();

  final assetRelativePathList = _getAssetRelativePathList(pubspecFile, assets);
  final assetTypeQueue = ListQueue<AssetType>.from(
      _constructAssetTree(assetRelativePathList).children);
  final assetsStaticStatements = <_Statement>[];

  final integrations = <Integration>[];
  if (flutterGen != null &&
      flutterGen.hasIntegrations &&
      flutterGen.integrations.hasFlutterSvg) {
    integrations.add(SvgIntegration());
  }

  while (assetTypeQueue.isNotEmpty) {
    final assetType = assetTypeQueue.removeFirst();
    final assetAbsolutePath = join(pubspecFile.parent.path, assetType.path);

    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      final statements = _createDirectoryClassGenStatements(
          pubspecFile, assetType, integrations);

      if (assetType.isDefaultAssetsDirectory) {
        assetsStaticStatements.addAll(statements);
      } else {
        final className = '\$${assetType.path.camelCase().capitalize()}Gen';
        classesBuffer
            .writeln(_directoryClassGenDefinition(className, statements));
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

  classesBuffer.writeln(_assetsClassDefinition(assetsStaticStatements));
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
  File pubspecFile,
  FlutterAssets assets,
) {
  final assetRelativePathList = <String>[];
  for (final assetName in assets.assets) {
    final assetAbsolutePath = join(pubspecFile.parent.path, assetName);
    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      assetRelativePathList.addAll(Directory(assetAbsolutePath)
          .listSync()
          .whereType<File>()
          .map((e) => relative(e.path, from: pubspecFile.parent.path))
          .toList());
    } else if (FileSystemEntity.isFileSync(assetAbsolutePath)) {
      assetRelativePathList
          .add(relative(assetAbsolutePath, from: pubspecFile.parent.path));
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

List<_Statement> _createDirectoryClassGenStatements(
    File pubspecFile, AssetType assetType, List<Integration> integrations) {
  final statements = assetType.children
      .map((child) {
        final childAssetAbsolutePath =
            join(pubspecFile.parent.path, child.path);
        _Statement statement;
        if (child.isSupportedImage) {
          statement = _Statement(
            type: 'AssetGenImage',
            name: child.baseName.camelCase(),
            value: 'AssetGenImage\(\'${posixStyle(child.path)}\'\)',
            isConstConstructor: true,
          );
        } else if (FileSystemEntity.isDirectorySync(childAssetAbsolutePath)) {
          final childClassName = '\$${child.path.camelCase().capitalize()}Gen';
          statement = _Statement(
            type: childClassName,
            name: child.baseName.camelCase(),
            value: '$childClassName\(\)',
            isConstConstructor: true,
          );
        } else if (!child.isUnKnownMime) {
          final integration = integrations.firstWhere(
            (element) => element.mime == child.mime,
            orElse: () => null,
          );
          if (integration == null) {
            statement ??= _Statement(
              type: 'String',
              name: child.baseName.camelCase(),
              value: '\'${posixStyle(child.path)}\'',
              isConstConstructor: false,
            );
          } else {
            integration.isEnabled = true;
            statement = _Statement(
              type: integration.className,
              name: child.baseName.camelCase(),
              value: integration.classInstantiate(posixStyle(child.path)),
              isConstConstructor: integration.isConstConstructor,
            );
          }
        }
        return statement;
      })
      .whereType<_Statement>()
      .toList();
  return statements;
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
