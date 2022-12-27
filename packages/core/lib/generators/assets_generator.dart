import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';

import '../settings/asset_type.dart';
import '../settings/config.dart';
import '../settings/pubspec.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';
import 'integrations/flare_integration.dart';
import 'integrations/integration.dart';
import 'integrations/lottie_integration.dart';
import 'integrations/rive_integration.dart';
import 'integrations/svg_integration.dart';

class AssetsGenConfig {
  AssetsGenConfig._(
    this.rootPath,
    this._packageName,
    this.flutterGen,
    this.assets,
    this.exclude,
  );

  factory AssetsGenConfig.fromConfig(File pubspecFile, Config config) {
    return AssetsGenConfig._(
      pubspecFile.parent.absolute.path,
      config.pubspec.packageName,
      config.pubspec.flutterGen,
      config.pubspec.flutter.assets,
      config.pubspec.flutterGen.assets.exclude
          .map((pattern) => Glob(pattern))
          .toList(),
    );
  }

  final String rootPath;
  final String _packageName;
  final FlutterGen flutterGen;
  final List<String> assets;
  final List<Glob> exclude;

  String get packageParameterLiteral =>
      flutterGen.assets.outputs.packageParameterEnabled ? _packageName : '';
}

String generateAssets(
  AssetsGenConfig config,
  DartFormatter formatter,
) {
  if (config.assets.isEmpty) {
    throw const InvalidSettingsException(
        'The value of "flutter/assets:" is incorrect.');
  }

  final importsBuffer = StringBuffer();
  final classesBuffer = StringBuffer();

  final integrations = <Integration>[
    if (config.flutterGen.integrations.flutterSvg)
      SvgIntegration(config.packageParameterLiteral),
    if (config.flutterGen.integrations.flareFlutter)
      FlareIntegration(config.packageParameterLiteral),
    if (config.flutterGen.integrations.rive)
      RiveIntegration(config.packageParameterLiteral),
    if (config.flutterGen.integrations.lottie)
      LottieIntegration(config.packageParameterLiteral),
  ];

  // TODO: This code will be removed.
  // ignore: deprecated_member_use_from_same_package
  final deprecatedStyle = config.flutterGen.assets.style != null;
  final deprecatedPackageParam =
      // ignore: deprecated_member_use_from_same_package
      config.flutterGen.assets.packageParameterEnabled != null;
  if (deprecatedStyle || deprecatedPackageParam) {
    stderr.writeln('''
                                                                                        
                ░░░░                                                                    
                                                                                        
                                            ██                                          
                                          ██░░██                                        
  ░░          ░░                        ██░░░░░░██                            ░░░░      
                                      ██░░░░░░░░░░██                                    
                                      ██░░░░░░░░░░██                                    
                                    ██░░░░░░░░░░░░░░██                                  
                                  ██░░░░░░██████░░░░░░██                                
                                  ██░░░░░░██████░░░░░░██                                
                                ██░░░░░░░░██████░░░░░░░░██                              
                                ██░░░░░░░░██████░░░░░░░░██                              
                              ██░░░░░░░░░░██████░░░░░░░░░░██                            
                            ██░░░░░░░░░░░░██████░░░░░░░░░░░░██                          
                            ██░░░░░░░░░░░░██████░░░░░░░░░░░░██                          
                          ██░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░██                        
                          ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██                        
                        ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██                      
                        ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██                      
                      ██░░░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░░░██                    
        ░░            ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██                    
                        ██████████████████████████████████████████                      
                                                                                        
                                                                                        
                  ░░''');
  }
  if (deprecatedStyle && deprecatedPackageParam) {
    stderr.writeln('''
    ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                                                     │
    │   The `style` and `package_parameter_enabled` property moved from asset to under asset.output. │
    │   It should be changed in the following pubspec.yaml.                                          │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                                           │
    │                                                                                                │
    │ [pubspec.yaml]                                                                                 │
    │                                                                                                │
    │  fluttergen:                                                                                   │
    │    assets:                                                                                     │
    │      outputs:                                                                                  │
    │        style: snake-case                                                                       │
    │        package_parameter_enabled: true                                                         │
    └────────────────────────────────────────────────────────────────────────────────────────────────┘''');
  } else if (deprecatedStyle) {
    stderr.writeln('''
    ┌───────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                            │
    │   The `style` property moved from asset to under asset.output.        │
    │   It should be changed in the following ways                          │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                  │
    │                                                                       │
    │ [pubspec.yaml]                                                        │
    │                                                                       │
    │  fluttergen:                                                          │
    │    assets:                                                            │
    │      outputs:                                                         │
    │        style: snake-case                                              │
    └───────────────────────────────────────────────────────────────────────┘''');
  } else if (deprecatedPackageParam) {
    stderr.writeln('''
    ┌────────────────────────────────────────────────────────────────────────────────────────┐
    │ ⚠️  Warning                                                                             │
    │   The `package_parameter_enabled` property moved from asset to under asset.output.     │
    │   It should be changed in the following pubspec.yaml.                                  │
    │   https://github.com/FlutterGen/flutter_gen/pull/294                                   │
    │                                                                                        │
    │ [pubspec.yaml]                                                                         │
    │                                                                                        │
    │  fluttergen:                                                                           │
    │    assets:                                                                             │
    │      outputs:                                                                          │
    │        package_parameter_enabled: true                                                 │
    └────────────────────────────────────────────────────────────────────────────────────────┘''');
  }

  if (config.flutterGen.assets.outputs.isDotDelimiterStyle) {
    classesBuffer.writeln(_dotDelimiterStyleDefinition(config, integrations));
  } else if (config.flutterGen.assets.outputs.isSnakeCaseStyle) {
    classesBuffer.writeln(_snakeCaseStyleDefinition(config, integrations));
  } else if (config.flutterGen.assets.outputs.isCamelCaseStyle) {
    classesBuffer.writeln(_camelCaseStyleDefinition(config, integrations));
  } else {
    throw 'The value of "flutter_gen/assets/style." is incorrect.';
  }

  classesBuffer.writeln(_assetGenImageClassDefinition(
    config.packageParameterLiteral,
  ));

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
  buffer.writeln(ignore);
  buffer.writeln(importsBuffer.toString());
  buffer.writeln(classesBuffer.toString());
  return formatter.format(buffer.toString());
}

List<String> _getAssetRelativePathList(
  String rootPath,
  List<String> assets,
  List<Glob> excludes,
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
    }
  }

  if (excludes.isEmpty) {
    return assetRelativePathList;
  }

  return assetRelativePathList
      .where((file) => !excludes.any((exclude) => exclude.matches(file)))
      .toList();
}

AssetType _constructAssetTree(
    List<String> assetRelativePathList, String rootPath) {
  // Relative path is the key
  final assetTypeMap = <String, AssetType>{
    '.': AssetType(rootPath: rootPath, path: '.'),
  };
  for (final assetPath in assetRelativePathList) {
    var path = assetPath;
    while (path != '.') {
      assetTypeMap.putIfAbsent(
          path, () => AssetType(rootPath: rootPath, path: path));
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
  AssetType assetType,
  List<Integration> integrations,
  String name,
) {
  final childAssetAbsolutePath = join(rootPath, assetType.path);
  if (assetType.isSupportedImage) {
    return _Statement(
      type: 'AssetGenImage',
      filePath: assetType.path,
      name: name,
      value: 'AssetGenImage(\'${posixStyle(assetType.path)}\')',
      isConstConstructor: true,
      isDirectory: false,
      needDartDoc: true,
    );
  } else if (FileSystemEntity.isDirectorySync(childAssetAbsolutePath)) {
    final childClassName = '\$${assetType.path.camelCase().capitalize()}Gen';
    return _Statement(
      type: childClassName,
      filePath: assetType.path,
      name: name,
      value: '$childClassName()',
      isConstConstructor: true,
      isDirectory: true,
      needDartDoc: false,
    );
  } else if (!assetType.isIgnoreFile) {
    final integration = integrations.firstWhereOrNull(
      (element) => element.isSupport(assetType),
    );
    if (integration == null) {
      return _Statement(
        type: 'String',
        filePath: assetType.path,
        name: name,
        value: '\'${posixStyle(assetType.path)}\'',
        isConstConstructor: false,
        isDirectory: false,
        needDartDoc: true,
      );
    } else {
      integration.isEnabled = true;
      return _Statement(
        type: integration.className,
        filePath: assetType.path,
        name: name,
        value: integration.classInstantiate(posixStyle(assetType.path)),
        isConstConstructor: integration.isConstConstructor,
        isDirectory: false,
        needDartDoc: true,
      );
    }
  }
  return null;
}

/// Generate style like Assets.foo.bar
String _dotDelimiterStyleDefinition(
  AssetsGenConfig config,
  List<Integration> integrations,
) {
  final buffer = StringBuffer();
  final className = config.flutterGen.assets.outputs.className;
  final assetRelativePathList = _getAssetRelativePathList(
    config.rootPath,
    config.assets,
    config.exclude,
  );
  final assetsStaticStatements = <_Statement>[];

  final assetTypeQueue = ListQueue<AssetType>.from(
      _constructAssetTree(assetRelativePathList, config.rootPath).children);

  while (assetTypeQueue.isNotEmpty) {
    final assetType = assetTypeQueue.removeFirst();
    final assetAbsolutePath = join(config.rootPath, assetType.path);

    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      final statements = assetType.children
          .mapToIsUniqueWithoutExtension()
          .map(
            (e) => _createAssetTypeStatement(
              config.rootPath,
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
      } else {
        final className = '\$${assetType.path.camelCase().capitalize()}Gen';
        buffer.writeln(_directoryClassGenDefinition(className, statements));
        // Add this directory reference to Assets class
        // if we are not under the default asset folder
        if (dirname(assetType.path) == '.') {
          assetsStaticStatements.add(_Statement(
            type: className,
            filePath: assetType.path,
            name: assetType.baseName.camelCase(),
            value: '$className()',
            isConstConstructor: true,
            isDirectory: true,
            needDartDoc: true,
          ));
        }
      }

      assetTypeQueue.addAll(assetType.children);
    }
  }
  buffer.writeln(_dotDelimiterStyleAssetsClassDefinition(
      className, assetsStaticStatements));
  return buffer.toString();
}

/// Generate style like Assets.fooBar
String _camelCaseStyleDefinition(
  AssetsGenConfig config,
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    config,
    integrations,
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
  List<Integration> integrations,
) {
  return _flatStyleDefinition(
    config,
    integrations,
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
  String Function(AssetTypeIsUniqueWithoutExtension) createName,
) {
  final statements = _getAssetRelativePathList(
    config.rootPath,
    config.assets,
    config.exclude,
  )
      .distinct()
      .sorted()
      .map((assetPath) => AssetType(rootPath: config.rootPath, path: assetPath))
      .mapToIsUniqueWithoutExtension()
      .map(
        (e) => _createAssetTypeStatement(
          config.rootPath,
          e.assetType,
          integrations,
          createName(e),
        ),
      )
      .whereType<_Statement>()
      .toList();
  final className = config.flutterGen.assets.outputs.className;
  return _flatStyleAssetsClassDefinition(className, statements);
}

String _flatStyleAssetsClassDefinition(
  String className,
  List<_Statement> statements,
) {
  final statementsBlock =
      statements.map((statement) => '''${statement.toDartDocString()}
           ${statement.toStaticFieldString()}
           ''').join('\n');
  return _assetsClassDefinition(className, statements, statementsBlock);
}

String _dotDelimiterStyleAssetsClassDefinition(
  String className,
  List<_Statement> statements,
) {
  final statementsBlock =
      statements.map((statement) => statement.toStaticFieldString()).join('\n');
  return _assetsClassDefinition(className, statements, statementsBlock);
}

String _assetValuesDefinition(List<_Statement> statements) {
  final values = statements.where((element) => !element.isDirectory);
  if (values.isEmpty) return '';
  final names = values
      .where((element) => element.valid)
      .map((value) => value.name)
      .join(', ');
  var type = values.first.type;
  for (var value in values) {
    if (type != value.type) {
      type = 'dynamic';
      break;
    }
  }

  return '''
  /// List of all assets
  List<$type> get values => [$names];''';
}

String _assetsClassDefinition(
  String className,
  List<_Statement> statements,
  String statementsBlock,
) {
  final valuesBlock = _assetValuesDefinition(statements);
  return '''
class $className {
  $className._();
  
  $statementsBlock
  $valuesBlock
}
''';
}

String _directoryClassGenDefinition(
  String className,
  List<_Statement> statements,
) {
  final statementsBlock = statements
      .map((statement) => statement.needDartDoc
          ? '''${statement.toDartDocString()}
          ${statement.toGetterString()}
          '''
          : statement.toGetterString())
      .join('\n');
  final valuesBlock = _assetValuesDefinition(statements);

  return '''
class $className {
  const $className();
  
  $statementsBlock
  $valuesBlock
}
''';
}

String _assetGenImageClassDefinition(String packageName) {
  final packageParameter = packageName.isNotEmpty ? " = '$packageName'" : '';

  final keyName = packageName.isEmpty
      ? '_assetName'
      : "'packages/$packageName/\$_assetName'";

  return '''

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package$packageParameter,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => $keyName;
}
''';
}

class _Statement {
  const _Statement({
    required this.type,
    required this.filePath,
    required this.name,
    required this.value,
    required this.isConstConstructor,
    required this.isDirectory,
    required this.needDartDoc,
  });

  final String type;
  final String filePath;
  final String name;
  final String value;
  final bool isConstConstructor;
  final bool isDirectory;
  final bool needDartDoc;

  String toDartDocString() => '/// File path: ${posixStyle(filePath)}';

  String toGetterString() =>
      '${valid ? '' : '/*'}$type get $name => ${isConstConstructor ? 'const' : ''} $value;${valid ? '' : '*/'}';

  String toStaticFieldString() =>
      '${valid ? '' : '/*'}static const $type $name = $value; ${valid ? '' : '*/'}';

  bool get valid =>
      !type.startsWith(RegExp('[0-9]')) &&
      !name.startsWith(RegExp('[0-9]')) &&
      !keywords.contains(type) &&
      !keywords.contains(name);
}

const keywords = [
  'abstract',
  'else',
  'import',
  'show',
  'as',
  'enum',
  'in',
  'static',
  'assert',
  'export',
  'interface',
  'super',
  'async',
  'extends',
  'is',
  'switch',
  'await',
  'extension',
  'late',
  'sync',
  'break',
  'external',
  'library',
  'this',
  'case',
  'factory',
  'mixin',
  'throw',
  'catch',
  'false',
  'new',
  'true',
  'class',
  'final',
  'null',
  'try',
  'const',
  'finally',
  'on',
  'typedef',
  'continue',
  'for',
  'operator',
  'var',
  'covariant',
  'Function',
  'part',
  'void',
  'default',
  'get',
  'required',
  'while',
  'deferred',
  'hide',
  'rethrow',
  'with',
  'do',
  'if',
  'return',
  'yield',
  'dynamic',
  'implements',
  'set'
];
